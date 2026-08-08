/*===========================================================================
 * canal_analysis.do
 * Cao & Chen (2022, AER) — Rebel on the Canal 完整复现代码（合并版）
 *
 * 由 data_setup.do + main_analysis.do 合并而成
 * 对应推文：「运河上的反叛：当京杭大运河停止流淌」
 *
 * ── 使用前必读 ──
 *
 * 数据获取（二选一）：
 *   git clone https://github.com/Zhihan-iris/literature-reading.git
 *   cd literature-reading/canal_data
 *   或直接下载：.../raw/main/canal_data/canal_rebellion.dta
 *
 * 外部命令安装（仅需一次）：
 *   ssc install reghdfe
 *   ssc install ftools
 *   ssc install estout
 *   ssc install ols_spatial_HAC
 *   ssc install synth_runner
 *   ssc install cic
 *   ssc install matmap
 *
 * 运行建议：
 *   - 整文件运行：先跑 PART A（数据准备），再按需选中各分析块依次运行
 *   - 每次只运行一个代码块（一张图或一个表），避免中间结果被覆盖
 *   - Table 3 整体约需 10-15 分钟（含 Conley SE）
 *   - Figure A2 涉及 120 次 ols_spatial_HAC 调用，耗时最长，可选择性运行
 *   - 经 graph export 导出的 PNG 文件保存在当前工作目录下
 *===========================================================================*/


/*###########################################################################
 * PART A: 数据准备（原 data_setup.do）
 * #########################################################################*/

/*---------------------------------------------------------------------------
 * A1. 环境设置
 *---------------------------------------------------------------------------*/

* --- 请将路径改为你本机的 canal_data 文件夹位置 ---
cd "你的路径/canal_data"

* --- 加载数据 ---
use "canal_rebellion.dta", clear

* --- 扩大矩阵容量，高维固定效应回归需要 ---
set matsize 11000

* --- 声明面板结构：个体 = OBJECTID（县），时间 = year（年）---
xtset OBJECTID year


/*---------------------------------------------------------------------------
 * A2. 被解释变量：反叛次数的标准化
 *---------------------------------------------------------------------------
 * 论文使用了多种标准化方式，最终基准设定为：
 *   asinh(onset_all / (cntypop1600 / 1000000))
 * 即：每百万人口（1600年基准）的反叛次数，再取反双曲正弦。
 *
 * asinh 的优点：x=0 时 asinh(0)=0，无需像 log(1+x) 那样加任意常数；
 * 值大时近似 log(2x)，值小时近似线性，不会过度压缩小值。
 *---------------------------------------------------------------------------*/

*** 按土地面积标准化
gen lonset_km2   = ln(1 + onset_all / (AREA / 10000))
gen ashonset_km2 = asinh(onset_all / (AREA / 10000))

*** 按逐年插值人口标准化
* 人口密度：在六个已知年份截面之间做分段线性插值
gen popden = popden1600 if year <= 1600
replace popden = popden1600 + (year - 1600) * ((popden1776 - popden1600) / (1776 - 1600)) ///
    if year > 1600 & year <= 1776
replace popden = popden1776 + (year - 1776) * ((popden1820 - popden1776) / (1820 - 1776)) ///
    if year > 1776 & year <= 1820
replace popden = popden1820 + (year - 1820) * ((popden1851 - popden1820) / (1851 - 1820)) ///
    if year > 1820 & year <= 1851
replace popden = popden1851 + (year - 1851) * ((popden1880 - popden1851) / (1880 - 1851)) ///
    if year > 1851 & year <= 1880
replace popden = popden1880 + (year - 1880) * ((popden1910 - popden1880) / (1910 - 1880)) ///
    if year > 1880 & year <= 1910
replace popden = popden1910 if year > 1910

* 县级总人口 = 人口密度 × 面积（平方公里）/ 1,000,000
gen pop     = popden     * AREA / 1000000
gen pop1600 = popden1600 * AREA / 1000000
gen pop1820 = popden1820 * AREA / 1000000

* 基于不同人口分母的反叛标准化（对数形式）
gen lonset_pop      = ln(1 + onset_all / pop)
gen lonset_pop1600  = ln(1 + onset_all / pop1600)
gen lonset_pop1820  = ln(1 + onset_all / pop1820)

* 基于不同人口分母的反叛标准化（asinh 形式）
gen ashonset_pop      = asinh(onset_all / pop)
gen ashonset_pop1600  = asinh(onset_all / pop1600)
gen ashonset_pop1820  = asinh(onset_all / pop1820)

*** 按插值县级人口（cntypop）标准化
* cntypop 与 popden 逻辑相同：六次截面之间线性插值
gen cntypop = cntypop1600 if year <= 1600
replace cntypop = cntypop1600 + (year - 1600) * ((cntypop1776 - cntypop1600) / (1776 - 1600)) ///
    if year > 1600 & year <= 1776
replace cntypop = cntypop1776 + (year - 1776) * ((cntypop1820 - cntypop1776) / (1820 - 1776)) ///
    if year > 1776 & year <= 1820
replace cntypop = cntypop1820 + (year - 1820) * ((cntypop1851 - cntypop1820) / (1851 - 1820)) ///
    if year > 1820 & year <= 1851
replace cntypop = cntypop1851 + (year - 1851) * ((cntypop1880 - cntypop1851) / (1880 - 1851)) ///
    if year > 1851 & year <= 1880
replace cntypop = cntypop1880 + (year - 1880) * ((cntypop1910 - cntypop1880) / (1910 - 1880)) ///
    if year > 1880 & year <= 1910
replace cntypop = cntypop1910 if year > 1910

gen ashonset_cntypop      = asinh(onset_all / (cntypop / 1000000))
gen ashonset_cntypop1600  = asinh(onset_all / (cntypop1600 / 1000000))
gen ashonset_cntypop1820  = asinh(onset_all / (cntypop1820 / 1000000))

* 辅助变量：1600年县人口密度（对数），用作控制变量
gen popdencnty1600    = cntypop1600 / AREA
gen lpopdencnty1600   = ln(popdencnty1600)


/*---------------------------------------------------------------------------
 * A3. 控制变量：全部以 "× reform" 交互项形式进入方程
 *---------------------------------------------------------------------------
 * 每个控制变量都乘以 reform（=1 表示 1826 年后），意味着该变量对反叛
 * 的影响被允许在改革前后不同。这样做的好处是：
 *   - 地形、气候等变量在改革前的效应被固定效应吸收
 *   - 交互项捕捉的是这些因素在改革后是否产生了额外影响
 *---------------------------------------------------------------------------*/

sort OBJECTID year

*** 事前反叛趋势（允许初始反叛水平不同的县有不同的时间趋势）
by OBJECTID: egen prerebels = total((onset_all / (cntypop / 1000000)) * (reform == 0))
gen ashprerebels = asinh(prerebels)

*** 地理 × reform
gen rug_after    = ruggedness    * reform   // 地形崎岖度 × 改革后
gen huang_after  = alonghuang    * reform   // 黄河沿线 × 改革后
gen yangtze_after = alongyangtze * reform   // 长江沿线 × 改革后

*** 气候 × reform
egen reconmean   = mean(recon)
egen reconsd     = sd(recon)
gen disaster     = (abs(recon - reconmean) > reconsd)   // 温度异常虚拟变量
gen drought      = (climate == 1)                       // 旱灾虚拟变量
gen flooding     = (climate == 5)                       // 水灾虚拟变量

*** 距离 × reform
gen distyellow_after = distance_huang * reform          // 距黄河距离 × 改革后
gen distcoast_after  = distance_coast * 100 * reform    // 距海岸距离(×100) × 改革后

*** 基础地理 × reform
gen larea_after     = ln(AREA)        * reform   // ln(县面积) × 改革后
gen lpop1600_after  = ln(cntypop1600) * reform   // ln(1600年人口) × 改革后

*** 气候冲击 × reform
gen recon_after    = recon    * reform   // 温度偏差 × 改革后
gen drought_after  = drought  * reform   // 旱灾 × 改革后
gen flooding_after = flooding * reform   // 水灾 × 改革后
gen disaster_after = disaster * reform   // 温度异常 × 改革后

*** 农业 × reform
gen maize_after       = maize              * reform   // 玉米引入 × 改革后
gen sweetpotato_after = sweetpotato        * reform   // 甘薯引入 × 改革后
gen wheat_after       = suitable_wheat_good * reform  // 小麦适宜性 × 改革后
gen rice_after        = suitable_rice_good  * reform  // 水稻适宜性 × 改革后
gen lwheat_after      = ln(si_wheat)       * reform   // ln(小麦适宜性指数) × 改革后
gen lrice_after       = ln(si_rice)        * reform   // ln(水稻适宜性指数) × 改革后

*** 人口密度 × reform
gen popdencnty1600_after  = popdencnty1600  * reform
gen lpopdencnty1600_after = lpopdencnty1600 * reform

*** 太平天国区域 × reform（用于稳健性检验）
gen taiping_after = Taiping * reform


/*---------------------------------------------------------------------------
 * A4. 变量标签
 *---------------------------------------------------------------------------*/

label variable drought          "Drought"
label variable drought_after    "Drought $\times$ Post"
label variable flooding         "Flooding"
label variable flooding_after   "Flooding $\times$ Post"
label variable disaster         "Temperature Anomaly"
label variable disaster_after   "Temperature Anomaly $\times$ Post"
label variable onset_any        "Presence"
label variable rug_after        "Ruggedness $\times$ Post"
label variable taiping_after    "Taiping Region $\times$ Post"
label variable recon            "Temperature Deviation"
label variable huang_after      "Huang River $\times$ Post"
label variable yangtze_after    "Yangtze River $\times$ Post"
label variable distyellow_after "Distance to Yellow River $\times$ Post"
label variable distcoast_after  "Distance to the Coast $\times$ Post"
label variable larea_after      "ln(land area) $\times$ Post"
label variable lpop1600_after   "ln(initial population in 1600) $\times$ Post"

label variable interaction1     "Along Canal $\times$ Post"


/*---------------------------------------------------------------------------
 * A5. 全局宏：后续回归直接引用 $Y, $X, $ctrls
 *---------------------------------------------------------------------------
 * 好处：
 *   1. 避免反复书写长变量名，降低手动输入出错的可能
 *   2. 需要更换被解释变量或控制变量集时，只需修改此处，不用逐一改回归命令
 *---------------------------------------------------------------------------*/

macro drop _all
est clear

* 被解释变量：asinh(每百万1600年人口的反叛次数) —— 基准设定
global Y ashonset_cntypop1600

* 核心解释变量：运河沿线 × 1826年后 —— DID 交互项
global X interaction1

