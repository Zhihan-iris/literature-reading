"""Generate the reader-facing lecture and presentation (Python standard library)."""
from pathlib import Path
import json,html
ROOT=Path(__file__).resolve().parents[1];E=html.escape
slides=json.loads((ROOT/'src/reader.json').read_text());N=len(slides)
css=(ROOT/'lecture.css').read_text();js=(ROOT/'lecture.js').read_text()
nav='';last=None;sections=[]
for i,s in enumerate(slides,1):
 if s['section']!=last:nav+='<p class="chapter">'+E(s['section'])+'</p>';last=s['section']
 nav+=f'<a href="#{i}" data-slide="{i}"><span>{i:02}</span>{E(s["title"])}</a>'
 codes=''
 for j,c in enumerate(s['codes']):
  lines=''.join(f'<span class="code-line"><span class="lineno">{n}</span><code>{E(t)}</code></span>' for n,t in enumerate(c['lines'],c['start']))
  codes+=f'<details class="code-block"><summary>对应代码 {j+1} <span>{E(c["path"])}</span></summary><div class="code-inner"><p class="code-meta">原文件第 {c["start"]}–{c["end"]} 行 · {E(c["status"])}</p><pre tabindex="0" aria-label="源码摘录">{lines}</pre><h3>代码说明</h3><p>{E(c["explain"])}</p></div></details>'
 sections.append(f'<article class="page" id="page-{i}" data-page="{i}"><header class="page-head"><p class="eyebrow">{E(s["section"])} <span>READING {i:02} / {N}</span></p><h1>{E(s["title"])}</h1><p class="subtitle">{E(s["sub"])}</p></header><div class="body">{s["body"]}</div>{codes}<footer class="source"><span>来源与定位</span>{E(s["source"])}</footer><nav class="page-bottom"><button data-prev>← 上一页</button><span>{i:02} / {N}</span><button data-next>下一页 →</button></nav></article>')
for filename,mode in [('presentation.html','single'),('index.html','reading')]:
 doc=f'''<!doctype html><html lang="zh-CN"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="theme-color" content="#101012"><meta name="description" content="监管企业集团：52页中文论文讲义，含政策背景、DID、结构模型、福利分析、24处复现代码与实际运行核验。"><title>监管企业集团 · 论文解读与复现代码</title><style>{css}</style></head><body class="{mode}"><a class="skip" href="#main">跳到正文</a><header class="topbar"><a class="brand" href="index.html">LITERATURE <span>／</span> 监管企业集团</a><div class="tools"><button id="toc-toggle" aria-controls="toc" aria-expanded="false">目录</button><button id="mode">{'连续阅读' if mode=='single' else '逐页呈现'}</button><button id="fullscreen">全屏</button><button id="print">打印</button></div></header><aside id="toc" aria-label="章节目录" hidden><div class="toc-title"><h2>阅读目录</h2><button id="toc-close" aria-label="关闭目录">×</button></div><input type="search" id="search" placeholder="搜索页面标题" aria-label="搜索页面标题">{nav}</aside><main id="main">{''.join(sections)}</main><div class="bottom"><button data-prev aria-label="上一页">←</button><label><input id="jump" type="number" min="1" max="{N}" value="1" aria-label="跳转页码"> / {N}</label><span id="current-title"></span><button data-next aria-label="下一页">→</button></div><div class="progress" aria-hidden="true"><div id="progress"></div></div><script>{js}</script></body></html>'''
 (ROOT/filename).write_text(doc)
print(f'Built {N} pages / {sum(len(s["codes"]) for s in slides)} code excerpts')
