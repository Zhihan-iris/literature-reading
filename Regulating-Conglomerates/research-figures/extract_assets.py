from pathlib import Path
import subprocess,json,concurrent.futures
from PIL import Image,ImageOps,ImageDraw
ROOT=Path.cwd(); OUT=ROOT/'literature-reading/Regulating-Conglomerates/assets/handout'; OUT.mkdir(parents=True,exist_ok=True)
items=[('fig1','main',3),('fig2','main',12),('fig3','main',14),('fig4','main',18),('fig5','main',21),('fig6','main',33),('fig7','main',39),('tab1','main',15),('tab2','main',19),('tab3','main',23),('tab4','main',32),('tab5','main',35)]
items += [('figA'+str(n),'appendix',80+n) for n in [1,2,3,5,6,7,8,11,12,13,14,15,17,18,19,20]]
items += [('tabA8','appendix',108),('tabA17','appendix',115),('tabA36','appendix',129),('tabA38','appendix',131),('tabA3-A4','appendix',105),('tabA33-A34','appendix',127)]
files={'main':'Chen_et_al_conglomerates.pdf','appendix':'22048.pdf'}
def render(item):
 key,kind,page=item; stem=ROOT/'tmp/research'/key
 subprocess.run(['pdftoppm','-f',str(page),'-l',str(page),'-r','160','-png','-singlefile',str(ROOT/files[kind]),str(stem)],check=True,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
 im=Image.open(str(stem)+'.png').convert('RGB'); w,h=im.size
 # Preserve all plots, captions, table notes; omit page header/footer only.
 crop=(int(w*.10),int(h*.072),int(w*.90),int(h*.94))
 if key=='fig1':crop=(int(w*.10),int(h*.10),int(w*.90),int(h*.62))
 if key=='fig2':crop=(int(w*.10),int(h*.072),int(w*.90),int(h*.67))
 if key=='tab4':crop=(int(w*.10),int(h*.10),int(w*.90),int(h*.44))
 if key=='tab5':crop=(int(w*.10),int(h*.10),int(w*.90),int(h*.45))
 im.crop(crop).save(OUT/(key+'.webp'),'WEBP',quality=92)
 return {'id':key,'source':files[kind],'pdf_page':page,'printed_page':page-1 if kind=='main' else page,'dpi':160,'crop_px':crop,'asset':'assets/handout/'+key+'.webp'}
with concurrent.futures.ThreadPoolExecutor(max_workers=4) as ex:meta=list(ex.map(render,items))
(OUT/'sources.json').write_text(json.dumps(meta,ensure_ascii=False,indent=2))
thumbs=[]
for m in meta:
 im=Image.open(OUT/(m['id']+'.webp')); im.thumbnail((250,330)); tile=Image.new('RGB',(280,365),'#eae5dc'); tile.paste(im,((280-im.width)//2,25));ImageDraw.Draw(tile).text((10,5),m['id']+' p.'+str(m['pdf_page']),fill='black');thumbs.append(tile)
sheet=Image.new('RGB',(280*6,365*((len(thumbs)+5)//6)),'white')
for i,im in enumerate(thumbs):sheet.paste(im,((i%6)*280,(i//6)*365))
sheet.save(ROOT/'tmp/research/contact.png');print('Rendered',len(meta),'assets')
