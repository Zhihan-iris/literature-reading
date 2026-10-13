
*Data for Table A.38: Direct and Spillover Effects of Top 10,000 Program

*******************************************
* Data for Top10,000 Regulated Regression
*******************************************

*----------
*  Sample 
*----------

* Import Data

use "$revision/Raw_Data/ASIF/ASIF.dta",clear

* Time Period

keep if year>=2009

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

* Drop Top10000 Related Firms

merge m:1 id_in_panel using "$revision/Data/Related_ID_Short.dta",update
drop if _merge==2
drop _merge

drop if top10000_related==1 & wanjia_dummy!=1

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

*Fixed Effects
gen province=int(address_adj/10000)
egen province_year=group(province year)
gen ind2=int(ind4/100)
egen ind2_year=group(ind2 year)

*Energy-Intensive Industry
keep if ind2==6 | ind2==7 | ind2==25 | ind2==26 | ind2==31 | ind2==32 | ind2==33 | ind2==44 | ind2==17 | ind2==22

*Treat-Post
gen treat_post=1 if wanjia_dummy==1 & year>=2012
replace treat_post=0 if treat_post==.

*Variables for Analysis

keep id_in_panel name legcode year ind4 ind2 province loutput soe roa age exp ind2_year province_year wanjia_dummy treat_post

xtset id_in_panel year
egen firmid=group(id_in_panel)
drop id_in_panel

order firmid name legcode year ind4 ind2 province loutput soe roa age exp ind2_year province_year wanjia_dummy treat_post

ren wanjia_dummy top10000

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
label variable loutput "ln(Output)"
label variable soe "State Owned"
label variable roa "Return to Asset"
label variable age "Firm Age"
label variable exp "Export Status"
label variable province_year "Province*Year"
label variable ind2_year "2-digit Industry*Year"
label variable top10000 "Top10000"
label variable treat_post "Top10000*Post"

xtset firmid year

save "$revision/Data/TableA38_A.dta",replace

******************************************
* Data for Top10,000 Related Regression
******************************************

*----------
*  Sample 
*----------

*Import Data

use "$revision/Raw_Data/ASIF/ASIF.dta",clear

* Time Period

keep if year>=2009

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

* Drop Sample after Policy

sort id_in_panel year
by id_in_panel: gen startyear=year[1]
drop if startyear>=2012
drop startyear

* Drop Sample before Policy

gsort id_in_panel -year
by id_in_panel: gen endyear=year[1]
drop if endyear<=2011
drop endyear

* Drop if Only One Sample before Policy

duplicates tag id_in_panel if year<=2011,gen(num_before)
xtset id_in_panel year
xfill num_before,i(id_in_panel)
drop if num_before==0
drop num_before

*--------------------
*  Top10000 Related
*--------------------

merge m:1 id_in_panel using "$revision/Data/Related_ID_Short.dta" ,update
drop if _merge==2
drop _merge

replace top10000_related=0 if top10000_related==.

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

*Fixed Effects
gen province=int(address_adj/10000)
egen province_year=group(province year)
gen ind2=int(ind4/100)
egen ind2_year=group(ind2 year)

*Energy-Intensive Industry
keep if ind2==6 | ind2==7 | ind2==25 | ind2==26 | ind2==31 | ind2==32 | ind2==33 | ind2==44 | ind2==17 | ind2==22

*Variables for Analysis

keep id_in_panel name legcode year ind4 ind2 province giovpp loutput soe roa age exp ind2_year province_year top10000_related

xtset id_in_panel year
egen firmid=group(id_in_panel)
drop id_in_panel

order firmid name legcode year ind4 ind2 province giovpp loutput soe roa age exp ind2_year province_year top10000_related

ren giovpp output

xtset firmid year

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
label variable soe "State Owned"
label variable roa "Return to Asset"
label variable age "Firm Age"
label variable exp "Export Status"
label variable province_year "Province*Year"
label variable ind2_year "2-digit Industry*Year"
label variable top10000_related "Top10000 Related"

