/* User wording is retained in presentation-original.md. This builder changes only presentation. */
const fs=require('node:fs'),path=require('node:path');
const {marked}=require('./vendor/marked.cjs'),katex=require('./vendor/katex.cjs');
const root=path.resolve(__dirname,'..'),read=p=>fs.readFileSync(path.join(root,p),'utf8');
const escape=s=>s.replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;').replaceAll('"','&quot;');
const raw=read('src/presentation-original.md');
const formula={
 '(Δ_n^(1/(1-α)) - 1)x² + x - (P/P*)^(ρ/(1-ρ)) · ξ^(-(1-α_lρ)/(1-ρ)) · Δ_n^(1/(1-α)) = 0':String.raw`\left(\Delta_n^{\frac{1}{1-\alpha}}-1\right)x^2+x-\left(\frac{P}{P^*}\right)^{\frac{\rho}{1-\rho}}\xi^{-\frac{1-\alpha_l\rho}{1-\rho}}\Delta_n^{\frac{1}{1-\alpha}}=0`,
 'θ̂ = argmin [m_d - m(θ)]\'W[m_d - m(θ)]':String.raw`\hat\theta=\arg\min_{\theta}[m_d-m(\theta)]'W[m_d-m(\theta)]`,
 'l_i/l_1 = δ^((i-1)/(1-α)) · [1+λ/(w+p_e)]^(1/(1-α))':String.raw`\frac{l_i}{l_1}=\delta^{\frac{i-1}{1-\alpha}}\left[1+\frac{\lambda}{w+p_e}\right]^{\frac{1}{1-\alpha}}`,
 'x = [1+λ/(w+p_e)]^(1/(1-ρ))':String.raw`x=\left[1+\frac{\lambda}{w+p_e}\right]^{\frac{1}{1-\rho}}`,
 '[1+λ/(w+p_e)]^(1/(1-α))':String.raw`\left[1+\frac{\lambda}{w+p_e}\right]^{\frac{1}{1-\alpha}}`,
 'δ^((i-1)/(1-α))':String.raw`\delta^{\frac{i-1}{1-\alpha}}`,
 'α_l(1-ρ)/(1-α)=2':String.raw`\frac{\alpha_l(1-\rho)}{1-\alpha}=2`,
 'δ^(i-1)':String.raw`\delta^{i-1}`,'α_k':String.raw`\alpha_k`,'w + p_e + λ':String.raw`w+p_e+\lambda`,'w + p_e':String.raw`w+p_e`,
 'δ^(i-1)φ':String.raw`\delta^{i-1}\varphi`,
 'λ_n/(w+p_e)':String.raw`\frac{\lambda_n}{w+p_e}`,
 'π(φ, n+1) - π(φ, n) - fr > 0':String.raw`\pi(\varphi,n+1)-\pi(\varphi,n)-f_r>0`,
 'e_1 ≤ ξ e_1*':String.raw`e_1\leq\xi e_1^*`,
 'l_1 ≤ ξ l_1*':String.raw`l_1\leq\xi l_1^*`,
 'e_1*':String.raw`e_1^*`,'e_i = l_i':String.raw`e_i=l_i`,
 'FOC_1 = w + p_e + λ':String.raw`\mathrm{FOC}_1=w+p_e+\lambda`,
 'FOC_i = w + p_e':String.raw`\mathrm{FOC}_i=w+p_e`,
 'ξ_q,n':String.raw`\xi_{q,n}`,'(i-1)/0.1':String.raw`\frac{i-1}{0.1}`,
 '0.9^10':String.raw`0.9^{10}`,'α_l':String.raw`\alpha_l`,'σ_m':String.raw`\sigma_m`,
 'φ_n':String.raw`\varphi_n`,'φ_1':String.raw`\varphi_1`,'λ_n':String.raw`\lambda_n`,
 'l_i/l_1':String.raw`\frac{l_i}{l_1}`,'e_1':String.raw`e_1`,'l_1':String.raw`l_1`,'x²':String.raw`x^2`,'fr':String.raw`f_r`
};
const re=new RegExp(Object.keys(formula).sort((a,b)=>b.length-a.length).map(s=>s.replace(/[.*+?^${}()|[\]\\]/g,'\\$&')).join('|'),'g');
let mathCount=0;
function render(md){
 const slots=[];
 function protect(tex,display,original){
  tex=tex.replace(/\b(Treat|Related|Spillover|Post|Year)_/g,'\\mathrm{$1}_').replace(/\bfr\b/g,'f_r');
  const rendered=katex.renderToString(tex,{displayMode:display,output:'mathml',throwOnError:true,strict:'ignore'});
  const id=slots.length;slots.push(display?`<div class="equation" tabindex="0" aria-label="数学公式" data-original="${escape(original)}">${rendered}</div>`:`<span class="math-inline" data-original="${escape(original)}">${rendered}</span>`);mathCount++;return `MATHSLOT${id}END`;
 }
 md=md.replace(/\\\[([\s\S]*?)\\\]/g,(whole,tex)=>protect(tex.trim(),true,whole)).replace(/\$\$([\s\S]*?)\$\$/g,(whole,tex)=>protect(tex.trim(),true,whole));
 md=md.replace(re,(s,offset)=>{if(s==='fr'&&/[A-Za-z]/.test((md[offset-1]||'')+(md[offset+2]||'')))return s;return protect(formula[s],false,s)});
 md=md.replace(/\*\*([^*\n]+)\*\*/g,'<strong>$1</strong>');
 return marked.parse(md,{gfm:true,breaks:true}).replace(/<p>(MATHSLOT\d+END)<\/p>/g,'$1').replace(/MATHSLOT(\d+)END/g,(_,n)=>slots[+n]);
}
const figures={
 '3a':{src:'assets/handout/fig3.webp',w:885,h:1233,rect:[0,0,446,337],label:'Figure 3 · Panel A',page:14},
 '3e':{src:'assets/handout/fig3.webp',w:885,h:1233,rect:[0,665,446,329],label:'Figure 3 · Panel E',page:14},
 '4a':{src:'assets/handout/fig4.webp',w:885,h:956,rect:[68,0,375,297],label:'Figure 4 · Panel A',page:18},
 '4d':{src:'assets/handout/fig4.webp',w:885,h:956,rect:[448,300,375,294],label:'Figure 4 · Panel D',page:18},
 '5b':{src:'assets/figure5b.png',label:'Figure 5 · Panel B',page:21},
 '5a':{src:'assets/figure5a.png',label:'Figure 5 · Panel A',page:21},
 '2a':{src:'assets/figure2.png',w:990,h:1702,rect:[0,0,990,832],label:'Figure 2 · Panel A',page:12},
 '2b':{src:'assets/figure2.png',w:990,h:1702,rect:[0,849,990,784],label:'Figure 2 · Panel B',page:12},
 '6b':{src:'assets/figure6b.png',label:'Figure 6 · Panel B',page:33},
 '7a':{src:'assets/figure7a.png',label:'Figure 7 · Panel A',page:39},
 '7b':{src:'assets/figure7b.png',label:'Figure 7 · Panel B',page:39}
};
function fig(id){const f=figures[id];if(!fs.existsSync(path.join(root,f.src)))throw Error(f.src);let img=`<img src="${f.src}" alt="${f.label} 论文原图">`;if(f.rect){const [x,y,w,h]=f.rect;img=`<span class="crop" style="aspect-ratio:${w}/${h}"><img src="${f.src}" alt="${f.label} 论文原图" style="width:${100*f.w/w}%;left:${-100*x/w}%;top:${-100*y/h}%"></span>`;}return `<figure><button class="figure-open" data-image="${f.src}" data-label="${f.label}" aria-label="放大 ${f.label}">${img}</button><figcaption>${f.label} · 点击放大</figcaption></figure>`;}
const block=html=>`<div class="block">${html}</div>`,col=html=>`<div class="column">${html}</div>`;
const slides=raw.split(/^## P/gm).slice(1).map(chunk=>{const [,n,title,rest]=chunk.match(/^(\d+) · (.+)\n([\s\S]*)/);const [main,notes='']=rest.split('**讲稿**：');return {n:+n,title,main:main.replace('**PPT文字内容**：','').replace('**（本页无讲稿）**','').trim(),notes:notes.trim()};});
const N=slides.length;if(N!==20)throw Error('Expected 20 slides');
function compare(left,right,group=''){
 return `<div class="comparison ${group?'within-group':''}" role="img" aria-label="${escape((group?group+'：':'')+'处理组：'+left+'；控制组：'+right)}">${group?`<div class="group-name">${group}</div>`:''}<div class="compare-row"><div class="compare-cell treatment"><small>处理组</small><p>${left}</p></div><div class="versus">对比</div><div class="compare-cell control"><small>控制组</small><p>${right}</p></div></div></div>`;
}
const universe=`<div class="universe" role="img" aria-label="所有企业分为受监管企业、关联企业、无关企业；关联企业分为同4位行业与非同4位行业"><div class="universe-title">所有企业</div><div class="set-grid"><div class="set regulated">受监管企业</div><div class="set related"><div>关联企业</div><div class="subsets"><span>同4位行业企业</span><span>非同4位行业企业</span></div></div><div class="set unrelated">无关企业</div></div></div><p class="diagram-caption">只有同4位行业的关联企业，才有可能承接被监管企业的产出</p>`;
const exposure=`<div class="exposure" role="img" aria-label="比较高暴露行业与低暴露行业中的无关企业，采用连续行业暴露度"><div class="exposure-labels"><span>低暴露行业中的无关企业</span><span>高暴露行业中的无关企业</span></div><div class="exposure-scale"></div><p>连续的行业暴露度 →</p></div>`;
const coverage=`<div class="coverage" role="img" aria-label="行业能耗覆盖率：受监管企业56%，关联企业30%，无关企业14%；监管集团覆盖86%"><div class="coverage-bar"><span style="flex:56">56%</span><span style="flex:30">30%</span><span style="flex:14">14%</span></div><div class="coverage-legend"><span><i></i>受监管企业：56%</span><span><i></i>关联企业：30%（套利空间）</span><span><i></i>无关企业：14%</span></div><div class="coverage-bracket">监管集团可覆盖：86%</div></div>`;
let articles=[],toc=[];
for(const s of slides){const groups=s.main.split(/\n\n(?=\*\*)/).map(render);const b=i=>block(groups[i]||'');let body='',cls='';
 switch(s.n){
 case 1:body=render(s.main);cls='cover';break;
 case 2:body=col(b(0)+b(1))+col(b(2)+b(3));cls='two overview';break;
 case 3:body=groups.map(g=>col(block(g))).join('');cls='three';break;
 case 4:body=b(0)+b(1)+`<div class="wide">${universe}</div>`;cls='two data20';break;
 case 5:body=b(0)+compare('受监管企业（Top 1,000）','无关企业中的Top 10,000<br>（且与处理组无集团关联）')+b(2)+b(3);cls='stack identification';break;
 case 6:case 8:body=`<div class="wide figure-intro">${groups[0]}</div>`+col(fig(s.n===6?'3a':'4a')+b(1))+col(fig(s.n===6?'3e':'4d')+b(2))+col(b(3));cls='three empirical';break;
 case 7:body=b(0)+compare('关联企业中的同4位行业企业','无关企业中的同4位行业、<br>政策前规模相近的企业')+b(2)+b(3);cls='stack identification';break;
 case 9:body=`<div class="wide">${b(0)}</div>`+col(compare('集团内被监管的企业<br>（受监管企业）','集团内没有被监管的关联企业<br>（关联企业）','同一集团 · 同一年')+b(2)+b(3)+b(4))+col(fig('5b'));cls='two within-result';break;
 case 10:body=`<div class="wide">${b(0)+b(1)}</div>`+col(exposure+b(4)+b(5))+col(fig('5a'))+`<div class="wide">${b(3)}</div>`;cls='two market-result';break;
 case 11:body=col(b(0)+b(1))+col(b(2)+b(3));cls='two bridge';break;
 case 12:body=col(b(0)+b(1))+col(fig('2a')+b(2));cls='two model20';break;
 case 13:body=`<div class="wide profit">${b(0)}</div>`+col(b(1))+col(b(2));cls='two equilibrium';break;
 case 14:body=col(fig('2a')+fig('2b'))+col(b(1))+col(b(2));cls='three propositions20';break;
 case 15:body=`<div class="wide lagrangian">${b(1)}</div>`+col(b(0)+b(2))+col(b(3));cls='two policy20';break;
 case 16:body=`<div class="wide">${b(0)}</div>`+col(b(1)+b(2))+col(b(3))+col(b(4));cls='three quadratic20';break;
 case 17:body=col(b(1)+b(2))+col(fig('6b')+b(3))+col(b(0));cls='three estimation';break;
 case 18:body=col(b(0)+b(1)+b(2))+col(fig('7a'));cls='two welfare20';break;
 case 19:body=col(b(0)+fig('7b'))+col(coverage+b(2))+col(b(3));cls='three alternatives';break;
 case 20:body=col(b(0))+col(b(1))+`<div class="wide conclusion">${b(2)+b(3)}</div>`;cls='two conclusion20';break;
 }
 const notes=s.notes?`<aside class="speaker-notes" aria-label="补充说明"><div class="notes-text">${render(s.notes)}</div></aside>`:'';
 articles.push(`<section class="slide s${s.n}" id="slide-${s.n}" aria-label="第${s.n}页：${escape(s.title)}"><header><div class="eyebrow"><span>REGULATING CONGLOMERATES</span><span>ZHIHAN · ${String(s.n).padStart(2,'0')} / ${N}</span></div><h1>${escape(s.title)}</h1></header><div class="slide-body ${cls}">${body}</div>${notes}<footer><span>${[6,8,9,10,12,14,17,18,19].includes(s.n)?'图源：Chen et al. (2025) 论文原图':'Chen et al. (2025) · AER 115(2): 408–447'}</span><a href="handout.html" target="_blank" rel="noopener">详细讲义 ↗</a></footer></section>`);
 toc.push(`<a href="#${s.n}"><span>${String(s.n).padStart(2,'0')}</span>${escape(s.title)}</a>`);
}
const html=`<!doctype html><html lang="zh-CN"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="theme-color" content="#0d0d0d"><meta name="description" content="20页演示版：原文要点、小字号说明、对应论文图表与分组示意图。"><title>被高估的节能政策 · 20页演示版</title><style>${read('presentation.css')}</style></head><body><main id="viewport"><div id="stage">${articles.join('')}</div></main><nav class="controls" aria-label="演示导航"><button id="prev" aria-label="上一页">←</button><label><input id="jump" type="number" min="1" max="${N}" value="1" aria-label="跳转页码"> / ${N}</label><button id="next" aria-label="下一页">→</button><button id="toc-open">目录</button><button id="notes-toggle" aria-pressed="true">隐藏小字</button><button id="fullscreen">全屏</button><button id="print">打印</button></nav><div class="progress" id="progress"></div><dialog id="toc"><div class="dialog-head"><h2>20页演示版</h2><button data-close>关闭 ×</button></div><nav>${toc.join('')}</nav></dialog><dialog id="image-dialog"><div class="dialog-head"><h2>论文原图</h2><button data-close>关闭 ×</button></div><img alt="论文原图"></dialog><script>${read('presentation.js')}</script></body></html>`;
if(/【此处插入|讲稿|MATHSLOT\d+END/.test(html))throw Error('Unresolved placeholder or unwanted label');
fs.writeFileSync(path.join(root,'presentation.html'),html);
console.log(`Built ${N} slides, ${mathCount} formulas; source wording preserved.`);
