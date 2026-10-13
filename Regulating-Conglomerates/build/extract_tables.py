from pathlib import Path
import pypdfium2 as pdfium
import json, shutil
root=Path('literature-reading/Regulating-Conglomerates');p=pdfium.PdfDocument('Chen_et_al_conglomerates.pdf')
# Coordinates refer to 2x PDF renders; crops preserve original pixels.
crops={'table1':(15,(215,320,1000,1205)), 'table1-ab':(15,(360,375,855,755)), 'table1-c':(15,(355,755,855,1040)), 'table2':(19,(215,207,1000,1265)), 'table2-ab':(19,(355,243,855,605)), 'table2-cd':(19,(355,623,855,1084)), 'table3':(23,(215,207,1000,1143)), 'table3-a':(23,(288,260,917,548)), 'table3-b':(23,(338,551,876,835)), 'table4':(32,(215,207,1000,650)), 'table5':(35,(215,207,1000,677))}
meta={}
for name,(page,box) in crops.items():
 im=p[page-1].render(scale=3).to_pil();box=tuple(round(x*1.5) for x in box);im.crop(box).save(root/'assets'/f'{name}.png');meta[name]={'source':'Chen_et_al_conglomerates.pdf','pdf_page':page,'printed_page':page-1,'crop_at_scale_3':box}
for n,f in [('figure3','Figure 3 A–B 能耗事件研究.png'),('figure4','Figure 4 A–B 关联企业与安慰剂.png'),('figure6','Figure 6 B 模型样本外验证.png'),('figure7','Figure 7 B 替代监管方案.png')]:shutil.copy(Path('.work')/f,root/'assets'/f'{n}.png')
(root/'assets/sources.json').write_text(json.dumps(meta,ensure_ascii=False,indent=2))
s=json.loads((root/'src/reader.json').read_text())
for number,table in [(15,1),(18,2),(21,3),(34,4),(37,5)]:
 x=s[number-1];tag=f'<figure class="original-table"><a href="assets/table{table}.png" target="_blank" rel="noopener"><img src="assets/table{table}.png" alt="论文原文 Table {table}，含完整表注" loading="lazy"></a><figcaption>原文 Table {table} · 点击查看大图；下文按原表解释结果。</figcaption></figure>'
 x['body']=tag+x['body']
s[0]['body']+='<p>汇报人：<span class="presenter-name">Zhihan</span></p>'
(root/'src/reader.json').write_text(json.dumps(s,ensure_ascii=False,indent=2))
css=(root/'lecture.css').read_text().replace('--pink:#dfa9ba','--pink:#e0bc77')
for a,b in {'#efc8d5':'#e7d7ba','#88455c':'#806c41','#df9db50a':'#e0bc770a','#5b4551':'#5c4b35','#b7a8af':'#b1aaa2','#bca8af':'#b1aaa2'}.items():css=css.replace(a,b)
css+='\n.presenter-name{color:#dfa9ba}.original-table{text-align:center}.original-table img{display:block;max-width:100%;max-height:880px;width:auto;margin:0 auto;background:white}.original-table figcaption{font-size:14px;color:var(--muted)}\n'
(root/'lecture.css').write_text(css)
