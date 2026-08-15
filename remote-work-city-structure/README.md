# Remote Work and City Structure — 官方复现代码包详解

> **论文：** Monte, Ferdinando, Charly Porcher, and Esteban Rossi-Hansberg. "Remote Work and City Structure." *American Economic Review*, 2026, 116(8): 3152–3196.
>
> **本目录内容：** 论文官方复现代码包 `Remote Work and City Structure.zip`（分卷存放）+ 阅读笔记 [remote.md](remote.md) + 正文 PDF + 复现代码包内容详解（本文档）。

---

## 一、压缩包概况

`Remote Work and City Structure.zip` 是论文作者发布的官方复现包：

| 项目 | 数值 |
|---|---|
| 压缩包大小 | **3.93 GB**（4,228,760,229 字节） |
| 解压后大小 | **约 23 GB**（24,693,915,817 字节） |
| 文件总数 | **455 个** |
| 顶层目录 | `code/`、`data/`、`output/`、`documentation/`、`logs/` 及 `LICENSE.txt`、`README.pdf` |

> ⚠️ **为什么分卷存放？** GitHub 对单个仓库文件有 **100 MB 硬性上限**，3.93 GB 的压缩包无法直接上传。因此拆分为 **45 个 95 MB 的分卷**（`Remote-Work-and-City-Structure.zip.part000` … `part044`）。合并方法见文末「分卷恢复」一节，SHA256 校验已通过，分卷与原文件逐字节一致。

---

## 二、目录结构总览（按大小）

```
Remote Work and City Structure.zip
├── LICENSE.txt                         1.8 KB   代码 MIT / 数据 CC BY 4.0
├── README.pdf                         370 KB    22 页复现说明文档
├── code/                               约 1 MB   完整复现流水线（Stata + MATLAB + Mathematica）
├── data/                               约 17 GB  原始与中间数据（多为商业/受控数据）
├── documentation/                      约 3.8 MB 31 个数据 codebook
├── output/                             约 6.5 GB 全部中间结果与图表
└── logs/                               空目录    运行日志（复现时生成）
```

---

## 三、`code/` — 复现流水线（约 55 个文件，约 1 MB）

三种软件分工：**Stata** 完成绝大部分数据构建与参数估计；**MATLAB**（需 Mapping Toolbox）做 CBD 定位；**Mathematica** 求解多重性锥与福利。

### 编排脚本
| 文件 | 作用 |
|---|---|
| `rundirectory.sh` | 总入口，按「安装 → 构建 → 分析 → 出图」顺序逐条调用 do-file，并在 MATLAB / Mathematica 两个手工步骤处暂停等待 |
| `install_stata_packages.do` | 安装所需用户自写 Stata 包（`reghdfe`、`ivreghdfe`、`fastreshape`、`geodist` 等） |

### `code/build/`（21 个文件）— 数据构建层
- `dataset_aux1.do` / `dataset_aux2.do` — 公共辅助数据准备
- `dataset_trips.do`、`dataset_trips_cbd.do`、`dataset_trips_cbd_work.do` — SafeGraph 手机足迹 → 通勤面板
- `dataset_housing.do`、`dataset_housing_aux.do` — Zillow ZHVI 房价
- `dataset_nhgis.do`、`dataset_nhgis_aux.do` — NHGIS 街区组租金
- `dataset_nlsy.do`、`dataset_nlsy_2022.do`、`dataset_nlsy_aux.do`、`dataset_nlsy_geocode.do`（受控数据）— NLSY79 工资面板
- `dataset_census.do`、`dataset_census_2022.do`、`dataset_census_2023.do`、`dataset_census_aux.do` — IPUMS 普查/ACS
- `dataset_employment_concentration.do` — 行业就业集中度
- `define_cbd.m` — **MATLAB 脚本**：网格搜索每个都会区的 CBD 中心

### `code/analysis/`（20 个文件）— 估计与表格层
- Stata 表格脚本：`tables_share_remote.do`（远程份额）、`tables_trips_cbd.do`（通勤缺口）、`tables_housing.do`（房价梯度）、`tables_transition_elasticity.do`（转移弹性与切换成本）、`tables_remote_work_premium.do`（远程工资溢价）、`tables_elasticity_substitution.do`、`tables_nhgis.do`、`tables_delta.do` / `tables_alternative_delta.do`（集聚外部性）、`tables_calibration.do`（校准）、`tables_determinants_multiplicity.do`（锥内判定）、`tables_robustness_elasticities.do`、`tables_welfare_sensitivity_xi_theta.do` 等
- **Mathematica 笔记本**（需手工运行）：
  - `analysis_multiplicity.nb` — 核心：求解多重性锥 `[coneLow, coneHigh]` 与福利差
  - `tables_employment_concentration.nb` — 就业集中度相关
  - `sensitivity_to_xi_theta.nb` — 对 `ξ、θ` 的敏感性

### `code/figures/`（9 个 do-file）— 出图层
`figures_opening_facts.do`（开篇事实）、`figures_trip_shortfall.do`（通勤缺口）、`figures_rent_gradients.do`（租金梯度）、`figures_remote_work_premium.do`（远程溢价）、`figures_delta_vs_alt_delta.do`、`figures_welfare.do`（福利）、`figures_delta_gamma_z_vs_trip_shortfall.do`、`figures_delta_gamma_cone_vs_size.do`（锥与规模）

---

## 四、`data/` — 数据（约 17 GB）

> 注意：SafeGraph 手机定位、IPUMS 原始微观数据、NLSY geocode 为**商业或受控数据**，许可协议见 `LICENSE.txt`。

