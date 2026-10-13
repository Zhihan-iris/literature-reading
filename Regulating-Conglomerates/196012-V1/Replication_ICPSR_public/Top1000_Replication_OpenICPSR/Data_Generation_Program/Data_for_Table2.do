
* Data for Table 2. Spillover Effects on the Related Firms

*************************************************
*  Pre-Treatment of ASIF for Distance Matching
*************************************************

*------------
*  Raw Data 
*------------

use "$revision/Raw_Data/ASIF/ASIF.dta",clear

*----------
*  Sample 
*----------

*Time Period: 2001-2011
keep if year>2000 & year<2012

*Drop Top1000 Firms
xtset id_in_panel year
replace qianjia_md_dummy=. if qianjia_md_dummy==0
xfill qianjia_md_dummy,i(id_in_panel)
replace qianjia_md_dummy=0 if qianjia_md_dummy==.
drop if qianjia_md_dummy==1

*Drop Sample after Policy
sort id_in_panel year
by id_in_panel: gen startyear=year[1]
drop if startyear>=2007
drop startyear

*Drop Sample before Policy
gsort id_in_panel -year
by id_in_panel: gen endyear=year[1]
drop if endyear<=2006
drop endyear

*Drop if Only One Sample before Policy
duplicates tag id_in_panel if year<=2006,gen(num_before)
xtset id_in_panel year
xfill num_before,i(id_in_panel)
drop if num_before==0
drop num_before

*-----------------------
*  Industry Adjustment
*-----------------------

gen ind4=cic03
duplicates tag id_in_panel ind4,gen(du_ind4)
gsort id_in_panel -du_ind4 -year
by id_in_panel: replace ind4=ind4[1]
drop du_ind4
drop if ind4==.

*-------------
*  Variables
*-------------

*Output
replace giovpp=0 if giovpp==.
gen loutput=ln(giovpp)

*SOE
drop soe
gen ownership=rtype
replace ownership=. if ownership<100 | ownership>390
gen soe=1 if ownership==110 | ownership==141 | ownership==143 | ownership==151
replace soe=0 if soe==. & ownership!=.

*ROA
gen roa=oprofit/tasset
winsor2 roa,trim replace

*Age
replace fyear=. if fyear<1800
gen age=year-fyear+1
replace age=. if age<0

xtset id_in_panel year
replace age=l.age+1 if age==.
replace age=f.age-1 if age==.

*Export
gen exp=1 if edv>0 & edv!=.
replace exp=0 if exp==.

*Sales
gen lsales=ln(salesrevenue)

*Profit
gen lprofit=ln(oprofit)

*Fasset
gen lfasset=ln(fasset)

*Employment
gen lemp=ln(twagepay)

*Fixed Effects
gen province=int(address_adj/10000)
egen province_year=group(province year)
gen ind2=int(ind4/100)
egen ind2_year=group(ind2 year)

*Variables for Analysis

keep id_in_panel name legcode_in_panel year ind4 ind2 province giovpp loutput lsales lprofit lfasset lemp soe roa age exp ind2_year province_year 

xtset id_in_panel year
egen firmid=group(id_in_panel)
drop id_in_panel

order firmid name legcode_in_panel year ind4 ind2 province giovpp loutput lsales lprofit lfasset lemp soe roa age exp ind2_year province_year 

ren legcode_in_panel legcode
ren giovpp output

*----------
*  Label
*----------

label variable firmid "Firm ID"
label variable name "Firm Name"
label variable legcode "Legal Code"
label variable year "Data Year"
label variable ind4 "4-digit Industry"
label variable ind2 "2-digit Industry"
label variable province "Province ID"
label variable output "Output"
label variable loutput "ln(Output)"
label variable lsales "ln(Sales)"
label variable lprofit "ln(Profit)"
label variable lfasset "ln(Fixed Assets)"
label variable lemp "ln(Labor)"
label variable soe "State Owned"
label variable roa "Return to Asset"
label variable age "Firm Age"
label variable exp "Export Status"
label variable province_year "Province*Year"
label variable ind2_year "2-digit Industry*Year"

