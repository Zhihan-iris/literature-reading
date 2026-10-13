
* Data for Table A.24 Spillover Effects on the Output of Related Firms: Robustness to Different Definitions of Related Parties

*--------------------------------------
* Samples without Shareholding Changes
*--------------------------------------

use "$revision/Raw_Data/CARD/related_firms_name.dta",clear
keep if same_ind4==1
merge 1:1 name using "$revision/Raw_Data/CARD/Shareholding_Change.dta"
keep if _merge==1
drop _merge change
save "$revision/Data/TableA24_1.dta",replace

merge 1:1 name using "$revision/Raw_Data/CARD/Related_Legcode.dta" 
keep if _merge==3
drop if legcode==""
gen legcodelength=length(legcode)
keep if legcodelength==9
keep legcode same_ind2 same_ind4 same_province
gen related=1
order legcode related same_ind2 same_ind4 same_province
save "$revision/Data/TableA24_2.dta",replace

*----------------------------------------------------------
* Data for Scalars: Drop Samples with Shareholding Changes
*----------------------------------------------------------

use "$revision/Raw_Data/ASIF/ASIF.dta",clear

*Same Period

keep if year>=2001 & year<=2011

*Top1000 Firms

xtset id_in_panel year
replace qianjia_md_dummy=. if qianjia_md_dummy==0
xfill qianjia_md_dummy,i(id_in_panel)
replace qianjia_md_dummy=0 if qianjia_md_dummy==.

*Related Firms

ren legcode_in_panel legcode
merge m:1 legcode using "$revision/Data/TableA24_2.dta"
drop if _merge==2
drop _merge

merge m:1 name using "$revision/Data/TableA24_1.dta",update
drop if _merge==2
drop _merge

replace same_ind4=. if same_ind4==0
xtset id_in_panel year
xfill same_ind4,i(id_in_panel)
replace same_ind4=0 if same_ind4==.

*Sample

keep if qianjia_md_dummy==1 | same_ind4==1

*Variables

egen firmid=group(id_in_panel)

keep firmid year name legcode qianjia_md_dummy same_ind4 giovpp
order firmid year name legcode qianjia_md_dummy same_ind4 giovpp

ren qianjia_md_dummy top1000
ren same_ind4 top1000_related
ren giovpp output

*Label

label variable firmid "Firm ID"
label variable year "Data Year"
label variable name "Firm Name"
label variable legcode "Firm Legal Code"
label variable top1000 "Top1000"
label variable top1000 "Top1000 Related"
label variable output "Industrial Ouptut"

save "$revision/Data/TableA24_3.dta",replace

*----------------------------------
* Data for Scalars: Six Level 20%
*----------------------------------

use "$revision/Raw_Data/ASIF/ASIF.dta",clear

*Same Period

keep if year>=2001 & year<=2011

*Top1000 Firms

xtset id_in_panel year
replace qianjia_md_dummy=. if qianjia_md_dummy==0
xfill qianjia_md_dummy,i(id_in_panel)
replace qianjia_md_dummy=0 if qianjia_md_dummy==.

*Related Firms

ren legcode_in_panel legcode
merge m:1 legcode using "$revision/Data/TableA7_4.dta"
drop if _merge==2
drop _merge

merge m:1 name using "$revision/Data/TableA7_3.dta",update
drop if _merge==2
drop _merge

replace same_ind4=. if same_ind4==0
xtset id_in_panel year
xfill same_ind4,i(id_in_panel)
replace same_ind4=0 if same_ind4==.

*Sample

keep if qianjia_md_dummy==1 | same_ind4==1

*Variables

egen firmid=group(id_in_panel)

keep firmid year name legcode qianjia_md_dummy same_ind4 giovpp
order firmid year name legcode qianjia_md_dummy same_ind4 giovpp

ren qianjia_md_dummy top1000
ren same_ind4 top1000_related
ren giovpp output

*Label

label variable firmid "Firm ID"
label variable year "Data Year"
label variable name "Firm Name"
label variable legcode "Firm Legal Code"
label variable top1000 "Top1000"
label variable top1000 "Top1000 Related"
label variable output "Industrial Ouptut"

save "$revision/Data/TableA24_4.dta",replace

*----------------------------------
* Data for Scalars: Two Level 20%
*----------------------------------

use "$revision/Raw_Data/ASIF/ASIF.dta",clear

*Same Period

keep if year>=2001 & year<=2011

*Top1000 Firms

xtset id_in_panel year
replace qianjia_md_dummy=. if qianjia_md_dummy==0
xfill qianjia_md_dummy,i(id_in_panel)
replace qianjia_md_dummy=0 if qianjia_md_dummy==.

*Related Firms

ren legcode_in_panel legcode
merge m:1 legcode using "$revision/Data/TableA7_6.dta"
drop if _merge==2
drop _merge

merge m:1 name using "$revision/Data/TableA7_5.dta",update
drop if _merge==2
drop _merge

replace same_ind4=. if same_ind4==0
xtset id_in_panel year
xfill same_ind4,i(id_in_panel)
replace same_ind4=0 if same_ind4==.

*Sample

keep if qianjia_md_dummy==1 | same_ind4==1

*Variables

egen firmid=group(id_in_panel)

keep firmid year name legcode qianjia_md_dummy same_ind4 giovpp
order firmid year name legcode qianjia_md_dummy same_ind4 giovpp

ren qianjia_md_dummy top1000
ren same_ind4 top1000_related
ren giovpp output

*Label

label variable firmid "Firm ID"
label variable year "Data Year"
label variable name "Firm Name"
label variable legcode "Firm Legal Code"
label variable top1000 "Top1000"
label variable top1000 "Top1000 Related"
label variable output "Industrial Ouptut"

save "$revision/Data/TableA24_5.dta",replace

*----------------------------------
* Data for Scalars: Two Level 51%
*----------------------------------

use "$revision/Raw_Data/ASIF/ASIF.dta",clear

*Same Period

keep if year>=2001 & year<=2011

*Top1000 Firms

xtset id_in_panel year
replace qianjia_md_dummy=. if qianjia_md_dummy==0
xfill qianjia_md_dummy,i(id_in_panel)
replace qianjia_md_dummy=0 if qianjia_md_dummy==.

*Related Firms

ren legcode_in_panel legcode
merge m:1 legcode using "$revision/Data/TableA7_8.dta"
drop if _merge==2
drop _merge

merge m:1 name using "$revision/Data/TableA7_7.dta",update
drop if _merge==2
drop _merge

replace same_ind4=. if same_ind4==0
xtset id_in_panel year
xfill same_ind4,i(id_in_panel)
replace same_ind4=0 if same_ind4==.

*Sample

keep if qianjia_md_dummy==1 | same_ind4==1

*Variables

egen firmid=group(id_in_panel)

keep firmid year name legcode qianjia_md_dummy same_ind4 giovpp
order firmid year name legcode qianjia_md_dummy same_ind4 giovpp

ren qianjia_md_dummy top1000
ren same_ind4 top1000_related
ren giovpp output

*Label

label variable firmid "Firm ID"
label variable year "Data Year"
label variable name "Firm Name"
label variable legcode "Firm Legal Code"
label variable top1000 "Top1000"
label variable top1000 "Top1000 Related"
label variable output "Industrial Ouptut"

save "$revision/Data/TableA24_6.dta",replace
