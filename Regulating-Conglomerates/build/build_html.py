# -*- coding: utf-8 -*-
"""Build a single self-contained HTML slide deck from the same SLIDES spec.

Output is one .html file with images embedded as base64, keyboard navigation,
a speaker-notes panel, a table of contents, and print-to-PDF support.
No network, no server, no external files.
"""
import base64, os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from build_ppt import SLIDES, ASSETS
from preview import render_slide

ROOT = "/Users/iris/Desktop/文献阅读/Regulating Conglomerates"
OUT = os.path.join(ROOT, "output/汇报PPT/Regulating_Conglomerates_演示稿.html")

_cache = {}


def datauri(name):
    if name not in _cache:
        with open(os.path.join(ASSETS, name), "rb") as f:
            _cache[name] = "data:image/png;base64," + base64.b64encode(f.read()).decode()
    return _cache[name]


def notes_html(text):
    """Turn the plain-text speaker notes into paragraphs."""
    out = []
    for block in text.strip().split("\n\n"):
        block = block.strip()
        if not block:
            continue
        safe = (block.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;"))
        safe = re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", safe)
        safe = safe.replace("\n", "<br>")
        m = re.match(r"^【(.+?)】$", block)
        if m:
            out.append('<p class="ntime">%s</p>' % safe)
        else:
            out.append("<p>%s</p>" % safe)
    return "".join(out)


titles = []
sections = []
for spec in SLIDES:
    titles.append(spec.get("title") or "封面")
    sections.append(spec.get("eyebrow") or "")

slide_blocks = []
for i, spec in enumerate(SLIDES, 1):
    html = render_slide(spec, i, len(SLIDES), img_src=datauri)
    inner = html.split("<body>", 1)[1].rsplit("</body>", 1)[0]
    inner = inner.replace("<img src='data:image/png;base64,",
                          "<img data-zoom='1' src='data:image/png;base64,")
    slide_blocks.append(
        '<section class="slide%s" id="s%d"><div class="canvas">%s</div></section>'
        % (" active" if i == 1 else "", i, inner)
    )

notes_blocks = []
for i, spec in enumerate(SLIDES, 1):
    notes_blocks.append(
        '<div class="npane%s" id="n%d"><h3>%02d · %s</h3>%s</div>'
        % (" active" if i == 1 else "", i, i, titles[i - 1],
           notes_html(spec.get("notes", "")))
    )

toc_items = "".join(
    '<a href="#%d" data-goto="%d"><span>%02d</span><b>%s</b><i>%s</i></a>'
    % (i, i, i, titles[i - 1], sections[i - 1])
    for i in range(1, len(SLIDES) + 1)
)

CSS = """
*{margin:0;padding:0;box-sizing:border-box}
:root{--ink:#1A1A1A;--accent:#A6192E;--muted:#767676;--line:#E4E4E0}
html,body{height:100%}
body{background:#2A2A2C;color:var(--ink);overflow:hidden;
 font-family:'PingFang SC','Microsoft YaHei',-apple-system,sans-serif}
#viewport{position:absolute;inset:0 0 46px 0;display:flex;align-items:center;
 justify-content:center;overflow:hidden}
#stage{position:relative;width:1280px;height:720px;transform-origin:center center;
 flex:none;background:#fff;box-shadow:0 18px 60px rgba(0,0,0,.45)}
.slide{position:absolute;inset:0;display:none}
.slide.active{display:block}
.canvas{position:absolute;inset:0;width:1280px;height:720px;background:#fff;
 font-family:'PingFang SC','Microsoft YaHei',-apple-system,sans-serif;color:var(--ink)}
.canvas img{background:#fff}
.canvas img[data-zoom]:hover{outline:2px solid var(--accent);cursor:zoom-in}
body.actual #viewport{overflow:auto;align-items:flex-start;justify-content:flex-start}
body.actual #stage{transform:none!important}
#hud{position:fixed;left:0;right:0;bottom:0;height:46px;background:#1C1C1E;
 border-top:1px solid #3A3A3C;display:flex;align-items:center;gap:10px;
 padding:0 16px;color:#D8D8DA;font-size:13px;z-index:40}
#hud .sp{flex:1}
#hud button{background:#2E2E30;color:#EDEDEF;border:1px solid #454547;
 padding:6px 13px;border-radius:4px;font-size:13px;cursor:pointer;
 font-family:inherit}
#hud button:hover{background:#3A3A3C}
#hud button:disabled{opacity:.3;cursor:default}
#pos{font-variant-numeric:tabular-nums;color:#EDEDEF}
#bar{position:fixed;left:0;bottom:46px;height:3px;background:var(--accent);
 z-index:41;transition:width .18s ease;width:0}
#notes{position:fixed;right:0;top:0;bottom:46px;width:420px;background:#161618;
 color:#E6E6E8;border-left:1px solid #3A3A3C;padding:26px 26px 40px;
 overflow-y:auto;z-index:39;transform:translateX(100%);
 transition:transform .2s ease}
#notes.open{transform:none}
body.notes-open #viewport{right:420px}
#notes h3{font-size:14px;color:#B9B9BD;font-weight:600;margin-bottom:16px;
 letter-spacing:.5px;position:sticky;top:-26px;background:#161618;
 padding:8px 0 12px;border-bottom:1px solid #333}
#notes p{font-size:15px;line-height:1.85;margin-bottom:14px;color:#DEDEE0}
#notes .ntime{color:var(--accent);font-weight:700;font-size:14px;
 background:#241A1C;border-left:3px solid var(--accent);padding:7px 12px;
 border-radius:3px;margin-bottom:18px}
.npane{display:none}
.npane.active{display:block}
#toc{position:fixed;inset:0;background:rgba(9,9,11,.985);z-index:60;display:none;
 backdrop-filter:blur(8px);overflow-y:auto;padding:66px 8vw}
#toc.open{display:block}
#toc h2{color:#fff;font-size:20px;margin-bottom:26px;font-weight:600}
#toc nav{display:grid;grid-template-columns:1fr 1fr;gap:8px 26px}
#toc a{display:flex;gap:14px;align-items:baseline;text-decoration:none;
 padding:11px 13px;border-bottom:1px solid #2E2E30;color:#DADADC}
#toc a:hover{background:#242426}
#toc a span{color:var(--accent);font-variant-numeric:tabular-nums;font-size:13px}
#toc a b{color:#fff;font-weight:600;font-size:14px;flex:1}
#toc a i{color:#8A8A8E;font-style:normal;font-size:12px}
#toc .hint{color:#8A8A8E;font-size:13px;margin-top:22px}
@media print{
 @page{size:1280px 720px;margin:0}
 body{background:#fff;overflow:visible}
 #viewport{position:static;inset:auto;display:block;overflow:visible}
 #stage{width:1280px;height:auto;transform:none!important;box-shadow:none}
 .slide{display:block!important;position:relative;width:1280px;height:720px;
  page-break-after:always;break-after:page}
 .canvas{position:relative}
 #hud,#bar,#notes,#toc{display:none!important}
}
"""

JS = """
(function(){
 var slides=[].slice.call(document.querySelectorAll('.slide'));
 var panes=[].slice.call(document.querySelectorAll('.npane'));
 var n=slides.length,cur=1;
 var stage=document.getElementById('stage');
 var pos=document.getElementById('pos'),bar=document.getElementById('bar');
 var notes=document.getElementById('notes'),toc=document.getElementById('toc');
 function fit(){
   var vp=document.getElementById('viewport');
   var s=Math.min((vp.clientWidth-48)/1280,(vp.clientHeight-48)/720);
   stage.style.transform='scale('+Math.min(s,1.6)+')';
 }
 function toggleNotes(){
   notes.classList.toggle('open');
   document.body.classList.toggle('notes-open',notes.classList.contains('open'));
   fit();
 }
 function show(i){
   i=Math.max(1,Math.min(n,i));
   if(i===cur&&slides[cur-1].classList.contains('active'))return;
   slides.forEach(function(s){s.classList.remove('active')});
   panes.forEach(function(p){p.classList.remove('active')});
   slides[i-1].classList.add('active');
   panes[i-1].classList.add('active');
   cur=i;
   pos.textContent=('0'+i).slice(-2)+' / '+n;
   bar.style.width=(i/n*100)+'%';
   if(location.hash!=='#'+i)history.replaceState(null,'','#'+i);
 }
 document.getElementById('prev').onclick=function(){show(cur-1)};
 document.getElementById('next').onclick=function(){show(cur+1)};
 document.getElementById('tocbtn').onclick=function(){toc.classList.toggle('open')};
 document.getElementById('notesbtn').onclick=toggleNotes;
 toc.onclick=function(e){
   var a=e.target.closest('a');if(!a)return;
   e.preventDefault();toc.classList.remove('open');show(+a.dataset.goto);
 };
 document.addEventListener('click',function(e){
   var img=e.target.closest('img[data-zoom]');
   if(img){window.open(img.src,'_blank')}
 });
 document.addEventListener('keydown',function(e){
   var k=e.key;
   if(k==='ArrowRight'||k==='ArrowDown'||k===' '||k==='PageDown'){e.preventDefault();show(cur+1)}
   else if(k==='ArrowLeft'||k==='ArrowUp'||k==='PageUp'){e.preventDefault();show(cur-1)}
   else if(k==='Home'){e.preventDefault();show(1)}
   else if(k==='End'){e.preventDefault();show(n)}
   else if(k==='n'||k==='N'){toggleNotes()}
   else if(k==='t'||k==='T'){toc.classList.toggle('open')}
   else if(k==='f'||k==='F'){document.body.classList.toggle('actual');fit()}
   else if(k==='Escape'){toc.classList.remove('open')}
 });
 window.addEventListener('resize',fit);
 var start=parseInt((location.hash||'').replace('#',''),10);
 fit();show(isNaN(start)?1:start);
})();
"""

html = (
    '<!DOCTYPE html>\n<html lang="zh-CN">\n<head>\n<meta charset="utf-8">\n'
    '<meta name="viewport" content="width=device-width,initial-scale=1">\n'
    "<title>监管企业集团 · 汇报（%d 页）</title>\n<style>%s</style>\n</head>\n<body>\n"
    '<div id="viewport"><div id="stage">%s</div></div>\n'
    '<div id="bar"></div>\n'
    '<aside id="notes">%s</aside>\n'
    '<div id="toc"><h2>目录 · 监管企业集团（%d 页）</h2><nav>%s</nav>'
    '<p class="hint">点击任意一页跳转，或按 Esc 关闭。'
    "快捷键：← → 翻页 ｜ N 讲稿 ｜ T 目录 ｜ F 适应／原始尺寸</p></div>\n"
    '<div id="hud">'
    '<button id="prev">‹ 上一页</button>'
    '<button id="next">下一页 ›</button>'
    '<button id="tocbtn">目录 (T)</button>'
    '<button id="notesbtn">讲稿 (N)</button>'
    '<span id="pos">01 / %d</span>'
    '<span class="sp"></span>'
    '<span style="color:#8A8A8E">← → 翻页 ｜ 点击图表放大 ｜ 打印可直接导出 PDF</span>'
    "</div>\n<script>%s</script>\n</body>\n</html>\n"
    % (len(SLIDES), CSS, "".join(slide_blocks), "".join(notes_blocks),
       len(SLIDES), toc_items, len(SLIDES), JS)
)

with open(OUT, "w", encoding="utf-8") as f:
    f.write(html)
print("wrote %s" % OUT)
print("slides: %d | size: %.2f MB" % (len(SLIDES), os.path.getsize(OUT) / 1e6))
