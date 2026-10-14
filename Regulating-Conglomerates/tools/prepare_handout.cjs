/* Additive presentation transforms: never rewrite src/handout.md. */
module.exports=function prepare(md,read,escape){
 const slots=[];
 const slot=html=>{const i=slots.push(html)-1;return `\n\nHTMLSLOT${i}END\n\n`;};
 const fold=(start,end,title)=>{
  const a=md.indexOf(start),b=md.indexOf(end,a+start.length);
  if(a<0||b<0)throw Error('Missing derivation boundary: '+title);
  md=md.slice(0,a)+slot(`<details class="derivation"><summary>${escape(title)}</summary><div class="detail-body">`)+md.slice(a,b)+slot('</div></details>')+md.slice(b);
 };
 fold('**需求函数的推导过程**：','**小p和大P不一样**','展开推导：CES需求函数（五步）');
 fold('**从需求函数到收入函数**：','所以：\n\n\\[\n\\boxed{p','展开推导：从需求函数到收入函数');
 fold('**这个利润函数的来源**：','- \\(w\\)：工资。','展开推导：集团利润函数的来源');
 const within=(section,start,end,title)=>{
  const at=md.indexOf(section),tail=md.slice(at),a=tail.indexOf(start),b=tail.indexOf(end,a+start.length);
  if(at<0||a<0||b<0)throw Error('Missing scoped derivation boundary: '+title);
  const first=md.slice(0,at),last=tail.slice(b);
  md=first+tail.slice(0,a)+slot(`<details class="derivation"><summary>${escape(title)}</summary><div class="detail-body">`)+tail.slice(a,b)+slot('</div></details>')+last;
 };
 within('### 8.4','**第一步**','### 8.5','展开命题1的完整推导');
 within('### 8.5','**第二步**','**命题2得证**','展开命题2的阈值推导');
 within('### 8.8','拉格朗日函数：','**为什么从','展开：有政策约束的拉格朗日函数');
 within('### 8.8','**一阶条件**','**关键含义**','展开：完整一阶条件');
 within('### 8.9','**第一步**','核心企业被限制','展开命题3的完整推导');
 within('### 8.10','**第一步**','**第六步**','展开推导：从一阶条件到影子成本方程');
 within('### 8.10','**为什么是二次方程？**','### 8.11','展开：二次方程的解释与正根');
 within('### 8.11','代入δ =','#### 第二步','展开数值计算：集团规模项');
 within('#### 第三步：解影子成本','先算常数：','**规律**','展开数值计算：逐个集团规模求影子成本');
 within('#### 第四步：计算产出楔子','先算常数：','关联企业越多，集团越能','展开数值计算：产出楔子');
 within('#### 第五步：检查价格方程','左边：','#### 第六步','展开数值计算：价格方程与迭代检查');
 within('#### 第六步：计算能耗楔子','先算常数：','关联企业越多，集团总能耗','展开数值计算：能耗楔子');
 within('#### 第七步：计算总能耗变化','- ρ/(1−α_lρ)','即**全国净节能','展开数值计算：全国能耗加总');
 for(const s of JSON.parse(read('src/handout-supplements.json'))){
  if(!md.includes(s.before))throw Error('Missing supplement anchor: '+s.before);
  const opening=s.collapsed?`<details class="code-excerpt"><summary>${escape(s.title)}</summary><div class="detail-body"><p class="excerpt-label">公众号原文节选</p>`:`<aside class="wechat-supplement"><div class="excerpt-label">公众号补充 · 原文节选</div><h4>${escape(s.title)}</h4>`;
  let ending=s.collapsed?'</div></details>':'</aside>';
  if(s.title.startsWith('40%'))ending='<p class="calculation-note"><strong>读数提示：</strong>47%的分母是核心企业原产出，约41%的分母是核心企业减产量，两者不能直接比较为“实际值与上限”。这三步是规模与DID系数结合的近似核算，剩余部分的去向仍需市场溢出和一般均衡分析。</p>'+ending;
  // A callback keeps literal $$ (display math) and $& / $' in excerpts intact.
  md=md.replace(s.before,()=>slot(opening)+(s.excerpts||[s.body]).join('\n\n')+slot(ending)+s.before);
 }
 // Protect code before parsing dollar signs and underscores as mathematics.
 md=md.replace(/```([\w-]*)\n([\s\S]*?)```/g,(_,lang,code)=>slot(`<pre><code class="language-${escape(lang)}">${escape(code)}</code></pre>`));
 return {md,slots};
};
