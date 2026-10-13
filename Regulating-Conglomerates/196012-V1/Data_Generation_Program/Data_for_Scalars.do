
* Data for Scalars

*-------------------------------------------------
* Output Share of Related Firms to Top1000 Firms
*-------------------------------------------------

use "$revision/Raw_Data/ASIF/ASIF.dta",clear

*Time Period: 2001-2011

keep if year>2000 & year<2012

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

* Sample

keep if qianjia_md_dummy==1 | same_ind4==1

* Variables

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

save "$revision/Data/Scalars.dta",replace
