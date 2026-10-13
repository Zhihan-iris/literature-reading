
* Data for Figure A.12 Lack of Entry Effect

*------------------------------------------
* Panel A: Relative Size of New Affiliates
*------------------------------------------

* CESD Sample

use "$revision/Data/Table1.dta",clear
keep name
duplicates drop name,force
gen sample=1
save "$revision/Data/baseline_name.dta",replace

use "$revision/Data/Table1.dta",clear
keep legcode
duplicates drop legcode,force
gen sample=1
save "$revision/Data/baseline_legcode.dta",replace

* Cleaning before Matching

use "$revision/Data/Table1.dta", clear

keep if top1000==1
keep firmid legcode name
duplicates drop legcode name,force

replace legcode="132284914" if name=="上海焦化有限公司"
replace legcode="834764058" if name=="中国石化南京化学工业有限公司连云港碱厂"
replace legcode="217871878" if name=="云南红磷化工有限责任公司"
replace legcode="774422223" if name=="唐山市汇丰炼焦制气有限公司"
replace legcode="715010034" if name=="宁夏金昱元化工集团有限公司"
replace legcode="705022576" if name=="安徽巢东水泥股份有限公司"
replace legcode="16928036X" if name=="山东东明石化集团有限公司"
replace legcode="113904479" if name=="山西海鑫钢铁集团有限公司"
replace legcode="113904479" if name=="山西省海鑫钢铁有限公司"
replace legcode="602460012" if name=="平朔煤炭工业公司"
replace legcode="200887558" if name=="广西河池化学工业集团公司"
replace legcode="756530693" if name=="广西维尼纶集团有限责任公司"
replace legcode="723064200" if name=="柳州化学工业集团有限公司"
replace legcode="752281327" if name=="河南心连心化肥有限公司"
replace legcode="725820997" if name=="河南省骏马化工集团有限公司"
replace legcode="753431083" if name=="襄樊巨力化工实业有限公司"
replace legcode="24203000X" if name=="金城造纸股份有限公司"
replace legcode="755239802" if name=="五台县化肥厂"
replace legcode="701013437" if name=="山西省丰喜肥业股份有限公司闻喜分公司"
replace name="辽宁渤海水泥（集团）有限责任公司" if name=="辽宁渤海水泥(集团)有限责任公司"
replace name="合肥四方化工集团" if name=="合肥四方化工集团有限责任公司"
replace legcode="178411464" if name=="大冶特殊钢股份有限公司"
replace name="甘肃金昌化工（集团）有限责任公司" if name=="甘肃省金昌化工（集团）有限责任公司"
replace name="冷水江钢铁总厂" if name=="冷水江钢铁集团"
replace legcode="618066431" if name=="建滔(衡阳)氮肥有限公司"

* Top1000 Capital Data

ren name 企业名称
joinby 企业名称 using "$revision/Raw_Data/Top1000/Top1000_Capital.dta",unmatched(master) update 
drop _merge 组织机构代码 注册资本
ren 企业名称 name
ren legcode 组织机构代码
joinby 组织机构代码 using "$revision/Raw_Data/Top1000/Top1000_Capital.dta",unmatched(master) update 
drop _merge 企业名称 注册资本
ren 组织机构代码 legcode
gsort firmid -capital
duplicates drop firmid,force
gen type="Top1000"
save "$revision/Data/Top1000_Capital_Baseline.dta",replace

* Top1000 Related Capital Data 

use "$revision/Raw_Data/CARD/Related_Firms.dta",clear

keep if same_ind4==1
keep qianjia related

merge m:1 qianjia using "$revision/Raw_Data/Top1000/Top1000_QXB_ID.dta",update
drop if _merge==2
drop _merge

merge m:1 name using "$revision/Data/baseline_name.dta",update
drop if _merge==2
drop _merge

ren legcode_in_panel legcode
merge m:1 legcode using "$revision/Data/baseline_legcode.dta",update
drop if _merge==2
drop _merge

keep if sample==1
keep related
duplicates drop related,force

ren related name
fdta name,f("（")
fdta name,f("）")

merge m:1 name using "$revision/Raw_Data/CARD/Related_Capital.dta" ,update
keep if _merge==3
drop _merge

gen startyear=substr(var3,1,4)
destring startyear,replace

keep name startyear var4

gsort name startyear var4
gen related_id=_n
ren var4 capital
gen type="Related"

append using "$revision/Data/Top1000_Capital_Baseline.dta"

*Variables

keep firmid related_id startyear type capital

ren firmid top1000_id
order top1000_id related_id startyear type capital

* Label

label variable top1000_id "ID for Top1000"
label variable related_id "ID for Top1000 Related"
label variable startyear "Start Year for Related"
label variable type "Top1000 or Related"
label variable capital "Inital Capital"

