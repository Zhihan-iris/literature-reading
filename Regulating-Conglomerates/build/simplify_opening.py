from pathlib import Path
import json
root=Path('literature-reading/Regulating-Conglomerates')
def save(name,s):(root/'src'/name).write_text(json.dumps(s,ensure_ascii=False,indent=2))
s=json.loads((root/'src/deck.json').read_text())
s[1].update(title='同一集团的两家企业，只有一家受到节能约束',body='<p>假设一个集团拥有两家生产同类产品的企业 A 和 B，可以在它们之间安排生产任务。</p><div class="columns"><div><h2>企业 A：被列入节能名单</h2><p>政策要求 A 减少能源消耗。A 可以通过改善生产技术节能，也可能通过减少生产来降低能耗。</p><div class="statement">问题：A 少生产的部分去了哪里？</div></div><div><h2>企业 B：没有被列入名单</h2><p>B 与 A 受同一集团控制。如果 B 接过部分生产任务，它的产出和能耗就可能增加。</p><div class="statement">集团可以把部分生产转到 B</div></div></div><p class="boundary">“企业集团”指由所有权关系连接、可共同安排经营活动的多家企业；这里的 B 是 A 的关联企业。</p>',reader=[2,3],source='概念示例 · 对应论文关于集团内生产转移的研究问题')
s[2].update(title='A 少用了 20 单位能源，集团实际节约多少？',section='01 研究问题',body='<p>假设 A 减少生产，B 承接部分生产任务。两家企业的能源消耗变化如下。</p><table><thead><tr><th>能源消耗（统一单位）</th><th>企业 A：名单内</th><th>企业 B：名单外</th><th>集团合计</th></tr></thead><tbody><tr><td>政策前</td><td>100</td><td>40</td><td>140</td></tr><tr><td>政策后</td><td>80</td><td>52</td><td>132</td></tr><tr><td>变化</td><td>−20</td><td>+12</td><td>−8</td></tr></tbody></table><div class="equation">集团净节能 8 = A 节能 20 − B 增耗 12</div><p>论文研究的问题是：这种生产转移是否发生？把名单外企业的反应也计入后，整个行业节约了多少能源？</p><p class="boundary">数字仅用于说明机制，并非论文估计结果。“行业”还包括同类产品的其他生产企业。</p>',reader=[3],source='教学示例 · 论文随后通过企业数据和模型分析这一问题')
s[3]['body']=s[3]['body'].replace('政策公布／事件研究基年','政策公布').replace('DID 的政策后时期','观察政策实施后的变化')
s[6]['title']='双重差分（DID）：比较两组企业的变化'
s[6]['body']=s[6]['body'].replace('<h2>受监管企业的直接反应</h2>','<h2>比较一：名单内企业怎样变化？</h2>').replace('<h2>关联企业的溢出反应</h2>','<h2>比较二：关联企业是否承接生产？</h2>').replace('DID =（处理组政策后 − 政策前）−（对照组政策后 − 政策前）','双重差分 = 处理组的前后变化 − 对照组的前后变化')
s[7]['body']=s[7]['body'].replace('Table 1 第 (4) 列为完整规格；前几列逐步加入固定效应与企业控制变量。','ln 表示自然对数，系数可换算为百分比变化；Table 1 各列逐步加入固定效应与控制变量。')
s[19]['body']=s[19]['body'].replace('对照组也可能受市场溢出影响。结构模型提供共同的无政策基准及行业加总。','结构模型把生产和需求关系写成方程，计算“有政策”与“无政策”两种情形，用于加总行业影响。')
save('deck.json',s)
r=json.loads((root/'src/reader.json').read_text())
r[0]['body']=r[0]['body'].replace('政策约束施加于名单内企业，生产决策则可能由整个集团统筹。监管对象与决策主体的边界差异构成本文的研究问题。','政策要求名单内企业节能。同一集团可能把部分生产转到名单外的关联企业，论文由此考察整个行业实际节约了多少能源。')
r[1].update(title='同一集团的两家企业，为什么要一起看？',sub='从生产任务可以在关联企业之间转移这一情形出发',body='<p>一个集团可以拥有多家企业，并统筹它们的生产任务。假设企业 A 和企业 B 属于同一集团，生产的产品相近，但只有 A 被列入节能名单。</p><h3>企业 A 怎样减少能耗？</h3><p>A 可以改善生产技术，用更少的能源生产相同产品；也可能减少生产，使能源消耗随之下降。</p><h3>企业 B 可能发生什么变化？</h3><p>如果集团把 A 的部分生产任务交给 B，B 的产出和能耗就可能增加。只看 A 的节能量，就无法得知两家企业合计节约了多少能源。</p><p class="takeaway">论文由此提出：关联企业是否承接了生产？把名单外企业的反应也计入后，整个行业还节约了多少能源？</p><p class="caption">这里的“关联企业”指通过所有权关系与 A 相联系的企业；基准分析进一步限定同一四位行业，以考察生产可替代性较强的企业。下一页用假设数字说明这种机制。</p>',source='研究问题与概念示例；原文 Introduction、Section III')
save('reader.json',r)
