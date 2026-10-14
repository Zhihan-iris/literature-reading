/* Preserve the supplied manuscript verbatim; insert figures through a separate map. */
const fs=require('node:fs'),path=require('node:path');
const {marked}=require('./vendor/marked.cjs'),katex=require('./vendor/katex.cjs');
const root=path.resolve(__dirname,'..');const read=p=>fs.readFileSync(path.join(root,p),'utf8');
let md=read('src/handout.md');const escape=s=>s.replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;').replaceAll('"','&quot;');
const originalTitle=md.match(/^# (.+)/)[1];
const byId=Object.fromEntries(JSON.parse(read('assets/handout/sources.json')).map(m=>[m.id,m]));
const math=[],figures=[];
const captions=JSON.parse(read('src/handout-captions.json'));
const prepared=require('./prepare_handout.cjs')(md,read,escape);md=prepared.md;
for(const placement of JSON.parse(read('src/handout-figures.json'))){
 if(!md.includes(placement.before))throw Error('Missing figure anchor: '+placement.before);
 md=md.replace(placement.before,placement.figures.map(id=>`@@${id}@@`).join('\n\n')+'\n\n'+placement.before);
}
function protect(tex,display){tex=tex.replace(/\b(Spillover|Treat|Post|Year|Related)_/g,'\\mathrm{$1}_');const result=katex.renderToString(tex.trim(),{displayMode:display,output:'mathml',throwOnError:true,strict:'ignore'});const id=math.length;math.push(display?`<div class="equation">${result}</div>`:`<span class="math-inline">${result}</span>`);return `MATHSLOT${id}END`;}
md=md.replace(/\$\$([\s\S]*?)\$\$/g,(_,t)=>protect(t,true)).replace(/\\\[([\s\S]*?)\\\]/g,(_,t)=>protect(t,true)).replace(/\\\(([\s\S]*?)\\\)/g,(_,t)=>protect(t,false)).replace(/\$([^$\n]+)\$/g,(_,t)=>protect(t,false));
if(/^\s*\${1,2}\s*$/m.test(md))throw Error('Unrendered display-math delimiter in handout');
// Format previously plain-text identifiers without changing their values or wording.
const plainMath={
 '`e₁ ≤ ξ · e₁*`':'e_1 \\leq \\xi \\cdot e_1^*',
 'Σ δ^((i−1)×10)':'\\sum \\delta^{(i-1)\\times 10}',
 'α_lρ²/(1−α_lρ)':'\\alpha_l\\rho^2/(1-\\alpha_l\\rho)',
 '(1−α_lρ)/(1−ρ)':'(1-\\alpha_l\\rho)/(1-\\rho)',
 'α_l/(1−α_l)':'\\alpha_l/(1-\\alpha_l)',
 'ρ/(1−α_lρ)':'\\rho/(1-\\alpha_l\\rho)',
 'λ_n/(w+p_e)':'\\lambda_n/(w+p_e)',
 'ξ^α_l':'\\xi^{\\alpha_l}',
 'Spillover_j':'\\mathrm{Spillover}_j', 'Post_t':'\\mathrm{Post}_t',
 'ξ_q^0.75':'\\xi_q^{0.75}', 'ξ_q,n':'\\xi_{q,n}', 'ξ_e,n':'\\xi_{e,n}',
 's_φ̄':'s_{\\bar{\\phi}}','σ_m':'\\sigma_m','α_l':'\\alpha_l','α_k':'\\alpha_k',
 'Δ_n^10':'\\Delta_n^{10}','Δ_1^10':'\\Delta_1^{10}','Δ_2^10':'\\Delta_2^{10}','Δ_3^10':'\\Delta_3^{10}',
 'Δ_n':'\\Delta_n','λ_n':'\\lambda_n','ξ_q':'\\xi_q','ξ_e':'\\xi_e','p_e':'p_e','P/P*':'P/P^*',
 'δ^10':'\\delta^{10}','ξ^(−1.6)':'\\xi^{-1.6}','ρ/(1−ρ)':'\\rho/(1-\\rho)','1/(1−α)':'1/(1-\\alpha)'
};
const escapeRe=s=>s.replace(/[.*+?^${}()|[\]\\]/g,'\\$&');
const plainPattern=Object.keys(plainMath).sort((a,b)=>b.length-a.length).map(escapeRe).join('|');
md=md.replace(new RegExp(plainPattern,'g'),s=>protect(plainMath[s],false));
md=md.replace(/(\d+(?:\.\d+)?)\^(?:\(([−-]?\d+(?:\.\d+)?)\)|([−-]?\d+(?:\.\d+)?))/g,(_,base,a,b)=>protect(`${base}^{${(a||b).replace('−','-')}}`,false));
// CJK-adjacent percentages otherwise fail CommonMark's emphasis boundary rule.
md=md.replace(/\*\*([^*\n]+)\*\*/g,'<strong>$1</strong>');

md=md.replace(/@@([^@]+)@@/g,(_,id)=>{const m=byId[id];if(!m||!fs.existsSync(path.join(root,m.asset)))throw Error('Missing asset '+id);const label=id.replace(/^figA/,'Figure A.').replace(/^tabA/,'Table A.').replace(/^fig/,'Figure ').replace(/^tab/,'Table ').replace('-A',' / A.');figures.push({id,label});return `<figure class="evidence" id="evidence-${id}"><div class="evidence-head"><b>${label}</b></div><button class="zoom-open" aria-label="放大 ${label}"><img src="${m.asset}" width="${m.width}" height="${m.height}" loading="lazy" decoding="async" alt="${label} 原文图表"></button><figcaption><p class="caption-title"><strong>${escape(captions[id][0])}</strong></p><p><strong>怎么看：</strong>${escape(captions[id][1])}</p><p><strong>说明什么：</strong>${escape(captions[id][2])}</p><div class="locator">来源：${m.source==='22048.pdf'?'在线附录':'正文作者稿'} · PDF 第 ${m.pdf_page} 页${m.source==='22048.pdf'?'':` · 印刷页 ${m.printed_page}`} · 点击图表放大</div></figcaption></figure>`;});
// The original H1 becomes the masthead; its wording is unchanged.
md=md.replace(/^# .+\n/,'');
let html=marked.parse(md,{gfm:true,breaks:false});html=html.replace(/<p>(MATHSLOT\d+END)<\/p>/g,'$1').replace(/MATHSLOT(\d+)END/g,(_,i)=>math[Number(i)]);
html=html.replace(/<p>(HTMLSLOT\d+END)<\/p>/g,'$1').replace(/HTMLSLOT(\d+)END/g,(_,i)=>prepared.slots[Number(i)]);
html=html.replace(/<table>/g,'<div class="table-wrap"><table>').replace(/<\/table>/g,'</table></div>');
const chapters=[],chunks=html.split(/(?=<h2>)/);const preface=chunks[0].startsWith('<h2>')?'':chunks.shift();
chunks.forEach((chunk,i)=>{const title=chunk.match(/<h2>([\s\S]*?)<\/h2>/)[1];let num=0;chunk=chunk.replace(/<h3>/g,()=>`<h3 id="chapter-${i+1}-${++num}">`);chapters.push({title:title.replace(/<[^>]*>/g,''),html:`<section class="chapter" id="chapter-${i+1}">${chunk}</section>`})});
const nav=chapters.map((c,i)=>`<a href="#chapter-${i+1}"><span>${String(i+1).padStart(2,'0')}</span>${escape(c.title.replace(/^[一二三四五六七八九十]+、/,''))}</a>`).join('');
const figureIndex=figures.map(f=>`<a href="#evidence-${f.id}">${f.label}</a>`).join('');
const doc=`<!doctype html><html lang="zh-CN"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="theme-color" content="#14212b"><meta name="description" content="${escape(originalTitle)}"><title>${escape(originalTitle)}</title><style>${read('handout.css')}[hidden]{display:none!important}</style></head><body><a class="skip" href="#main">跳到讲义正文</a><div class="mobile-bar"><span>REGULATING CONGLOMERATES</span><button id="menu" aria-controls="rail" aria-expanded="false">目录</button></div><aside class="rail" id="rail"><div class="mark">LITERATURE READING / 2025</div><h1>监管企业集团</h1><div class="small">完整详细解读与思考</div><input id="search" type="search" aria-label="搜索讲义章节内容" placeholder="搜索全文，定位章节…"><p class="search-empty">没有找到匹配的章节。</p><nav aria-label="讲义目录">${nav}</nav><footer><button data-print>打印讲义</button></footer></aside><div class="layout"><header class="hero"><h1 style="font-size:clamp(30px,3.2vw,52px)">${escape(originalTitle)}</h1></header><div class="toolbar"><a href="#chapter-1">开始阅读 ↓</a><button id="figures" aria-expanded="false" aria-controls="figure-index">原图表索引（${figures.length}）</button><button data-print>打印 / 保存 PDF</button><button data-derivations="open">展开全部推导</button><button data-derivations="close">收起全部推导</button><a href="src/handout.md">讲义源文稿</a><a href="https://doi.org/10.1257/aer.20211455" target="_blank" rel="noopener">论文 DOI ↗</a></div><main class="content" id="main"><div id="figure-index" class="figure-index" aria-label="原图表索引"><h2>原图表索引</h2>${figureIndex}</div>${preface}${chapters.map(c=>c.html).join('')}</main></div><div class="progress" aria-hidden="true"><div id="progress"></div></div><button class="back-top" aria-label="返回顶部">↑</button><dialog class="lightbox" id="lightbox" aria-labelledby="image-title"><header><span id="image-title"></span><div><button id="actual-size">原尺寸 / 适应</button> <button id="close-image" aria-label="关闭图表">关闭 ×</button></div></header><div class="viewer"><img id="big-image" alt=""></div></dialog><script>${read('handout.js')}</script></body></html>`;
fs.writeFileSync(path.join(root,'handout.html'),doc);console.log(JSON.stringify({chapters:chapters.length,figures:figures.length,formulas:math.length,derivations:(doc.match(/class="derivation"/g)||[]).length,supplements:JSON.parse(read('src/handout-supplements.json')).length,bytes:Buffer.byteLength(doc)}));