* 辅助变量
gen area_after = AREA * reform

* 控制变量集：18个 "× reform" 交互项
global ctrls larea_after rug_after disaster disaster_after flooding drought ///
       flooding_after drought_after lpopdencnty1600_after maize maize_after ///
       sweetpotato sweetpotato_after wheat_after rice_after

* 星号显示选项（nostar = 不显示显著性星号，纯数字报告）
global stars nostar


/*---------------------------------------------------------------------------
 * A6. 图形默认设置
 *---------------------------------------------------------------------------*/

graph set window fontface "Cambria"
set scheme s2color


/*===========================================================================
 * END OF PART A — 数据准备完成，以下为各图表分析块
 *
 * 每个分析块以 preserve 开始、restore 结束，确保块间数据状态独立。
 * 选中一个块的代码运行即可，不必从 PART A 重新开始。
 *===========================================================================*/


/*###########################################################################
 * PART B: 正文图表（原 main_analysis.do）
 * #########################################################################*/


/*===========================================================================
 * Figure 2. 第一阶段：漕运量的断裂
 *
 * 问题：1826年改革是否实质性地改变了运河的使用？
 * 方法：分段线性拟合，1826年前一根线、1826年后一根线
 * 预期：漕运量在1826年后断崖式下降
 *===========================================================================*/
preserve

duplicates drop year, force          // 漕运量是全国数据，同一年所有县都一样
keep if year > 1755 & year < 1860    // 聚焦改革前后100年窗口

