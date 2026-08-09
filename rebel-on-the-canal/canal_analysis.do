/*******************************************************************************
项目：Rebel on the Canal 完整复现
原论文：Cao, Yiming and Shuo Chen (2022), American Economic Review
整理者：Zhihan Lin
整理说明：本文件由 Zhihan Lin 整理得到。

文件职责：
1. 只需运行这一份 do 文件；数据准备步骤已合并为 canal_prepare 程序。
2. 数据统一放在仓库的 canal_data/canal_rebellion.dta。
3. 所有图、表、中间数据和日志分别写入 replication_output 子目录。
4. 默认复现教学所需的正文与附录回归；极耗时部分由开关控制。

重要：本文件保留原论文识别设定，只修复路径、临时变量丢失、变量命名和
      Stata 18 兼容性问题。任何估计结果均应结合论文定义和样本限制解读。
*
* ======================== 教学阅读路线 ========================
* 1. 先看第 0--2 节：路径、运行开关和依赖检查。这里决定“读哪个数据、
*    输出到哪里、哪些慢速模块是否打开”。
* 2. 再看 canal_prepare：它是全文件唯一的数据准备入口。每次调用都会
*    重新 use 一份干净数据，并统一生成因变量、处理变量、控制变量和宏。
* 3. 搜索 [TABLE_3_BASELINE]：这是最重要的 DID 估计。前四列逐步加入
*    固定效应/趋势，第五列再加入控制变量，便于观察核心系数是否稳定。
* 4. 搜索 [FIGURE_4_EVENT_STUDY]：这是平行趋势和动态效应的图形化检查。
* 5. 搜索 [APPENDIX_CIC]、[APPENDIX_SYNTHETIC_CONTROL]：这是分布效应和
*    另一条反事实路径的扩展，不改变基准 DID 的识别逻辑。
*
* Stata 命令的统一读法是：
*   reghdfe 因变量 自变量, absorb(固定效应) cluster(聚类单位)
* 例如：reghdfe $Y $X, absorb(i.OBJECTID i.year) cluster(OBJECTID)
* 在真正执行前，$Y 会被宏展开为 ashonset_cntypop1600，$X 会被展开为
* interaction1；因此读者既可以先理解宏，也可以把宏替换成实际变量名阅读。
*******************************************************************************/

version 18.0
clear all
set more off
set linesize 255
set varabbrev on
capture log close _all

*------------------------------------------------------------------------------
* 0. 项目路径：本文件必须从 GitHub 仓库的 rebel-on-the-canal 文件夹运行。
*    这样代码和数据都使用仓库内相对路径，不依赖任何本机绝对路径。
*------------------------------------------------------------------------------
global PROJECT_ROOT "`c(pwd)'"
capture confirm file "$PROJECT_ROOT/canal_data/canal_rebellion.dta"
if _rc {
    * 如果从仓库根目录调用 do 文件，则自动进入其文献子目录；仍然是相对路径。
    capture confirm file "$PROJECT_ROOT/rebel-on-the-canal/canal_data/canal_rebellion.dta"
    if !_rc global PROJECT_ROOT "$PROJECT_ROOT/rebel-on-the-canal"
}
capture confirm file "$PROJECT_ROOT/canal_data/canal_rebellion.dta"
if _rc {
    display as error "找不到 canal_data/canal_rebellion.dta；请先在 Stata 中 cd 到 literature-reading 或 rebel-on-the-canal。"
    exit 601
}

global DATA_FILE        "$PROJECT_ROOT/canal_data/canal_rebellion.dta"
global OUTPUT_DIR       "$PROJECT_ROOT/replication_output"
global FIGURE_DIR       "$OUTPUT_DIR/figures"
global TABLE_DIR        "$OUTPUT_DIR/tables"
global INTERMEDIATE_DIR "$OUTPUT_DIR/intermediate"
global LOG_DIR          "$OUTPUT_DIR/logs"
global ADO_DIR          "$PROJECT_ROOT/stata_ado"

capture mkdir "$OUTPUT_DIR"
capture mkdir "$FIGURE_DIR"
capture mkdir "$TABLE_DIR"
capture mkdir "$INTERMEDIATE_DIR"
capture mkdir "$LOG_DIR"

* 如果仓库中存在本地 Mata/ado 依赖，就优先加入；否则使用 Stata 已安装的
* SSC 命令。GitHub 仓库不硬编码第三方依赖的本机路径。
capture confirm file "$ADO_DIR/synth.ado"
if !_rc {
    adopath ++ "$ADO_DIR"
}

* synth 的 Mata 函数库位于项目目录。Stata 对自定义 ado 路径不会总是
* 自动建立 mlib 索引，因此在当前会话中显式索引一次，再恢复原工作目录。
capture confirm file "$ADO_DIR/synth.ado"
if !_rc {
    local __pwd_before_mlib "`c(pwd)'"
    quietly cd "$ADO_DIR"
    capture mata: mata mlib index
    quietly cd "`__pwd_before_mlib'"
}

