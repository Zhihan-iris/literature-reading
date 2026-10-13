
********************************************************************************
*                      Data Cleaning for ASIF
********************************************************************************

// Import raw data

use "$revision/Raw_Data/ASIF/ASIF_raw.dta",clear

// Add Top1000 and Top1000 identifiers

merge 1:1 id_in_panel legcode_in_panel name year using "$revision/Raw_Data/Namelist/Top1000_Top10000_ID1.dta"
drop _merge

replace qianjia_md_dummy=0 if qianjia_md_dummy==.
replace qianjia_kh_dummy=0 if qianjia_kh_dummy==.
replace qianjia_all_dummy=0 if qianjia_all_dummy==.
replace wanjia_dummy=0 if wanjia_dummy==.
replace legcode_id=0 if legcode_id==.

// Save file

save "$revision/Raw_Data/ASIF/ASIF.dta",replace

// Adjust identifiers with panel id

gsort id_in_panel -qianjia_md_dummy
by id_in_panel: replace qianjia_md_dummy=qianjia_md_dummy[1]

gsort id_in_panel -qianjia_kh_dummy
by id_in_panel: replace qianjia_kh_dummy=qianjia_kh_dummy[1]

gsort id_in_panel -qianjia_all_dummy
by id_in_panel: replace qianjia_all_dummy=qianjia_all_dummy[1]

gsort id_in_panel -wanjia_dummy
by id_in_panel: replace wanjia_dummy=wanjia_dummy[1]

gsort id_in_panel legcode_id
by id_in_panel: replace legcode_id=legcode_id[1]

// Keep Top1000 and Top10000 samples

keep if qianjia_md_dummy==1 | qianjia_kh_dummy==1  | qianjia_all_dummy==1 |  wanjia_dummy==1

// Save file

save "$revision/Raw_Data/ASIF/ASIF_Top1000_Top10000.dta", replace

// Drop samples that cannot be uniquely identified

drop if legcode_id==99999 | legcode_id==1099999
ren * GQ_*
ren GQ_legcode_id legcode_id
ren GQ_year year

// Save file

save "$revision/Raw_Data/ASIF_Top1000_Top10000_for_Matching_CESD.dta",replace

********************************************************************************
*                          Data Cleaning for CESD
********************************************************************************

// Import raw data

use "$revision/Raw_Data/CESD/CESD_raw.dta",clear

// Add Top1000 and Top1000 Identifiers

merge 1:1 id_in_panel legcode_in_panel name year using "$revision/Raw_Data/Namelist/Top1000_Top10000_ID2.dta"
drop _merge

replace qianjia_md_dummy=0 if qianjia_md_dummy==.
replace qianjia_kh_dummy=0 if qianjia_kh_dummy==.
replace qianjia_all_dummy=0 if qianjia_all_dummy==.
replace wanjia_dummy=0 if wanjia_dummy==.
replace legcode_id=0 if legcode_id==.

// Save file

save "$revision/Raw_Data/CESD/CESD.dta",replace

// Adjust identifiers with panel id 

gsort id_in_panel -qianjia_md_dummy
by id_in_panel: replace qianjia_md_dummy=qianjia_md_dummy[1]

gsort id_in_panel -qianjia_kh_dummy
by id_in_panel: replace qianjia_kh_dummy=qianjia_kh_dummy[1]

gsort id_in_panel -qianjia_all_dummy
by id_in_panel: replace qianjia_all_dummy=qianjia_all_dummy[1]

gsort id_in_panel -wanjia_dummy
by id_in_panel: replace wanjia_dummy=wanjia_dummy[1]

gsort id_in_panel legcode_id
by id_in_panel: replace legcode_id=legcode_id[1]

// Keep Top1000 and Top10000 samples

keep if qianjia_md_dummy==1 | qianjia_kh_dummy==1 | qianjia_all_dummy==1 | wanjia_dummy==1

// Drop firm samples that cannot be uniquely identified

drop if legcode_id==99999 | legcode_id==1099999

duplicates tag legcode_id year,gen(du_legcode_id_year)
drop if du_legcode_id_year>0
drop du_legcode_id_year

// Merge with ASIF

merge 1:1 legcode_id year using "$revision/Raw_Data/ASIF_Top1000_Top10000_for_Matching_CESD.dta"
drop if _merge==2
ren _merge merge_GQ

// Save file

xtset id_in_panel year

save "$revision/Raw_Data/CESD/CESD_Top1000_Top10000_Raw.dta",replace