| 子目录 | 大小 | 内容 |
|---|---|---|
| `SafeGraph/` | 空 | 手机定位足迹（商业授权，未随包重分发；`dataset_trips.do` 需自行放置） |
| `census/` | 14.4 GB | **IPUMS 微观样本**：`ipums_sample_00023.dta`（**14.2 GB**）、`00024`（469 MB）、`00025`（459 MB）；`cbsa-est2020/21/23-alldata.csv` 都会区人口估计；`cpi_1969-2023.dta`；职业代码 crosswalk |
| `nlsy/` | 194 MB | NLSY79 面板：`tagset6/tagset6.dta`（120 MB）、`tagset8/tagset8.dta`（83 MB） |
| `housing/` | 1.4 GB | **Zillow ZHVI**（113 MB CSV，邮编级房价指数）；**NHGIS** 住房：`nhgis_housing_blck_grp.dta`（838 MB）、`_tract_a`（280 MB）、`_tract_b`（179 MB）；`controls_msa.dta`、`housing_blockg_acs.dta` |
| `geography/` | 650 MB | CBG/ZCTA/PUMA/郡县 crosswalk、`2020_Gaz_zcta_national.txt`（ZCTA 地理）、`Lee_Lin_data.dta`（307 MB，房价工具数据）、BEA 就业、`downtown_google_maps_lat_lon.csv` |
| `CBP/` | 51 MB | 人口普查局 County Business Patterns：`cbp19msa.txt`（53 MB） |
| `agglomeration_externality/` | 111 MB | `cbp19co.txt`（116 MB，县级 CBP）、`gamma_njs.csv`（集聚外部性参数） |

---

## 五、`output/` — 中间结果与图表（约 6.5 GB）

| 子目录 | 大小 | 内容 |
|---|---|---|
| `calibration/` | 2.1 MB | **核心输出**：`allCitiesCones.csv`（全部城市的多重性锥上下界、福利差、相对工资变化）等逐城校准文件 |
| `figures/` | 5.6 MB | 论文全部 100 张图 |
| `tables/` | — | 回归表格（约 21 个） |
| `tables_aux/` | 95 MB | 72 个辅助表（远程份额、远程溢价按城市/职业、CBD 访问量等） |
| `census/` | 4.2 GB | 构建好的普查/ACS 面板 |
| `geography/` | 203 MB | 地理构建面板 |
| `housing/` | 1.4 GB | 房价/租金距离梯度面板 |
| `nlsy/` | 327 MB | NLSY 构建面板 |
| `trips_cbd/` | 428 MB | 通勤面板：`visits_by_orig_tract_cbsa*.dta`（分城市）、`nb_trips_cbg_2019.csv`（27 MB）、`temp/cbds_3_lat_lon_radius_1_cbsa_*.csv`（CBD 定位结果） |
| `agglomeration_externality/` | 3.4 MB | 集聚估计结果 |
| `CBP/` | — | CBP 构建结果 |

---

## 六、复现流程

1. 合并分卷并解压（见下节），得到完整的复现包目录。
2. 安装 **StataNow / Stata MP/SE**、**MATLAB + Mapping Toolbox**、**Mathematica**。
3. 若需从原始数据重跑，需自行准备 **SafeGraph** 数据；IPUMS/NLSY 原始文件已在包内。
4. 运行 `bash code/rundirectory.sh`：
   - **Stage 1 构建**：Stata 跑完 `dataset_aux1` 后，脚本停在 **MATLAB 手工步骤**（运行 `define_cbd.m` 生成 CBD 定位文件），回车继续；
   - **Stage 2 分析**：Stata 跑完核心表格后，脚本停在 **Mathematica 手工步骤**（运行 `analysis_multiplicity.nb` 等三个笔记本），回车继续；
   - **Stage 3 出图**：Stata 跑完 8 个图脚本结束。
5. 日志写入 `logs/`。

---

## 七、论文核心结论（与代码的对应）

- **问题：** 一次临时冲击（疫情封锁导致通勤骤降）能否**永久**改变一座城市的结构？
- **机制：** 通勤行为存在自我强化的外部性 → 模型存在**两个稳态**（高通勤 / 低通勤），疫情把部分城市从高通勤稳态推到低通勤稳态后无法自动弹回。
- **数据与估计：** SafeGraph 手机定位、IPUMS/NLSY 微观工资、Zillow 房价、NHGIS 租金等七类数据，估计出转移弹性 `s`、切换成本 `F`、远程工资溢价、集聚外部性 `δ` 等参数。
- **结果：** 参数齐全的 278 个都会区中，**208 个**在疫情前就处于多重性锥内；切换到低通勤稳态的平均福利损失 **2.3%**（区间 1.2%–4.0%）。
- 阅读笔记详见 [remote.md](remote.md)，每步估计对应的 do-file 在笔记中逐段拆解。

---

## 八、许可说明

`LICENSE.txt` 明确：
- **代码**：MIT License（© 2026 Monte, Porcher, Rossi-Hansberg）
- **可重分发的数据**：CC BY 4.0
- **未覆盖**：原始 IPUMS 微观数据、SafeGraph 数据、受限 NLSY geocode 数据（其再分发须遵守各数据提供方的条款）

---

## 九、分卷恢复

```bash
# 进入本目录后运行：
bash combine.sh
```

脚本会：① `cat` 拼接 45 个分卷 → `Remote Work and City Structure.zip`；② 校验 SHA256 是否等于 `0eb33cc6475e4787d140509f787c5c67eb9b824ced1c0ec90039fdacb7e8ad08`；③ 提示解压命令。各分卷哈希同时记录在 [SHA256SUMS](SHA256SUMS) 中。
