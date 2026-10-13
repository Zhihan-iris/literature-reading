
*Data for Table.A9_B: Robustness to Different Samples (Infilling Missing Coal Data with ATS)

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

* Drop Firms That Do Not Report Energy Data

gen energy_data=1 if coal!=0 | oil!=0 | gas!=0
xfill energy_data
drop if energy_data==.

* Electricity-Intensive Industry

merge m:1 ind4 using "$revision/Raw_Data/CESD/Industry_Electricity_Share.dta" 
keep if _merge==3
drop _merge

* Power Type

merge m:1 ind4 using "$revision/Raw_Data/CESD/Energy_Type.dta"
keep if _merge==3
drop _merge

* Energy and Output Variable

gen energy=coal*0.9+oil*1.4286+gas*13.3 if power_type==1
replace energy=coal*0.9+oil*1.4286 if power_type==2 | power_type==0
replace energy=coal*0.9+oil*1.4286+gas*5 if power_type==3 

gen lenergy=ln(energy)
gen loutput=ln(production*10)
gen lefficiency=ln(production*10/energy)

* Drop Untreated

gen untreated=(energy>18*10^4 & energy!=. & qianjia_all_dummy==0 & year==2004 )
replace untreated=0 if untreated!=1
gsort id_in_panel -untreated
by id_in_panel: replace untreated=untreated[1]
drop if untreated==1

* Comparable Energy and Output

replace loutput=. if lenergy==.

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

*Treat*Post

gen post2007=1 if year>2006
replace post2007=0 if year<=2006

gen treat_post= qianjia_md_dummy*post2007

*Province

gen province=int(countyid_new_panel/10000)

*-----------------------
* Infill with ATS Data
*-----------------------

*Preparation

xtset id_in_panel year
tsfill,full

duplicates tag id_in_panel name,gen(du_name)
replace du_name=-1 if name==""
gsort id_in_panel -du_name
by id_in_panel: replace name=name[1] if name==""
drop du_name

duplicates tag id_in_panel legcode,gen(du_legcode)
replace du_legcode=-1 if legcode==""
gsort id_in_panel -du_legcode
by id_in_panel: replace legcode=legcode[1] if legcode==""
drop du_legcode

xfill ind2,i(id_in_panel)
xfill province,i(id_in_panel)

egen ind2_year=group(ind2 year)
egen province_year=group(province year)

xfill qianjia_md_dummy, i(id_in_panel)
replace treat_post=1 if qianjia_md_dummy==1 & year>=2007
replace treat_post=0 if treat_post==.

*Matching with ATS Data

merge m:1 name year using "$revision/Raw_Data/ATS/ATS_Energy_Name.dta",update
drop if _merge==2
drop _merge

merge m:1 legcode year using "$revision/Raw_Data/ATS/ATS_Energy_Legcode.dta",update
drop if _merge==2
drop _merge

*---------------
* Data Cleaning
*---------------

* Drop Firms without Energy Data After 2006

drop if lenergy==.

gsort id_in_panel -year
by id_in_panel: gen endyear=year[1]
drop if endyear<=2006
drop endyear

* Drop Extreme Values

xtset id_in_panel year
gen growth_energy=D.energy/L.energy
bysort id_in_panel:egen total_energy=total(energy) 
bysort id_in_panel:gen mean_energy=(total_energy-energy)/(_N-1)
gen energy_level=energy/mean_energy
gen energy_right=(growth_energy<10 | energy_level<10 )

drop if energy_right==0 & qianjia_md_dummy!=1

* Drop Firms That Did Not Report Coal Data Annually

sort id_in_panel coal
by id_in_panel: egen missing=count(id_in_panel) if coal==0

xtset id_in_panel year
xfill missing, i(id_in_panel)
replace missing=0 if missing==.

drop if missing>0

*-----------------
* Variable Label
*-----------------

keep id_in_panel legcode name year ind4 ind2 province qianjia_md_dummy lenergy loutput lefficiency treat_post province_year ind2_year electricity50 electricity30 electricity25 missing 

ren qianjia_md_dummy top1000

xtset id_in_panel year
egen firmid=group(id_in_panel)
drop id_in_panel

order firmid legcode name year ind4 ind2 province top1000 lenergy loutput lefficiency treat_post province_year ind2_year electricity50 electricity30 electricity25 missing 

*Label
label variable firmid "Firm ID"
label variable legcode "Legal Code"
label variable name "Firm Name"
label variable year "Data Year"
label variable ind4 "4-digit Industry"
label variable ind2 "2-digit Industry"
label variable province "Province ID"
label variable top1000 "Treat"
label variable lenergy "ln(Energy)"
label variable loutput "ln(Output)"
label variable lefficiency "ln(Energy Efficiency)"
label variable treat_post "Treat*Post"
label variable province_year "Province*Year"
label variable ind2_year "2-digit Industry*Year"
label variable missing "Missing Coal Data"

xtset firmid year

save "$revision/Data/TableA9_B.dta",replace

