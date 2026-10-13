# Regulating Conglomerates：研究与写作讲义

以 Chen et al. (2025, AER) 为例，学习论文内容、课堂表达与研究写作逻辑。

- [在线讲义](index.html)：42 页内容 + 每页逐字稿 + 每页 6 项研究写作拆解。
- [研究设计工作坊](writing-workshop.html)：从最小两厂模型逐步引出不完全转移、市场均衡、验证和福利评价。含独立教学模型与可导出的个人研究提纲。
- [课堂演示稿](presentation.html)：黑金主题、少量粉色。N 显示逐字稿，W 显示写作拆解，P 打开演讲者窗口，方向键翻页。保留 20 分钟精简路线。
- [可打印逐字稿及写作拆解](script.html)：浏览器打印为浅色版，适合纸面批注。
- [写作拆解 Markdown](writing-notes.md)。

讲义中的写作分析和示范段落是教学性重写，不声称还原作者的真实研究顺序。工作坊两厂模型是独立教学推导，不是原文模型或实证估计。源文件中的图表截图来自用户提供的论文稿本，正文以表号、章节定位。正式出处：[AEA](https://www.aeaweb.org/articles?id=10.1257/aer.20211455)。

练习与阅读进度仅存于当前浏览器 localStorage，不上传服务器，不跨设备同步。可自行导出 Markdown。

## 维护

静态站点，无需 Node 或第三方依赖。内容源在 `src/lessons.json`、`src/writing.json`、`src/workshop-body.html`。修改后从仓库任意路径执行：

```sh
python3 Regulating-Conglomerates/tools/build.py
```

讲义布局为 `lecture.css`，交互为 `lecture.js` 与 `workshop.js`。`src/presentation.base.html` 保留原演示稿，构建时追加黑金粉主题和逐页写作抽屉。部署使用仓库 `main` 分支根目录的 GitHub Pages，不覆盖其他文献页面。