xtset firmid year

save "$revision/Data/Table2_1.dta",replace

************************************************
*  Pre-Treatment of CESD for Distance Matching
************************************************

*===========================
*  Construct ASIF Controls
*===========================

*-----------
*  Legcode
*-----------

use "$revision/Raw_Data/ASIF/ASIF.dta",clear

keep if year>=2001 & year<=2010

*SOE
drop soe
gen ownership=rtype
replace ownership=. if ownership<100 | ownership>390
gen soe=1 if ownership==110 | ownership==141 | ownership==143 | ownership==151
replace soe=0 if soe==. & ownership!=.

*ROA
gen roa=oprofit/tasset
winsor2 roa, trim replace

*Age
replace fyear=. if fyear<1800
gen age=year-fyear+1
replace age=. if age<0

xtset id_in_panel year
replace age=l.age+1 if age==.
replace age=f.age-1 if age==.

*Export
gen exp=1 if edv>0 & edv!=.
replace exp=0 if exp==.

duplicates tag legcode_in_panel year,gen(du)
drop if du>0

keep legcode_in_panel year soe roa age exp salescost
order legcode_in_panel year soe roa age exp salescost

save "$revision/Data/ASIF_Control_Legcode.dta",replace

*--------
*  Name
*--------

use "$revision/Raw_Data/ASIF/ASIF.dta",clear

keep if year>=2001 & year<=2010

*SOE
drop soe
gen ownership=rtype
replace ownership=. if ownership<100 | ownership>390
gen soe=1 if ownership==110 | ownership==141 |ownership==143 | ownership==151
replace soe=0 if soe==. & ownership!=.

*ROA
gen roa=oprofit/tasset
winsor2 roa,trim replace

*Age
replace fyear=. if fyear<1800
gen age=year-fyear+1
replace age=. if age<0

xtset id_in_panel year
replace age=l.age+1 if age==.
replace age=f.age-1 if age==.

*Export
gen exp=1 if edv>0 & edv!=.
replace exp=0 if exp==.

duplicates tag name year,gen(du)
drop if du>0

keep name year soe roa age exp salescost
order name year soe roa age exp salescost

save "$revision/Data/ASIF_Control_Name.dta",replace

*======================
*  CESD Data Cleaning
*======================

use "$revision/Raw_Data/CESD/CESD.dta", clear

*----------------------------------------
* Drop Electricity-Intensive Industries
*----------------------------------------

merge m:1 ind4 using "$revision/Raw_Data/CESD/Energy_Type.dta"
drop if _merge==1
drop _merge
drop if power_type==0

*-------------------
* Energy and Output
*-------------------

gen output=v10
replace output=emi_production_1 if year==2010
gen coal=v15
replace coal=emi_coal if year==2010
gen oil=v19
replace oil=emi_oil if year==2010
gen gas=v23
replace gas=emi_gas if year==2010

replace output=0 if output==.
replace coal=0 if coal==.
replace oil=0 if oil==.
replace gas=0 if gas==.

gen energy=coal*0.9+oil*1.4286+gas*13.3 if power_type==1
replace energy=coal*0.9+oil*1.4286 if power_type==2
replace energy=coal*0.9+oil*1.4286+gas*5 if power_type==3

gen lenergy=ln(energy)
gen loutput=ln(output*10)
gen lefficiency=ln(output*10/energy)

*--------
* Sample
*--------

*Time Period
drop if wrong==1
drop if year<2001

*Drop Fire Power
gen firepower=(ind4==4411)
drop if firepower==1

*Drop Extreme Value
xtset id_in_panel year
gen growth_energy=D.energy/L.energy
bysort id_in_panel: egen total_energy=total(energy) 
bysort id_in_panel: gen mean_energy=(total_energy-energy)/(_N-1)
gen energy_test=energy/mean_energy

gen energy_right=(growth_energy<10 | energy_test<10)
drop if energy_right==0