save "$revision/Data/TableA38_B.dta",replace

***************************************************
* Data for Top10,000 Market Spillover Regression
***************************************************

*-------------------------------------
* Energy Saving Target for Top10,000
*-------------------------------------

* Industry-Level Aggregate

use "$revision/Raw_Data/Top10000/Top10000_Energy_Saving_Target.dta",clear

keep ind2 target
drop if ind2==.
replace target=target/10000

bysort ind2: egen target_ind2=total(target)
duplicates drop ind2,force

merge 1:1 ind2 using "$revision/Raw_Data/Industry/Industry_Energy_Use_2010.dta",update

replace target_ind2=0 if target_ind2==.
gen top10000_spillover=target_ind2/total2010
drop if top10000_spillover==.

keep ind2 top10000_spillover
label variable ind2 "2-digit Industry 2002"
label variable top10000_spillover "Top10,000 Market Spillover"

* Incremental Target

merge 1:1 ind2 using "$revision/Data/Top1000_2008_2010_Industry.dta",update
drop _merge

ren spillover top1000_spillover
gen spillover=top10000_spillover-top1000_spillover

sum spillover if ind2==6 | ind2==7 | ind2==25 | ind2==26 | ind2==31 | ind2==32 | ind2==33 | ind2==44 | ind2==17 | ind2==22
local a=r(mean)
save "$revision/Data/Top10000_Industry.dta",replace

*---------------
*   ASIF Data
*---------------

* Drop Top1000 & Related

use "$revision/Raw_Data/ASIF/ASIF.dta",clear

keep if year>=2009 & year<=2013

xtset id_in_panel year
replace qianjia_md_dummy=. if qianjia_md_dummy==0
xfill qianjia_md_dummy,i(id_in_panel)
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

* Drop Top10000 and Related

drop if wanjia_dummy==1

merge m:1 id_in_panel using "$revision/Data/Related_ID_Short.dta",update
drop if _merge==2
drop _merge

drop if top10000_related==1

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

* Depedent Variable and Firm Controls

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

* Energy-Intensive Industry

gen top1000_industry=1 if ind2==6 | ind2==7 | ind2==25 | ind2==26 | ind2==31 | ind2==32 | ind2==33 | ind2==44 | ind2==17 | ind2==22

* Market Spillover

merge m:1 ind2 using "$revision/Data/Top10000_Industry.dta",update
drop if _merge!=3
drop _merge

gen spillover_post=spillover
replace spillover_post=0 if year<2012
replace spillover_post=spillover_post/`a'

* Industry Controls

merge m:1 ind2 year using "$revision/Raw_Data/Industry/Industry_Control_2009_2013.dta"
drop if _merge==2
drop _merge

gen loutput_ind2=ln(output_ind2)
gen lenergy_ind2=ln(energy_ind2)

* Variables for Analysis

keep id_in_panel name year ind2 loutput spillover_post soe roa age exp loutput_ind2 lenergy_ind2 top1000_industry

xtset id_in_panel year
egen firmid=group(id_in_panel)
drop id_in_panel

order firmid name year ind2 loutput spillover_post soe roa age exp loutput_ind2 lenergy_ind2 top1000_industry

* Label

label variable firmid "Firm ID"
label variable name "Firm Name"
label variable year "Data Year"
label variable ind2 "2-digit Industry"
label variable loutput "ln(Output)"
label variable spillover_post "Market Spillover(Top10000-Top1000)*Post"
label variable loutput_ind2 "ln(Industry Output)"
label variable lenergy_ind2 "ln(Industry Energy)"
label variable soe "State Owned"
label variable roa "Return to Asset"
label variable age "Firm Age"
label variable exp "Export Status"
label variable top1000_industry "Energy-Intensive Indstries"

save "$revision/Data/TableA38_C.dta",replace

erase "$revision/Data/Shareholder.dta"
erase "$revision/Data/Top1000_2008_2010_Industry.dta"
erase "$revision/Data/Top10000_Industry.dta"
