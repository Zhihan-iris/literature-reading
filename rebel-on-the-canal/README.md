# Rebel on the Canal

本文件夹整理 Cao and Chen（2022, *American Economic Review*）“Rebel on the Canal”的数据与可复现代码。

## 文件结构

- `canal_data/canal_rebellion.dta`：县—年面板数据。
- `canal_analysis.do`：Zhihan Lin 整理的单一主 do 文件，包含数据准备、基准 DID、事件研究、稳健性检验、CIC、合成控制和 Conley 标准误。
- `canal_reproduction.ipynb`：辅助教学 notebook。
- `replication_output/`：运行后自动生成的图、表、中间数据和日志，不需要预先创建。

## 运行方式

```stata
cd "literature-reading/rebel-on-the-canal"
do "canal_analysis.do" 0 0 0 0 100
```

五个参数依次为：`RUN_CONLEY`、`RUN_CONLEY_GRID`、`RUN_CIC`、`RUN_SYNTH` 和 `CIC_REPS`。

一次打开本次已验证的全部模块：

```stata
do "canal_analysis.do" 1 0 1 1 100
```

代码只读取当前文件夹下的 `canal_data/canal_rebellion.dta`，不包含任何本机绝对路径。运行前请安装 Stata 依赖：

```stata
ssc install reghdfe
ssc install ftools
ssc install estout
ssc install ols_spatial_HAC
ssc install matmap
ssc install synth
ssc install synth_runner
```

CIC 的低内存实现已直接写在主 do 文件中，不再依赖外部 `cic.ado`。`RUN_CONLEY_GRID=1` 是更慢的距离—时间截断值敏感性分析，默认关闭。

整理者：**Zhihan Lin**。
