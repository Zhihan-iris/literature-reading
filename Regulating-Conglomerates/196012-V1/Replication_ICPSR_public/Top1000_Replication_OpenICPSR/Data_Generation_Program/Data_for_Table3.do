
*Data for Table 3. Industry-level Spillovers and Within-Conglomerate Effects

***************************************
*  Data for Industry-Level Spillovers
***************************************

*------------------------
*  Energy Saving Target
*------------------------

* Industry-Level Target

use "$revision/Raw_Data/Top1000/Top1000_Energy_Saving_Target.dta",clear

keep ind2 target
bysort ind2: egen target_ind2=total(target)
duplicates drop ind2,force

* Industry-Level Total Energy Use

merge 1:1 ind2 using "$revision/Raw_Data/Industry/Industry_Energy_2004.dta",update

replace target_ind2=0 if target_ind2==.
gen spillover=target_ind2/total2004

keep ind2 spillover
label variable ind2 "2-digit Industry 2002"
label variable spillover "Market Spillover"

* Mean Spillover for Energy-Intensive Industries

sum spillover if ind2==6 | ind2==7 | ind2==25 | ind2==26 | ind2==17 | ind2==22 | ind2==31 | ind2==32 | ind2==33 | ind2==44
local a=r(mean)
dis `a'

save "$revision/Data/Top1000_2008_2010_Industry.dta",replace

*---------------
*   ASIF Data
*---------------

use "$revision/Raw_Data/ASIF/ASIF.dta",clear

keep if year>2000 & year<2012

* Industry & Province

gen ind4=cic03
duplicates tag id_in_panel ind4,gen(du_ind4)
gsort id_in_panel -du_ind4 -year
by id_in_panel: replace ind4=ind4[1]
drop du_ind4

gen ind2=int(ind4/100)
drop if ind2==.
keep if ind2>=6 & ind2<=46

gen province=int(address_adj/10000)
drop if province==.
drop if province<11 | province>65

* Identify Industries with Top1000

xtset id_in_panel year
replace qianjia_md_dummy=. if qianjia_md_dummy==0
xfill qianjia_md_dummy,i(id_in_panel)
replace qianjia_md_dummy=0 if qianjia_md_dummy==.

duplicates drop id_in_panel if qianjia_md_dummy==1,force
bysort ind4: egen top1000_count=total(qianjia_md_dummy)
replace top1000_count=1 if top1000_count>1 & top1000_count!=.

* Drop Top1000 & Related

drop if qianjia_md_dummy==1

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
drop if same_ind4==1

* Energy-Intensive Industries

gen top1000_industry=1 if ind2==6 | ind2==7 | ind2==25 | ind2==26 | ind2==31 | ind2==32 | ind2==33 | ind2==44 | ind2==17 | ind2==22

* Dependent Variables and Firm Controls

gen loutput=ln(giovpp)

drop soe
gen ownership=rtype
replace ownership=. if ownership<100 | ownership>390
gen soe=1 if ownership==110 | ownership==141 |ownership==143 | ownership==151
replace soe=0 if soe==. & ownership!=.
drop ownership

gen roa=oprofit/tasset
winsor2 roa,trim replace

gen age=year-fyear+1

gen exp=1 if edv>0 & edv!=.
replace exp=0 if exp==.

drop if loutput==. | soe==. | roa==. | age==. | exp==.

* Market Spillover (Policy Intensity)

merge m:1 ind2 using "$revision/Data/Top1000_2008_2010_Industry.dta"
drop if _merge!=3
drop _merge

gen spillover_post=spillover
replace spillover_post=0 if year<2007

replace spillover=spillover/`a'
replace spillover_post=spillover_post/`a'

* Industry Controls

merge m:1 ind2 year using "$revision/Raw_Data/Industry/Industry_Output_2001_2011.dta"
drop if _merge==2
drop _merge

merge m:1 ind2 year using "$revision/Raw_Data/Industry/Industry_Energy_2001_2011.dta"
drop if _merge==2
drop _merge

gen loutput_ind2=ln(output_ind2)
gen lenergy_ind2=ln(energy_ind2)

* Variables for Analysis

keep id_in_panel name year ind2 loutput spillover spillover_post loutput_ind2 lenergy_ind2 soe roa age exp top1000_industry top1000_count

xtset id_in_panel year
egen firmid=group(id_in_panel)
drop id_in_panel

order firmid name year ind2 loutput spillover spillover_post loutput_ind2 lenergy_ind2 soe roa age exp top1000_industry top1000_count

* Label

label variable firmid "Firm ID"
label variable name "Firm Name"
label variable year "Data Year"
label variable ind2 "2-digit Industry"
label variable loutput "ln(Output)"
label variable spillover "Spillover"
label variable spillover_post "Spillover*Post"
label variable loutput_ind2 "ln(Industry Output)"
label variable lenergy_ind2 "ln(Industry Energy)"
label variable soe "State Owned"
label variable roa "Return to Asset"
label variable age "Firm Age"
label variable exp "Export Status"
label variable top1000_industry "Energy-Intensive Indstries"
label variable top1000_count "With Top1000 Firms in 4-digit Industry"

save "$revision/Data/Table3_1.dta",replace

**********************************************************
* Data for Within-Conglomerate Difference-in-Differences
**********************************************************

*------------
*  Raw Data
*------------

use "$revision/Raw_Data/ASIF/ASIF.dta",clear

*----------
*  Sample 
*----------

keep if year>2000 & year<2012

*---------------------
*  Top1000 & Related
*---------------------

*Top1000 Firms

xtset id_in_panel year
replace qianjia_md_dummy=. if qianjia_md_dummy==0
xfill qianjia_md_dummy,i(id_in_panel)
replace qianjia_md_dummy=0 if qianjia_md_dummy==.

*Related Firms

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
replace same_ind4=0 if same_ind4==.
replace same_ind4=0 if qianjia_md_dummy==1

keep if qianjia_md_dummy==1 | same_ind4==1

*----------------
*  Conglomerate
*----------------

*Top1000

gen qianjia=name
fdta qianjia,f(".")
fdta qianjia,f("（") t("(")
fdta qianjia,f("）") t(")")

merge m:1 qianjia using "$revision/Raw_Data/CARD/Conglomerate_ID_Top1000_Name.dta"
drop if _merge==2
drop _merge

sort id_in_panel conglomerate
by id_in_panel: replace conglomerate=conglomerate[1]
by id_in_panel: replace type=type[1]

fdta qianjia,f("(") 
fdta qianjia,f(")") 

merge m:1 qianjia using "$revision/Raw_Data/CARD/Conglomerate_ID_Top1000_Name2.dta",update
drop if _merge==2
drop _merge

sort id_in_panel conglomerate
by id_in_panel: replace conglomerate=conglomerate[1]
by id_in_panel: replace type=type[1]

merge m:1 legcode using "$revision/Raw_Data/CARD/Conglomerate_ID_Top1000_Legcode.dta",update
drop if _merge==2
drop _merge

sort id_in_panel conglomerate
by id_in_panel: replace conglomerate=conglomerate[1]
by id_in_panel: replace type=type[1]

*Related

merge m:1 name using "$revision/Raw_Data/CARD/Conglomerate_ID_Related_Name.dta",update
drop if _merge==2
drop _merge

sort id_in_panel conglomerate
by id_in_panel: replace conglomerate=conglomerate[1]
by id_in_panel: replace type=type[1]

merge m:1 legcode using "$revision/Raw_Data/CARD/Conglomerate_ID_Related_Legcode.dta",update
drop if _merge==2
drop _merge

sort id_in_panel conglomerate
by id_in_panel: replace conglomerate=conglomerate[1]
by id_in_panel: replace type=type[1]

*-----------------------
*  Industry Adjustment
*-----------------------

gen ind4=cic03
duplicates tag id_in_panel ind4,gen(du_ind4)
gsort id_in_panel -du_ind4 -year
by id_in_panel: replace ind4=ind4[1]
drop du_ind4

gen ind2=int(ind4/100)
drop if ind2==.
keep if ind2>=6 & ind2<=46

*-------------
*  Variables
*-------------

*Output
drop if giovpp==. | giovpp==0
gen loutput=ln(giovpp)

*SOE
drop soe
gen ownership=rtype
replace ownership=. if ownership<100 | ownership>390
gen soe=1 if ownership==110 | ownership==141 |ownership==143 | ownership==151
replace soe=0 if soe==. & ownership!=.
drop ownership

*ROA
gen roa=oprofit/tasset
winsor2 roa,trim replace

*Age
replace fyear=. if fyear<1800
gen age=year-fyear+1
xtset id_in_panel year
replace age=l.age+1 if age==.
replace age=f.age-1 if age==.

*Export
gen exp=1 if edv>0 & edv!=.
replace exp=0 if exp==.

*Fixed Effects
gen province=int(address_adj/10000)
drop if province==.
drop if province<11 | province>65
egen province_year=group(province year)
egen ind2_year=group(ind2 year)
egen conglomerate_year=group(conglomerate year)

*Treat-Post
gen treat_post=1 if qianjia_md_dummy==1 & year>=2007
replace treat_post=0 if treat_post==.

*Variables for Analysis

keep id_in_panel name legcode year ind4 ind2 province qianjia_md_dummy same_ind4 treat_post giovpp loutput soe roa age exp province_year ind2_year conglomerate conglomerate_year

xtset id_in_panel year
egen firmid=group(id_in_panel)
drop id_in_panel

order firmid name legcode year ind4 ind2 province qianjia_md_dummy same_ind4 treat_post giovpp loutput soe roa age exp province_year ind2_year conglomerate conglomerate_year

ren qianjia_md_dummy top1000
ren same_ind4 related
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
label variable top1000 "Top1000 Firm"
label variable related "4-digit Industry Related Firm"
label variable treat_post "Treat*Post"
label variable output "Output"
label variable loutput "ln(Output)"
label variable soe "State Owned"
label variable roa "Return to Asset"
label variable age "Firm Age"
label variable exp "Export Status"
label variable province_year "Province*Year"
label variable ind2_year "2-digit Industry*Year"
label variable conglomerate "Conglomerate ID"
label variable conglomerate_year "Conglomerate*Year"

save "$revision/Data/Table3_2.dta",replace
