
*Data for Table A.22 Robustness of Spillovers to Related Firms on Output: Entropy Matching

***********************************************
*  Pre-Treatment of ASIF for Entropy Matching
***********************************************

*---------------
*  Import Data 
*---------------

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

*Drop Sample without Output Data 
drop if giovpp==. | giovpp==0

*Drop Sample before Policy
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

*-----------------------
*  Industry Adjustment
*-----------------------

gen ind4=cic03
duplicates tag id_in_panel ind4,gen(du_ind4)
gsort id_in_panel -du_ind4 -year
by id_in_panel: replace ind4=ind4[1]
drop du_ind4

*-------------
*  Variables
*-------------

*Output
gen loutput=ln(giovpp)

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

* Variables for Analysis

keep id_in_panel name legcode_in_panel year ind4 ind2 province loutput lsales lprofit lfasset lemp soe roa age exp ind2_year province_year 

xtset id_in_panel year
egen firmid=group(id_in_panel)
drop id_in_panel

order firmid name legcode_in_panel year ind4 ind2 province loutput lsales lprofit lfasset lemp soe roa age exp ind2_year province_year 

ren legcode_in_panel legcode

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

save "$revision/Data/TableA22.dta",replace
