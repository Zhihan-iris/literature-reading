
* Data for Moment 5. Estimation for Energy Share

*-----------------------------
* Top1000 & Related (Top10000)
*-----------------------------

*Import CESD Data

use "$revision/Raw_Data/CESD/CESD_Top1000_Top10000.dta",clear

*Keep Top1000 & Top10000

keep if qianjia_md_wanjia==1 & coal_exist==1

*Keep 4-digit Related Firms

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

keep if qianjia_md_dummy==1 | same_ind4==1

*Variables

keep id_in_panel name year ind4 ind2 qianjia_md_dummy coal_s GQ_interinput GQ_twagepay
order id_in_panel name year ind4 ind2 qianjia_md_dummy coal_s GQ_interinput GQ_twagepay

egen firmid=group(id_in_panel)
drop id_in_panel

ren qianjia_md_dummy top1000
ren coal_s energy
ren GQ_interinput intercost
ren GQ_twagepay laborcost

xtset firmid year

label variable firmid "Firm ID"
label variable name "Firm Name"
label variable year "Data Year"
label variable ind4 "4-digit Industry"
label variable ind2 "2-digit Industry"
label variable top1000 "Treat"
label variable energy "Energy"
label variable intercost "Intermediate Input Cost"
label variable laborcost "Labor Cost"

save "$revision/Data/Moment5_1.dta",replace

*------------------
* Top1000 Industry
*------------------

*ASIF Controls

use "$revision/Raw_Data/ASIF/ASIF.dta",clear
keep legcode_in_panel name year interinput twagepay
ren legcode_in_panel legcode
keep if year>=2001 & year<=2007

preserve
keep legcode year interinput twagepay
duplicates tag legcode year,gen(du)
drop if du>0
save "$revision/Data/ASIF_Variable_Legcode.dta",replace
restore

keep name year interinput twagepay
duplicates tag name year,gen(du)
drop if du>0
save "$revision/Data/ASIF_Variable_Name.dta",replace

*Import CESD Data

use "$revision/Raw_Data/CESD/CESD.dta",clear

*Drop Electricity-Intensive Industries

merge m:1 ind4 using "$revision/Raw_Data/CESD/Energy_Type.dta"
keep if _merge==3
drop _merge
drop if power_type==0

*Energy Variable

gen coal=v15
replace coal=emi_coal if year==2010
gen oil=v19
replace oil=emi_oil if year==2010
gen gas=v23
replace gas=emi_gas if year==2010

replace coal=0 if coal==.
replace oil=0 if oil==.
replace gas=0 if gas==.

gen energy=coal*0.9+oil*1.4286+gas*13.3 if power_type==1
replace energy=coal*0.9+oil*1.4286 if power_type==2
replace energy=coal*0.9+oil*1.4286+gas*5 if power_type==3

*Data Cleaning

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
gen energy_level=energy/mean_energy

gen energy_right=(growth_energy<10 | energy_level<10)
drop if energy_right==0

*Drop Untreated

gen untreated=(energy>18*10^4 & energy!=. & qianjia_all_dummy==0 & year==2004 )
replace untreated=0 if untreated!=1
gsort id_in_panel -untreated
by id_in_panel: replace untreated=untreated[1]

drop if untreated==1

*Drop Firms That Did Not Report Coal Data Annually

sort id_in_panel coal
by id_in_panel: egen missing=count(id_in_panel) if coal==0

xtset id_in_panel year
xfill missing, i(id_in_panel)
replace missing=0 if missing==.

drop if missing>0

*Top1000 Industries

keep if ind2==32 | ind2==26 | ind2==31 | ind2==33 | ind2==7 | ind2==25 | ind2==6 | ind2==17 | ind2==22 | ind2==44

*Matched with ASIF Data

ren legcode_in_panel legcode
merge m:1 legcode year using "$revision/Data/ASIF_Variable_Legcode.dta"
drop if _merge==2
drop _merge

merge m:1 name year using "$revision/Data/ASIF_Variable_Name.dta",update
drop if _merge==2
drop _merge

*Variables

keep id_in_panel name year ind4 ind2 qianjia_md_dummy energy interinput twagepay
order id_in_panel name year ind4 ind2 qianjia_md_dummy energy interinput twagepay

egen firmid=group(id_in_panel)
drop id_in_panel

ren qianjia_md_dummy top1000
ren interinput intercost
ren twagepay laborcost

xtset firmid year

label variable firmid "Firm ID"
label variable name "Firm Name"
label variable year "Data Year"
label variable ind4 "4-digit Industry"
label variable ind2 "2-digit Industry"
label variable top1000 "Treat"
label variable energy "Energy"
label variable intercost "Intermediate Input Cost"
label variable laborcost "Labor Cost"

save "$revision/Data/Moment5_2.dta",replace

* Erase Temp File

erase "$revision/Data/ASIF_Variable_Legcode.dta"
erase "$revision/Data/ASIF_Variable_Name.dta"