#d ;                                 // 将命令分隔符改为分号，方便多图层叠加
twoway
    (lfit lamount year if year <= 1825, lpattern(dash) lcolor("0 0 0"))
    (lfit lamount year if year >= 1826, lpattern(dash) lcolor("0 0 0"))
    (scatter lamount year, color("190 190 190") msize(*0.75))
    ,
    ytitle("Shipping volume (log million piculs)", size(*0.9))
    xtitle("")
    yline(0.8(0.1)1.8, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
    xline(1760(10)1860, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
    xline(1825.3, lpattern(dash) lcolor("128 0 0"))  // 1826年秋≈1825.3
    ylabel(0.8(0.2)1.8, angle(0) format(%5.1f) labsize(*0.85))
    xlabel(, labsize(*0.85))
    graphregion(fcolor(gs16) lcolor(gs16))            // AER经典浅灰背景
    plotregion(lcolor("white") lwidth(*0.9))
    legend(off)
    ;
#d cr                                // 恢复默认换行分隔
graph export "fig_canal_usage.png", replace

restore


/*===========================================================================
 * Figure 4. 事件研究：运河废弃与反叛的动态效应
 *
 * 方法：将年份按10年一组分箱，以-60期为基准组
 * 预期：改革前系数围绕零波动，改革后系统性跃升至零以上
 *===========================================================================*/
preserve

* --- 步骤一：构造事件窗口 ---
gen aperiod = floor((year - 1826) / 10) * 10
replace aperiod = -60 if aperiod < -60
tab aperiod, gen(aperiod)
keep if aperiod < 70

* --- 步骤二：估计事件研究回归 ---
* c.alongcanal#(c.aperiod2-aperiod15) 生成13个交互项，aperiod1(-60期)为基准组
reghdfe $Y c.alongcanal#(c.aperiod2-aperiod15) $ctrls, ///
    absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) cluster(OBJECTID)

* --- 步骤三：提取系数和置信区间 ---
matrix coef = e(b)
matrix cov  = e(V)
gen coef = .
gen se   = .
forvalues i = 1(1)12 {
    replace coef = coef[1, `i'] if _n == `i'
    replace se   = sqrt(cov[`i', `i']) if _n == `i'
}
gen lb = coef - invttail(e(df_r), 0.025) * se   // t分布临界值，非正态1.96
gen ub = coef + invttail(e(df_r), 0.025) * se
keep coef se lb ub
drop if coef == .
gen year = _n

* --- 步骤四：绘图 ---
#d ;
twoway
    (rarea ub lb year, color("193 205 205%80"))
    (scatter coef year, color(gs0) msize(*0.75))
    (line coef year, lpattern(solid) lcolor("4 4 4"))
    ,
    ytitle("Coefficients", size(*0.9))
    xtitle("Number of years since the 1826 reform", size(*0.9) margin(medsmall))
    yline(-0.05(0.025)0.2, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
    xline(1(0.5)12, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
    yline(0, lpattern(dash) lcolor("128 0 0"))         // 零效应参考线
    xline(5.5, lpattern(dash) lcolor("128 0 0"))        // 1826年（-10和+10之间）
    ylabel(-0.05(0.05)0.2, angle(0) format(%5.2f) labsize(*0.85))
    xlabel(1 "-50" 2 "-40" 3 "-30" 4 "-20" 5 "-10"
           6 "10" 7 "20" 8 "30" 9 "40" 10 "50" 11 "60" 12 "70", labsize(*0.85))
    graphregion(fcolor(gs16) lcolor(gs16))
    plotregion(lcolor("white") lwidth(*0.9))
    legend(off)
    ;
#d cr
graph export "fig_event_study.png", replace

restore


/*===========================================================================
 * Table 1. 数据来源与描述性统计
 *
 * 目的：展示所有变量的来源编号、均值、标准差
 * 变量分组：Ylist(被解释变量) / Xlist(运河变量) / Clist(气候地理) / Olist(其他)
 *===========================================================================*/
preserve

* --- 构建描述性统计所需的辅助变量 ---
gen town = town1820 if year == 1820
replace town = town1911 if year == 1911
replace distance_coast = distance_coast * 100
gen onset_cntypop1600 = onset_all / (cntypop1600 / 1000000)
gen canaltown = (town1820_r10canal * alongcanal) / town1820

* --- 变量标签 ---
label variable onset_cntypop1600   "Number of rebellions per million population"
label variable onset_all           "Number of Rebellions (Onset)"
label variable canal_den           "Length of canal per 100 $ km^2 $"
label variable popdencnty1600      "Population density"
label variable distance_huang      "Distance from the Yellow River (km)"
label variable distance_coast      "Distance from the coast (km)"
label variable AREA                "Land size"
label variable soldier             "Imperial Soldiers Stationed"
label variable attack              "Number of Attacking Cases"
label variable runinto             "Number of Retreating Cases"
label variable drought             "Drought"
label variable flooding            "Flood"
label variable disaster            "Temperature Anomaly"
label variable suitable_rice_good  "Suitable for wetland rice"
label variable suitable_wheat_good "Suitable for wheat"
label variable town                "Number of Towns and Local Markets"
label variable canaltown           "Share of towns within 10km of the canal"
label variable mp                  "Average grain price (silver tael per 10,000 kilocalorie)"

* --- 分组定义 ---
recode alongcanal (1=0) (0=1), gen(sugroup)   // 反转编码用于分组比较
local Ylist onset_cntypop1600
local Xlist alongcanal canal_den canaltown distance_canal
local Clist AREA ruggedness disaster flooding drought popdencnty1600 ///
           maizeyear swtpotatoyear suitable_rice_good suitable_wheat_good
local Olist soldier pref_capital attack runinto town alongcourier mp green_senior
des `Ylist' `Xlist' `Clist' `Olist'

* --- 汇总统计 ---
estpost summarize `Ylist' `Xlist' `Clist' `Olist'
eststo des2

* --- 来源编号（用于Table 1的"Sourcelist"列）---
preserve
clear
set obs 1
gen onset_cntypop1600   = 1
gen alongcanal          = 2
gen canal_den           = 2
gen canaltown           = 2
gen distance_canal      = 2
gen AREA                = 2
gen ruggedness          = 5
gen disaster            = 3
gen drought             = 4
gen flooding            = 4
gen popdencnty1600      = 6
gen maizeyear           = 4
gen swtpotatoyear       = 4
gen suitable_wheat_good = 8
gen suitable_rice_good  = 8
gen soldier             = 7
gen pref_capital        = 2
gen attack              = 1
gen runinto             = 1
gen town                = 2
gen alongcourier        = 2
gen mp                  = 4
gen green_senior        = 9
estpost summarize `Ylist' `Xlist' `Clist' `Olist'
eststo des1
restore

restore


/*===========================================================================
 * Table 2. 事前趋势检验
 *
 * 问题：处理组和对照组在1826年之前是否已有不同趋势？
 * 方法：将样本限制在1776-1825年，用 alongcanal × year 检验趋势差异
 * 预期：系数不显著 → 改革前两组趋势平行
 *===========================================================================*/
preserve

keep if year >= 1776 & year <= 1825
gen pretrend = alongcanal * year
label variable pretrend "$ Along Canal \times Year $ "
global X pretrend

tab OBJECTID
scalar groups = r(r)
su $Y
scalar ymean = r(mean)

* --- 四列递进回归（与Table 3结构相同）---
reghdfe $Y $X, absorb(i.OBJECTID i.year) cluster(OBJECTID)
eststo est1
qui tab OBJECTID if e(sample)
scalar groups = r(r)
qui su $Y if e(sample)
scalar ymean = r(mean)
estadd scalar depavg = ymean : est1
estadd scalar N_g    = groups : est1

reghdfe $Y $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year) cluster(OBJECTID)
eststo est2
qui tab OBJECTID if e(sample)
scalar groups = r(r)
qui su $Y if e(sample)
scalar ymean = r(mean)
estadd scalar depavg = ymean : est2
estadd scalar N_g    = groups : est2

reghdfe $Y $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) ///
    cluster(OBJECTID)
eststo est3
qui tab OBJECTID if e(sample)
scalar groups = r(r)
qui su $Y if e(sample)
scalar ymean = r(mean)
estadd scalar depavg = ymean : est3
estadd scalar N_g    = groups : est3

reghdfe $Y $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year ///
    i.prefid#c.year) cluster(OBJECTID)
eststo est4
qui tab OBJECTID if e(sample)
scalar groups = r(r)
qui su $Y if e(sample)
scalar ymean = r(mean)
estadd scalar depavg = ymean : est4
estadd scalar N_g    = groups : est4

estfe est1 est2 est3 est4

* --- Conley空间标准误（每列分别计算）---
* 四列的Conley SE计算结构相同，仅吸收的固定效应不同
* 关键参数：distcutoff(500) = 500km空间截断, lagcutoff(50) = 50年时间截断
preserve
    hdfe $Y $X, clear absorb(i.OBJECTID i.year) tol(0.001) ///
        keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) ///
        panel(OBJECTID) distcutoff(500) lagcutoff(50) disp star
    matrix V_spat = vecdiag(e(V))
    matmap V_spat SE_spat, m(sqrt(@))
    estadd matrix sesp = SE_spat : est1
restore

preserve
    hdfe $Y $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year) ///
        tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) ///
        panel(OBJECTID) distcutoff(500) lagcutoff(50) disp star
    matrix V_spat = vecdiag(e(V))
    matmap V_spat SE_spat, m(sqrt(@))
    estadd matrix sesp = SE_spat : est2
restore

preserve
    hdfe $Y $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year ///
        i.provid#i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) ///
        panel(OBJECTID) distcutoff(500) lagcutoff(50) disp star
    matrix V_spat = vecdiag(e(V))
    matmap V_spat SE_spat, m(sqrt(@))
    estadd matrix sesp = SE_spat : est3
restore

preserve
    hdfe $Y $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year ///
        i.provid#i.year i.prefid#c.year) tol(0.001) ///
        keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) ///
        panel(OBJECTID) distcutoff(500) lagcutoff(50) disp star
    matrix V_spat = vecdiag(e(V))
    matmap V_spat SE_spat, m(sqrt(@))
    estadd matrix sesp = SE_spat : est4
restore

restore


/*===========================================================================
 * Table 3. 基准回归：运河废弃与反叛
 *
 * 论文最核心的表格。五列递进增加固定效应和控制变量：
 *   (1) 县FE + 年FE
 *   (2) + 事前反叛趋势×年FE
 *   (3) + 省×年FE
 *   (4) + 府×线性趋势
 *   (5) + 全部控制变量
 * 每列后面跟 Conley 空间标准误（500km, 262年）
 *===========================================================================*/
preserve

* --- 列(1)：基准 ---
reghdfe $Y $X, absorb(i.OBJECTID i.year) cluster(OBJECTID)
eststo est1
qui tab OBJECTID if e(sample)
scalar groups = r(r)
qui su $Y if e(sample)
scalar ymean = r(mean)
estadd scalar depavg = ymean : est1
estadd scalar N_g    = groups : est1

* --- 列(2)：+ 事前反叛趋势 × 年FE ---
reghdfe $Y $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year) cluster(OBJECTID)
eststo est2
qui tab OBJECTID if e(sample)
scalar groups = r(r)
qui su $Y if e(sample)
scalar ymean = r(mean)
estadd scalar depavg = ymean : est2
estadd scalar N_g    = groups : est2

* --- 列(3)：+ 省×年FE ---
reghdfe $Y $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) ///
    cluster(OBJECTID)
eststo est3
qui tab OBJECTID if e(sample)
scalar groups = r(r)
qui su $Y if e(sample)
scalar ymean = r(mean)
estadd scalar depavg = ymean : est3
estadd scalar N_g    = groups : est3

* --- 列(4)：+ 府×线性趋势 ---
reghdfe $Y $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year ///
    i.prefid#c.year) cluster(OBJECTID)
eststo est4
qui tab OBJECTID if e(sample)
scalar groups = r(r)
qui su $Y if e(sample)
scalar ymean = r(mean)
estadd scalar depavg = ymean : est4
estadd scalar N_g    = groups : est4

* --- 列(5)：+ 全部控制变量（完整设定）---
reghdfe $Y $X $ctrls, absorb(i.OBJECTID i.year c.ashprerebels#i.year ///
    i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
eststo est5
qui tab OBJECTID if e(sample)
scalar groups = r(r)
qui su $Y if e(sample)
scalar ymean = r(mean)
estadd scalar depavg = ymean : est5
estadd scalar N_g    = groups : est5

estfe est1 est2 est3 est4 est5

* --- Conley空间标准误（每列分别计算）---
* 与Table 2的Conley块结构相同，但lagcutoff=262（全部年份）而非50
* 原理：先用hdfe去均值化（FWL定理），再在残差上用ols_spatial_HAC

* 列(1) Conley SE
preserve
    hdfe $Y $X, clear absorb(i.OBJECTID i.year) tol(0.001) ///
        keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) ///
        panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
    matrix V_spat = vecdiag(e(V))
    matmap V_spat SE_spat, m(sqrt(@))
    estadd matrix sesp = SE_spat : est1
restore

* 列(2) Conley SE
preserve
    hdfe $Y $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year) ///
        tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) ///
        panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
    matrix V_spat = vecdiag(e(V))
    matmap V_spat SE_spat, m(sqrt(@))
    estadd matrix sesp = SE_spat : est2
restore

* 列(3) Conley SE
preserve
    hdfe $Y $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year ///
        i.provid#i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) ///
        panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
    matrix V_spat = vecdiag(e(V))
    matmap V_spat SE_spat, m(sqrt(@))
    estadd matrix sesp = SE_spat : est3
restore

* 列(4) Conley SE
preserve
    hdfe $Y $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year ///
        i.provid#i.year i.prefid#c.year) tol(0.001) ///
        keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) ///
        panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
    matrix V_spat = vecdiag(e(V))
    matmap V_spat SE_spat, m(sqrt(@))
    estadd matrix sesp = SE_spat : est4
restore

* 列(5) Conley SE（完整设定，含控制变量）
preserve
    hdfe $Y $X $ctrls, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year ///
        i.provid#i.year i.prefid#c.year) tol(0.001) ///
        keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) ///
        panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
    matrix V_spat = vecdiag(e(V))
    matmap V_spat SE_spat, m(sqrt(@))
    estadd matrix sesp = SE_spat : est5
restore

restore


/*===========================================================================
 * Table 4. 处理强度：运河依赖度与反叛的剂量-反应关系
 *
 * 三个连续处理变量：
 *   ash_den_after：运河密度 × 改革后（预期正）
 *   canaltown_after：运河城镇占比 × 改革后（预期正）
 *   ash_dist_after：距运河距离 × 改革后（预期负）
 * 三边证据构成剂量-反应关系的逻辑三角
 *===========================================================================*/
preserve

gen ash_den  = asinh(canal_den)
gen ash_dist = asinh(ctadmin_canal)
gen ash_den_after  = ash_den  * reform
gen ash_dist_after = ash_dist * reform
gen canaltown_after = (town1820_r10canal * alongcanal) / town1820 * reform
label variable ash_den_after    "Canal length (per 100 $ km^2 $) $ \times $ Post"
label variable ash_dist_after   "Distance to canal $ \times $ Post"
label variable canaltown        "Canal town share"
label variable canaltown_after  "Canal town share $ \times $ Post"

global X1 ash_den_after
global X2 canaltown_after
global X3 ash_dist_after

* --- 回归1：运河密度 ---
reghdfe $Y $X1, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year ///
    i.prefid#c.year) cluster(OBJECTID)
estimates store int1
qui tab OBJECTID if e(sample)
scalar groups = r(r)
su $Y if e(sample)
scalar ymean = r(mean)
estadd scalar depavg = ymean : int1
estadd scalar N_g    = groups : int1

* --- 回归2：运河城镇占比 ---
reghdfe $Y $X2, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year ///
    i.prefid#c.year) cluster(OBJECTID)
estimates store int2
qui tab OBJECTID if e(sample)
scalar groups = r(r)
su $Y if e(sample)
scalar ymean = r(mean)
estadd scalar depavg = ymean : int2
estadd scalar N_g    = groups : int2

* --- 回归3：距运河距离 ---
reghdfe $Y $X3, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year ///
    i.prefid#c.year) cluster(OBJECTID)
estimates store int3
qui tab OBJECTID if e(sample)
scalar groups = r(r)
su $Y if e(sample)
scalar ymean = r(mean)
estadd scalar depavg = ymean : int3
estadd scalar N_g    = groups : int3

estfe int1 int2 int3

* --- Conley 标准误 ---
foreach est in int1 int2 int3 {
    preserve
        if "`est'" == "int1" local Xvar $X1
        if "`est'" == "int2" local Xvar $X2
        if "`est'" == "int3" local Xvar $X3
        hdfe $Y `Xvar', clear absorb(i.OBJECTID i.year c.ashprerebels#i.year ///
            i.provid#i.year i.prefid#c.year) tol(0.001) ///
            keepvars(OBJECTID year Y_COORD X_COORD)
        ols_spatial_HAC $Y `Xvar', lat(Y_COORD) lon(X_COORD) time(year) ///
            panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
        matrix V_spat = vecdiag(e(V))
        matmap V_spat SE_spat, m(sqrt(@))
        estadd matrix sesp = SE_spat : `est'
    restore
}

restore


/*===========================================================================
 * Table 5. 南北异质性
 *
 * 问题：运河效应在南方和北方是否不同？
 * 方法：以旧黄河与运河的交点纬度作为南北分界，跑三重交互
 * 预期：北方效应 > 南方（北方缺少替代水运通道）
 *===========================================================================*/
preserve

* --- 构造南北分界 ---
gen intlat = Y_COORD if along_oldhuang == 1 & alongcanal == 1
egen intersectlat = min(intlat)
gen north = (Y_COORD > intersectlat)
gen northpost = north * reform
gen triple = alongcanal * reform * north
label variable northpost "$ North \times Post $"
label variable triple   " $ Along Canal \times Post \times North $ "
global X triple interaction1 northpost

* --- 四列递进回归 ---
reghdfe $Y $X, absorb(i.OBJECTID i.year) cluster(OBJECTID)
eststo est1
qui tab OBJECTID if e(sample)
scalar groups = r(r)
qui su $Y if e(sample)
scalar ymean = r(mean)
estadd scalar depavg = ymean : est1
estadd scalar N_g    = groups : est1

reghdfe $Y $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year) cluster(OBJECTID)
eststo est2
qui tab OBJECTID if e(sample)
scalar groups = r(r)
qui su $Y if e(sample)
scalar ymean = r(mean)
estadd scalar depavg = ymean : est2
estadd scalar N_g    = groups : est2

reghdfe $Y $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) ///
    cluster(OBJECTID)
eststo est3
qui tab OBJECTID if e(sample)
scalar groups = r(r)
qui su $Y if e(sample)
scalar ymean = r(mean)
estadd scalar depavg = ymean : est3
estadd scalar N_g    = groups : est3

reghdfe $Y $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year ///
    i.prefid#c.year) cluster(OBJECTID)
eststo est4
qui tab OBJECTID if e(sample)
scalar groups = r(r)
qui su $Y if e(sample)
scalar ymean = r(mean)
estadd scalar depavg = ymean : est4
estadd scalar N_g    = groups : est4

estfe est1 est2 est3 est4

* --- Conley 标准误（四列 × 相同结构）---
forvalues c = 1/4 {
    if `c' == 1 local fes i.OBJECTID i.year
    if `c' == 2 local fes i.OBJECTID i.year c.ashprerebels#i.year
    if `c' == 3 local fes i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year
    if `c' == 4 local fes i.OBJECTID i.year c.ashprerebels#i.year ///
        i.provid#i.year i.prefid#c.year
    preserve
        hdfe $Y $X, clear absorb(`fes') tol(0.001) ///
            keepvars(OBJECTID year Y_COORD X_COORD)
        ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) ///
            panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
        matrix V_spat = vecdiag(e(V))
        matmap V_spat SE_spat, m(sqrt(@))
        estadd matrix sesp = SE_spat : est`c'
    restore
}

restore


/*===========================================================================
 * Table 6. 安慰剂检验：替代交通路线
 *
 * 问题：效应是否独属于运河，而非任何古老路线沿线都如此？
 * 检验：将运河替换为长江、旧黄河、海岸线、驿道四条伪处理路线
 * 预期：四条路线全部不显著，运河显著 → 排除替代解释
 *===========================================================================*/
preserve

gen oldhuang_after = along_oldhuang * reform
gen coast_after    = alongcoast    * reform
gen courier_after  = alongcourier  * reform
egen plcb = rowmax(alongyangtze along_oldhuang alongcoast alongcourier)
gen plcb_after = plcb * reform
label variable yangtze_after  "Along Yangtze $ \times $ Post"
label variable oldhuang_after "Along Huang $ \times $ Post"
label variable coast_after    "Along Coast $ \times $ Post"
label variable courier_after  "Along Courier $ \times $ Post"
label variable plcb_after     "Along $ \times $ Post"

global Xp1    yangtze_after
global Xp2    oldhuang_after
global Xp3    coast_after
global Xp4    courier_after
global Xp_any plcb_after

* --- 五列回归（四条路线 + 汇总）---
foreach x in Xp1 Xp2 Xp3 Xp4 Xp_any {
    local col = subinstr("`x'", "Xp", "", .)
    if "`col'" == "_any" local col = 5
    reghdfe $Y ${`x'}, absorb(i.OBJECTID i.year c.ashprerebels#i.year ///
        i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
    eststo est`col'
    qui tab OBJECTID if e(sample)
    scalar groups = r(r)
    qui su $Y if e(sample)
    scalar ymean = r(mean)
    estadd scalar depavg = ymean : est`col'
    estadd scalar N_g    = groups : est`col'
}

estfe est1 est2 est3 est4 est5

* --- Conley 标准误 ---
foreach x in Xp1 Xp2 Xp3 Xp4 Xp_any {
    local col = subinstr("`x'", "Xp", "", .)
    if "`col'" == "_any" local col = 5
    preserve
        hdfe $Y ${`x'}, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year ///
            i.provid#i.year i.prefid#c.year) tol(0.001) ///
            keepvars(OBJECTID year Y_COORD X_COORD)
        ols_spatial_HAC $Y ${`x'}, lat(Y_COORD) lon(X_COORD) time(year) ///
            panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
        matrix V_spat = vecdiag(e(V))
        matmap V_spat SE_spat, m(sqrt(@))
        estadd matrix sesp = SE_spat : est`col'
    restore
}

restore


/*===========================================================================
 * Table 7. 排除战争干扰：鸦片战争与太平天国
 *
 * Panel A：从样本中剔除战场/核心区 → 重新跑基准回归
 * Panel B：三重交互（alongcanal × reform × warzone）
 * 关键：interaction1（运河基本效应）在控制战争后是否依然显著
 *===========================================================================*/
preserve

gen taipingregion = (Taiping >= 2) if Taiping < .
gen triple1  = alongcanal * reform * opiumbattle
gen triple1a = opiumbattle * reform
gen triple2  = alongcanal * reform * taipingregion
gen triple2a = taipingregion * reform
label variable interaction1 "Canal $ \times $ Post"
label variable triple1      "Canal $ \times $ Opium Battlefield $\times$ Post"
label variable triple1a     "Opium Battlefield $ \times $ Post"
label variable triple2      "Canal $ \times $ Taiping $\times$ Post"
label variable triple2a     "Taiping $ \times $ Post"

* --- Panel A: 剔除鸦片战争战场县 ---
preserve
    keep if opiumbattle == 0
    reghdfe $Y $X, absorb(OBJECTID year c.ashprerebels#i.year i.prefid#c.year ///
        i.provid#i.year) cluster(OBJECTID)
    eststo omtopium1
    tab OBJECTID if e(sample)
    scalar groups = r(r)
    su onset_all if e(sample)
    scalar ymean = r(mean)
    estadd scalar depavg = ymean : omtopium1
    estadd scalar N_g    = groups : omtopium1
restore

* Panel A Conley（鸦片战争）
preserve
    keep if opiumbattle == 0
    hdfe $Y $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year ///
        i.provid#i.year i.prefid#c.year) tol(0.001) ///
        keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) ///
        panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
    matrix V_spat = vecdiag(e(V))
    matmap V_spat SE_spat, m(sqrt(@))
    estadd matrix sesp = SE_spat : omtopium1
restore

* --- Panel A: 剔除太平天国核心区 ---
preserve
    keep if Taiping < 2
    reghdfe $Y $X, absorb(OBJECTID year c.ashprerebels#i.year i.prefid#c.year ///
        i.provid#i.year) cluster(OBJECTID)
    eststo omttaiping1
    tab OBJECTID if e(sample)
    scalar groups = r(r)
    su onset_all if e(sample)
    scalar ymean = r(mean)
    estadd scalar depavg = ymean : omttaiping1
    estadd scalar N_g    = groups : omttaiping1
restore

* Panel A Conley（太平天国）
preserve
    keep if Taiping < 2
    hdfe $Y $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year ///
        i.provid#i.year i.prefid#c.year) tol(0.001) ///
        keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) ///
        panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
    matrix V_spat = vecdiag(e(V))
    matmap V_spat SE_spat, m(sqrt(@))
    estadd matrix sesp = SE_spat : omttaiping1
restore

* --- Panel B: 三重交互 ---
* 鸦片战争三重交互
reghdfe $Y interaction1 triple1a triple1, absorb(i.OBJECTID i.year ///
    c.ashprerebels#i.year i.prefid#c.year i.provid#i.year) cluster(OBJECTID)
est store opium1
tab OBJECTID if e(sample)
scalar groups = r(r)
su onset_all if e(sample)
scalar ymean = r(mean)
estadd scalar depavg = ymean : opium1
estadd scalar N_g    = groups : opium1

* 太平天国三重交互
reghdfe $Y interaction1 triple2a triple2, absorb(i.OBJECTID i.year ///
    c.ashprerebels#i.year i.prefid#c.year i.provid#i.year) cluster(OBJECTID)
est store taiping1
tab OBJECTID if e(sample)
scalar groups = r(r)
su onset_all if e(sample)
scalar ymean = r(mean)
estadd scalar depavg = ymean : taiping1
estadd scalar N_g    = groups : taiping1

* Panel B Conley（鸦片战争三重交互）
preserve
    hdfe $Y interaction1 triple1a triple1, clear absorb(i.OBJECTID i.year ///
        c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) ///
        keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC $Y interaction1 triple1a triple1, lat(Y_COORD) lon(X_COORD) ///
        time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
    matrix V_spat = vecdiag(e(V))
    matmap V_spat SE_spat, m(sqrt(@))
    estadd matrix sesp = SE_spat : opium1
restore

* Panel B Conley（太平天国三重交互）
preserve
    hdfe $Y interaction1 triple2a triple2, clear absorb(i.OBJECTID i.year ///
        c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) ///
        keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC $Y interaction1 triple2a triple2, lat(Y_COORD) lon(X_COORD) ///
        time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
    matrix V_spat = vecdiag(e(V))
    matmap V_spat SE_spat, m(sqrt(@))
    estadd matrix sesp = SE_spat : taiping1
restore

restore


/*===========================================================================
 * Figure A1. 反叛次数的时间分布
 *
 * 展示1650-1911年每年反叛总次数，标记1826年改革时点
 *===========================================================================*/
preserve

collapse (sum) onset_all, by(year)
label variable onset_all "Count of Rebellions"
#d ;
twoway
    (line onset_all year, lwidth(*1.05) lcolor(gray*2.6))
    (scatter onset_all year, color(gs0) msize(*0.15))
    ,
    ytitle("Count of Rebellions", size(*0.9))
    xtitle("")
    yline(0(10)60, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
    xline(1650(25)1900, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
    xline(1826, lpattern(dash) lcolor("128 0 0"))
    ylabel(0(20)60, angle(0) format(%12.0f) labsize(*0.85))
    xlabel(1650(50)1900, labsize(*0.85))
    graphregion(fcolor(gs16) lcolor(gs16))
    plotregion(lcolor("white") lwidth(*0.9))
    legend(off)
    ;
#d cr
graph export "fig_rebellion_timeline.png", replace

restore


/*===========================================================================
 * Figure A2. Conley标准误参数敏感性分析
 *
 * 问题：t值是否依赖特定的空间/时间截断参数？
 * 方法：对Table 3的每一列，遍历6个距离截断 × 4个时间截断，看t值变化
 *      同时对比聚类标准误（县级、府级）
 * 结论：无论如何调参，t值始终高于1.96
 *
 * ⚠ 耗时最长：涉及120次ols_spatial_HAC调用，可选择性运行
 *===========================================================================*/
preserve

local c = 1
forvalues c = 1/5 {
    * --- 确定该列的固定效应和控制变量 ---
    if `c' == 1 local fes i.OBJECTID i.year
    if `c' == 2 local fes i.OBJECTID i.year c.ashprerebels#i.year
    if `c' == 3 local fes i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year
    if `c' == 4 local fes i.OBJECTID i.year c.ashprerebels#i.year ///
        i.provid#i.year i.prefid#c.year
    if `c' == 5 local fes i.OBJECTID i.year c.ashprerebels#i.year ///
        i.provid#i.year i.prefid#c.year
    local ctrl
    if `c' == 5 local ctrl $ctrls

    mat tests`c' = (0, 0, .)

    * --- 遍历空间截断(50-2000km) × 时间截断(20-262年) ---
    preserve
        hdfe $Y $X `ctrl', clear absorb(`fes') tol(0.001) ///
            keepvars(OBJECTID year Y_COORD X_COORD)
        foreach d of numlist 50 100 200 500 1000 2000 {
            foreach t of numlist 20 100 200 262 {
                disp "Estimating model `c' with distancecutoff `d' and lagcutoff `t' ..."
                ols_spatial_HAC $Y $X `ctrl', lat(Y_COORD) lon(X_COORD) ///
                    time(year) panel(OBJECTID) distcutoff(`d') lagcutoff(`t')
                ereturn display
                mat ests = r(table)
                scalar d = `d'
                scalar t = `t'
                mat tests`c' = (tests`c' \ d, t, ests[3, 1])
            }
        }
    restore

    * --- 县级聚类 ---
    reghdfe $Y $X `ctrl', absorb(`fes') cluster(OBJECTID)
    ereturn display
    mat ests = r(table)
    scalar d = -1
    scalar t = -1
    mat tests`c' = (tests`c' \ d, t, ests[3, 1])

    * --- 府级聚类 ---
    reghdfe $Y $X `ctrl', absorb(`fes') cluster(prefid)
    ereturn display
    mat ests = r(table)
    scalar d = -2
    scalar t = -2
    mat tests`c' = (tests`c' \ d, t, ests[3, 1])

    * --- 保存统计量 ---
    preserve
        clear
        svmat tests`c', names(stat)
        rename (stat1 stat2 stat3) (dist lag tvalue)
        save "errors_tests`c'.dta", replace
    restore
}

* --- 可视化：五列各自的t值随参数变化图 ---
local c = 1
forvalues c = 1/5 {
    use "errors_tests`c'.dta", clear
    drop in 1
    recode dist (-1 -2 = 1 "NA") (50 = 2 "50") (100 = 4 "100") ///
        (200 = 6 "200") (500 = 8 "500") (1000 = 10 "1000") (2000 = 12 "2000"), ///
        gen(distcat) label(distcat)
    gen mlabel = "cluster(county)"      if dist == -1
    replace mlabel = "cluster(prefecture)" if dist == -2
    #d ;
    twoway
        (connected tvalue distcat if dist > 0 & lag == 20,  msymbol(Oh) color(black))
        (connected tvalue distcat if dist > 0 & lag == 100, msymbol(T)  color(black))
        (connected tvalue distcat if dist > 0 & lag == 200, msymbol(O)  color(black))
        (connected tvalue distcat if dist > 0 & lag == 262, msymbol(X)  color(black))
        (scatter tvalue distcat if inlist(dist, -1, -2), ///
            mlabel(mlabel) mlabcolor(black) msize(*0.5) color(black))
        ,
        ytitle("Test t-value", size(*0.9))
        xtitle("Distance cutoff (km)", size(*0.9) margin(medsmall))
        yline(1.75(0.25)3.25, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
        xline(1(1)12, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
        yline(1.96, lpattern(dash) lcolor("128 0 0"))
        yline(2.58, lpattern(dash) lcolor("128 0 0"))
        text(1.94 0.6 "**" 2.56 0.55 "***", color("128 0 0"))
        ylabel(1.8 " " 2 "2.0" 2.5 "2.5" 3 "3.0", angle(0) ///
            format(%5.1f) labsize(*0.85) notick)
        xlabel(1 2(2)12, valuelabel labsize(*0.85))
        graphregion(fcolor(gs16) lcolor(gs16))
        plotregion(lcolor("white") lwidth(*0.9))
        legend(order(1 "lagcutoff:20 years" 2 "lagcutoff:100 years" ///
            3 "lagcutoff:200 years" 4 "lagcutoff:all (262) years") ///
            row(1) size(*0.45))
        title("", size(small) margin(small))
        ;
        #d cr
    graph export "fig_conley_sensitivity_col`c'.png", replace
}

restore


/*===========================================================================
 * Figure A3. 灵活处理强度：运河密度与城镇依赖的binned估计
 *
 * 方法：将运河密度和城镇占比各分为5组，用reghdfe估计每组的处理效应
 * 目的：检验处理效应是否随依赖度单调递增
 *===========================================================================*/
preserve

gen canaltown = (town1820_r10canal * alongcanal) / town1820

* --- Panel (a)：运河密度分组 ---
preserve
    egen intensity = cut(canal_den), at(0, 0.001, 2, 4, 6, 15)
    replace intensity = -1 if alongcanal == 0
    tab intensity, gen(inten)
    reghdfe $Y c.reform#(c.inten2-inten6), absorb(i.OBJECTID i.year ///
        c.ashprerebels#i.year i.provid#i.year) cluster(OBJECTID)
    matrix coef = e(b)
    matrix cov  = e(V)
    gen coef = .
    gen se   = .
    forvalues i = 1(1)5 {
        replace coef = coef[1, `i'] if _n == `i'
        replace se   = sqrt(cov[`i', `i']) if _n == `i'
    }
    gen lb = coef - invttail(e(df_r), 0.025) * se
    gen ub = coef + invttail(e(df_r), 0.025) * se
    keep coef se lb ub
    drop if coef == .
    gen ph_intensity = _n
    #d ;
    twoway
        (line lb ph_intensity, lpattern(dash) lcolor("0 0 0"))
        (line ub ph_intensity, lpattern(dash) lcolor("0 0 0"))
        (scatter coef ph_intensity, color(gs0) msize(*0.75))
        (line coef ph_intensity, lpattern(solid) lcolor("4 4 4"))
        ,
        ytitle("Coefficients", size(*0.9))
        xtitle("Canal length per 100 square km", size(*0.9) margin(medsmall))
        yline(-0.05(0.025)0.10, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
        xline(1(0.5)5, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
        yline(0, lpattern(dash) lcolor("128 0 0"))
        ylabel(-0.05(0.05)0.10, angle(0) format(%5.2f) labsize(*0.85))
        xlabel(1 "0" 2 "2" 3 "4" 4 "6" 5 "6+", labsize(*0.85))
        graphregion(fcolor(gs16) lcolor(gs16))
        plotregion(lcolor("white") lwidth(*0.9))
        legend(off)
        ;
        #d cr
    graph export "fig_flexible_density.png", replace
restore

* --- Panel (b)：运河城镇占比分组 ---
preserve
    egen intensity = cut(canaltown), at(0, .2, .4, .6, .8, 1.1)
    replace intensity = -1 if alongcanal == 0
    tab intensity, gen(inten)
    reghdfe $Y c.reform#(c.inten2-inten6), absorb(i.OBJECTID i.year ///
        c.ashprerebels#i.year i.provid#i.year) cluster(OBJECTID)
    matrix coef = e(b)
    matrix cov  = e(V)
    gen coef = .
    gen se   = .
    forvalues i = 1(1)5 {
        replace coef = coef[1, `i'] if _n == `i'
        replace se   = sqrt(cov[`i', `i']) if _n == `i'
    }
    gen lb = coef - invttail(e(df_r), 0.025) * se
    gen ub = coef + invttail(e(df_r), 0.025) * se
    keep coef se lb ub
    drop if coef == .
    gen ph_intensity = _n
    #d ;
    twoway
        (line lb ph_intensity, lpattern(dash) lcolor("0 0 0"))
        (line ub ph_intensity, lpattern(dash) lcolor("0 0 0"))
        (scatter coef ph_intensity, color(gs0) msize(*0.75))
        (line coef ph_intensity, lpattern(solid) lcolor("4 4 4"))
        ,
        ytitle("Coefficients", size(*0.9))
        xtitle("Share of towns within 10km to the canal", size(*0.9) margin(medsmall))
        yline(-0.05(0.025)0.15, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
        xline(1(0.5)5, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
        yline(0, lpattern(dash) lcolor("128 0 0"))
        ylabel(-0.05(0.05)0.15, angle(0) format(%5.2f) labsize(*0.85))
        xlabel(1 "0.2" 2 "0.4" 3 "0.6" 4 "0.8" 5 "1.0", labsize(*0.85))
        graphregion(fcolor(gs16) lcolor(gs16))
        plotregion(lcolor("white") lwidth(*0.9))
        legend(off)
        ;
        #d cr
    graph export "fig_flexible_townshare.png", replace
restore

restore


/*===========================================================================
 * Figure A4. 灵活距离：反叛效应随距运河距离的衰减
 *
 * 方法：将距运河距离按25km分箱（共16组），估计每组处理效应
 * 预期：系数随距离递减，约在150km外消失
 *===========================================================================*/
preserve

gen band = ceil(ctadmin_canal / 25) * 25
replace band = 425 if band >= 425 & band != .
tab band, gen(dist)
reghdfe $Y c.reform#(c.dist1-dist16), absorb(i.OBJECTID i.year ///
    c.ashprerebels#i.year i.provid#i.year) cluster(OBJECTID)
matrix coef = e(b)
matrix cov  = e(V)
gen coef = .
gen se   = .
forvalues i = 1(1)16 {
    replace coef = coef[1, `i'] if _n == `i'
    replace se   = sqrt(cov[`i', `i']) if _n == `i'
}
gen lb = coef - invttail(e(df_r), 0.025) * se
gen ub = coef + invttail(e(df_r), 0.025) * se
keep coef se lb ub
drop if coef == .
gen distance_canal = _n
#d ;
twoway
    (line lb distance_canal, lpattern(dash) lcolor("0 0 0"))
    (line ub distance_canal, lpattern(dash) lcolor("0 0 0"))
    (scatter coef distance_canal, color(gs0) msize(*0.75))
    (line coef distance_canal, lpattern(solid) lcolor("4 4 4"))
    ,
    ytitle("Coefficients", size(*0.9))
    xtitle("Distance to the canal (km)", size(*0.9) margin(medsmall))
    yline(-0.05(0.025)0.15, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
    xline(1(0.5)16, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
    yline(0, lpattern(dash) lcolor("128 0 0"))
    ylabel(-0.05(0.05)0.15, angle(0) format(%5.2f) labsize(*0.85))
    xlabel(1 "25" 2 "50" 3 "75" 4 "100" 5 "125" 6 "150" 7 "175" 8 "200" ///
        9 "225" 10 "250" 11 "275" 12 "300" 13 "325" 14 "350" 15 "375" 16 "400", ///
        labsize(*0.85))
    graphregion(fcolor(gs16) lcolor(gs16))
    plotregion(lcolor("white") lwidth(*0.9))
    legend(off)
    ;
#d cr
graph export "fig_distance_decay.png", replace

restore


/*===========================================================================
 * Figure A5. Changes-in-Changes (CIC) 估计
 *
 * 方法：Athey & Imbens (2006)，不假设线性处理效应
 * 先去均值化（FWL），保留组别标识，再跑cic命令
 * 结果展示各分位点的处理效应
 *
 * ⚠ 注意：原代码作者标注cic命令存在兼容性问题
 *===========================================================================*/
preserve

* --- 构造四组别虚拟变量 ---
gen G0T0 = (alongcanal == 0 & reform == 0)
gen G1T0 = (alongcanal == 1 & reform == 0)
gen G0T1 = (alongcanal == 0 & reform == 1)
gen G1T1 = (alongcanal == 1 & reform == 1)

* --- FWL去均值化：剔除固定效应，保留组别标识 ---
qui reg $Y G0T0 G1T0 G0T1 G1T1 c.ashprerebels#i.year i.OBJECTID i.year ///
    i.provid#i.year i.prefid#c.year, nocons
predict res, residual
mat coef = e(b)
gen Yhat = res + coef[1,1]*G0T0 + coef[1,2]*G1T0 + coef[1,3]*G0T1 + coef[1,4]*G1T1

* --- CIC估计（100次bootstrap）---
su Yhat, detail
cic Yhat, group(alongcanal) time(reform) reps(100)   // 存在点问题，见推文说明
matrix qte = e(qte)
clear
svmat qte, names(qte)
rename (qte1 qte2 qte3 qte4 qte5) (qntl qte std lb ub)
#d ;
twoway
    (line lb qntl, lpattern(dash) lcolor("0 0 0"))
    (line ub qntl, lpattern(dash) lcolor("0 0 0"))
    (scatter qte qntl, color(gs0) msize(*0.75))
    (line qte qntl, lpattern(solid) lcolor("4 4 4"))
    ,
    ytitle("Treatment effects", size(*0.9))
    xtitle("Quantiles", size(*0.9) margin(medsmall))
    yline(0(0.025)0.15, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
    xline(0(0.1)1, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
    ylabel(0(0.05)0.15, angle(0) format(%5.2f) labsize(*0.85))
    xlabel(, format(%5.1f) labsize(*0.85))
    graphregion(fcolor(gs16) lcolor(gs16))
    plotregion(lcolor("white") lwidth(*0.9))
    legend(off)
    ;
#d cr
graph export "fig_cic.png", replace

restore


/*===========================================================================
 * Figure A6. 合成控制法 (SCM)
 *
 * Panel (a)：运河县实际反叛路径 vs 合成控制反事实路径
 * Panel (b)：处理效应 + 排列检验p值（双轴图）
 *
 * 控制池限制：非运河县且距运河至少150km
 *===========================================================================*/
preserve

* --- 折叠为十年均值，减少年度噪声 ---
replace year = floor((year - 1826) / 10) * 10 + 1826
collapse (mean) onset_all cntypop1600 alongcanal distance_canal, by(OBJECTID year)
gen ashonset_cntypop1600 = asinh(onset_all / (cntypop1600 / 1000000))
gen y = ashonset_cntypop1600
keep if y < .
keep if year >= 1776
drop if distance_canal < 150 & alongcanal == 0   // 排除距运河150km内的非运河县
gen interaction1 = alongcanal * (year >= 1826)

* --- 运行合成控制法 ---
synth_runner y y(1776) y(1796) y(1806) y(1816), d(interaction1) gen_var
matrix P = e(pvals_std)

* --- 提取排列检验p值 ---
preserve
    clear
    svmat P, names(matcol)
    gen I = 1
    reshape long Pc, i(I) j(lead)
    drop I
    rename Pc p_vals
    tempfile temp
    save "`temp'.dta", replace
restore
merge m:1 lead using "`temp'.dta", nogenerate
save "synth10alt.dta", replace

* --- Panel (a)：实际路径 vs 合成路径 ---
use "synth10alt.dta", clear
replace year = year - 1826
keep if alongcanal == 1
collapse (mean) p_vals y y_synth, by(year)
gen effect = y - y_synth
keep if year < 70
#d ;
twoway
    (connected y year, lpattern(solid)  msymbol(C) msize(*0.75) color("4 4 4"))
    (connected y_synth year, lpattern(dash) msymbol(T) msize(*0.75) ///
        color("119 119 119"))
    ,
    ytitle("Coefficients", size(*0.9))
    xtitle("Number of years since the 1826 reform", size(*0.9) margin(medsmall))
    yline(0(0.1)0.9, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
    xline(-50(5)60, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
    xline(-5, lpattern(dash) lcolor("128 0 0"))
    ylabel(0(0.2)0.8, angle(0) format(%5.1f) labsize(*0.85))
    xlabel(-50 "-50" -40 "-40" -30 "-30" -20 "-20" -10 "-10" ///
        0 "10" 10 "20" 20 "30" 30 "40" 40 "50" 50 "60" 60 "70", labsize(*0.85))
    graphregion(fcolor(gs16) lcolor(gs16))
    plotregion(lcolor("white") lwidth(*0.9))
    legend(label(1 "Canal counties (treated)") label(2 "Synthetic controls") ///
        size(*0.85))
    ;
#d cr
graph export "fig_scm_path.png", replace

* --- Panel (b)：处理效应 + p值双轴图 ---
#d ;
twoway
    (line effect year, yaxis(1) lpattern(solid) color("4 4 4"))
    (scatter p_vals year, yaxis(2) msymbol(O) msize(*0.9) color("4 4 4"))
    ,
    ytitle("Treatment effects", axis(1) size(*0.9))
    ytitle("p-values", axis(2) size(*0.9))
    xtitle("Number of years since the 1826 reform", size(*0.9) margin(medsmall))
    yline(-0.2(0.1)0.8, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
    xline(-50(5)60, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
    xline(-5, lpattern(dash) lcolor("128 0 0"))
    ylabel(-0.2(0.2)0.8, angle(0) format(%5.1f) labsize(*0.85) axis(1))
    ylabel(0(0.2)1, angle(0) format(%5.1f) labsize(*0.85) axis(2))
    xlabel(-50 "-50" -40 "-40" -30 "-30" -20 "-20" -10 "-10" ///
        0 "10" 10 "20" 20 "30" 30 "40" 40 "50" 50 "60" 60 "70", labsize(*0.85))
    graphregion(fcolor(gs16) lcolor(gs16))
    plotregion(lcolor("white") lwidth(*0.9))
    legend(label(1 "Treatment effects") label(2 "P-values") size(*0.85))
    ;
#d cr
graph export "fig_scm_effects.png", replace

restore


/*===========================================================================
 * Figure A7. 异质性：距长江距离的调节效应
 *
 * 方法：按距长江100km带宽滑动窗口估计运河效应
 * 预期：离长江越近 → 替代水运通道 → 运河效应越弱
 *===========================================================================*/
preserve

mat result = (., ., ., .)
capture program drop svresult
program define svresult
    args distance_yangtze
    qui {
        reghdfe $Y $X $ctrls ///
            if distance_yangtze >= `distance_yangtze' - 100 ///
            & distance_yangtze < `distance_yangtze', ///
            a(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year ///
            i.prefid#c.year) cl(OBJECTID)
        scalar b      = _b[inter]
        scalar se     = _se[inter]
        scalar uci_95 = _b[inter] + invttail(e(df_r), 0.025) * se
        scalar lci_95 = _b[inter] - invttail(e(df_r), 0.025) * se
        mat result = (result \ `distance_yangtze', b, lci_95, uci_95)
    }
end

_dots 0
forvalues i = 100(100)400 {
    svresult `i'
    _dots `i' 0
}

clear
svmat result
drop in 1
rename result1 dist
rename result2 coef
rename result3 lci_95
rename result4 rci_95
export delimited "distance_yangtze.txt", delimit(tab) replace
import delimited using "distance_yangtze.txt", clear
#d ;
twoway
    (rcap rci_95 lci_95 dist, lcolor(Gray) lpattern(dash) lwidth(thin) msize(*0.75))
    (scatter coef dist, color(gs0) msize(*0.75))
    ,
    ytitle("Coefficients", size(*0.9))
    xtitle("Distance to the Yangtze river", size(*0.9) margin(medsmall))
    yline(0(0.05)0.3, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
    yline(0, lpattern(dash) lcolor("128 0 0"))
    xline(100(50)400, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
    ylabel(0(0.1)0.3, angle(0) format(%5.1f) labsize(*0.85))
    xlabel(, labsize(*0.85))
    graphregion(fcolor(gs16) lcolor(gs16))
    plotregion(lcolor("white") lwidth(*0.9))
    legend(off)
    ;
#d cr
graph export "fig_yangtze_heterogeneity.png", replace

restore


/*===========================================================================
 * Figure C4b. 旱涝灾害的时间分布
 *===========================================================================*/
preserve

preserve
    collapse (sum) flooding drought, by(year)
    label variable flooding "Flooding"
    label variable drought  "Drought"
    gen fd = flooding + drought
    label variable fd "Drought"
    #d ;
    twoway
        (bar fd year, barw(0.85) base(0) color("89 89 89"))
        (bar flooding year, barw(0.85) base(0) color("190 190 190"))
        ,
        ytitle("")
        xtitle("")
        yline(0(50)100, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
        xline(1650(25)1910, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
        xline(1826, lwidth(*1.25) lpattern(dash) lcolor("128 0 0"))
        ylabel(0(100)400, angle(0) format(%12.0f) labsize(*0.85))
        xlabel(, labsize(*0.85))
        graphregion(fcolor(gs16) lcolor(gs16))
        plotregion(lcolor("white") lwidth(*0.9))
        ;
    #d cr
    graph export "fig_climate_timeline.png", replace
restore

restore


/*===========================================================================
 * Figure C6b. 新大陆作物（玉米、甘薯）引种的时间分布
 *===========================================================================*/
preserve

preserve
    sort year
    collapse (count) maizeyear swtpotatoyear (sum) maize sweetpotato, by(year)
    gen maizeshare = maize / maizeyear
    gen spshare    = sweetpotato / swtpotatoyear
    label variable maize      "Maize"
    label variable sweetpotato "Sweet Potato"
    #d ;
    twoway
        (line maize year, lpattern(solid)  msize(*0.75) color("4 4 4"))
        (line sweetpotato year, lpattern(dash) msize(*0.75) color("119 119 119"))
        ,
        ytitle("Number of counties adopted", size(*0.9))
        xtitle("")
        yline(0(100)600, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
        xline(1650(25)1910, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
        xline(1826, lpattern(dash) lcolor("128 0 0"))
        ylabel(0(200)600, angle(0) format(%5.0f) labsize(*0.85))
        xlabel(, labsize(*0.85))
        graphregion(fcolor(gs16) lcolor(gs16))
        plotregion(lcolor("white") lwidth(*0.9))
        legend(label(1 "Maize") label(2 "Sweet Potato"))
        ;
    #d cr
    graph export "fig_newcrops_timeline.png", replace
restore

restore


/*===========================================================================
 * Table A1. 平衡性检验：运河县 vs 非运河县
 *
 * 截面比较（collapse到县级），检验两组在可观测特征上是否可比
 *===========================================================================*/
preserve

* --- 截面 collapse + 标签（隔离在 preserve 内）---
preserve
gen larea = ln(AREA)
gen lrug  = ln(ruggedness)
gen lpop  = ln(popdencnty1600)
gen lwheat = ln(si_wheat)
gen lrice  = ln(si_rice)
global balancevars larea ruggedness disaster flooding drought lpop maize ///
    sweetpotato suitable_wheat_good suitable_rice_good
collapse (mean) alongcanal $balancevars, by(OBJECTID)
label variable larea               "Land area"
label variable ruggedness          "Ruggedness Index"
label variable disaster            "Temperature Anomaly"
label variable flooding            "Frequency of flooding"
label variable drought             "Frequency of droughts"
label variable lpop                "Population density in 1600"
label variable maize               "Maize introduction"
label variable sweetpotato         "Sweet potato introduction"
label variable suitable_wheat_good "Suitable for wheat"
label variable suitable_rice_good  "Suitable for wetland rice"
restore

* --- 分组统计 ---
recode alongcanal (1=0) (0=1), gen(sugroup)
keep if lpop < .
estpost summarize $balancevars if sugroup == 0   // 运河县
eststo des1
estpost summarize $balancevars if sugroup == 1   // 非运河县
eststo des2
estpost ttest $balancevars, by(sugroup)          // 差异检验
eststo des3

restore


/*===========================================================================
 * Table A2. 替代抽样方法：不同样本窗口的稳健性
 *
 * 列：同府内 / 100km / 150km / 200km / 全样本
 * 行：50年 / 100年 / 150年 / 200年 / 全时段窗口
 * 共5×5=25个回归 + 县和府两个层面 = 50组结果
 *===========================================================================*/
preserve

* --- 列定义（地理范围）---
local col1 prefalong == 1
local col2 distance_canal <= 100
local col3 distance_canal <= 150
local col4 distance_canal <= 200
local col5 distance_canal <= .

* --- 行定义（时间窗口）---
local row1 year > 1800 & year <= 1850
local row2 year > 1775 & year <= 1875
local row3 year > 1750 & year <= 1900
local row4 year > 1711 & year <= 1911
local row5 year <= .

* --- 县级层面：5×5 网格 ---
forvalues r = 1/5 {
    forvalues c = 1/5 {
        di " `col`c'' & `row`r''"
        reghdfe $Y $X if `col`c'' & `row`r'', absorb(i.OBJECTID i.year ///
            c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
        est store r`r'c`c'

        preserve
            hdfe $Y $X if `col`c'' & `row`r'', clear absorb(i.OBJECTID i.year ///
                c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) ///
                tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
            ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) ///
                panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
            matrix V_spat = vecdiag(e(V))
            matmap V_spat SE_spat, m(sqrt(@))
            estadd matrix sesp = SE_spat : r`r'c`c'
        restore
    }
}

* --- 府级层面：collapse 到府后重新估计 ---
global Yp ashonset_pop1600
forvalues r = 1/5 {
    sort prefid year
    collapse (sum) onset_all AREA (first) provid reform (max) alongcanal ///
        interaction1 area_pref popden* cntypop* (mean) Y_COORD X_COORD, ///
        by(prefid year)
    gen pop1600 = popden1600 * AREA / 1000000
    gen pop1820 = popden1820 * AREA / 1000000
    gen pop     = popden     * AREA / 1000000
    su AREA area_pref
    gen ashonset_pop1600  = asinh(onset_all / pop1600)
    gen ashonset_pop1820  = asinh(onset_all / pop1820)
    gen ashonset_pop      = asinh(onset_all / pop)
    by prefid: egen prerebels = total((onset_all / (pop1600)) * (reform == 0))
    gen ashprerebels = asinh(prerebels)
    di "`col6' & `row`r''"
    reghdfe $Yp $X if `row`r'', absorb(i.prefid i.year c.ashprerebels#i.year ///
        i.provid##i.year) cluster(prefid)
    est store r`r'c6

    preserve
        hdfe $Yp $X if `row`r'', clear absorb(i.prefid i.year ///
            c.ashprerebels#i.year i.provid##i.year) tol(0.001) ///
            keepvars(prefid year Y_COORD X_COORD)
        ols_spatial_HAC $Yp $X, lat(Y_COORD) lon(X_COORD) time(year) ///
            panel(prefid) distcutoff(500) lagcutoff(262) disp star
        matrix V_spat = vecdiag(e(V))
        matmap V_spat SE_spat, m(sqrt(@))
        estadd matrix sesp = SE_spat : r`r'c6
    restore
}

label variable interaction "Along Canal $ \times $ Post"
estfe r*c*

restore


/*===========================================================================
 * Table A3. 替代被解释变量：不同标准化方式的稳健性
 *
 * 五种Y：
 *   ashonset_cntypop1820  — 按1820年人口标准化
 *   ashonset_cntypop      — 按逐年插值人口标准化
 *   ashonset_km2          — 按土地面积标准化
 *   ashonset_num          — 不标准化（原始次数）
 *   onset_cntypop1600     — 线性（不用asinh）
 * 每种跑四列递进回归 + Conley SE
 *===========================================================================*/
preserve

gen onset_cntypop1600 = onset_all / (cntypop1600 / 1000000)
gen ashonset_num = asinh(onset_all)
global Ys ashonset_cntypop1820 ashonset_cntypop ashonset_km2 ashonset_num ///
    onset_cntypop1600

foreach Y of varlist $Ys {
    * --- 四列递进回归 ---
    reghdfe `Y' $X, absorb(i.OBJECTID i.year) cluster(OBJECTID)
    eststo `Y'_1
    qui tab OBJECTID if e(sample)
    scalar groups = r(r)
    qui su $Y if e(sample)
    scalar ymean = r(mean)
    estadd scalar depavg = ymean : `Y'_1
    estadd scalar N_g    = groups : `Y'_1

    reghdfe `Y' $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year) cluster(OBJECTID)
    eststo `Y'_2
    qui tab OBJECTID if e(sample)
    scalar groups = r(r)
    qui su $Y if e(sample)
    scalar ymean = r(mean)
    estadd scalar depavg = ymean : `Y'_2
    estadd scalar N_g    = groups : `Y'_2

    reghdfe `Y' $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year ///
        i.provid#i.year) cluster(OBJECTID)
    eststo `Y'_3
    qui tab OBJECTID if e(sample)
    scalar groups = r(r)
    qui su $Y if e(sample)
    scalar ymean = r(mean)
    estadd scalar depavg = ymean : `Y'_3
    estadd scalar N_g    = groups : `Y'_3

    reghdfe `Y' $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year ///
        i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
    eststo `Y'_4
    qui tab OBJECTID if e(sample)
    scalar groups = r(r)
    qui su $Y if e(sample)
    scalar ymean = r(mean)
    estadd scalar depavg = ymean : `Y'_4
    estadd scalar N_g    = groups : `Y'_4

    estfe `Y'_1 `Y'_2 `Y'_3 `Y'_4

    * --- Conley SE（四列）---
    forvalues c = 1/4 {
        if `c' == 1 local fes i.OBJECTID i.year
        if `c' == 2 local fes i.OBJECTID i.year c.ashprerebels#i.year
        if `c' == 3 local fes i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year
        if `c' == 4 local fes i.OBJECTID i.year c.ashprerebels#i.year ///
            i.provid#i.year i.prefid#c.year
        preserve
            hdfe `Y' $X, clear absorb(`fes') tol(0.001) ///
                keepvars(OBJECTID year Y_COORD X_COORD)
            ols_spatial_HAC `Y' $X, lat(Y_COORD) lon(X_COORD) time(year) ///
                panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
            matrix V_spat = vecdiag(e(V))
            matmap V_spat SE_spat, m(sqrt(@))
            estadd matrix sesp = SE_spat : `Y'_`c'
        restore
    }
}

restore


/*===========================================================================
 * Table A4. 机制一：国家控制力
 *
 * 三重交互检验：
 *   - 运河密度 × 驻军数 × 改革后（预期：驻军多的县效应更弱）
 *   - 运河密度 × 府治所在地 × 改革后（预期：行政中心效应更弱）
 * 外加攻防类型区分（attack vs runinto）
 *===========================================================================*/
preserve

gen ashdensity = asinh(canal_den)
global canal ashdensity
gen ashattack_cntypop1600   = asinh(attack  / (cntypop1600 / 1000000))
gen ashretreat_cntypop1600  = asinh(runinto / (cntypop1600 / 1000000))
gen canal_after = ${canal} * reform
label variable canal_after "Canal $ \times $ Post"

* --- 驻军三重交互 ---
gen triplesoldier = ${canal} * asinh(soldier / 100) * reform
gen soldier_after = asinh(soldier / 100) * reform
label variable soldier_after  "Soldiers $\times$ Post"
label variable triplesoldier  "Soldiers $\times$ Canal $\times$ Post"

reghdfe $Y canal_after soldier_after triplesoldier, absorb(i.OBJECTID i.year ///
    c.ashprerebels#i.year i.provid#i.year) cluster(OBJECTID)
eststo vul1
su onset_all if e(sample)
scalar y2mean = r(mean)
qui tab OBJECTID if e(sample)
scalar groups = r(r)
estadd scalar depavg = y2mean : vul1
estadd scalar N_g    = groups : vul1

preserve
    hdfe $Y canal_after soldier_after triplesoldier, clear absorb(i.OBJECTID ///
        i.year c.ashprerebels#i.year i.provid#i.year) tol(0.001) ///
        keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC $Y canal_after soldier_after triplesoldier, lat(Y_COORD) ///
        lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
    matrix V_spat = vecdiag(e(V))
    matmap V_spat SE_spat, m(sqrt(@))
    estadd matrix sesp = SE_spat : vul1
restore

* --- 府治所在地三重交互 ---
gen triplecapital = ${canal} * pref_capital * reform
gen capital_after = pref_capital * reform
label variable capital_after  "Prefecture Capital $\times$ Post"
label variable triplecapital  "Prefecture Capital $\times$ Canal $\times$ Post"

preserve
    reghdfe $Y canal_after capital_after triplecapital, absorb(i.OBJECTID i.year ///
        c.ashprerebels#i.year i.provid#i.year) cluster(OBJECTID)
    eststo vul2
    su onset_all if e(sample)
    scalar y2mean = r(mean)
    qui tab OBJECTID if e(sample)
    scalar groups = r(r)
    estadd scalar depavg = y2mean : vul2
    estadd scalar N_g    = groups : vul2
restore

preserve
    hdfe $Y canal_after capital_after triplecapital, clear absorb(i.OBJECTID ///
        i.year c.ashprerebels#i.year i.provid#i.year) tol(0.001) ///
        keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC $Y canal_after capital_after triplecapital, lat(Y_COORD) ///
        lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
    matrix V_spat = vecdiag(e(V))
    matmap V_spat SE_spat, m(sqrt(@))
    estadd matrix sesp = SE_spat : vul2
restore

* --- 攻击型 vs 退守型案件 ---
reghdfe ashattack_cntypop1600 canal_after, absorb(i.OBJECTID i.year ///
    c.ashprerebels#i.year i.provid#i.year) cluster(OBJECTID)
eststo vul3
su attack if e(sample)
scalar y2mean = r(mean)
qui tab OBJECTID if e(sample)
scalar groups = r(r)
estadd scalar depavg = y2mean : vul3
estadd scalar N_g    = groups : vul3

preserve
    hdfe ashattack_cntypop1600 canal_after, clear absorb(i.OBJECTID i.year ///
        c.ashprerebels#i.year i.provid#i.year) tol(0.001) ///
        keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC ashattack_cntypop1600 canal_after, lat(Y_COORD) ///
        lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
    matrix V_spat = vecdiag(e(V))
    matmap V_spat SE_spat, m(sqrt(@))
    estadd matrix sesp = SE_spat : vul3
restore

reghdfe ashretreat_cntypop1600 canal_after, absorb(i.OBJECTID i.year ///
    c.ashprerebels#i.year i.provid#i.year) cluster(OBJECTID)
eststo vul4
su runinto if e(sample)
scalar y2mean = r(mean)
qui tab OBJECTID if e(sample)
scalar groups = r(r)
estadd scalar depavg = y2mean : vul4
estadd scalar N_g    = groups : vul4

preserve
    hdfe ashretreat_cntypop1600 canal_after, clear absorb(i.OBJECTID i.year ///
        c.ashprerebels#i.year i.provid#i.year) tol(0.001) ///
        keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC ashretreat_cntypop1600 canal_after, lat(Y_COORD) ///
        lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
    matrix V_spat = vecdiag(e(V))
    matmap V_spat SE_spat, m(sqrt(@))
    estadd matrix sesp = SE_spat : vul4
restore

estfe vul1 vul2 vul3 vul4

restore


/*===========================================================================
 * Table A5. 机制二：贸易通道
 *
 * 检验：
 *   1. 运河废弃后沿线城镇数量是否下降（DID on town count）
 *   2. 驿道网络是否替代运河功能（驿道密度三重交互）
 *   3. 气候冲击时运河县粮价上涨是否更大（温度异常三重交互）
 *===========================================================================*/
preserve

gen ashdensity    = asinh(canal_den)
gen ashcourierden = asinh(courier_length / (AREA / 10000))
global canal   ashdensity
global courier ashcourierden

* --- 城镇数量变化（1820→1911 两期面板DID）---
preserve
    duplicates drop OBJECTID, force
    drop year
    rename town1820_r10canal  canalside1820
    rename town1911_r10canal  canalside1911
    rename town1820_r10courier courierside1820
    rename town1911_r10courier courierside1911
    reshape long town canalside courierside, i(OBJECTID) j(year)
    gen canal_after = ${canal} * (year == 1911)
    replace town = ln(town)
    label variable town        "Town Number (ln)"
    label variable canal_after "Canal $\times$ Post"

    reghdfe town canal_after, absorb(i.OBJECTID i.year) cluster(OBJECTID)
    eststo trade1
    su town if e(sample)
    scalar y2mean = r(mean)
    qui tab OBJECTID if e(sample)
    scalar groups = r(r)
    estadd scalar depavg = y2mean : trade1
    estadd scalar N_g    = groups : trade1

    hdfe town canal_after, clear absorb(i.OBJECTID i.year) tol(0.001) ///
        keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC town canal_after, lat(Y_COORD) lon(X_COORD) time(year) ///
        panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
    matrix V_spat = vecdiag(e(V))
    matmap V_spat SE_spat, m(sqrt(@))
    estadd matrix sesp = SE_spat : trade1
restore

* --- 驿道替代效应 ---
gen canal_after = ${canal} * reform
label variable canal_after "Canal $ \times $ Post"
gen triplecourier = ${canal} * reform * ${courier}
gen courier_after = reform * ${courier}
label variable triplecourier "Canal $ \times $ Courier $ \times $ Post"
label variable courier_after  "Courier $ \times $ Post"

reghdfe $Y canal_after courier_after triplecourier, absorb(i.OBJECTID i.year) ///
    cluster(OBJECTID)
eststo trade2
su $Y if e(sample)
scalar y2mean = r(mean)
qui tab OBJECTID if e(sample)
scalar groups = r(r)
estadd scalar depavg = y2mean : trade2
estadd scalar N_g    = groups : trade2

preserve
    hdfe $Y canal_after courier_after triplecourier, clear absorb(i.OBJECTID ///
        i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC $Y canal_after courier_after triplecourier, lat(Y_COORD) ///
        lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
    matrix V_spat = vecdiag(e(V))
    matmap V_spat SE_spat, m(sqrt(@))
    estadd matrix sesp = SE_spat : trade2
restore

* --- 气候冲击 × 运河依赖（粮价渠道）---
gen tripledisaster = ${canal} * reform * disaster
gen disaster_canal = ${canal} * disaster
label variable tripledisaster "Canal $ \times $ Temperature Anomaly $ \times $ Post"
label variable disaster_canal  "Canal $ \times $ Temperature Anomaly"

reghdfe $Y canal_after disaster disaster_canal disaster_after tripledisaster, ///
    absorb(i.OBJECTID i.year) cluster(OBJECTID)
eststo trade3
su $Y if e(sample)
scalar y2mean = r(mean)
qui tab OBJECTID if e(sample)
scalar groups = r(r)
estadd scalar depavg = y2mean : trade3
estadd scalar N_g    = groups : trade3

preserve
    hdfe $Y canal_after disaster disaster_canal disaster_after tripledisaster, ///
        clear absorb(i.OBJECTID i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC $Y canal_after disaster disaster_canal disaster_after ///
        tripledisaster, lat(Y_COORD) lon(X_COORD) time(year) ///
        panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
    matrix V_spat = vecdiag(e(V))
    matmap V_spat SE_spat, m(sqrt(@))
    estadd matrix sesp = SE_spat : trade3
restore

estfe trade1 trade2 trade3

restore


/*===========================================================================
 * Table A6. 机制三：农业生产率（水稻 vs 小麦适宜性）
 *
 * 检验：水稻适宜区的运河效应 > 小麦适宜区？
 * 逻辑：水稻经济商品化程度更高，更依赖运河贸易
 *===========================================================================*/
preserve

gen ashdensity = asinh(canal_den)
global canal ashdensity
gen triplerice  = ${canal} * reform * suitable_rice_good
gen triplewheat = ${canal} * reform * suitable_wheat_good
gen canal_after = ${canal} * reform
label variable triplerice   "Canal $ \times $ Rice suitability $ \times $ Post"
label variable triplewheat  "Canal $ \times $ Wheat suitability $ \times $ Post"
label variable rice_after   "Rice suitability $ \times $ Post"
label variable wheat_after  "Wheat suitability $ \times $ Post"
label variable canal_after  "Canal $ \times $ Post"
global X_rice  canal_after rice_after  triplerice
global X_wheat canal_after wheat_after triplewheat

* --- 第一步：运河废弃对粮价的影响 ---
reghdfe mp canal_after, absorb(i.OBJECTID i.year) cluster(OBJECTID)
eststo agri1
su mp if e(sample)
scalar y2mean = r(mean)
qui tab OBJECTID if e(sample)
scalar groups = r(r)
estadd scalar depavg = y2mean : agri1
estadd scalar N_g    = groups : agri1

preserve
    hdfe mp canal_after, clear absorb(i.OBJECTID i.year) tol(0.001) ///
        keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC mp canal_after, lat(Y_COORD) lon(X_COORD) time(year) ///
        panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
    matrix V_spat = vecdiag(e(V))
    matmap V_spat SE_spat, m(sqrt(@))
    estadd matrix sesp = SE_spat : agri1
restore

* --- 第二步：水稻适宜性的异质性 ---
reghdfe $Y $X_rice, absorb(i.OBJECTID i.year) cluster(OBJECTID)
eststo agri2
su $Y if e(sample)
scalar y2mean = r(mean)
qui tab OBJECTID if e(sample)
scalar groups = r(r)
estadd scalar depavg = y2mean : agri2
estadd scalar N_g    = groups : agri2

preserve
    hdfe $Y $X_rice, clear absorb(i.OBJECTID i.year) tol(0.001) ///
        keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC $Y $X_rice, lat(Y_COORD) lon(X_COORD) time(year) ///
        panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
    matrix V_spat = vecdiag(e(V))
    matmap V_spat SE_spat, m(sqrt(@))
    estadd matrix sesp = SE_spat : agri2
restore

* --- 第三步：小麦适宜性的异质性 ---
reghdfe $Y $X_wheat, absorb(i.OBJECTID i.year) cluster(OBJECTID)
eststo agri3
su $Y if e(sample)
scalar y2mean = r(mean)
qui tab OBJECTID if e(sample)
scalar groups = r(r)
estadd scalar depavg = y2mean : agri3
estadd scalar N_g    = groups : agri3

preserve
    hdfe $Y $X_wheat, clear absorb(i.OBJECTID i.year) tol(0.001) ///
        keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC $Y $X_wheat, lat(Y_COORD) lon(X_COORD) time(year) ///
        panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
    matrix V_spat = vecdiag(e(V))
    matmap V_spat SE_spat, m(sqrt(@))
    estadd matrix sesp = SE_spat : agri3
restore

estfe agri1 agri2 agri3

restore


/*===========================================================================
 * Table A7. 青帮与运河废弃
 *
 * 截面回归：运河沿线县的青帮高级成员数是否更高？
 * 控制府级固定效应，robust标准误
 *===========================================================================*/
preserve

collapse (mean) green_senior alongcanal prefid provid, by(OBJECTID)
global canal alongcanal
xi: reg green_senior $canal i.prefid, robust
eststo pst1
su green_senior if e(sample)
scalar ymean = r(mean)
estadd scalar depavg = ymean : pst1

restore


/*===========================================================================
 * END OF canal_analysis.do
 *
 * 所有图表均已通过 graph export 导出为 PNG 文件，保存在当前工作目录下。
 *
 * 如需导出 LaTeX 表格，可在上述各表中追加：
 *   esttab est1 est2 est3 est4 est5 using "table3.tex", replace ///
 *       keep(interaction1) ${stars} se stats(depavg N_g N, ///
 *       labels("Mean of depvar" "Number of groups" "Observations"))
 *
 * 所有结果应与 Cao & Chen (2022) Table 3-7, Figure 2, 4, A1-A7 一致。
 *===========================================================================*/
