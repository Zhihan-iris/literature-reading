
*Data for Table A.8 : Waterfall Table

*------------------
* Import CESD Data
*------------------

use "$revision/Raw_Data/CESD/CESD_Top1000_Top10000_Raw.dta", clear

*------------
* Data Clean
*------------

drop if name=="重庆市永荣矿业有限公司总医院"
drop if wrong==1

*-----------------------
* Drop Data Before 2001
*-----------------------

drop if year<2001

*-------------------------
* Energy and Output Data
*-------------------------

* Raw Data

gen production=v10
replace production=emi_production_1 if year==2010
gen coal=v15
replace coal=emi_coal if year==2010
gen oil=v19
replace oil=emi_oil if year==2010
gen gas=v23
replace gas=emi_gas if year==2010

replace production=0 if production==.
replace coal=0 if coal==.
replace oil=0 if oil==.
replace gas=0 if gas==.

* Electricity-Intensive Industry

merge m:1 ind4 using "$revision/Raw_Data/CESD/Industry_Electricity_Share.dta",update 
drop if _merge==2
drop _merge

* Power Type

merge m:1 ind4 using "$revision/Raw_Data/CESD/Energy_Type.dta",update 
drop if _merge==2
drop _merge

* Energy and Output Variable

gen energy=coal*0.9+oil*1.4286+gas*13.3 if power_type==1
replace energy=coal*0.9+oil*1.4286 if power_type==2 | power_type==0
replace energy=coal*0.9+oil*1.4286+gas*5 if power_type==3 

gen lenergy=ln(energy)
gen loutput=ln(production*10)
gen lefficiency=ln(production*10/energy)

*-----------
* Controls
*-----------

* Top10000

gen qianjia_md_wanjia=1 if qianjia_md_dummy==1
replace qianjia_md_wanjia=1 if wanjia_dummy==1 & qianjia_all_dummy!=1
keep if qianjia_md_wanjia==1

* Drop 4-digit Related Firms

ren legcode_in_panel legcode
merge m:1 legcode using "$revision/Raw_Data/CARD/related_firms_legcode.dta"
drop if _merge==2
drop _merge

merge m:1 name using "$revision/Raw_Data/CARD/related_firms_name.dta",update
drop if _merge==2
drop _merge

replace same_ind4=. if same_ind4==0
xtset id_in_panel year
xfill same_ind4,i(id_in_panel)
replace same_ind4=. if qianjia_md_dummy==1
drop if same_ind4==1

*-----------------
* Other Variables
*-----------------

* Treat*Post

gen post2007=1 if year>2006
replace post2007=0 if year<=2006

gen treat_post= qianjia_md_dummy*post2007

* Fixed Effects

gen province=int(countyid_new_panel/10000)
egen province_year=group(province year)
egen ind2_year=group(ind2 year)

* Control Variables

gen roa=GQ_oprofit/GQ_tasset
winsor2 roa,trim replace

gen age=year-GQ_fyear+1

gen exp=1 if GQ_edv>0 & GQ_edv!=.
replace exp=0 if exp==.

gen ownership= GQ_rtype
replace ownership=. if ownership<100 | ownership>390

gen SOE=1 if ownership==110 | ownership==141 |ownership==143 | ownership==151
replace SOE=0 if SOE==. & ownership!=.

replace SOE=2 if SOE==.
gsort id_in_panel SOE
by id_in_panel: replace SOE=SOE[1] if SOE[1]<2 & SOE==2
replace SOE=. if SOE==2

*-----------------
* Variable Label
*-----------------

keep id_in_panel legcode name year ind4 ind2 province qianjia_md_dummy wanjia_dummy lenergy loutput lefficiency ///
energy coal oil gas treat_post province_year ind2_year electricity50 electricity30 electricity25 ///
power_type SOE roa age exp 

ren qianjia_md_dummy top1000
ren wanjia_dummy top10000
ren SOE soe

xtset id_in_panel year
egen firmid=group(id_in_panel)
drop id_in_panel

xtset firmid year
replace soe=l.soe  if year==2010
replace roa=l.roa if year==2010
replace age=l.age+1 if year==2010
replace exp=l.exp if year==2010
replace age=. if age>200

order firmid legcode name year ind4 ind2 province top1000 top10000 lenergy loutput lefficiency ///
energy coal oil gas treat_post province_year ind2_year electricity50 electricity30 electricity25 ///
power_type soe roa age exp 

label variable firmid "Firm ID"
label variable legcode "Legal Code"
label variable name "Firm Name"
label variable year "Data Year"
label variable ind4 "4-digit Industry"
label variable ind2 "2-digit Industry"
label variable province "Province ID"
label variable top1000 "Top1000 Firms"
label variable top10000 "Top10000 Firms"
label variable lenergy "ln(Energy)"
label variable loutput "ln(Output)"
label variable lefficiency "ln(Energy Efficiency)"
label variable energy "Energy"
label variable coal "Coal"
label variable oil "Oil"
label variable gas "Gas"
label variable treat_post "Treat*Post"
label variable province_year "Province*Year"
label variable ind2_year "2-digit Industry*Year"
label variable soe "State Owned"
label variable roa "Return to Asset"
label variable age "Firm Age"
label variable exp "Export Status"
label variable power_type "Power Type"

xtset firmid year

save "$revision/Data/TableA8.dta",replace