save "$revision/Data/FigureA12_A.dta",replace

*----------------------------------
* Panel B: New Affiliates by Year
*----------------------------------

/* Top1,000 Related Startup */

* Identify Related Firms of Baseline Sample

use "$revision/Raw_Data/CARD/Related_Firms.dta",clear

keep if same_ind4==1
keep qianjia related

merge m:1 qianjia using "$revision/Raw_Data/Top1000/Top1000_QXB_ID.dta",update
drop if _merge==2
drop _merge

merge m:1 name using "$revision/Data/baseline_name.dta",update
drop if _merge==2
drop _merge

ren legcode_in_panel legcode
merge m:1 legcode using "$revision/Data/baseline_legcode.dta",update
drop if _merge==2
drop _merge

keep if sample==1
keep related
duplicates drop related,force

* Add Startup Information for Top1,000 Related

ren related name
fdta name,f("（")
fdta name,f("）")

merge m:1 name using "$revision/Raw_Data/CARD/Related_Capital.dta" ,update
keep if _merge==3
drop _merge

gen startyear=substr(var3,1,4)
destring startyear,replace

keep if startyear>=2001 & startyear<=2010

gen num=.

forvalues i=2001(1)2010 {
     egen num`i'=count(startyear) if startyear==`i'
	 replace num=num`i' if startyear==`i'
}

duplicates drop startyear,force
gsort startyear

keep startyear num 
order startyear num
ren num top1000_num

save "$revision/Data/Top1000_Conglomerate_Startup",replace

/* Name List for Top10000 Related Exclude Top1000, Top10,000 and Top1000 Related */

* ASIF Data

use "$revision/Raw_Data/ASIF/ASIF.dta",clear

* Drop Top1000 Firms

xtset id_in_panel year
replace qianjia_md_dummy=. if qianjia_md_dummy==0
xfill qianjia_md_dummy,i(id_in_panel)
drop if qianjia_md_dummy==1

* Drop Top1000 Related Firms

ren legcode_in_panel legcode
merge m:1 legcode using "$revision/Raw_Data/CARD/related_firms_legcode.dta"
drop if _merge==2
drop _merge

merge m:1 name using "$revision/Raw_Data/CARD/related_firms_name.dta",update
drop if _merge==2
drop _merge

xtset id_in_panel year
replace same_ind4=. if same_ind4==0
xfill same_ind4,i(id_in_panel)
drop if same_ind4==1

* Drop Top10000 Firms

drop if wanjia_dummy==1

* Add Top10000 Related

merge m:1 id_in_panel using "$revision/Data/Related_ID_Short.dta" ,update
drop if _merge==2
drop _merge

keep if top10000_related==1

gsort id_in_panel -year
keep id_in_panel name
duplicates drop id_in_panel,force

order id_in_panel name

save "$revision/Data/Top10000_Related_List.dta",replace

/* Top10,000 Related Startup */

* Identify Related Firms of Baseline Sample

use "$revision/Data/Related_ID.dta",clear
gsort rank
duplicates drop top10000_id asif_id,force
keep top10000_id asif_id
ren asif_id id_in_panel

ren top10000_id Top10000_id
merge m:1 Top10000_id using "$revision/Raw_Data/Top10000/Top10000_QXB_ID.dta",update
drop if _merge==2
drop _merge

ren Top10000_name name
merge m:1 name using "$revision/Data/baseline_name.dta",update
drop if _merge==2
drop _merge

ren Top10000_legcode legcode
merge m:1 legcode using "$revision/Data/baseline_legcode.dta",update
drop if _merge==2
drop _merge

keep if sample==1
keep id_in_panel
duplicates drop id_in_panel,force

merge 1:1 id_in_panel using "$revision/Data/Top10000_Related_List.dta",update
keep if _merge==3
drop _merge
duplicates drop name,force

* Add Startup Information for Top10,000 Related

merge 1:m name using "$revision/Raw_Data/CARD/Top10000_Related_Capital.dta", update
keep if _merge==3
drop _merge

gen startyear=substr(成立日期,1,4) if right==1
destring startyear,replace force
replace startyear=fyear if startyear==.

keep if startyear>=2001 & startyear<=2010

gen num=.

forvalues i=2001(1)2010 {
     egen num`i'=count(startyear) if startyear==`i'
	 replace num=num`i' if startyear==`i'
}

duplicates drop startyear,force
gsort startyear

keep startyear num
order startyear num 
ren num top10000_num

merge 1:1 startyear using "$revision/Data/Top1000_Conglomerate_Startup"

keep startyear top1000_num top10000_num
order startyear top1000_num top10000_num

label variable top1000_num "New Related of Top1000 (Baseline Sample)"
label variable top10000_num "New Related of Top10000 (Baseline Sample)"

save "$revision/Data/FigureA12_B.dta",replace

