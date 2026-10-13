from pathlib import Path
import json,math,re,shutil
B=Path(__file__).resolve().parents[1];R=B/'literature-reading/Regulating-Conglomerates';p=R/'src/reader.json';S=json.loads(p.read_text());r=json.loads((B/'.work/replication-check/verified.json').read_text());b=r['baseline'];x=r['comparison'][9];k=(-math.log(x[2])/math.log(x[3]));gwtp=k/(1+k)*.8*2752/6.38
rows=[['模型矩','读取 param_opt.mat 重算 9 个矩','已运行；没有重新寻找参数'],['行业能源变化','−ln(E/E*)×100 = %.4f'%(-math.log(b['rel_E'])*100),'对应原文约 4%%；简单比例降幅为 %.4f%%'%((1-b['rel_E'])*100)],['价格指数变化','ln(P/P*)×100 = %.4f'%(math.log(b['rel_P'])*100),'对应原文约 3.5%%；简单比例涨幅为 %.4f%%'%((b['rel_P']-1)*100)],['GWTP 换算','%.2f 美元／吨 CO₂'%gwtp,'四舍五入为 161；使用历史校准'],['监管门槛 φ̃','本副本求解 %.4f'%b['phi_t'],'论文参数表 9.289；未强行改成一致'],['Table 5 收入分解','受管 DID %.2f；关联 DID %.2f'%(b['decomposition_results'][2][3]*100,b['decomposition_results'][5][3]*100),'接近报告 −20.5、+12.8；小项仍有版本／舍入差异'],['Table 1–3 微观回归','未运行','本地副本缺少 .dta 数据'],['Figure 6B 投入／能效预测','原码可运行，数值暂不认定复现','存在下方列出的变量引用差异']]
audit='<div class="table-wrap"><table><thead><tr><th>核验对象</th><th>本次实际输出／状态</th><th>与论文的关系</th></tr></thead><tbody>'+''.join('<tr>'+''.join('<td>'+v+'</td>' for v in row)+'</tr>' for row in rows)+'</tbody></table></div><p class="caption">完整数值记录：<a href="src/verified-results.json">verified-results.json</a>。基准参数、9 个矩、18 个政策组合与收入分解均有留存。</p>'
for s in S:
 if 'audit-results' in s['body']:s['body']=s['body'].replace('<div id="audit-results"></div>',audit)
 for c in s['codes']:
  if c['path'].endswith('decomposition.m') and c['start']==80:
   lines=(B/'196012-V1'/c['path']).read_text().splitlines();c['start']=76;c['end']=81;c['lines']=lines[75:81]
 if '备用' in s['sub']:s['sub']=s['sub'].replace('备用','补充说明')
 if s['title']=='从异质性企业到企业集团':s['body']+='<p class="caption"><a href="https://melitz.scholars.harvard.edu/publications/impact-trade-intra-industry-reallocations-and-aggregate-industry-productivity">Melitz（2003）原始论文与作者页面</a></p>'
 if s['title']=='把整个集团作为监管单位':s['body']+='<p class="caption">本次代码直接按同一 ξ 求出的集团方案，价格成本与基准不同；“多节能约 10%”需要在相同价格成本上比较，而不能直接用同一 ξ 的两行结果相减。</p>'
# Reduce wide excerpts to exactly meaningful source blocks.
for s in S:
 for c in s['codes']:
  if c['path']=='Do/Table3.do' and c['start']==50:
   lines=(B/'196012-V1'/c['path']).read_text().splitlines();c['start']=47;c['end']=60;c['lines']=lines[46:60]
p.write_text(json.dumps(S,ensure_ascii=False,indent=2))
r['verification_note']='给定作者参数和数据矩运行；不是从微观数据完整复现。投入分解变量引用差异见讲义第51页。';r['date']='2026-10-11';(R/'src/verified-results.json').write_text(json.dumps(r,ensure_ascii=False,indent=2))
root=B/'literature-reading';s=(root/'index.html').read_text();s=s.replace('42 页在线讲义含逐字稿、逐页写作拆解，以及从两厂模型到完整论文的研究设计工作坊。','52 页黑金粉主题讲义，按政策、实证、模型与福利展开，含 24 处复现代码解释和 MATLAB 实际运行核验。');s=re.sub(r'\s*<a href="Regulating-Conglomerates/(writing-workshop|script)\.html">.*?</a>','',s);(root/'index.html').write_text(s)
s=(root/'README.md').read_text();s=re.sub(r'  - 在线讲义：\[index.html\]\(Regulating-Conglomerates/index.html\).*','  - 在线讲义：[index.html](Regulating-Conglomerates/index.html)，52 页正文与 24 处复现代码解释',s);s=re.sub(r'^.*Regulating-Conglomerates/(writing-workshop|writing-notes|script)\.(html|md).*\n','',s,flags=re.M);s=re.sub(r'  - 黑金粉主题演示稿：.*','  - 黑金粉主题演示稿：[presentation.html](Regulating-Conglomerates/presentation.html)，逐页呈现、连续阅读、目录与打印',s);(root/'README.md').write_text(s)
(R/'README.md').write_text('''# 监管企业集团：论文解读与复现代码导读

- [连续阅读讲义](index.html)
- [逐页呈现文稿](presentation.html)

52 页，黑金配少量粉色。内容按政策背景、数据与 DID、实证结果、集团模型、福利与政策启示展开，含 24 处带原文件行号的代码摘录与中文解释。面向读者的页面仅含论文内容和复现解释。

## 操作

用目录或底部页码跳转；逐页模式支持左右方向键。连续阅读展开代码，逐页模式按需展开。打印输出所有页面和代码解释。HTML 内嵌样式、脚本和图像，可直接离线打开。

## 构建

修改 `src/reader.json`、`lecture.css` 或 `lecture.js`，再运行：

```sh
python3 tools/build.py
```

## 核验范围

用户提供的 `196012-V1` 根目录副本不含 `.dta` 文件，因此未重跑微观回归。2026-10-11 使用 MATLAB R2024a 在独立副本运行 `Estimation/Main_test.m`、`Counterfactual Baseline/Main.m` 与 `Main_compare.m`。这是给定参数／数据矩下的模型求解，不是重新估计全篇论文。

结果保存在 `src/verified-results.json`。复现得出对数口径净节能 3.9644%、价格变化 3.4857%、GWTP 161.45 美元／吨 CO₂。门槛约 9.3443，与论文报告的 9.289 有差异。投入分解代码存在需核对的变量引用，详见讲义第 51 页，不能将相应预测视为已确认复现。

原始微观数据、软件和完整复现包不包含在此网站。代码摘录保留来源与行号；论文原图仅用于对应结果的学术说明。

论文：Chen et al. (2025), AER 115(2):408–447，DOI 10.1257/aer.20211455。代码来源：作者 openICPSR 项目 196012，用户提供的 V1 副本。
''')
print('Updated audit and reader navigation')