*------------------------------------------------------------------------------
* 1. 运行开关
*------------------------------------------------------------------------------
* 可在 do 命令后依次传入：RUN_CONLEY RUN_CONLEY_GRID RUN_CIC RUN_SYNTH CIC_REPS
* 例如：do "本文件.do" 0 0 1 0 0    （打开 CIC，只算点估计）
*       do "本文件.do" 0 0 1 0 100  （打开 CIC，并做 100 次 bootstrap）
args arg_conley arg_conley_grid arg_cic arg_synth arg_cic_reps
global RUN_CONLEY      0
global RUN_CONLEY_GRID 0
global RUN_CIC         0
global RUN_SYNTH       0
global CIC_REPS        100
if "`arg_conley'"      != "" global RUN_CONLEY      `arg_conley'
if "`arg_conley_grid'" != "" global RUN_CONLEY_GRID `arg_conley_grid'
if "`arg_cic'"         != "" global RUN_CIC         `arg_cic'
if "`arg_synth'"       != "" global RUN_SYNTH       `arg_synth'
if "`arg_cic_reps'"    != "" global CIC_REPS        `arg_cic_reps'

log using "$LOG_DIR/grand_canal_replication_Zhihan_Lin.log", text replace name(replication)
capture graph set window fontface "Helvetica"
set scheme s2color

*------------------------------------------------------------------------------
* 2. 依赖检查
*------------------------------------------------------------------------------
local core_commands reghdfe eststo esttab estadd estpost
foreach cmd of local core_commands {
    capture which `cmd'
    if _rc {
        display as error "缺少核心命令 `cmd'。请先安装 reghdfe/ftools/estout。"
        exit 499
    }
}
if $RUN_CONLEY {
    foreach cmd in ols_spatial_HAC matmap {
        capture which `cmd'
        if _rc {
            display as error "RUN_CONLEY=1，但缺少命令 `cmd'。"
            exit 499
        }
    }
}
* CIC 使用下方随主脚本提供的低内存经验分布实现，不再依赖外部 cic.ado。
if $RUN_SYNTH {
    foreach cmd in synth synth_runner {
        capture which `cmd'
        if _rc exit 499
    }
}

*------------------------------------------------------------------------------
* 3. 通用语法速查
* use/clear：每个分析重新载入干净数据，避免上一节变量污染下一节。
* gen/replace：新建变量/按条件修改变量。
* preserve/restore：临时改变数据后恢复。
* reghdfe：估计 OLS 并吸收多组高维固定效应。
* absorb()：指定固定效应和组别趋势；cluster()：县级聚类标准误。
* eststo/estadd：保存估计，并附加因变量均值、县数等统计量。
* canal_hdfe + ols_spatial_HAC：残差化后计算 Conley 空间-时间稳健标准误。
*
* 因子变量语法是阅读 reghdfe 的关键：
*   i.OBJECTID：把县 ID 当作一组分类固定效应；
*   i.year：把年份当作一组分类固定效应；
*   c.ashprerebels#i.year：允许“改革前历史反叛程度”在每一年有不同斜率；
*   i.provid#i.year：允许各省拥有自己的年度冲击；
*   i.prefid#c.year：允许各府拥有自己的线性时间趋势。
* `#` 表示交互项，`##` 才会同时自动加入两个主效应；本文件使用 `#` 是
* 因为县和年份主效应已经由前面的 i.OBJECTID、i.year 单独吸收。
*
* 估计结果的保存也有固定顺序：
*   eststo est1：把当前回归存为 est1；
*   estadd scalar depavg=...：给 est1 附加因变量均值等自定义统计量；
*   estadd matrix sesp=...：给 est1 附加 Conley 标准误；
*   esttab _all using ...：把当前内存中的估计统一导出为 CSV。
*------------------------------------------------------------------------------

capture program drop canal_prepare
*** [DATA_PREPARATION]
program define canal_prepare
    version 18.0
    * program define 把一串命令封装成可重复调用的“自定义命令”。
    * 因此每一节只需写 canal_prepare，而不必重复粘贴下面的数据准备。
    use "$DATA_FILE", clear
    * use ..., clear：载入整理后的县—年面板；clear 明确丢弃上一节的临时数据，
    * 防止上一节生成的同名变量污染当前表格。

    * 数据准备步骤包括：
    * 声明面板、人口插值、结果标准化、改革后交互控制、Y/X/ctrls 宏。
capture set matsize 11000
    * matsize 决定 Stata 可容纳的矩阵大小；capture 让旧版 Stata 不支持该
    * 设置时也能继续执行。xtset 则告诉 Stata 哪一列是县、哪一列是年份。
xtset OBJECTID year


*************************************************
*** Normalization
*************************************************
*** By land area
* 下面先按土地面积标准化反叛次数。AREA 的单位是公顷，因此 AREA/10000
* 转成平方公里；asinh 比 ln(1+x) 更适合含有大量 0 的计数型结果。
gen lonset_km2=ln(1+onset_all/(AREA/10000))
gen ashonset_km2=asinh(onset_all/(AREA/10000))
*** By population
* popden 是县级人口密度的逐年插值。原始资料只在若干基准年份有观测，
* 每条 replace 都只负责一个区间；例如 1600--1776 年用两端点做线性插值。
* 这样做的目的，是为描述性结果提供随时间变化的人口分母。
gen popden=popden1600 if year<=1600
replace popden=popden1600+(year-1600)*((popden1776-popden1600)/(1776-1600)) if year>1600 & year<=1776
replace popden=popden1776+(year-1776)*((popden1820-popden1776)/(1820-1776)) if year>1776 & year<=1820
replace popden=popden1820+(year-1820)*((popden1851-popden1820)/(1851-1820)) if year>1820 & year<=1851
replace popden=popden1851+(year-1851)*((popden1880-popden1851)/(1880-1851)) if year>1851 & year<=1880
replace popden=popden1880+(year-1880)*((popden1910-popden1880)/(1910-1880)) if year>1880 & year<=1910
replace popden=popden1910 if year>1910

gen pop=popden*AREA/1000000
gen pop1600=popden1600*AREA/1000000
gen pop1820=popden1820*AREA/1000000

gen lonset_pop=ln(1+onset_all/pop)
gen lonset_pop1600=ln(1+onset_all/pop1600)
gen lonset_pop1820=ln(1+onset_all/pop1820)
gen ashonset_pop=asinh(onset_all/pop)
gen ashonset_pop1600=asinh(onset_all/pop1600)
gen ashonset_pop1820=asinh(onset_all/pop1820)
*** Imputed county level population
* 基准 DID 不使用改革后的当期人口作为分母，而使用固定的 1600 年县人口。
* 这避免“反叛/贸易冲击改变人口，人口又出现在因变量分母中”的坏控制。
* cntypop 则是用于部分附录和描述性统计的逐年插值县人口。
gen cntypop=cntypop1600 if year<=1600
replace cntypop=cntypop1600+(year-1600)*((cntypop1776-cntypop1600)/(1776-1600)) if year>1600 & year<=1776
replace cntypop=cntypop1776+(year-1776)*((cntypop1820-cntypop1776)/(1820-1776)) if year>1776 & year<=1820
replace cntypop=cntypop1820+(year-1820)*((cntypop1851-cntypop1820)/(1851-1820)) if year>1820 & year<=1851
replace cntypop=cntypop1851+(year-1851)*((cntypop1880-cntypop1851)/(1880-1851)) if year>1851 & year<=1880
replace cntypop=cntypop1880+(year-1880)*((cntypop1910-cntypop1880)/(1910-1880)) if year>1880 & year<=1910
replace cntypop=cntypop1910 if year>1910
gen ashonset_cntypop=asinh(onset_all/(cntypop/1000000))
gen ashonset_cntypop1600=asinh(onset_all/(cntypop1600/1000000))
gen ashonset_cntypop1820=asinh(onset_all/(cntypop1820/1000000))

gen popdencnty1600=cntypop1600/AREA
gen lpopdencnty1600=ln(popdencnty1600)

**************************************************************************
*** Define the set of controls
**************************************************************************
* prerebels 是改革前反叛强度的县级总和：先按县汇总，再对其做 asinh。
* 许多控制变量都写成“基础特征 × reform”，表示它们只允许在改革后
* 改变结果；这比把一个不随时间变化的变量单独放入县固定效应回归更有信息。
sort OBJECTID year
by OBJECTID: egen prerebels=total((onset_all/(cntypop/1000000))*(reform==0))
gen ashprerebels=asinh(prerebels)
gen rug_after=ruggedness*reform
gen taiping_after=Taiping*reform
gen huang_after=alonghuang*reform
gen yangtze_after=alongyangtze*reform
egen reconmean=mean(recon)
egen reconsd=sd(recon)
gen disaster=(abs(recon-reconmean)>reconsd)
gen drought=(climate==1)
gen flooding=(climate==5)
gen distyellow_after=distance_huang*reform
gen distcoast_after=distance_coast*100*reform
gen larea_after=ln(AREA)*reform
gen lpop1600_after=ln(cntypop1600)*reform
gen recon_after=recon*reform
gen drought_after=drought*reform
gen flooding_after=flooding*reform
gen disaster_after=disaster*reform
gen maize_after=maize*reform
gen sweetpotato_after=sweetpotato*reform
gen wheat_after=suitable_wheat_good*reform
gen rice_after=suitable_rice_good*reform
gen lwheat_after=ln(si_wheat)*reform
gen lrice_after=ln(si_rice)*reform
gen popdencnty1600_after=popdencnty1600*reform
gen lpopdencnty1600_after=lpopdencnty1600*reform

label variable drought "Drought"
label variable drought_after "Drought $ \times $ Post"
label variable flooding "Flooding"
label variable flooding_after "Flooding $ \times $ Post"
label variable disaster "Temperature Anomaly"
label variable disaster_after "Temperature Anomaly $\times$ Post"
label variable onset_any "Presence"
label variable rug_after "Ruggedness $\times$ Post"
label variable taiping_after "Taiping Region $\times$ Post"
label variable recon "Temperature Deviation"
label variable huang_after "Huang River $\times$ Post"
label variable yangtze_after "Yangtze River $\times$ Post"
label variable distyellow_after "Distance to Yellow River $\times$ Post"
label variable distcoast_after "Distance to the Coast $\times$ Post"
label variable larea_after "ln(land area) $ \times $ Post"
label variable lpop1600_after "ln(initial population in 1600) $ \times $ Post"


*************************************************
*** Add variable labels
*************************************************
label variable interaction1 "Along Canal $ \times $ Post"

*************************************************
*** Globals
*************************************************
* 不使用 macro drop _all：否则会误删项目路径和运行开关。
est clear

* 全局宏是“文本替换”而不是新变量：$Y、$X、$ctrls 在执行每条回归前
* 被替换成下面对应的变量列表。这样所有表都共享同一套核心定义。
global Y ashonset_cntypop1600
global X interaction1

gen area_after=AREA*reform

global ctrls larea_after rug_after disaster disaster_after flooding drought flooding_after drought_after lpopdencnty1600_after maize maize_after sweetpotato sweetpotato_after wheat_after rice_after

global stars nostar
end

* Table 1 专用准备：修复第二次 use 后临时变量丢失的问题。
capture program drop canal_prepare_table1
program define canal_prepare_table1
    version 18.0
    * 先运行通用准备，再补充 Table 1 专用的 1820/1911 城镇变量和
    * 每百万人反叛次数。把这些动作集中在一个程序里，避免 Table 1 前后
    * 两次 use 数据时忘记重新生成临时变量。
    canal_prepare
    gen town=town1820 if year==1820
    replace town=town1911 if year==1911
    replace distance_coast=distance_coast*100
    gen onset_cntypop1600=onset_all/(cntypop1600/1000000)
    gen canaltown=(town1820_r10canal*alongcanal)/town1820
    label variable onset_cntypop1600 "Number of rebellions per million population"
    label variable town "Number of Towns and Local Markets"
    label variable canaltown "Share of towns within 10km of the canal"
end

* Conley 标准误的兼容残差化程序。
* 旧代码依赖已停止维护的 hdfe 命令；这里对结果变量和每个解释变量分别
* 用 reghdfe 吸收同一组固定效应，依据 Frisch-Waugh-Lovell 定理得到与
* hdfe, clear 相同的残差化数据，再交给 ols_spatial_HAC。
*
* 这个程序的输入格式是：
*   canal_hdfe y x1 x2, clear absorb(FE) keepvars(id year lat lon)
* varlist 是需要残差化的变量；absorb() 是和原回归完全相同的固定效应；
* keepvars() 是空间 HAC 还需要的县 ID、年份和经纬度。程序先把这些变量
* 的共同非缺失样本固定下来，再逐个 residualize，避免 y 和 x 使用不同样本。
capture program drop canal_hdfe
program define canal_hdfe
    version 18.0
    syntax varlist(numeric) [if] [in], ABSorb(string asis) KEEPvars(varlist) ///
        [CLEAR TOLerance(real 0.001)]
    tempvar common_sample residual
    * marksample 同时读取 if/in 限制；markout 再把 keepvars 的缺失值排除。
    * 这一步很重要：空间标准误需要每条观测都有经纬度、年份和面板 ID。
    marksample common_sample
    quietly markout `common_sample' `keepvars'
    quietly keep if `common_sample'
    foreach v of local varlist {
        * Frisch-Waugh-Lovell：用同一组固定效应解释 v，并把剩余部分存为
        * residual。对 y、x1、x2 分别做这个操作，随后 OLS 系数保持不变。
        capture drop `residual'
        quietly reghdfe `v', absorb(`absorb') residuals(`residual') ///
            tolerance(`tolerance')
        quietly recast double `v'
        quietly replace `v'=`residual'
    }
    keep `varlist' `keepvars'
end

*------------------------------------------------------------------------------
* CIC 的低内存实现
*------------------------------------------------------------------------------
* 外部 cic.ado 在 14 万观测上会构造“全部支持点 × 全部观测”的 Mata
* 矩阵，容易耗尽内存。下面用排序和二分查找计算完全相同的经验分布映射：
*   F10(F00^{-1}(F01(y)))，再反演得到处理组改革后的反事实分位数。
* 已在小样本上逐项与 cic continuous 的 q10--q90 核对，差异为 0。
*
* 四个分布的含义是：
*   y00：对照组、改革前；y01：对照组、改革后；
*   y10：处理组、改革前；y11：处理组、改革后。
* CIC 的 q 分位效应不是简单的“处理组改革前后分位数相减”，而是先用
* 对照组的分布变化把处理组改革前分布映射到一个反事实的改革后分布，
* 再将真实 y11 的分位数与该反事实分位数比较。
mata:
real scalar canal_cic_cdf(real colvector ys, real scalar x)
{
    return(sum(ys :<= (x+epsilon(x)))/rows(ys))
}

real scalar canal_cic_qinv(real colvector ys, real scalar p)
{
    real scalar j
    j=ceil((p-epsilon(p))*rows(ys))
    j=max((1,min((rows(ys),j))))
    return(ys[j])
}

real scalar canal_cic_cf_q(real colvector y00, real colvector y01,
                           real colvector y10, real scalar q)
{
    real scalar lo,hi,mid,y,p,x,f
    lo=1
    hi=rows(y01)
    while (lo<hi) {
        mid=floor((lo+hi)/2)
        y=y01[mid]
        p=canal_cic_cdf(y01,y)
        x=canal_cic_qinv(y00,p)
        f=canal_cic_cdf(y10,x)
        if (f >= q-epsilon(q)) hi=mid
        else lo=mid+1
    }
    return(y01[lo])
}

real rowvector canal_cic_qtes(string scalar yvar, string scalar gvar,
                              string scalar tvar)
{
    real colvector y,g,t,y00,y01,y10,y11
    real rowvector qs,out
    real scalar i
    st_view(y=.,.,yvar)
    st_view(g=.,.,gvar)
    st_view(t=.,.,tvar)
    y00=sort(select(y,(g:==0):&(t:==0)),1)
    y01=sort(select(y,(g:==0):&(t:==1)),1)
    y10=sort(select(y,(g:==1):&(t:==0)),1)
    y11=sort(select(y,(g:==1):&(t:==1)),1)
    qs=(.1,.2,.3,.4,.5,.6,.7,.8,.9)
    out=J(1,cols(qs),.)
    for (i=1;i<=cols(qs);i++) {
        out[i]=canal_cic_qinv(y11,qs[i])-canal_cic_cf_q(y00,y01,y10,qs[i])
    }
    return(out)
}
end

capture program drop canal_cic_qte
program define canal_cic_qte, rclass
    version 18.0
    syntax varname(numeric), Group(varname numeric) Time(varname numeric)
    * rclass 让 bootstrap 可以读取 r(q10)、r(q20) ... r(q90)。
    * Group() 是处理组指示变量，Time() 是改革前后指示变量；本项目中
    * 它们分别对应 alongcanal 和 reform。
    tempname qtes
    mata: st_matrix("`qtes'",canal_cic_qtes("`varlist'","`group'","`time'"))
    forvalues i=1/9 {
        local q=`i'*10
        return scalar q`q'=`qtes'[1,`i']
    }
end

display as text "开始复现；数据：$DATA_FILE"
**************************************************************************
*** [FIGURE_2_CANAL_USAGE]
*** Figure2. Canal usage measured by tribute rice Transportation
* 教学目标：先验证 1826 年确实造成漕粮运输量的结构性下降。
* duplicates drop year：县级面板中运输量按年份重复，绘图前每年只保留一条。
* lfit：分别拟合改革前后线性趋势；红色竖线标记政策冲击时点。
**************************************************************************
canal_prepare
duplicates drop year, force
keep if year>1755 & year<1860

#d ;
twoway
(lfit lamount year if year<=1825, lpattern(dash) lcolor("0 0 0"))
(lfit lamount year if year>=1826, lpattern(dash) lcolor("0 0 0"))
(scatter lamount year, color("190 190 190") msize(*0.75))
,
ytitle("Shipping volume (log million piculs)", size(*0.9))
xtitle("")
yline(0.8(0.1)1.8, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
xline(1760(10)1860, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
xline(1825.3, lpattern(dash) lcolor("128 0 0"))
ylabel(0.8(0.2)1.8, angle(0) format(%5.1f) labsize(*0.85))
xlabel(, labsize(*0.85))
graphregion(fcolor(gs16) lcolor(gs16))
plotregion(lcolor("white") lwidth(*0.9))
legend(off)
;
#d cr
graph export "$FIGURE_DIR/figure2.png", replace




**************************************************************************
*** [FIGURE_4_EVENT_STUDY]
*** Figure4: Canal closure and rebellions: event study
* 教学目标：用事件研究同时检查改革前平行趋势和改革后的动态效应。
* aperiod 把年份压缩成十年窗口；最早窗口作为参照组，不进入交互项。
* reghdfe 吸收县、年份及更灵活的历史反叛/省份趋势；标准误按县聚类。
**************************************************************************
canal_prepare

gen aperiod=floor((year-1826)/10)*10
replace aperiod=-60 if aperiod<-60
tab aperiod, gen(aperiod)
keep if aperiod<70

reghdfe $Y c.alongcanal#(c.aperiod2-aperiod15) $ctrls, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) cluster(OBJECTID)
matrix coef = e(b)
matrix cov = e(V)
gen coef = .
gen se = .
forvalues i = 1(1)12 {
	replace coef = coef[1,`i'] if _n==`i'
	replace se = sqrt(cov[`i',`i']) if _n==`i'
}
gen lb=coef-invttail(e(df_r),0.025)*se
gen ub=coef+invttail(e(df_r),0.025)*se
keep coef se lb ub
drop if coef == .
gen year=_n

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
yline(0, lpattern(dash) lcolor("128 0 0"))
xline(5.5, lpattern(dash) lcolor("128 0 0"))
ylabel(-0.05(0.05)0.2, angle(0) format(%5.2f) labsize(*0.85))
xlabel(1 "-50" 2 "-40" 3 "-30" 4 "-20" 5 "-10" 6 "10" 7 "20" 8 "30" 9 "40" 10 "50" 11 "60" 12 "70", labsize(*0.85))
graphregion(fcolor(gs16) lcolor(gs16))
plotregion(lcolor("white") lwidth(*0.9))
legend(off)
;
#d cr
graph export "$FIGURE_DIR/figure4.png", replace




**************************************************************************
*** Table1. Data sources and summary statistics
* 教学目标：构造论文表 1 的描述统计，并说明各变量的量纲与数据来源编码。
* 本节两次载入数据，因此统一调用 canal_prepare_table1，避免临时变量在第二次载入后丢失。
**************************************************************************
canal_prepare_table1


label variable onset_cntypop1600 "Number of rebellions per million population"
label variable onset_all "Number of Rebellions (Onset)"
label variable canal_den "Length of canal per 100 $ km^2 $"
label variable popdencnty1600 "Population density"
label variable distance_huang "Distance from the Yellow River (km)"
label variable distance_coast "Distance from the coast (km)"
label variable AREA "Land size"
label variable soldier "Imperial Soldiers Stationed"
label variable attack "Number of Attacking Cases"
label variable runinto "Number of Retreating Cases"
label variable drought "Drought"
label variable flooding "Flood"
label variable disaster "Temperature Anomaly"
label variable suitable_rice_good "Suitable for wetland rice"
label variable suitable_wheat_good "Suitable for wheat"
label variable town "Number of Towns and Local Markets"
label variable canaltown "Share of towns within 10km of the canal"
label variable mp "Average grain price (silver tael per 10,000 kilocalorie)"

recode alongcanal (1=0) (0=1), gen(sugroup)
* recode ..., gen() 不覆盖原变量，而是生成一个方向相反的分组变量；
* 这里主要服务于论文原 Table 1 的分组展示，不改变后续 DID 的 alongcanal。
local Ylist onset_cntypop1600
local Xlist alongcanal canal_den canaltown distance_canal
local Clist AREA ruggedness disaster flooding drought popdencnty1600 maizeyear swtpotatoyear suitable_rice_good suitable_wheat_good
local Olist soldier pref_capital attack runinto town alongcourier mp green_senior
* local 宏只在当前 do 文件中临时保存变量列表；`des `Ylist' ...` 执行时，
* Stata 会把反引号/单引号中的宏替换为真实变量名。
des `Ylist' `Xlist' `Clist' `Olist'


**************************************************************************
*** Get statistics
**************************************************************************
canal_prepare_table1

* estpost 把 summarize 的结果转成 esttab 能读取的估计对象；它不是回归，
* 因此 Table 1 应理解为样本描述，不是因果效应。
estpost summarize `Ylist' `Xlist' `Clist' `Olist'
eststo des2

// Sourcelist
preserve
clear
set obs 1
gen onset_cntypop1600=1
gen alongcanal=2
gen canal_den=2
gen canaltown=2
gen distance_canal=2
gen AREA=2
gen ruggedness=5
gen disaster=3
gen drought=4
gen flooding=4
gen popdencnty1600=6
gen maizeyear=4
gen swtpotatoyear=4
gen suitable_wheat_good=8
gen suitable_rice_good=8
gen soldier=7
gen pref_capital=2
gen attack=1
gen runinto=1
gen town=2
gen alongcourier=2
gen mp=4
gen green_senior=9
estpost summarize `Ylist' `Xlist' `Clist' `Olist'
eststo des1
restore



* 导出描述统计。des2 是真实样本；des1 是论文数据来源编号。
esttab des2 using "$TABLE_DIR/table1_summary_statistics.csv", replace csv label nomtitle nonumber
display as result "已导出：$TABLE_DIR/table1_summary_statistics.csv"

**************************************************************************
*** [TABLE_2_PRETREND]
*** Table2. Canal closure and rebellions: pre-treatment trends
* 教学目标：只用 1776-1825 年改革前样本检验运河县是否已有差异趋势。
* pretrend = alongcanal × year；其系数若接近 0，支持无系统性预趋势。
* 这一节的识别问题不是“改革后有没有效应”，而是“处理组是否已经在改革前
* 沿着不同斜率变化”。因此样本必须限制在改革前，且不能把改革后的观测带入。
**************************************************************************
canal_prepare

keep if year>=1776 & year<=1825
* keep if 是样本限制；它只改变当前副本。下一节重新 canal_prepare，
* 所以这里删掉的改革后年份不会污染后面的表格。
gen pretrend=alongcanal*year
* pretrend 的系数表示运河县相对于非运河县的额外年度趋势；它不是改革后的
* DID 效应。若它接近 0，才有理由继续阅读后面的改革后系数。
label variable pretrend "$ Along Canal \times Year $ "
global X pretrend

tab OBJECTID
scalar groups=r(r)
su $Y
scalar ymean=r(mean)

*** Main estimates
reghdfe $Y $X, absorb(i.OBJECTID i.year) cluster(OBJECTID)
eststo est1
qui tab OBJECTID if e(sample)
scalar groups=r(r)
qui su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:est1
estadd scalar N_g=groups:est1

reghdfe $Y $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year) cluster(OBJECTID)
eststo est2
qui tab OBJECTID if e(sample)
scalar groups=r(r)
qui su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:est2
estadd scalar N_g=groups:est2

reghdfe $Y $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) cluster(OBJECTID)
eststo est3
qui tab OBJECTID if e(sample)
scalar groups=r(r)
qui su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:est3
estadd scalar N_g=groups:est3

reghdfe $Y $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
eststo est4
qui tab OBJECTID if e(sample)
scalar groups=r(r)
qui su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:est4
estadd scalar N_g=groups:est4

*** Get indicators of FEs
capture quietly estfe est1 est2 est3 est4

*** Get Conley standard errors
preserve
if $RUN_CONLEY {
canal_hdfe $Y $X, clear absorb(i.OBJECTID i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(50) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: est1
}
restore
preserve
if $RUN_CONLEY {
canal_hdfe $Y $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(50) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: est2
}
restore
preserve
if $RUN_CONLEY {
canal_hdfe $Y $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(50) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: est3
}
restore
preserve
if $RUN_CONLEY {
canal_hdfe $Y $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(50) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: est4
}
restore




* 导出本节当前保存的全部估计。b() 控制系数位数，se() 输出县聚类标准误。
esttab _all using "$TABLE_DIR/table2_pre_treatment_trends.csv", replace csv b(4) se(4) label compress
display as result "已导出：$TABLE_DIR/table2_pre_treatment_trends.csv"

**************************************************************************
*** [TABLE_3_BASELINE]
*** Table3. Canal closure and rebellions: baseline estimates
* 教学目标：逐列加入固定效应、历史反叛趋势、省份趋势、府级线性趋势和控制变量。
* interaction1 = alongcanal × reform 是 DID 核心项；系数衡量运河关闭后的额外反叛变化。
* cluster(OBJECTID) 允许同一县跨年份误差相关。
* 五列的比较逻辑：先看最简双向固定效应，再逐步吸收更强的历史趋势，最后
* 加入可能影响结果的改革后控制项。每列都重新调用 canal_prepare，保证样本和
* 变量定义来自同一份原始面板；eststo 把每列保存下来供 esttab 一次导出。
**************************************************************************
canal_prepare
* 第 1 列：县固定效应 + 年份固定效应，是最基础的 DID。
reghdfe $Y $X, absorb(i.OBJECTID i.year) cluster(OBJECTID)
eststo est1
qui tab OBJECTID if e(sample)
scalar groups=r(r)
qui su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:est1
estadd scalar N_g=groups:est1

* 第 2 列：允许县的改革前反叛程度拥有不同年度斜率，排除历史动荡趋势差异。
reghdfe $Y $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year) cluster(OBJECTID)
eststo est2
qui tab OBJECTID if e(sample)
scalar groups=r(r)
qui su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:est2
estadd scalar N_g=groups:est2

* 第 3 列：进一步加入省份×年份固定效应，吸收省级年度冲击。
reghdfe $Y $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) cluster(OBJECTID)
eststo est3
qui tab OBJECTID if e(sample)
scalar groups=r(r)
qui su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:est3
estadd scalar N_g=groups:est3

* 第 4 列：加入府级线性时间趋势，控制更细的长期发展路径。
reghdfe $Y $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
eststo est4
qui tab OBJECTID if e(sample)
scalar groups=r(r)
qui su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:est4
estadd scalar N_g=groups:est4

* 第 5 列：在第 4 列基础上加入 $ctrls；这些控制变量主要是基础特征×改革后。
reghdfe $Y $X $ctrls, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
eststo est5
qui tab OBJECTID if e(sample)
scalar groups=r(r)
qui su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:est5
estadd scalar N_g=groups:est5

*** Get indicators of FEs
capture quietly estfe est1 est2 est3 est4 est5

*** Get Conley standard errors
preserve
if $RUN_CONLEY {
canal_hdfe $Y $X, clear absorb(i.OBJECTID i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: est1
}
restore
preserve
if $RUN_CONLEY {
canal_hdfe $Y $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: est2
}
restore
preserve
if $RUN_CONLEY {
canal_hdfe $Y $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: est3
}
restore
preserve
if $RUN_CONLEY {
canal_hdfe $Y $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: est4
}
restore
preserve
if $RUN_CONLEY {
canal_hdfe $Y $X $ctrls, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: est5
}
restore



* 导出本节当前保存的全部估计。b() 控制系数位数，se() 输出县聚类标准误。
esttab _all using "$TABLE_DIR/table3_baseline_did.csv", replace csv b(4) se(4) label compress
display as result "已导出：$TABLE_DIR/table3_baseline_did.csv"

**************************************************************************
*** [TABLE_4_TREATMENT_INTENSITY]
*** Table4. Canal closure and rebellions: treatment intensities
* 教学目标：把二元处理扩展为运河密度、运河城镇依赖度和距运河距离三种剂量指标。
* asinh 变换可保留零值，且在较大取值处近似对数。
* 这三列不再只问“是否沿运河”，而是问冲击强度是否随暴露程度变化：
* ash_den_after 的系数应为正，ash_dist_after 的系数预期为负，canaltown_after
* 则衡量运河城镇依赖度更高的县是否受到更强影响。
**************************************************************************
canal_prepare

gen ash_den=asinh(canal_den)
gen ash_dist=asinh(ctadmin_canal)
gen ash_den_after=ash_den*reform
gen ash_dist_after=ash_dist*reform
gen canaltown=(town1820_r10canal*alongcanal)/town1820
gen canaltown_after=canaltown*reform
label variable ash_den_after "Canal length (per 100 $ km^2 $) $ \times $ Post"
label variable ash_dist_after "Distance to canal $ \times $ Post"
label variable canaltown "Canal town share"
label variable canaltown_after "Canal town share $ \times $ Post"
global X1 ash_den_after
global X2 canaltown_after
global X3 ash_dist_after

reghdfe $Y $X1, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
estimates store int1
qui tab OBJECTID if e(sample)
scalar groups=r(r)
su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:int1
estadd scalar N_g=groups:int1


reghdfe $Y $X2, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
estimates store int2
qui tab OBJECTID if e(sample)
scalar groups=r(r)
su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:int2
estadd scalar N_g=groups:int2


reghdfe $Y $X3, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
estimates store int3
qui tab OBJECTID if e(sample)
scalar groups=r(r)
su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:int3
estadd scalar N_g=groups:int3

*** Get indicators of FEs
capture quietly estfe int1 int2 int3

*** Get Conley standard errors
preserve
if $RUN_CONLEY {
canal_hdfe $Y $X1, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X1, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: int1
}
restore
preserve
if $RUN_CONLEY {
canal_hdfe $Y $X2, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X2, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: int2
}
restore
preserve
if $RUN_CONLEY {
canal_hdfe $Y $X3, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X3, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: int3
}
restore



* 导出本节当前保存的全部估计。b() 控制系数位数，se() 输出县聚类标准误。
esttab _all using "$TABLE_DIR/table4_treatment_intensity.csv", replace csv b(4) se(4) label compress
display as result "已导出：$TABLE_DIR/table4_treatment_intensity.csv"

**************************************************************************
*** Table5. Canal closure and rebellions: north versus south
* 教学目标：用三重交互检验运河效应是否主要来自黄河交汇点以北地区。
* triple 的系数是“运河 × 改革后 × 北方”的额外效应。
* 这里的 interaction1 是南方/基准组的 DID，triple 是北方相对于南方的
* 增量效应；不要只看 triple 的显著性，而要同时看 interaction1+triple 的含义。
**************************************************************************
canal_prepare

gen intlat=Y_COORD if along_oldhuang==1 & alongcanal==1
egen intersectlat=min(intlat)
gen north=(Y_COORD>intersectlat)
gen northpost=north*reform
gen triple=alongcanal*reform*north
label variable northpost "$ North \times Post $"
label variable triple " $ Along Canal \times Post \times North $ "
global X triple interaction1 northpost
*** Main estimates
reghdfe $Y $X, absorb(i.OBJECTID i.year) cluster(OBJECTID)
eststo est1
qui tab OBJECTID if e(sample)
scalar groups=r(r)
qui su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:est1
estadd scalar N_g=groups:est1

reghdfe $Y $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year) cluster(OBJECTID)
eststo est2
qui tab OBJECTID if e(sample)
scalar groups=r(r)
qui su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:est2
estadd scalar N_g=groups:est2

reghdfe $Y $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) cluster(OBJECTID)
eststo est3
qui tab OBJECTID if e(sample)
scalar groups=r(r)
qui su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:est3
estadd scalar N_g=groups:est3

reghdfe $Y $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
eststo est4
qui tab OBJECTID if e(sample)
scalar groups=r(r)
qui su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:est4
estadd scalar N_g=groups:est4

*** Get indicators of FEs
capture quietly estfe est1 est2 est3 est4

*** Get Conley standard errors
preserve
if $RUN_CONLEY {
canal_hdfe $Y $X, clear absorb(i.OBJECTID i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: est1
}
restore
preserve
if $RUN_CONLEY {
canal_hdfe $Y $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: est2
}
restore
preserve
if $RUN_CONLEY {
canal_hdfe $Y $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: est3
}
restore
preserve
if $RUN_CONLEY {
canal_hdfe $Y $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: est4
}
restore




* 导出本节当前保存的全部估计。b() 控制系数位数，se() 输出县聚类标准误。
esttab _all using "$TABLE_DIR/table5_north_south.csv", replace csv b(4) se(4) label compress
display as result "已导出：$TABLE_DIR/table5_north_south.csv"

**************************************************************************
*** [TABLE_6_PLACEBO_ROUTES]
*** Table6. Canal closure and rebellions: placebo treatments
* 教学目标：把长江、旧黄河、海岸和驿道当作伪处理路线。
* 若只有真实运河处理显著，而替代路线不显著，能削弱“所有交通线附近都更乱”的解释。
* Xp1--Xp4 分别替换为长江、旧黄河、海岸和驿道的“路线×改革后”；Xp_any
* 是这些路线的并集。若它们也机械地产生与 interaction1 相同的结果，识别就会
* 更像“所有交通线附近县都变乱”，而不是大运河冲击的局部效应。
**************************************************************************
canal_prepare

gen oldhuang_after=along_oldhuang*reform
gen coast_after=alongcoast*reform
gen courier_after=alongcourier*reform
egen plcb=rowmax(alongyangtze along_oldhuang alongcoast alongcourier)
gen plcb_after=plcb*reform
label variable yangtze_after "Along Yangtze $ \times $ Post"
label variable oldhuang_after "Along Huang $ \times $ Post"
label variable coast_after "Along Coast $ \times $ Post"
label variable courier_after "Along Courier $ \times $ Post"
label variable plcb_after "Along $ \times $ Post"
global Xp1 yangtze_after
global Xp2 oldhuang_after
global Xp3 coast_after
global Xp4 courier_after
global Xp_any plcb_after
*** Main estimates
reghdfe $Y $Xp1, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
eststo est1
qui tab OBJECTID if e(sample)
scalar groups=r(r)
qui su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:est1
estadd scalar N_g=groups:est1

reghdfe $Y $Xp2, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
eststo est2
qui tab OBJECTID if e(sample)
scalar groups=r(r)
qui su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:est2
estadd scalar N_g=groups:est2

reghdfe $Y $Xp3, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
eststo est3
qui tab OBJECTID if e(sample)
scalar groups=r(r)
qui su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:est3
estadd scalar N_g=groups:est3

reghdfe $Y $Xp4, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
eststo est4
qui tab OBJECTID if e(sample)
scalar groups=r(r)
qui su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:est4
estadd scalar N_g=groups:est4

reghdfe $Y $Xp_any, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
eststo est5
qui tab OBJECTID if e(sample)
scalar groups=r(r)
qui su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:est5
estadd scalar N_g=groups:est5

*** Get indicators of FEs
capture quietly estfe est1 est2 est3 est4 est5

*** Get Conley standard errors
preserve
if $RUN_CONLEY {
canal_hdfe $Y $Xp1, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $Xp1, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: est1
}
restore
preserve
if $RUN_CONLEY {
canal_hdfe $Y $Xp2, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $Xp2 , lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: est2
}
restore
preserve
if $RUN_CONLEY {
canal_hdfe $Y $Xp3, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $Xp3, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: est3
}
restore
preserve
if $RUN_CONLEY {
canal_hdfe $Y $Xp4, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $Xp4, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: est4
}
restore
preserve
if $RUN_CONLEY {
canal_hdfe $Y $Xp_any, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $Xp_any, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: est5
}
restore




* 导出本节当前保存的全部估计。b() 控制系数位数，se() 输出县聚类标准误。
esttab _all using "$TABLE_DIR/table6_placebo_routes.csv", replace csv b(4) se(4) label compress
display as result "已导出：$TABLE_DIR/table6_placebo_routes.csv"

**************************************************************************
*** [TABLE_7_WAR_EXCLUSION]
*** Table7. Canal closure and rebellions: major distortions
* 教学目标：排除鸦片战争与太平天国活动区域驱动主结果。
* Panel A 删除受影响县；Panel B 用三重交互显式控制战争区域的改革后变化。
* Panel A 改变样本，Panel B 保留样本但改变模型；两者回答的是不同的稳健性问题。
**************************************************************************
*** Panel A: Excluding Affected Counties
canal_prepare

gen taipingregion=(Taiping>=2) if Taiping<.
gen triple1 =alongcanal*reform*opiumbattle
gen triple1a=opiumbattle*reform
gen triple2 =alongcanal*reform*taipingregion
gen triple2a=taipingregion*reform
label variable interaction1 "Canal $ \times $ Post"
label variable triple1  "Canal $ \times $ Opium Battlefield $\times$ Post"
label variable triple1a "Opium Battlefield $ \times $ Post"
label variable triple2  "Canal $ \times $ Taiping $\times$ Post"
label variable triple2a "Taiping $ \times $ Post"

preserve
keep if opiumbattle==0
reghdfe $Y $X, absorb(OBJECTID year c.ashprerebels#i.year i.prefid#c.year i.provid#i.year) cluster(OBJECTID)
eststo omtopium1
tab OBJECTID if e(sample)
scalar groups=r(r)
su onset_all if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:omtopium1
estadd scalar N_g=groups:omtopium1
restore

preserve
keep if opiumbattle==0
if $RUN_CONLEY {
canal_hdfe $Y $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: omtopium1
}
restore

preserve
keep if Taiping<2
reghdfe $Y $X, absorb(OBJECTID year c.ashprerebels#i.year i.prefid#c.year i.provid#i.year) cluster(OBJECTID)
eststo omttaiping1
tab OBJECTID if e(sample)
scalar groups=r(r)
su onset_all if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:omttaiping1
estadd scalar N_g=groups:omttaiping1
restore

preserve
keep if Taiping<2
if $RUN_CONLEY {
canal_hdfe $Y $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: omttaiping1
}
restore

*** Panel B: Interactions
reghdfe $Y interaction1 triple1a triple1, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.prefid#c.year i.provid#i.year) cluster(OBJECTID)
est store opium1
tab OBJECTID if e(sample)
scalar groups=r(r)
su onset_all if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:opium1
estadd scalar N_g=groups:opium1

reghdfe $Y interaction1 triple2a triple2, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.prefid#c.year i.provid#i.year) cluster(OBJECTID)
est store taiping1
tab OBJECTID if e(sample)
scalar groups=r(r)
su onset_all if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:taiping1
estadd scalar N_g=groups:taiping1

preserve
if $RUN_CONLEY {
canal_hdfe $Y interaction1 triple1a triple1, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y interaction1 triple1a triple1, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: opium1
}
restore

preserve
if $RUN_CONLEY {
canal_hdfe $Y interaction1 triple2a triple2, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y interaction1 triple2a triple2, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: taiping1
}
restore




* 导出本节当前保存的全部估计。b() 控制系数位数，se() 输出县聚类标准误。
esttab _all using "$TABLE_DIR/table7_war_exclusions.csv", replace csv b(4) se(4) label compress
display as result "已导出：$TABLE_DIR/table7_war_exclusions.csv"

**************************************************************************
*** FigureA1: Number of rebellions onsets overtime
* 教学目标：展示 1650-1911 年全国样本内反叛发生数的原始时间趋势。
**************************************************************************
canal_prepare

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
graph export "$FIGURE_DIR/figureA1.png", replace







if $RUN_CONLEY & $RUN_CONLEY_GRID {
**************************************************************************
***FigureA2. Test statistics of Table 3 varying standard error adjustments
* 高耗时稳健性检验：系统改变 Conley 距离/时间截断值并比较 t 统计量。
* 默认关闭；将 RUN_CONLEY 与 RUN_CONLEY_GRID 同时设为 1 才运行。
**************************************************************************
**************************************************************************
*** Run regressions and obtain corrected standard errors
*** Results saved to save time
*** Could uncomment if need rerunning
**************************************************************************
canal_prepare

local c=1
forvalues c=1/5 {
    if `c'==1 local fes i.OBJECTID i.year
    if `c'==2 local fes i.OBJECTID i.year c.ashprerebels#i.year
    if `c'==3 local fes i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year
    if `c'==4 local fes i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year
	if `c'==5 local fes i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year
    local ctrl
    if `c'==5 local ctrl $ctrls
    mat tests`c'=(0,0,.)
    * Conley standard errors with varying distance and lag cutoffs
    preserve
if $RUN_CONLEY {
        canal_hdfe $Y $X `ctrl', clear absorb(`fes') tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
        foreach d of numlist 50 100 200 500 1000 2000 {
            foreach t of numlist 20 100 200 262 {
                disp "Estimating model `c' with distancecutoff `d' and lagcutoff `t' ..."
                ols_spatial_HAC $Y $X `ctrl', lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(`d') lagcutoff(`t')
                ereturn display
                mat ests=r(table)
                scalar d=`d'
                scalar t=`t'
                mat tests`c'=(tests`c'\d,t,ests[3,1])
            }
        }
}
    restore


    * Cluster by county
    reghdfe $Y $X `ctrl', absorb(`fes') cluster(OBJECTID)
    ereturn display
    mat ests=r(table)
    scalar d=-1
    scalar t=-1
    mat tests`c'=(tests`c'\d,t,ests[3,1])
    * Cluster by prefecture
    reghdfe $Y $X `ctrl', absorb(`fes') cluster(prefid)
    ereturn display
    mat ests=r(table)
    scalar d=-2
    scalar t=-2
    mat tests`c'=(tests`c'\d,t,ests[3,1])
    * Save statistics
    preserve
        clear
        svmat tests`c', names(stat)
        rename (stat1 stat2 stat3) (dist lag tvalue)
        save "$INTERMEDIATE_DIR/errors_tests`c'.dta", replace
    restore
}

**************************************************************************
*** Visualize the test statistics across different parameter choices
**************************************************************************
local c=1
forvalues c=1/5 {
    use "$INTERMEDIATE_DIR/errors_tests`c'.dta", clear
    drop in 1
    recode dist (-1 -2=1 "NA") (50=2 "50") (100=4 "100") (200=6 "200") (500=8 "500") (1000=10 "1000") (2000=12 "2000"),gen(distcat) label(distcat)
    gen mlabel="cluster(county)" if dist==-1
    replace mlabel="cluster(prefecture)" if dist==-2
    #d ;
	twoway
	(connected tvalue distcat if dist>0 & lag==20, msymbol(Oh) color(black))
	(connected tvalue distcat if dist>0 & lag==100, msymbol(T) color(black))
	(connected tvalue distcat if dist>0 & lag==200, msymbol(O) color(black))
	(connected tvalue distcat if dist>0 & lag==262, msymbol(X) color(black))
	(scatter tvalue distcat if inlist(dist,-1,-2),mlabel(mlabel) mlabcolor(black) msize(*0.5) color(black))
	,
	ytitle("Test t-value", size(*0.9))
	xtitle("Distance cutoff (km)", size(*0.9) margin(medsmall))
	yline(1.75(0.25)3.25, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
	xline(1(1)12, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
	yline(1.96, lpattern(dash) lcolor("128 0 0"))
	yline(2.58, lpattern(dash) lcolor("128 0 0"))
	text(1.94 0.6 "**" 2.56 0.55 "***", color("128 0 0"))
	ylabel(1.8 " " 2 "2.0" 2.5 "2.5" 3 "3.0", angle(0) format(%5.1f) labsize(*0.85) notick)
	xlabel(1 2(2)12,valuelabel labsize(*0.85))
	graphregion(fcolor(gs16) lcolor(gs16))
	plotregion(lcolor("white") lwidth(*0.9))
	legend(order(1 "lagcutoff:20 years" 2 "lagcutoff:100 years" 3 "lagcutoff:200 years" 4 "lagcutoff:all (262) years") row(1) size(*0.45))
	title("", size(small) margin(small))
	;
	#d cr
    graph export "$FIGURE_DIR/figureA2_col`c'_t.png", replace
}





}
**************************************************************************
*** FigureA3. Canal closure and rebellions: flexible treatment intensity
* 教学目标：不用线性强度假设，把运河密度和运河城镇占比分箱后估计灵活剂量反应。
**************************************************************************
canal_prepare

gen canaltown=(town1820_r10canal*alongcanal)/town1820
preserve
egen intensity=cut(canal_den),at(0,0.001,2,4,6,15)
replace intensity=-1 if alongcanal==0
tab intensity, gen(inten)
reghdfe $Y c.reform#(c.inten2-inten6), absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) cluster(OBJECTID)
matrix coef = e(b)
matrix cov = e(V)
gen coef = .
gen se = .
forvalues i = 1(1)5 {
 replace coef = coef[1,`i'] if _n==`i'
 replace se = sqrt(cov[`i',`i']) if _n==`i'
}
gen lb=coef-invttail(e(df_r),0.025)*se
gen ub=coef+invttail(e(df_r),0.025)*se
keep coef se lb ub
drop if coef == .
gen ph_intensity=_n
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
graph export "$FIGURE_DIR/figureA3a.png", replace
restore

preserve
egen intensity=cut(canaltown), at(0,.2,.4,.6,.8,1.1)
replace intensity=-1 if alongcanal==0
tab intensity, gen(inten)
reghdfe $Y c.reform#(c.inten2-inten6), absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) cluster(OBJECTID)
matrix coef = e(b)
matrix cov = e(V)
gen coef = .
gen se = .
forvalues i = 1(1)5 {
 replace coef = coef[1,`i'] if _n==`i'
 replace se = sqrt(cov[`i',`i']) if _n==`i'
}
gen lb=coef-invttail(e(df_r),0.025)*se
gen ub=coef+invttail(e(df_r),0.025)*se
keep coef se lb ub
drop if coef == .
gen ph_intensity=_n
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
graph export "$FIGURE_DIR/figureA3b.png", replace
restore






**************************************************************************
*** FigureA4. Canal closure and rebellions: flexible distance to the canal
* 教学目标：按距运河每 25 公里分箱，识别处理效应随空间距离衰减的范围。
**************************************************************************
canal_prepare

gen band=ceil(ctadmin_canal/25)*25
replace band=425 if band>=425 & band!=.
tab band, gen(dist)
reghdfe $Y c.reform#(c.dist1-dist16), absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) cluster(OBJECTID)
matrix coef = e(b)
matrix cov = e(V)
gen coef = .
gen se = .
forvalues i = 1(1)16 {
 replace coef = coef[1,`i'] if _n==`i'
 replace se = sqrt(cov[`i',`i']) if _n==`i'
}
gen lb=coef-invttail(e(df_r),0.025)*se
gen ub=coef+invttail(e(df_r),0.025)*se
keep coef se lb ub
drop if coef == .
gen distance_canal=_n
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
xlabel(1 "25" 2 "50" 3 "75" 4 "100" 5 "125" 6 "150" 7 "175" 8 "200" 9 "225" 10 "250" 11 "275" 12 "300" 13 "325" 14 "350" 15 "375" 16 "400", labsize(*0.85))
graphregion(fcolor(gs16) lcolor(gs16))
plotregion(lcolor("white") lwidth(*0.9))
legend(off)
;
#d cr
graph export "$FIGURE_DIR/figureA4.png", replace



if $RUN_CIC {
**************************************************************************
*** [APPENDIX_CIC]
*** FigureA5. Changes-in-changes estimations
* 可选的 Changes-in-Changes：估计不同结果分位数上的处理效应，而不只报告平均效应。
* 默认关闭；设 RUN_CIC=1 后运行。CIC_REPS=0 只算点估计，大于 0 时 bootstrap。
**************************************************************************
canal_prepare
* 四个 G/T 指示变量把样本分成“对照/处理 × 改革前/后”四个单元。
* 下面的回归先吸收县、年份、历史反叛趋势和地区趋势，再用 residual 重建
* 一个已经净化共同冲击的结果 Yhat，减少 bootstrap 时复制大面板的内存占用。
gen G0T0=(alongcanal==0 & reform==0)
gen G1T0=(alongcanal==1 & reform==0)
gen G0T1=(alongcanal==0 & reform==1)
gen G1T1=(alongcanal==1 & reform==1)
qui reg $Y G0T0 G1T0 G0T1 G1T1 c.ashprerebels#i.year i.OBJECTID i.year i.provid#i.year i.prefid#c.year, nocons
predict res, residual
mat coef=e(b)
* reg 的 nocons 让四个 G/T 单元各自拥有一个水平项；Yhat 是“控制固定效应
* 后的结果”，供后面的 CIC 分位数映射使用，而不是新的原始因变量。
gen Yhat=res+coef[1,1]*G0T0+coef[1,2]*G1T0+coef[1,3]*G0T1+coef[1,4]*G1T1
su Yhat,detail
* CIC 只需要结果、处理组和时期三个变量。先释放其余 140 多个变量及
* 高维固定效应回归矩阵，可避免 bootstrap 在复制样本时耗尽内存。
keep Yhat alongcanal reform
drop if missing(Yhat, alongcanal, reform)
compress
discard
* canal_cic_qte 返回 q10--q90 的连续型 CIC 分位处理效应。
* bootstrap 按“处理组 × 改革前后”四个层分层抽样，与标准 CIC 重抽样一致。
if $CIC_REPS>0 {
    * strata() 保证四个 G/T 单元在每次重抽样中都被保留；set seed 使
    * 100 次 bootstrap 可以被别人用同一份数据重复得到相同结果。
    egen cic_strata=group(alongcanal reform)
    set seed 20260809
    bootstrap q10=r(q10) q20=r(q20) q30=r(q30) q40=r(q40) q50=r(q50) ///
              q60=r(q60) q70=r(q70) q80=r(q80) q90=r(q90), ///
              reps($CIC_REPS) strata(cic_strata) nodots: ///
              canal_cic_qte Yhat, group(alongcanal) time(reform)
    matrix cic_b=e(b)
    matrix cic_V=e(V)
    local has_cic_v=1
}
else {
    * CIC_REPS=0 时跳过 bootstrap，只返回点估计，适合先检查代码和图形。
    canal_cic_qte Yhat, group(alongcanal) time(reform)
    matrix cic_b=J(1,9,.)
    forvalues i=1/9 {
        local q=`i'*10
        matrix cic_b[1,`i']=r(q`q')
    }
    local has_cic_v=0
}
clear
set obs 9
gen qntl=_n/10
gen qte=.
gen std=.
forvalues i=1/9 {
    replace qte=cic_b[1,`i'] in `i'
    if `has_cic_v' replace std=sqrt(cic_V[`i',`i']) in `i'
}
gen lb=cond(std<., qte-invnormal(0.975)*std, qte)
gen ub=cond(std<., qte+invnormal(0.975)*std, qte)
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
graph export "$FIGURE_DIR/figureA5.png", replace





}
if $RUN_SYNTH {
**************************************************************************
*** [APPENDIX_SYNTHETIC_CONTROL]
*** FigureA6. Synthetic control estimation
* 可选的合成控制：为运河县构造改革前路径最相似的加权对照。
* 默认关闭；设 RUN_SYNTH=1 后运行，并同时输出路径图及逐期 p 值图。
**************************************************************************
canal_prepare

* floor(...)*10+1826 把年度面板压缩为十年一期，并把相对年份重新锚定到
* 1826；collapse 后每个 OBJECTID-year 只保留一条县—十年观测。
replace year=floor((year-1826)/10)*10+1826
collapse (mean) onset_all cntypop1600 alongcanal distance_canal, by(OBJECTID year)
gen ashonset_cntypop1600=asinh(onset_all/(cntypop1600/1000000))
gen y=ashonset_cntypop1600
gen y_observed=y
keep if y<.
keep if year>=1776
drop if distance_canal<150 & alongcanal==0
gen interaction1=alongcanal*(year>=1826)
* synth 需要强平衡面板：每个县必须在每个十年期都有一条观测；xtset 的
* delta(10) 告诉 Stata 时间间隔不是 1 年而是 10 年。
xtset OBJECTID year, delta(10)

* synth 0.0.8 在 Stata 18 ARM 上会拒绝大量完全相同的零路径。
* 加入至多约 1e-7 的确定性序号扰动，只打破数值并列；绘图前恢复原始 y。
summarize OBJECTID, meanonly
replace y=y+(OBJECTID-r(min))*1e-10
set seed 20260809
* y(1776) 等是改革前的预测变量；d(interaction1) 指定 1826 年后开始处理。
* gen_vars 保存合成路径等中间结果，n_pl_avgs(100000) 控制安慰剂平均次数。
synth_runner y y(1776) y(1796) y(1806) y(1816), d(interaction1) ///
    gen_vars deterministicoutput n_pl_avgs(100000)
replace y=y_observed
drop y_observed
matrix P = e(pvals_std)
* pvals_std 是标准化安慰剂 p 值；先转成长表并和处理路径 merge，
* 再分别导出“处理组 vs 合成组”和“逐期效应 vs p 值”两张图。

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
save "$INTERMEDIATE_DIR/synth10alt.dta", replace

use "$INTERMEDIATE_DIR/synth10alt.dta", clear
replace year=year-1826
keep if alongcanal == 1
collapse (mean) p_vals y y_synth, by(year)
gen effect = y - y_synth
keep if year<70
#d ;
twoway
(connected y year, lpattern(solid) msymbol(C) msize(*0.75) color("4 4 4"))
(connected y_synth year, lpattern(dash) msymbol(T) msize(*0.75) color("119 119 119"))
,
ytitle("Coefficients", size(*0.9))
xtitle("Number of years since the 1826 reform", size(*0.9) margin(medsmall))
yline(0(0.1)0.9, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
xline(-50(5)60, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
xline(-5, lpattern(dash) lcolor("128 0 0"))
ylabel(0(0.2)0.8, angle(0) format(%5.1f) labsize(*0.85))
xlabel(-50 "-50" -40 "-40" -30 "-30" -20 "-20" -10 "-10" 0 "10" 10 "20" 20 "30" 30 "40" 40 "50" 50 "60" 60 "70", labsize(*0.85))
graphregion(fcolor(gs16) lcolor(gs16))
plotregion(lcolor("white") lwidth(*0.9))
legend(label(1 "Canal counties (treated)") label(2 "Synthetic controls") size(*0.85))
;
#d cr
graph export "$FIGURE_DIR/figureA6a.png", replace

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
xlabel(-50 "-50" -40 "-40" -30 "-30" -20 "-20" -10 "-10" 0 "10" 10 "20" 20 "30" 30 "40" 40 "50" 50 "60" 60 "70", labsize(*0.85))
graphregion(fcolor(gs16) lcolor(gs16))
plotregion(lcolor("white") lwidth(*0.9))
legend(label(1 "Treatment effects") label(2 "P-values") size(*0.85))
;
#d cr
graph export "$FIGURE_DIR/figureA6b.png", replace





}
**************************************************************************
*** FigureA7. Heterogeneous effects by distance to the Yangtze River
* 教学目标：按距长江的 100 公里区间重复基准回归，检查替代水路可达性的异质性。
**************************************************************************
canal_prepare

mat result = (., ., ., .)
capture program drop svresult
program define svresult
    args distance_yangtze
    qui {
        reghdfe $Y $X $ctrls ///
        if distance_yangtze >= `distance_yangtze' - 100 & distance_yangtze < `distance_yangtze', ///
        a(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) cl(OBJECTID)
        scalar b = _b[interaction1]
        scalar se = _se[interaction1]
        scalar uci_95 = _b[interaction1] + invttail(e(df_r), 0.025)*se
        scalar lci_95 = _b[interaction1] - invttail(e(df_r), 0.025)*se
        mat result = (result\ `distance_yangtze', b, lci_95, uci_95)
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
export delimited "$INTERMEDIATE_DIR/distance_yangtze.txt", delimit(tab) replace
import delimited using "$INTERMEDIATE_DIR/distance_yangtze.txt", clear
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
graph export "$FIGURE_DIR/figureA7.png", replace




**************************************************************************
*** FigureC4b. Chronological distribution of droughts and floodings
* 描述性附图：按年份汇总洪涝和旱灾县数，检查气候冲击的时间分布。
**************************************************************************
canal_prepare

preserve
collapse (sum) flooding drought, by(year)
label variable flooding "Flooding"
label variable drought "Drought"
gen fd=flooding+drought
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
graph export "$FIGURE_DIR/figureC4b.png", replace
restore



**************************************************************************
*** FigureC6b. Chronological distribution of new world crops adoption
* 描述性附图：按年份汇总玉米和甘薯采用县数，检查新大陆作物扩散趋势。
**************************************************************************
canal_prepare

preserve
sort year
collapse (count) maizeyear swtpotatoyear (sum) maize sweetpotato, by(year)
gen maizeshare=maize/maizeyear
gen spshare=sweetpotato/swtpotatoyear
label variable maize "Maize"
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
graph export "$FIGURE_DIR/figureC6b.png", replace
restore




**************************************************************************
*** TableA1. Comparisons between canal and non-canal counties
* 教学目标：把县折叠为横截面，比较运河县与非运河县的改革前协变量均值。
**************************************************************************
canal_prepare

* 这些变量必须在最后一次载入数据之后生成；否则 lpop 会被 Stata
* 当作 lpop1600_after、lpopdencnty1600 等变量的模糊缩写。
gen larea=ln(AREA)
gen lpop=ln(popdencnty1600)
global balancevars larea ruggedness disaster flooding drought lpop maize sweetpotato suitable_wheat_good suitable_rice_good
collapse (mean) alongcanal $balancevars, by(OBJECTID)
label variable larea "Land area"
label variable ruggedness "Ruggedness Index"
label variable disaster "Temperature Anomaly"
label variable flooding "Frequency of flooding"
label variable drought "Frequency of droughts"
label variable lpop "Population density in 1600"
label variable maize "Maize introduction"
label variable sweetpotato "Sweet potato introduction"
label variable suitable_wheat_good "Suitable for wheat"
label variable suitable_rice_good "Suitable for wetland rice"

**************************************************************************
*** Get statistics
**************************************************************************
recode alongcanal (1=0) (0=1), gen(sugroup)
keep if lpop<.
*** Canal counties:
estpost summarize $balancevars if sugroup==0
eststo des1
*** Non-canal counties:
estpost summarize $balancevars if sugroup==1
eststo des2
*** Difference:
estpost ttest $balancevars, by(sugroup)
eststo des3




* 导出本节当前保存的全部估计。b() 控制系数位数，se() 输出县聚类标准误。
esttab _all using "$TABLE_DIR/tableA1_covariate_balance.csv", replace csv b(4) se(4) label compress
display as result "已导出：$TABLE_DIR/tableA1_covariate_balance.csv"

**************************************************************************
*** TableA2. Abandonment of the Grand Canal and rebellions: alternative sampling methods
* 教学目标：改变样本筛选和聚合层级，检验主结果是否依赖特定样本定义。
**************************************************************************
* Columns: within pref, within 100km, 150km, 200km, full
canal_prepare

local col1 prefalong==1
local col2 distance_canal<=100
local col3 distance_canal<=150
local col4 distance_canal<=200
local col5 distance_canal<=.
* Rows: 50-, 100-, 150-, 200-, full year window
local row1 year>1800 & year<=1850
local row2 year>1775 & year<=1875
local row3 year>1750 & year<=1900
local row4 year>1711 & year<=1911
local row5 year<=.

*** County level:
forvalues r=1/5 {
	forvalues c=1/5 {
		di " `col`c'' & `row`r''"
		reghdfe $Y $X if `col`c'' & `row`r'', absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
		est store r`r'c`c'

		*** Conley standard errors
		preserve
if $RUN_CONLEY {
		canal_hdfe $Y $X  if `col`c'' & `row`r'', clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
		ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
		matrix V_spat=vecdiag(e(V))
		matmap V_spat SE_spat,m(sqrt(@))
		estadd matrix sesp=SE_spat: r`r'c`c'
}
		restore
	}
}

*** Prefecture level:
global Yp ashonset_pop1600
forvalues r=1/5 {
	sort prefid year
	collapse (sum) onset_all AREA (first) provid reform (max) alongcanal interaction1 area_pref popden* cntypop* (mean) Y_COORD X_COORD, by(prefid year)
	gen pop1600=popden1600*AREA/1000000
	gen pop1820=popden1820*AREA/1000000
	gen pop=popden*AREA/1000000
	su AREA area_pref
	gen ashonset_pop1600=asinh(onset_all/pop1600)
	gen ashonset_pop1820=asinh(onset_all/pop1820)
	gen ashonset_pop=asinh(onset_all/pop)
	by prefid: egen prerebels=total((onset_all/(pop1600))*(reform==0))
	gen ashprerebels=asinh(prerebels)
	di "`col6' & `row`r''"
	reghdfe $Yp $X if `row`r'', absorb(i.prefid i.year c.ashprerebels#i.year i.provid##i.year) cluster(prefid)
	est store r`r'c6

	*** Conley standard errors
	preserve
if $RUN_CONLEY {
	canal_hdfe $Yp $X  if `row`r'', clear absorb(i.prefid i.year c.ashprerebels#i.year i.provid##i.year) tol(0.001) keepvars(prefid year Y_COORD X_COORD)
	ols_spatial_HAC $Yp $X, lat(Y_COORD) lon(X_COORD) time(year) panel(prefid) distcutoff(500) lagcutoff(262) disp star
	matrix V_spat=vecdiag(e(V))
	matmap V_spat SE_spat, m(sqrt(@))
	estadd matrix sesp=SE_spat: r`r'c6
}
	restore
}

label variable interaction "Along Canal $ \times $ Post"

capture quietly estfe r*c*




* 导出本节当前保存的全部估计。b() 控制系数位数，se() 输出县聚类标准误。
esttab _all using "$TABLE_DIR/tableA2_alternative_samples.csv", replace csv b(4) se(4) label compress
display as result "已导出：$TABLE_DIR/tableA2_alternative_samples.csv"

**************************************************************************
*** TableA3. Canal closure and rebellions: alternative transformations of outcome values
* 教学目标：依次替换人口口径、面积标准化、事件计数变换和水平值结果变量。
* 循环中的 `Y' 是当前结果变量；因变量均值也必须按当前 `Y' 计算。
**************************************************************************
canal_prepare

gen onset_cntypop1600=onset_all/(cntypop1600/1000000)
gen ashonset_num=asinh(onset_all)
global Ys ashonset_cntypop1820 ashonset_cntypop ashonset_km2 ashonset_num onset_cntypop1600

foreach Y of varlist $Ys {
    *** Main estimates
    reghdfe `Y' $X, absorb(i.OBJECTID i.year) cluster(OBJECTID)
    eststo `Y'_1
    qui tab OBJECTID if e(sample)
    scalar groups=r(r)
    qui su `Y' if e(sample)
    scalar ymean=r(mean)
    estadd scalar depavg=ymean:`Y'_1
    estadd scalar N_g=groups:`Y'_1

    reghdfe `Y' $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year) cluster(OBJECTID)
    eststo `Y'_2
    qui tab OBJECTID if e(sample)
    scalar groups=r(r)
    qui su `Y' if e(sample)
    scalar ymean=r(mean)
    estadd scalar depavg=ymean:`Y'_2
    estadd scalar N_g=groups:`Y'_2

    reghdfe `Y' $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) cluster(OBJECTID)
    eststo `Y'_3
    qui tab OBJECTID if e(sample)
    scalar groups=r(r)
    qui su `Y' if e(sample)
    scalar ymean=r(mean)
    estadd scalar depavg=ymean:`Y'_3
    estadd scalar N_g=groups:`Y'_3

    reghdfe `Y' $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
    eststo `Y'_4
    qui tab OBJECTID if e(sample)
    scalar groups=r(r)
    qui su `Y' if e(sample)
    scalar ymean=r(mean)
    estadd scalar depavg=ymean:`Y'_4
    estadd scalar N_g=groups:`Y'_4

    *** Get indicators of FEs
    capture quietly estfe `Y'_1 `Y'_2 `Y'_3 `Y'_4

    *** Get conley standard errors
    preserve
if $RUN_CONLEY {
    canal_hdfe `Y' $X, clear absorb(i.OBJECTID i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC `Y' $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
    matrix V_spat=vecdiag(e(V))
    matmap V_spat SE_spat, m(sqrt(@))
    estadd matrix sesp=SE_spat: `Y'_1
}
    restore
    preserve
if $RUN_CONLEY {
    canal_hdfe `Y' $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC `Y' $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
    matrix V_spat=vecdiag(e(V))
    matmap V_spat SE_spat, m(sqrt(@))
    estadd matrix sesp=SE_spat: `Y'_2
}
    restore
    preserve
if $RUN_CONLEY {
    canal_hdfe `Y' $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC `Y' $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
    matrix V_spat=vecdiag(e(V))
    matmap V_spat SE_spat, m(sqrt(@))
    estadd matrix sesp=SE_spat: `Y'_3
}
    restore
    preserve
if $RUN_CONLEY {
    canal_hdfe `Y' $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC `Y' $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
    matrix V_spat=vecdiag(e(V))
    matmap V_spat SE_spat, m(sqrt(@))
    estadd matrix sesp=SE_spat: `Y'_4
}
    restore
}




* 导出本节当前保存的全部估计。b() 控制系数位数，se() 输出县聚类标准误。
esttab _all using "$TABLE_DIR/tableA3_outcome_transformations.csv", replace csv b(4) se(4) label compress
display as result "已导出：$TABLE_DIR/tableA3_outcome_transformations.csv"

**************************************************************************
*** TableA4. Canal closure and rebellions: state capacity channel
* 机制检验：考察驻军、府治位置以及进攻/退却事件，区分国家能力解释。
**************************************************************************
canal_prepare

gen ashdensity=asinh(canal_den)
global canal ashdensity
gen ashattack_cntypop1600=asinh(attack/(cntypop1600/1000000))
gen ashretreat_cntypop1600=asinh(runinto/(cntypop1600/1000000))
gen canal_after=${canal}*reform
label variable canal_after "Canal $ \times $ Post"
gen triplesoldier=${canal}*asinh(soldier/100)*reform
gen soldier_after=asinh(soldier/100)*reform
label variable soldier_after "Soldiers $\times$ Post"
label variable triplesoldier "Soldiers $\times$ Canal $\times$ Post"
gen triplecapital=${canal}*pref_capital*reform
gen capital_after=pref_capital*reform
label variable capital_after "Prefecture Capital $\times$ Post"
label variable triplecapital "Prefecture Capital $\times$ Canal $\times$ Post"

reghdfe $Y canal_after soldier_after triplesoldier, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) cluster(OBJECTID)
eststo vul1
su onset_all if e(sample)
scalar y2mean=r(mean)
qui tab OBJECTID if e(sample)
scalar groups=r(r)
estadd scalar depavg=y2mean:vul1
estadd scalar N_g=groups:vul1

preserve
if $RUN_CONLEY {
canal_hdfe $Y canal_after soldier_after triplesoldier, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y canal_after soldier_after triplesoldier, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: vul1
}
restore

preserve
reghdfe $Y canal_after capital_after triplecapital, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) cluster(OBJECTID)
eststo vul2
su onset_all if e(sample)
scalar y2mean=r(mean)
qui tab OBJECTID if e(sample)
scalar groups=r(r)
estadd scalar depavg=y2mean:vul2
estadd scalar N_g=groups:vul2
restore

preserve
if $RUN_CONLEY {
canal_hdfe $Y canal_after capital_after triplecapital, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y canal_after capital_after triplecapital, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: vul2
}
restore

reghdfe ashattack_cntypop1600 canal_after, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) cluster(OBJECTID)
eststo vul3
su attack if e(sample)
scalar y2mean=r(mean)
qui tab OBJECTID if e(sample)
scalar groups=r(r)
estadd scalar depavg=y2mean:vul3
estadd scalar N_g=groups:vul3

preserve
if $RUN_CONLEY {
canal_hdfe ashattack_cntypop1600 canal_after, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC ashattack_cntypop1600 canal_after, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: vul3
}
restore

reghdfe ashretreat_cntypop1600 canal_after, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) cluster(OBJECTID)
eststo vul4
su runinto if e(sample)
scalar y2mean=r(mean)
qui tab OBJECTID if e(sample)
scalar groups=r(r)
estadd scalar depavg=y2mean:vul4
estadd scalar N_g=groups:vul4

preserve
if $RUN_CONLEY {
canal_hdfe ashretreat_cntypop1600 canal_after, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC ashretreat_cntypop1600 canal_after, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: vul4
}
restore

*** Get indicators of FEs
capture quietly estfe vul1 vul2 vul3 vul4




* 导出本节当前保存的全部估计。b() 控制系数位数，se() 输出县聚类标准误。
esttab _all using "$TABLE_DIR/tableA4_state_capacity.csv", replace csv b(4) se(4) label compress
display as result "已导出：$TABLE_DIR/tableA4_state_capacity.csv"

**************************************************************************
*** TableA5. Canal closure and rebellions: trade access channel
* 机制检验：考察城镇增长、驿道替代和灾害风险缓冲，识别贸易可达性渠道。
**************************************************************************
canal_prepare

gen ashdensity=asinh(canal_den)
gen ashcourierden=asinh(courier_length/(AREA/10000))
global canal ashdensity
global courier ashcourierden
preserve
duplicates drop OBJECTID, force
drop year
rename town1820_r10canal canalside1820
rename town1911_r10canal canalside1911
rename town1820_r10courier courierside1820
rename town1911_r10courier courierside1911
reshape long town canalside courierside, i(OBJECTID) j(year)
gen canal_after=${canal}*(year==1911)
replace town=ln(town)
label variable town "Town Number (ln)"
label variable canal_after "Canal $\times$ Post"

*** Run the regression
reghdfe town canal_after, absorb(i.OBJECTID i.year) cluster(OBJECTID)
eststo trade1
su town if e(sample)
scalar y2mean=r(mean)
qui tab OBJECTID if e(sample)
scalar groups=r(r)
estadd scalar depavg=y2mean:trade1
estadd scalar N_g=groups:trade1

*** Obtain Conley standard error
if $RUN_CONLEY {
canal_hdfe town canal_after, clear absorb(i.OBJECTID i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC town canal_after, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: trade1
}
restore

********************************************************
*** Heterogeneous effects
********************************************************
gen canal_after=${canal}*reform
label variable canal_after "Canal $ \times $ Post"
gen triplecourier=${canal}*reform*${courier}
gen courier_after=reform*${courier}
label variable triplecourier "Canal $ \times $ Courier $ \times $ Post"
label variable courier_after "Courier $ \times $ Post"
gen tripledisaster=${canal}*reform*disaster
gen disaster_canal=${canal}*disaster
label variable tripledisaster "Canal $ \times $ Temperature Anomaly $ \times $ Post"
label variable disaster_canal "Canal $ \times $ Temperature Anomaly"

*** Run the regressions

*** Substitution
reghdfe $Y canal_after courier_after triplecourier, absorb(i.OBJECTID i.year) cluster(OBJECTID)
eststo trade2
su $Y if e(sample)
scalar y2mean=r(mean)
qui tab OBJECTID if e(sample)
scalar groups=r(r)
estadd scalar depavg=y2mean:trade2
estadd scalar N_g=groups:trade2

preserve
if $RUN_CONLEY {
canal_hdfe $Y canal_after courier_after triplecourier, clear absorb(i.OBJECTID i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y canal_after courier_after triplecourier, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: trade2
}
restore

*** Mitigation
reghdfe $Y canal_after disaster disaster_canal disaster_after tripledisaster, absorb(i.OBJECTID i.year) cluster(OBJECTID)
eststo trade3
su $Y if e(sample)
scalar y2mean=r(mean)
qui tab OBJECTID if e(sample)
scalar groups=r(r)
estadd scalar depavg=y2mean:trade3
estadd scalar N_g=groups:trade3

preserve
if $RUN_CONLEY {
canal_hdfe $Y canal_after disaster disaster_canal disaster_after tripledisaster, clear absorb(i.OBJECTID i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y canal_after disaster disaster_canal disaster_after tripledisaster, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: trade3
}
restore

*** Get indicators of FEs
capture quietly estfe trade1 trade2 trade3



* 导出本节当前保存的全部估计。b() 控制系数位数，se() 输出县聚类标准误。
esttab _all using "$TABLE_DIR/tableA5_trade_access.csv", replace csv b(4) se(4) label compress
display as result "已导出：$TABLE_DIR/tableA5_trade_access.csv"

**************************************************************************
*** TableA6. Canal closure and rebellions: agricultural productivity
* 机制检验：考察粮价及水稻/小麦适宜度三重交互，识别农业商业化异质性。
**************************************************************************
canal_prepare

gen ashdensity=asinh(canal_den)
global canal ashdensity
gen triplerice=${canal}*reform*suitable_rice_good
gen triplewheat=${canal}*reform*suitable_wheat_good
gen canal_after=${canal}*reform
label variable triplerice "Canal $ \times $ Rice suitability $ \times $ Post"
label variable triplewheat "Canal $ \times $ Wheat suitability $ \times $ Post"
label variable rice_after "Rice suitability $ \times $ Post"
label variable wheat_after "Wheat suitability $ \times $ Post"
label variable canal_after "Canal $ \times $ Post"
global X_rice canal_after rice_after triplerice
global X_wheat canal_after wheat_after triplewheat

reghdfe mp canal_after, absorb(i.OBJECTID i.year) cluster(OBJECTID)
eststo agri1
su mp if e(sample)
scalar y2mean=r(mean)
qui tab OBJECTID if e(sample)
scalar groups=r(r)
estadd scalar depavg=y2mean:agri1
estadd scalar N_g=groups:agri1

preserve
if $RUN_CONLEY {
canal_hdfe mp canal_after, clear absorb(i.OBJECTID i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC mp canal_after, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: agri1
}
restore

reghdfe $Y $X_rice, absorb(i.OBJECTID i.year) cluster(OBJECTID)
eststo agri2
su $Y if e(sample)
scalar y2mean=r(mean)
qui tab OBJECTID if e(sample)
scalar groups=r(r)
estadd scalar depavg=y2mean:agri2
estadd scalar N_g=groups:agri2

preserve
if $RUN_CONLEY {
canal_hdfe $Y $X_rice, clear absorb(i.OBJECTID i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X_rice, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: agri2
}
restore

reghdfe $Y $X_wheat, absorb(i.OBJECTID i.year) cluster(OBJECTID)
eststo agri3
su $Y if e(sample)
scalar y2mean=r(mean)
qui tab OBJECTID if e(sample)
scalar groups=r(r)
estadd scalar depavg=y2mean:agri3
estadd scalar N_g=groups:agri3

preserve
if $RUN_CONLEY {
canal_hdfe $Y $X_wheat, clear absorb(i.OBJECTID i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X_wheat, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@))
estadd matrix sesp=SE_spat: agri3
}
restore

*** Get indicators of FEs
capture quietly estfe agri1 agri2 agri3




* 导出本节当前保存的全部估计。b() 控制系数位数，se() 输出县聚类标准误。
esttab _all using "$TABLE_DIR/tableA6_agricultural_productivity.csv", replace csv b(4) se(4) label compress
display as result "已导出：$TABLE_DIR/tableA6_agricultural_productivity.csv"

**************************************************************************
*** TableA7. Canal closure and the Green Gang
* 长期结果：县级横截面回归检验运河县与青帮资深成员分布的相关性。
**************************************************************************
canal_prepare

collapse (mean) green_senior alongcanal prefid provid, by(OBJECTID)
global canal alongcanal
*** Main estimates
xi:reg green_senior $canal i.prefid, robust
eststo pst1
su green_senior if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:pst1
































* 导出本节当前保存的全部估计。b() 控制系数位数，se() 输出县聚类标准误。
esttab _all using "$TABLE_DIR/tableA7_green_gang.csv", replace csv b(4) se(4) label compress
display as result "已导出：$TABLE_DIR/tableA7_green_gang.csv"
display as result "============================================================"
display as result "默认复现流程运行结束。"
display as result "图形目录：$FIGURE_DIR"
display as result "表格目录：$TABLE_DIR"
display as result "日志目录：$LOG_DIR"
display as result "如需慢速附录，请修改顶部 RUN_* 开关后重新运行。"
display as result "============================================================"
capture log close replication
