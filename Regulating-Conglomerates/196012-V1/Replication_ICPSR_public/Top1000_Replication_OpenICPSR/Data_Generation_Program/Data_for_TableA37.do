
*Data for Table A.37 Summary Statistics for Top 10,000 & Top 10,000 Related Firms

*----------------------------
* Identify Top10000 Related
*----------------------------

import excel "$revision/Raw_Data/Top10000/fudan_affiliates.xlsx", sheet("Sheet") firstrow clear
keep top10000_id asif_id
duplicates drop top10000_id asif_id,force
gen type="Affiliates"
gen rank=1
save "$revision/Data/Related_ID.dta",replace

import excel "$revision/Raw_Data/Top10000/fudan_shareholder_new.xlsx", sheet("Sheet") firstrow clear
fdta percents,f("[")
fdta percents,f("]")
split percents,parse(,)
destring percents1 percents2 percents3,replace
drop if percents2<0.25
drop if percents3<0.25
keep top10000_id asif_id
duplicates drop top10000_id asif_id,force
gen type="Shareholder"
gen rank=2
append using "$revision/Data/Related_ID.dta"
save "$revision/Data/Related_ID.dta",replace

import excel "$revision/Raw_Data/Top10000/fudan_investment_new.xlsx", sheet("Sheet") firstrow clear
fdta percents,f("[")
fdta percents,f("]")
split percents,parse(,)
destring percents1 percents2 percents3,replace
drop if percents2<0.25
drop if percents3<0.25
keep top10000_id asif_id
duplicates drop top10000_id asif_id,force
gen type="Investment"
gen rank=3
append using "$revision/Data/Related_ID.dta"
save "$revision/Data/Related_ID.dta",replace

import excel "$revision/Raw_Data/Top10000/fudan_shareholder_all.xlsx", sheet("Sheet") firstrow clear
gen shareholder=tail_of_path_name
merge m:1 shareholder using "$revision/Raw_Data/Top10000/Government_Shareholder.dta" 
keep if _merge==1
drop type _merge
gen x1=substr(shareholder,-3,3)
gen x2=substr(shareholder,-6,6)
gen x3=substr(shareholder,-9,9)
drop if x1=="局" | x1=="委"
drop if x2=="政府" | x2=="中心"
drop if x3=="委员会" | x3=="交易所" | x3=="财政厅" | x3=="商务厅" | x3=="管委会"	
drop x1 x2 x3
drop if regexm(shareholder,"国有资产")
drop if regexm(shareholder,"国有资本")
drop if shareholder=="中国国有企业结构调整基金股份有限公司"
drop if shareholder=="凉山州国有工业投资发展集团有限责任公司"
drop if shareholder=="攀枝花市国有投资（集团）有限责任公司"
drop if shareholder=="杭州上城区国有投资控股集团有限公司"
drop if shareholder=="湖南省国有投资经营有限公司"
drop if shareholder=="贵溪市国有控股集团有限公司"
drop if shareholder=="迁安市国有控股集团有限公司"
drop if shareholder=="镇江国有投资控股集团有限公司"
drop if shareholder=="长治市国有工业资产经营有限公司"
drop if shareholder=="上海湾区高新技术产业开发区财政所"
drop if shareholder=="中国人民银行"
drop if shareholder=="中国农业发展银行"
drop if shareholder=="中国进出口银行江西省分行"
drop if shareholder=="中国进出口银行辽宁省分行"
drop if shareholder=="义马市泰山路街道办事处"
drop if shareholder=="云南省益宁监狱"
drop if shareholder=="全国社会保障基金理事会"
drop if shareholder=="广州市人民政府办公厅"
drop if shareholder=="扶余市住房和城乡建设局（扶余市人民防空办公室）"
drop if shareholder=="新疆生产建设兵团第一师十六团"
drop if shareholder=="新疆生产建设兵团第六师"
drop if shareholder=="新疆生产建设兵团第六师土墩子农场"
drop if shareholder=="新疆维吾尔自治区吐鲁番监狱"
drop if shareholder=="沙河市民政局福利生产办公室"
drop if shareholder=="潜江市熊口管理区"
drop if shareholder=="绍兴市柯桥区福全街道办事处"
drop if shareholder=="绍兴市柯桥区钱清街道办事处"
drop if shareholder=="绍兴市越城区斗门街道办事处"
drop if shareholder=="辽宁省社会保障基金理事会（辽宁省产业（创业）投资引导基金管理中心）"
drop if shareholder=="高青县能源节约办公室"
drop shareholder
keep tail_of_path_eid
ren tail_of_path_eid shareholder_eid
save "$revision/Data/Shareholder.dta",replace