*----------------------------------
* Panel C: Entry Rate Event Study
*----------------------------------

/* Preparison for Top1000 */

* Name List for Top1000  

use "$revision/Raw_Data/ASIF/ASIF_Top1000_Top10000.dta",clear

xtset id_in_panel
replace qianjia_md_dummy=. if qianjia_md_dummy==0
xfill qianjia_md_dummy,i(id_in_panel)
keep if qianjia_md_dummy==1

duplicates tag id_in_panel cic03,gen(du)
replace du=-1 if cic03==.
gsort id_in_panel -du -year
by id_in_panel: replace cic03=cic03[1]
drop du 
ren cic03 ind4

gen province=int(code2010/10000)
duplicates tag id_in_panel province,gen(du)
replace du=-1 if province==.
gsort id_in_panel -du -year
by id_in_panel: replace province=province[1]
drop du

gsort legcode_id -year
duplicates drop legcode_id,force

ren legcode_in_panel legcode
keep legcode_id name legcode ind4 province
keep if legcode_id<9999

save "$revision/Data/Top1000_List.dta",replace

* Related Firms of Top1000 

use "$revision/Raw_Data/CARD/Related_Firms.dta",clear

keep if same_ind4==1
keep qianjia related top1000_cic03 top1000_province
ren top1000_cic03 ind4
ren top1000_province province

ren related name
fdta name,f("（")
fdta name,f("）")

merge m:1 name using "$revision/Raw_Data/CARD/Related_Capital.dta",update
keep if _merge==3
drop _merge

gen startyear=substr(var3,1,4)
destring startyear,replace
replace startyear=2000 if startyear<=2000
replace startyear=2011 if startyear>2011
ren name related 

* Number of New Related Firms

gsort related 
by related : egen weight=count(startyear)

egen group=group(qianjia startyear)
bysort group: egen number=total(1/weight)

duplicates drop qianjia startyear,force

merge m:1 qianjia using "$revision/Raw_Data/Top1000/Top1000_QXB_ID.dta",update
drop if _merge==2
drop _merge

merge m:1 legcode_id using "$revision/Data/Top1000_List.dta",update
replace startyear=2000 if _merge==2
drop _merge

xtset legcode_id startyear
tsfill,full
xfill qianjia,i(legcode_id)
replace qianjia=name if qianjia==""
xfill qianjia,i(legcode_id) 
xfill ind4,i(legcode_id)
xfill province,i(legcode_id)
xfill legcode,i(legcode_id)
replace number=0 if number==.

* Entry Rate of Top1000 Conglomerates

gen entry_rate=.

gsort legcode_id startyear
by legcode_id: egen initial_number=total(number) if startyear==2000
replace initial_number=initial_number+1
xfill initial_number,i(legcode_id)
replace entry_rate=number/initial_number

* Variables 

gsort legcode_id startyear
egen id=group(legcode_id)

keep id qianjia legcode startyear ind4 province number entry_rate
order id qianjia legcode startyear ind4 province number entry_rate
ren qianjia name
gen top1000=1

* Label

label var id "ID"
label var name "Firm Name"
label var legcode "Firm Legal Code"
label var startyear "Year of Start"
label var ind4 "4-Digit Industry"
label var province "Province"
label var number "Number of Startups"
label var entry_rate "Number of Startups/Initial Number(2000)"
label var top1000 "Top1000 (1) or Top10000 (0)"

save "$revision/Data/Top1000_Temp.dta",replace

/* Preparison for Top10000 */

* Name List for Top10000  

use "$revision/Raw_Data/ASIF/ASIF_Top1000_Top10000.dta",clear

* Drop Top1000 Firms

xtset id_in_panel year
replace qianjia_md_dummy=. if qianjia_md_dummy==0
xfill qianjia_md_dummy,i(id_in_panel)
drop if qianjia_md_dummy==1

* Drop Top1000 Related Firms

ren legcode_in_panel legcode
merge m:1 legcode using "$revision/Raw_Data/CARD/related_firms_legcode.dta"
drop if _merge==2
drop _merge

merge m:1 name using "$revision/Raw_Data/CARD/related_firms_name.dta",update
drop if _merge==2
drop _merge

xtset id_in_panel year
replace same_ind4=. if same_ind4==0
xfill same_ind4,i(id_in_panel)
drop if same_ind4==1

* Identify Top10000 Firms

keep if wanjia_dummy==1

* Province 

gen province=int(code2010/10000)
duplicates tag id_in_panel province,gen(du)
replace du=-1 if province==.
gsort id_in_panel -province -year
by id_in_panel: replace province=province[1]

keep id_in_panel name legcode province year
drop if province==.

preserve
gsort name -year
duplicates drop name,force
keep name province
ren name Top10000_name
save "$revision/Data/Top10000_Name_List_Temp.dta",replace
restore

