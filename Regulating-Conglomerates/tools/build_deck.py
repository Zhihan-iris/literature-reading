"""Build a 16:9 academic HTML deck with original paper tables and source-code references."""
from pathlib import Path
import json,html,base64,re
ROOT=Path(__file__).resolve().parents[1];E=html.escape

def build():
 slides=json.loads((ROOT/'src/deck.json').read_text());reader=json.loads((ROOT/'src/reader.json').read_text());css=(ROOT/'deck.css').read_text();js=(ROOT/'deck.js').read_text();N=len(slides);articles=[];nav=[];codes=[]
 def embed(m):
  path=m.group(2);data=base64.b64encode((ROOT/path).read_bytes()).decode();return m.group(1)+'="data:image/png;base64,'+data+'"'
 for i,s in enumerate(slides,1):
  refs=s['reader'];codepages=[r for r in refs if reader[r-1]['codes']];source=s['source'] or 'Chen et al. (2025) · '+ '；'.join(reader[r-1]['source'].split('；')[0] for r in refs)
  if len(source)>145:source=source[:142]+'…'
  links=f'<a href="index.html#{refs[0]}" target="_blank" rel="noopener">详细讲义 ↗</a>'
  if codepages:links=f'<button data-code="{",".join(map(str,codepages))}">对应代码</button>'+links
  articles.append(f'<section class="slide {s["kind"]}" id="slide-{i}" aria-label="第 {i} 页：{E(s["title"])}"><header class="slide-head"><p class="eyebrow"><span>{E(s["section"])}</span><span>REGULATING CONGLOMERATES · {i:02} / {N}</span></p><h1>{s["title"]}</h1></header><div class="slide-body">{s["body"]}</div><footer class="slide-footer"><span class="source">{E(source)}</span><span class="footer-links">{links}</span></footer></section>')
  nav.append(f'<a href="#{i}"><span>{i:02}</span>{E(s["title"])}</a>')
 for n,s in enumerate(reader,1):
  for c in s['codes']:
   lines=''.join(f'<span class="code-line"><span class="lineno">{k}</span><code>{E(line)}</code></span>' for k,line in enumerate(c['lines'],c['start']))
   codes.append(f'<article data-reader="{n}"><h3>{E(c["path"])}</h3><p class="code-meta">原文件第 {c["start"]}–{c["end"]} 行 · {E(c["status"])}</p><pre tabindex="0">{lines}</pre><h3>计算与结果的对应关系</h3><p>{E(c["explain"])}</p><a href="index.html#{n}" target="_blank" rel="noopener">相关讲义：{E(s["title"])}</a></article>')
 doc=f'''<!doctype html><html lang="zh-CN"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="theme-color" content="#0d0d0d"><meta name="description" content="监管企业集团：38页黑金学术演示，原文Table 1–5、DID与聚类标准误、结构模型及24处复现代码解释。"><title>监管企业集团 · Zhihan 学术汇报</title><style>{css}</style></head><body><main id="viewport"><div id="stage">{''.join(articles)}</div></main><div class="progress" id="progress"></div><nav class="controls" aria-label="演示导航"><button id="prev" aria-label="上一页">←</button><label><input id="jump" type="number" min="1" max="{N}" aria-label="跳转页码"> / {N}</label><button id="next" aria-label="下一页">→</button><span class="divider"></span><button id="toc-open">目录</button><button id="all-code">代码索引</button><button id="fullscreen">全屏</button><button id="print">打印</button></nav><dialog id="toc"><header><h2>报告目录</h2><button data-close aria-label="关闭目录">关闭 ×</button></header><nav>{''.join(nav)}</nav></dialog><dialog id="image-dialog"><header><h2>原文图表</h2><button data-close aria-label="关闭原图">关闭 ×</button></header><img alt="原文图表"></dialog><dialog id="code-dialog"><header><h2>复现代码与结果解释</h2><button data-close aria-label="关闭代码">关闭 ×</button></header>{''.join(codes)}</dialog><script>{js}</script></body></html>'''
 doc=re.sub(r'(src|data-image)="(assets/[^"]+\.png)"',embed,doc)
 (ROOT/'presentation.html').write_text(doc)
 print(f'Built academic deck: {N} slides, {len(codes)} code excerpts')
if __name__=='__main__':build()