import excel "$revision/Raw_Data/Top10000/fudan_shareholder_investment_all_new.xlsx", sheet("Sheet") firstrow clear
merge m:1 shareholder_eid using "$revision/Data/Shareholder.dta"
keep if _merge==3
fdta shareholder_percents,f("[")
fdta shareholder_percents,f("]")
split shareholder_percents,parse(,)
destring shareholder_percents1 shareholder_percents2 shareholder_percents3,replace
drop if shareholder_percents2<0.25
drop if shareholder_percents3<0.25
fdta invest_percents,f("[")
fdta invest_percents,f("]")
split invest_percents,parse(,)
destring invest_percents1 invest_percents2 invest_percents3,replace
drop if invest_percents2<0.25
drop if invest_percents3<0.25
keep top10000_id asif_id
duplicates drop top10000_id asif_id,force
gen type="Shareholder Investment"
gen rank=4
append using "$revision/Data/Related_ID.dta"
save "$revision/Data/Related_ID.dta",replace

import excel "$revision/Raw_Data/Top10000/fudan_personshareholder_investment_new.xlsx", sheet("Sheet") firstrow clear
fdta shareholder_percents,f("[")
fdta shareholder_percents,f("]")
split shareholder_percents,parse(,)
destring shareholder_percents1 shareholder_percents2,replace
drop if shareholder_percents1<0.25
drop if shareholder_percents2<0.25
fdta invest_percents,f("[")
fdta invest_percents,f("]")
split invest_percents,parse(,)
destring invest_percents1 invest_percents2,replace
drop if invest_percents1<0.25
drop if invest_percents2<0.25
keep top10000_id asif_id
duplicates drop top10000_id asif_id,force
gen type="Shareholder Investment"
gen rank=4
append using "$revision/Data/Related_ID.dta"
save "$revision/Data/Related_ID.dta",replace

use "$revision/Data/Related_ID.dta",clear
gsort rank
duplicates drop asif_id,force
keep asif_id
ren asif_id id_in_panel
gen top10000_related=1
save "$revision/Data/Related_ID_Short.dta",replace

*--------------------
* Summary Statistics
*--------------------

use "$revision/Raw_Data/ASIF/ASIF.dta",clear

* Top1000

xtset id_in_panel year
replace qianjia_md_dummy=. if qianjia_md_dummy==0
xfill qianjia_md_dummy,i(id_in_panel)
replace qianjia_md_dummy=0 if qianjia_md_dummy==.

* Top1000 Related

ren legcode_in_panel legcode
merge m:1 legcode using "$revision/Raw_Data/CARD/related_firms_legcode.dta",update
drop if _merge==2
drop _merge

merge m:1 name using "$revision/Raw_Data/CARD/related_firms_name.dta",update
drop if _merge==2
drop _merge

xtset id_in_panel year
replace same_ind4=. if same_ind4==0
xfill same_ind4,i(id_in_panel)
replace same_ind4=. if qianjia_md_dummy==1
replace same_ind4=0 if same_ind4==.

* Top10000 Related

merge m:1 id_in_panel using "$revision/Data/Related_ID_Short.dta",update
drop if _merge==2
drop _merge

replace top10000_related=0 if top10000_related==.
replace top10000_related=0 if wanjia_dummy==1

* Energy-Intensive Industries

gen ind4=cic03
duplicates tag id_in_panel ind4,gen(du_ind4)
gsort id_in_panel -du_ind4 -year
by id_in_panel: replace ind4=ind4[1]
gen ind2=int(ind4/100)

gen top1000_industry=1 if ind2==6 | ind2==7 | ind2==25 | ind2==26 | ind2==31 | ind2==32 | ind2==33 | ind2==44 | ind2==17 | ind2==22

* Sample

keep if qianjia_md_dummy==1 | wanjia_dummy==1 | same_ind4==1 | top10000_related==1

* Variables
egen firmid=group(id_in_panel)

keep firmid name year giovpp qianjia_md_dummy wanjia_dummy same_ind4 top10000_related top1000_industry 

ren giovpp output
ren qianjia_md_dummy top1000
ren wanjia_dummy top10000
ren same_ind4 top1000_related

order firmid name year output top1000 top10000 top1000_related top10000_related top1000_industry 

* Label

label variable firmid "Firm ID"
label variable name "Firm Name"
label variable year "Data Year"
label variable output "Output"
label variable top1000 "Top1000"
label variable top10000 "Top10000"
label variable top1000_related "Top1000 Relatd"
label variable top10000_related "Top10000 Relatd"
label variable top1000_industry "Energy-Intensive Industries"

save "$revision/Data/TableA37.dta",replace
