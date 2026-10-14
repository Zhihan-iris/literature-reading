# 监管企业集团：论文解读与复现代码导读

- [新版详细讲义：正文、附录与阅读思考](handout.html)
- [原版连续阅读与代码导读](index.html)
- [逐页呈现文稿](presentation.html)

当前 `presentation.html` 为20页演示版，按用户提供的框架保留要点与完整讲稿。第2—20页的补充文字位于页底，字号明显小于正文，可一键隐藏，不显示“讲稿”标签；首页不放补充文字。企业分类、DID分组与监管覆盖率按原稿绘制示意图。正文配有 Figure 2、3、4、5、6、7 的相应面板，点击可查看原图。详细讲义 `handout.html` 独立保留。

## 操作

演示稿支持目录、页码跳转、方向键、全屏、隐藏／显示讲稿和打印。桌面为16:9画布，手机切换为单列阅读。打印输出20页，包含讲稿。离线阅读需保留 `presentation.html` 与 `assets/` 的相对位置。

## 构建

- 当前原稿：`src/presentation-original.md`，与用户附件逐字节一致。
- 排版与数学格式：`tools/build_presentation.cjs`。
- 样式与交互：`presentation.css`、`presentation.js`。
- 原图：`assets/` 与 `assets/handout/`；面板通过CSS取景，完整原图保持不变。
- 精简版构建：`node tools/build_presentation.cjs`。
- 详细讲义构建：`node tools/build_handout.cjs`。
- 旧版连续阅读页构建：`python3 tools/build.py --reader-only`。
- `python3 tools/build.py` 同时构建旧版阅读页和当前精简演示版；需要 Node.js，或通过 `NODE_BINARY` 指定可执行文件。

原38页演示稿的结构数据 `src/deck.json` 保留作历史参考；当前演示稿使用20页更新稿；17页原稿 `src/concise-original.md` 留存作历史参考。

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
