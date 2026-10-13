# 监管企业集团：论文解读与复现代码导读

- [新版详细讲义：正文、附录与阅读思考](handout.html)
- [原版连续阅读与代码导读](index.html)
- [逐页呈现文稿](presentation.html)

38 页 16:9 学术演示与 52 页详细讲义。黑金主题，仅首页汇报人 Zhihan 使用粉色。内容按政策背景、数据与 DID、实证结果、集团模型、福利与政策启示展开，含 24 处带原文件行号的代码摘录与中文解释。面向读者的页面仅含论文内容和复现解释。

## 操作

演示稿通过目录、底部页码或左右方向键切换。Table 1–5 使用原文截图，较长表格按面板放大；点击查看完整原表及表注。页面“对应代码”与“代码索引”提供原始源码和解释。打印演示稿输出 38 页；完整讲义的打印版包含所有代码。两个 HTML 均内嵌样式、脚本和图像，可离线打开。

## 构建

演示稿修改 `src/deck.json`、`deck.css`、`deck.js`；完整讲义修改 `src/reader.json`、`lecture.css`、`lecture.js`。原表截图位于 `assets/`，裁切来源记录于 `assets/sources.json`。统一构建：

```sh
python3 tools/build.py
```

## 核验范围

用户提供的 `196012-V1` 根目录副本不含 `.dta` 文件，因此未重跑微观回归。2026-10-11 使用 MATLAB R2024a 在独立副本运行 `Estimation/Main_test.m`、`Counterfactual Baseline/Main.m` 与 `Main_compare.m`。这是给定参数／数据矩下的模型求解，不是重新估计全篇论文。

结果保存在 `src/verified-results.json`。复现得出对数口径净节能 3.9644%、价格变化 3.4857%、GWTP 161.45 美元／吨 CO₂。门槛约 9.3443，与论文报告的 9.289 有差异。投入分解代码存在需核对的变量引用，详见讲义第 51 页，不能将相应预测视为已确认复现。

原始微观数据、软件和完整复现包不包含在此网站。代码摘录保留来源与行号；论文原图仅用于对应结果的学术说明。

论文：Chen et al. (2025), AER 115(2):408–447，DOI 10.1257/aer.20211455。代码来源：作者 openICPSR 项目 196012，用户提供的 V1 副本。

## 新版详细讲义（2026-10-13）

`handout.html` 按用户提供的思路框架整理为17章，嵌入正文全部7张图、5张表，以及22处附录图表截图。273处公式使用预生成的原生 MathML，不依赖外部 CDN；图表点击放大、目录全文搜索、手机导航与打印均可使用。保留原版讲义和演示稿。

- 可编辑内容：`src/handout.md`
- 样式与交互：`handout.css`、`handout.js`
- 图表和裁切定位：`assets/handout/`、`assets/handout/sources.json`
- 构建：`node tools/build_handout.cjs`（Node.js；构建所需 marked、KaTeX及许可证已随仓库保存，运行页面不加载这些库）

主要核对：区分企业DID与总体变化；重写41%转移量计算；纠正固定资本下投入转移指数为 `1/(1-alpha_l)`；区分GWTP与SCC及CO₂单位；明确114—199美元是模型敏感性范围，非置信区间。第8章数表是给定价格的代数校验，并非完整微观或均衡复现。

在线路径：<https://zhihan-iris.github.io/literature-reading/Regulating-Conglomerates/handout.html>。本地离线阅读需保留 `handout.html` 与 `assets/handout/` 的相对目录。正文、附录PDF未重复上传，图表保留出处与页码。
