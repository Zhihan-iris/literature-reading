from PIL import Image
from pathlib import Path
import json, unicodedata

ROOT = Path('.work/pages')
OUT = Path('output/汇报PPT/assets')
OUT.mkdir(parents=True, exist_ok=True)

PAGE_W, PAGE_H = 1275.0, 1650.0   # 150 dpi render of letter page

# name: (pdf page, x0f, y0f, x1f, y1f)
CROPS = {
  # ---- figures ----
  'figure1':    (3,  0.16, 0.105, 0.84, 0.225),
  'figure2':    (12, 0.16, 0.105, 0.84, 0.375),
  'figure3':    (14, 0.13, 0.095, 0.87, 0.645),
  'figure3_ab': (14, 0.13, 0.095, 0.87, 0.285),
  'figure3_cd': (14, 0.13, 0.275, 0.87, 0.455),
  'figure3_ef': (14, 0.13, 0.455, 0.87, 0.645),
  'figure4':    (18, 0.04, 0.170, 0.96, 0.560),
  'figure4_a':  (18, 0.04, 0.170, 0.50, 0.370),
  'figure4_c':  (18, 0.04, 0.360, 0.50, 0.555),
  'figure4_d':  (18, 0.50, 0.360, 0.96, 0.555),
  'figure5':    (21, 0.16, 0.105, 0.84, 0.610),
  'figure5_a':  (21, 0.16, 0.105, 0.84, 0.350),
  'figure5_b':  (21, 0.16, 0.345, 0.84, 0.585),
  'figure6':    (33, 0.16, 0.140, 0.84, 0.630),
  'figure6_a':  (33, 0.16, 0.140, 0.84, 0.390),
  'figure6_b':  (33, 0.16, 0.385, 0.84, 0.620),
  'figure7':    (39, 0.16, 0.125, 0.84, 0.680),
  'figure7_a':  (39, 0.16, 0.125, 0.84, 0.400),
  'figure7_b':  (39, 0.16, 0.400, 0.84, 0.665),
  # ---- tables ----
  'table1':     (15, 0.20, 0.175, 0.80, 0.660),
  'table1_a':   (15, 0.20, 0.220, 0.80, 0.340),
  'table1_b':   (15, 0.20, 0.348, 0.80, 0.472),
  'table1_c':   (15, 0.20, 0.478, 0.80, 0.610),
  'table1_note':(15, 0.15, 0.620, 0.85, 0.735),
  'table2':     (19, 0.20, 0.115, 0.80, 0.600),
  'table2_ab':  (19, 0.20, 0.130, 0.80, 0.390),
  'table2_cd':  (19, 0.20, 0.390, 0.80, 0.600),
  'table2_note':(19, 0.15, 0.615, 0.85, 0.775),
  'table3':     (23, 0.20, 0.115, 0.80, 0.575),
  'table3_a':   (23, 0.20, 0.130, 0.80, 0.340),
  'table3_b':   (23, 0.20, 0.345, 0.80, 0.530),
  'table3_note':(23, 0.15, 0.520, 0.85, 0.690),
  'table4':     (32, 0.20, 0.250, 0.80, 0.470),
  'table5':     (35, 0.20, 0.250, 0.80, 0.490),
}

meta = {}
missing = []
for name, (page, x0, y0, x1, y1) in CROPS.items():
    f = ROOT / f'p-{page:03d}.png'
    if not f.exists():
        missing.append((name, page)); continue
    im = Image.open(f)
    W, H = im.size
    box = (round(x0*W), round(y0*H), round(x1*W), round(y1*H))
    crop = im.crop(box)
    # upscale x1.6 for crisp rendering in slide
    crop = crop.resize((crop.width*2, crop.height*2), Image.LANCZOS)
    crop.save(OUT / f'{name}.png')
    meta[name] = {'pdf_page': page, 'frac': [x0, y0, x1, y1], 'px150': list(box), 'out_size': list(crop.size)}

(OUT.parent / 'sources.json').write_text(json.dumps(meta, ensure_ascii=False, indent=2))
print('written', len(meta), 'crops ->', OUT)
if missing: print('MISSING PAGES:', missing)