gsort legcode -year
duplicates drop legcode,force
keep legcode province
ren legcode Top10000_legcode
save "$revision/Data/Top10000_Legcode_List_Temp.dta",replace

* Start Year for Top10000 Related Firm

use "$revision/Raw_Data/CARD/Top10000_Related_Capital.dta",clear

gen startyear=substr(成立日期,1,4) if right==1
destring startyear,replace force
replace startyear=fyear if startyear==.

duplicates drop name,force
keep name startyear 
save "$revision/Data/Top10000_Temp.dta",replace

* Related Firms of Top10000 Firms

use "$revision/Data/Related_ID.dta",clear
gsort rank
duplicates drop top10000_id asif_id,force
keep top10000_id asif_id
ren asif_id id_in_panel

merge m:1 id_in_panel using "$revision/Data/Top10000_Related_List.dta",update
keep if _merge==3
drop _merge

merge m:1 name using "$revision/Data/Top10000_Temp.dta",update
keep if _merge==3
drop _merge

replace startyear=2000 if startyear<2000
replace startyear=2011 if startyear>2011

* Number of New Related Firms

gsort id_in_panel
by id_in_panel: egen weight=count(id_in_panel)

egen group=group(top10000_id startyear)
bysort group: egen number=total(1/weight)

duplicates drop top10000_id startyear,force
keep top10000_id startyear number

ren top10000_id Top10000_id
merge m:1 Top10000_id using "$revision/Raw_Data/Top10000/Top10000_QXB_ID.dta",update
replace startyear=2000 if _merge==2
drop _merge

merge m:1 Top10000_legcode using "$revision/Data/Top10000_Legcode_List_Temp.dta",update
drop if _merge==2
drop _merge
xtset Top10000_id startyear
xfill province,i(Top10000_id)

merge m:1 Top10000_name using "$revision/Data/Top10000_Name_List_Temp.dta",update
drop if _merge==2
drop _merge
xtset Top10000_id startyear
xfill province,i(Top10000_id)
drop if province==.

xtset Top10000_id startyear
tsfill,full
xfill Top10000_name,i(Top10000_id)
xfill Top10000_legcode,i(Top10000_id)
ren Top10000_ind4 ind4
xfill ind4,i(Top10000_id)
xfill province,i(Top10000_id)
replace number=0 if number==.

* Entry Rate of Top10000 Conglomerates

gen entry_rate=.

gsort Top10000_id startyear
by Top10000_id: egen initial_number=total(number) if startyear==2000
replace initial_number=initial_number+1
xfill initial_number,i(Top10000_id)
replace entry_rate=number/initial_number

* Variables

gsort Top10000_id startyear
egen id=group(Top10000_id)
replace id=id+1000

keep id Top10000_name Top10000_legcode startyear ind4 province number entry_rate 
order id Top10000_name Top10000_legcode startyear ind4 province number entry_rate
ren Top10000_name name
ren Top10000_legcode legcode
gen top1000=0

append using "$revision/Data/Top1000_Temp.dta"
xtset id startyear

* Label

label var id "ID"
label var name "Firm Name"
label var legcode "Firm Legal Code"
label var startyear "Year of Start"
label var ind4 "4-Digit Industry"
label var province "Province"
label var number "Number of Startups"
label var entry_rate "Number of Startups/Inital Number (2000)"
label var top1000 "Top1000 (1) or Top10000 (0)"

*Match with Baseline Sample

merge m:1 name using "$revision/Data/baseline_name.dta",update
drop if _merge==2
drop _merge

merge m:1 legcode using "$revision/Data/baseline_legcode.dta",update
drop if _merge==2
drop _merge

xtset id startyear
xfill sample,i(id)
keep if sample==1
drop sample

keep if startyear>=2001 & startyear<=2010

gen ind2=int(ind4/100)
egen ind2_year=group(ind2 startyear)
egen province_year=group(province startyear)

order ind2,after(ind4)
label variable ind2 "2-Digit Industry"

save "$revision/Data/FigureA12_C.dta",replace

* Erase Temp File

erase "$revision/Data/baseline_name.dta"
erase "$revision/Data/baseline_legcode.dta"
erase "$revision/Data/Top1000_Conglomerate_Startup.dta"
erase "$revision/Data/Top1000_Capital_Baseline.dta"
erase "$revision/Data/Top1000_List.dta"
erase "$revision/Data/Top1000_Temp.dta"
erase "$revision/Data/Top10000_Related_List.dta"
erase "$revision/Data/Top10000_Temp.dta"
erase "$revision/Data/Top10000_Name_List_Temp.dta"
erase "$revision/Data/Top10000_Legcode_List_Temp.dta"
erase "$revision/Data/Related_ID.dta"
erase "$revision/Data/Related_ID_short.dta"
