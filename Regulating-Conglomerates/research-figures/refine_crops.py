from pathlib import Path
import json,pdfplumber
from PIL import Image,ImageChops,ImageOps
root=Path.cwd();out=root/'literature-reading/Regulating-Conglomerates/assets/handout';meta=json.loads((out/'sources.json').read_text())
pdfs={n:pdfplumber.open(root/n) for n in ['Chen_et_al_conglomerates.pdf','22048.pdf']}
for m in meta:
 p=pdfs[m['source']].pages[m['pdf_page']-1];lines=p.extract_text_lines();im=Image.open(root/'tmp/research'/(m['id']+'.png')).convert('RGB');sc=im.width/p.width
 if m['source'].startswith('Chen'):
  src=[l for l in lines if l['text'].startswith('Source:')]
  assert src,m['id'];bottom=src[0]['bottom']+8;top=98
 else:
  usable=[l for l in lines if not(l['text'].strip().isdigit() and l['top']>p.height*.85)]
  top=max(20,min(l['top'] for l in usable)-12);bottom=min(p.height*.94,max(l['bottom'] for l in usable)+12)
 crop=(int(48*sc),int(top*sc),int((p.width-48)*sc),int(bottom*sc));sub=im.crop(crop)
 mask=ImageChops.difference(sub,Image.new('RGB',sub.size,'white')).convert('L').point(lambda x:255 if x>40 else 0)
 box=mask.getbbox()
 if box:
  pad=16;box=(max(0,box[0]-pad),max(0,box[1]-pad),min(sub.width,box[2]+pad),min(sub.height,box[3]+pad));sub=sub.crop(box)
 m['crop_px']=crop;m['trim_px']=box;m['width']=sub.width;m['height']=sub.height
 sub.save(out/(m['id']+'.webp'),'WEBP',quality=94)
(out/'sources.json').write_text(json.dumps(meta,ensure_ascii=False,indent=2))
print('Refined',len(meta),'images')
