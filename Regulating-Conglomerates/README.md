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

`handout.html` 按用户要求完整使用最初提供的16章原稿，保留原有描述、数字、公式及思考，不改写或润色。嵌入正文全部7张图、5张表，以及22处附录截图，每处图表均附读图说明、结果解释和来源页码。公众号新增细节以原文节选补入对应章节，11段代码摘录与16处长推导默认折叠，核心公式保持可见。公式采用预生成 MathML，页面支持图表放大、目录搜索、手机阅读与打印。

- 原稿：`src/handout.md`（与用户最初提供的文本逐字节一致）
- 图表位置：`src/handout-figures.json`（独立配置，避免改动原稿）
- 公众号原文与补充位置：`src/wechat-original.md`、`src/handout-supplements.json`（摘录逐字保留；代码节选未经重新运行）
- 图表解释：`src/handout-captions.json`
- 折叠与排版：`tools/prepare_handout.cjs`（仅改变展示，不改写原稿）
- 样式与交互：`handout.css`、`handout.js`
- 图表及来源：`assets/handout/`、`assets/handout/sources.json`
- 构建：`node tools/build_handout.cjs`（构建依赖及许可证随仓库提供）

在线地址：<https://zhihan-iris.github.io/literature-reading/Regulating-Conglomerates/handout.html>。离线阅读需保留页面与图表目录的相对位置。页面不含原版阅读或演示稿的跳转。