// Sample Restriction and Variable Generation

// Drop industries with electricity use >30%

merge m:1 ind4 using "$revision/Raw_Data/CESD/Energy_Type.dta",update 
keep if _merge==3
drop _merge
drop if power_type==0

// Energy and output data

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

gen energy=coal*0.9+oil*1.4286+ gas*13.3 if power_type==1
replace energy=coal*0.9+oil*1.4286 if power_type==2
replace energy=coal*0.9+oil*1.4286+ gas*5 if power_type==3

gen lcoal=ln(coal)
gen lenergy=ln(energy)
gen loil=ln(oil)
gen lgas=ln(gas)

gen loutput=ln(production*10)
gen loutput_ASIF=ln(GQ_giovpp)

// Energy efficiency

gen lefficiency=ln(production*10/energy)

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

gen eff_robust=GQ_salescost/(energy*coal_price/1000)
replace eff_robust=. if eff_robust<1
gen lefficiency_robust=ln(eff_robust)
label variable lefficiency_robust "ln(Sales Cost/Energy Cost)"

// Energy mix

gen coal_share=coal*0.9/energy
gen oil_share=oil*1.4286/energy
gen gas_share=1-coal_share-oil_share
replace gas_share=0 if gas_share<0

// Treat-post

gen post2007=1 if year>2006
replace post2007=0 if year<=2006

gen interaction_md_2007= qianjia_md_dummy* post2007
gen interaction_kh_2007= qianjia_kh_dummy* post2007
gen interaction_all_2007= qianjia_all_dummy* post2007

// Control groups

gen qianjia_md_wanjia=1 if qianjia_md_dummy==1
replace qianjia_md_wanjia=1 if wanjia_dummy==1 & qianjia_all_dummy!=1

gen qianjia_kh_wanjia=1 if qianjia_kh_dummy==1
replace qianjia_kh_wanjia=1 if wanjia_dummy==1 & qianjia_all_dummy!=1

gen qianjia_all_wanjia=1 if qianjia_all_dummy==1
replace qianjia_all_wanjia=1 if wanjia_dummy==1

// Ownership

cap drop soe
gen ownership= GQ_rtype
replace ownership=. if ownership<100 | ownership>390
gen soe=1 if ownership==110 | ownership==141 |ownership==143 | ownership==151
replace soe=0 if soe==. & ownership!=.
replace soe=2 if soe==.
gsort id_in_panel soe
by id_in_panel: replace soe=soe[1] if soe[1]<2 & soe==2
replace soe=. if soe==2

// Province

gen province=int(countyid_new_panel/10000)

// Energy-intensive industries

gen qianjia_hy=1 if ind2==26 | ind2==31 | ind2==44 |ind2==30 |ind2==25 |ind2==32 |ind2==6  |ind2==22 |ind2==7

// Drop samples with wrong data

drop if wrong==1

// Sample period

drop if year<2001

// Drop firepower firms

gen firepower=(ind4==4411)
drop if firepower==1

// Drop extreme values and untreated sample

xtset id_in_panel year
gen growth_energy=D.energy/L.energy
bysort id_in_panel:egen total_energy=total(energy) 
bysort id_in_panel:gen mean_energy=(total_energy-energy)/(_N-1)
gen energy_level=energy/mean_energy
gen energy_right=(growth_energy<10 | energy_level<10 )

gen untreated=(energy>18*10^4 & energy!=. & qianjia_all_dummy==0 & year==2004 )
replace untreated=0 if untreated!=1
gsort id_in_panel -untreated
by id_in_panel: replace untreated=untreated[1]

drop if energy_right==0
drop if untreated==1

// ASIF controls

gen roa=GQ_oprofit/GQ_tasset
winsor2 roa,trim replace

gen age=year-GQ_fyear+1

gen exp=1 if GQ_edv>0 & GQ_edv!=.
replace exp=0 if exp==.

// Check for annual coal data report

sort id_in_panel coal
by id_in_panel: gen coal_min=coal[1]
gsort id_in_panel -coal
by id_in_panel: gen coal_max=coal[1]
gen coal_exist=1 if coal_min>0 & coal_max>0 & coal_min!=. & coal_max!=.

keep if qianjia_md_wanjia==1 & coal_exist==1

// Save file 

xtset id_in_panel year

save "$revision/Raw_Data/CESD/CESD_Top1000_Top10000.dta",replace

// Erase temp file

erase "$revision/Raw_Data/ASIF_Top1000_Top10000_for_Matching_CESD.dta"
