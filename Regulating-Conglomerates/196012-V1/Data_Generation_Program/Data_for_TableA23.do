
* Data for Table A.23 Robustness of Spillovers to Related Firms on Energy Use and Energy Effciency: Entropy Matching

************************************************
*  Pre-Treatment of CESD for Entropy Matching
************************************************

*=========================
*  Pre-Treatment of CESD
*=========================

*----------
* Raw Data
*----------

use "$revision/Raw_Data/CESD/CESD.dta", clear

*----------------------------------------
* Drop Electricity-Intensive Industries
*----------------------------------------

merge m:1 ind4 using "$revision/Raw_Data/CESD/Energy_Type.dta"
drop if _merge==1
drop _merge
drop if power_type==0

*----------
* Variable
*----------

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

gen energy_right=(growth_energy<10 | energy_test<10 )
drop if energy_right==0

gen untreated=(energy>18*10^4 & energy!=. & qianjia_all_dummy==0 & year==2004 )
replace untreated=0 if untreated!=1
gsort id_in_panel -untreated
by id_in_panel: replace untreated=untreated[1]

drop if untreated==1

*Yearly Coal Data
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

*Drop Sample without Data after Policy
gsort id_in_panel -year
by id_in_panel: gen endyear=year[1]
drop if endyear<=2006
drop endyear

*Drop Sample without 2001-2006 Panel Data
xtset id_in_panel year
forvalues i=2001(1)2006 {
    gen sample`i'=1 if year==`i'
	xfill sample`i',i(id_in_panel)
	drop if sample`i'!=1
	drop sample`i'
	}
	
*Fixed Effects
egen ind2_year=group(ind2 year)

gen province=int(countyid_new_panel/10000)
egen province_year=group(province year)

*--------------------
* Add ASIF Controls
*--------------------

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

*----------
*  Label
*----------

keep id_in_panel name legcode_in_panel year ind4 ind2 province lenergy lefficiency soe roa age exp ind2_year province_year

xtset id_in_panel year
egen firmid=group(id_in_panel)
drop id_in_panel

order firmid name legcode_in_panel year ind4 ind2 province lenergy lefficiency soe roa age exp ind2_year province_year

ren legcode_in_panel legcode

label variable firmid "Firm ID"
label variable name "Firm Name"
label variable legcode "Legal Code"
label variable year "Data Year"
label variable ind4 "4-digit Industry"
label variable ind2 "2-digit Industry"
label variable province "Province ID"
label variable lenergy "ln(Energy)"
label variable lefficiency "ln(Efficiency)"
label variable soe "State Owned"
label variable roa "Return to Asset"
label variable age "Firm Age"
label variable exp "Export Status"
label variable province_year "Province*Year"
label variable ind2_year "2-digit Industry*Year"

save "$revision/Data/TableA23.dta",replace

* Erase Temp File

erase "$revision/Data/ASIF_Control_Legcode.dta"
erase "$revision/Data/ASIF_Control_Name.dta"