gen untreated=(energy>18*10^4 & energy!=. & qianjia_all_dummy==0 & year==2004 )
replace untreated=0 if untreated!=1
gsort id_in_panel -untreated
by id_in_panel: replace untreated=untreated[1]

drop if untreated==1

*Annual Coal Data
sort id_in_panel coal
by id_in_panel: gen coal_min=coal[1]
gsort id_in_panel -coal
by id_in_panel: gen coal_max=coal[1]
gen coal_exist=1 if coal_min>0 & coal_max>0 & coal_min!=. & coal_max!=.
keep if coal_exist==1

*Drop Top1000 Firms
xtset id_in_panel year
replace qianjia_md_dummy=. if qianjia_md_dummy==0
xfill qianjia_md_dummy,i(id_in_panel)
replace qianjia_md_dummy=0 if qianjia_md_dummy==.
drop if qianjia_md_dummy==1

*Drop Sample after Policy
sort id_in_panel year
by id_in_panel: gen startyear=year[1]
drop if startyear>=2007
drop startyear

*Drop Sample before Policy
gsort id_in_panel -year
by id_in_panel: gen endyear=year[1]
drop if endyear<=2006
drop endyear

*Drop if Only One Sample before Policy
duplicates tag id_in_panel if year<=2006,gen(num_before)
xtset id_in_panel year
xfill num_before,i(id_in_panel)
drop if num_before==0
drop num_before

*-----------
* Variables
*-----------

*Add ASIF Controls

merge m:1 legcode_in_panel year using "$revision/Data/ASIF_Control_Legcode",update
drop if _merge==2
drop _merge

merge m:1 name year using "$revision/Data/ASIF_Control_Name",update
drop if _merge==2
drop _merge

xtset id_in_panel year
replace soe=l.soe  if year==2010
replace roa=l.roa if year==2010
replace age=l.age+1 if year==2010
replace exp=l.exp if year==2010

*Fixed Effects

egen ind2_year=group(ind2 year)
gen province=int(countyid_new_panel/10000)
egen province_year=group(province year)

*Energy Efficiency Robustness

gen coal_price=334.78 if year==2001
replace coal_price=349.63 if year==2002
replace coal_price=334.36 if year==2003
replace coal_price=450.44 if year==2004
replace coal_price=535.43 if year==2005
replace coal_price=543.22 if year==2006
replace coal_price=592.85 if year==2007
replace coal_price=928.33 if year==2008
replace coal_price=763.90 if year==2009
replace coal_price=948.53 if year==2010
label variable coal_price "Price of Coal Equivalent"

gen eff_robust=salescost/(energy*coal_price/1000)
replace eff_robust=. if eff_robust<1
gen lefficiency_robust=ln(eff_robust)
label variable lefficiency_robust "ln(Sales Cost/Energy Cost)"

*Variables for Analysis

keep id_in_panel name legcode_in_panel year ind4 ind2 province energy lenergy lefficiency lefficiency_robust soe roa age exp ind2_year province_year 

xtset id_in_panel year
egen firmid=group(id_in_panel)
drop id_in_panel

order firmid name legcode_in_panel year ind4 ind2 province energy lenergy lefficiency lefficiency_robust soe roa age exp ind2_year province_year 

ren legcode_in_panel legcode

*----------
*  Label
*----------

label variable firmid "Firm ID"
label variable name "Firm Name"
label variable legcode "Legal Code"
label variable year "Data Year"
label variable ind4 "4-digit Industry"
label variable ind2 "2-digit Industry"
label variable province "Province ID"
label variable energy "Energy"
label variable lenergy "ln(Energy)"
label variable lefficiency "ln(Energy Efficiency)"
label variable soe "State Owned"
label variable roa "Return to Asset"
label variable age "Firm Age"
label variable exp "Export Status"
label variable province_year "Province*Year"
label variable ind2_year "2-digit Industry*Year"

save "$revision/Data/Table2_2.dta",replace
