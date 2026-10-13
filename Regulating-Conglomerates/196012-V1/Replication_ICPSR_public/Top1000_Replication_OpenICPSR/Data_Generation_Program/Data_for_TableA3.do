
* Data for Table A.3 Heterogeneous Spillover Effects by Location

*----------------------------
* Raw Data for Related Firms
*----------------------------

use "$revision/Raw_Data/CARD/Related_Firms.dta",clear 
save "$revision/Data/TableA3_1.dta",replace

use "$revision/Raw_Data/CARD/Related_Firms.dta",clear 
drop if legcode==""
keep legcode
duplicates drop legcode,force
save "$revision/Data/TableA3_Temp1.dta",replace

use "$revision/Raw_Data/CARD/Related_Firms.dta",clear 
keep related
ren related name
duplicates drop name,force
save "$revision/Data/TableA3_Temp2.dta",replace

*----------------------------
* Preparation of ASIF Data
*----------------------------

use "$revision/Raw_Data/ASIF/ASIF.dta",clear

*Industry
gen ind3=int(cic03/10)
keep if ind3!=441 & ind3!=442

*Sample Period
keep if year>2000 & year<2012

*Drop Top1000
xtset id_in_panel year
replace qianjia_md_dummy=. if qianjia_md_dummy==0
xfill qianjia_md_dummy,i(id_in_panel)
drop if qianjia_md_dummy==1

*Variables
keep id_in_panel name legcode_in_panel year giovpp
order id_in_panel name legcode_in_panel year giovpp

*Keep Related
ren legcode_in_panel legcode
merge m:1 legcode using "$revision/Data/TableA3_Temp1.dta",update
drop if _merge==2
ren _merge merge_legcode

merge m:1 name using "$revision/Data/TableA3_Temp2.dta",update
drop if _merge==2
ren _merge merge_name

keep if merge_legcode==3 | merge_name==3
save "$revision/Data/TableA3_2.dta",replace

*Erase Temp File

erase "$revision/Data/TableA3_Temp1.dta"
erase "$revision/Data/TableA3_Temp2.dta"
