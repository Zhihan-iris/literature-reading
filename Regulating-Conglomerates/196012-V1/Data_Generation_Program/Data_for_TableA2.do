
* Data for Table A.2 Heterogeneous Spillover Effects by Local Pollution and Density

*-------------------------------------------
*  Pre-Treatment: Top1000 City Information
*-------------------------------------------

use "$revision/Raw_Data/ASIF/ASIF_Top1000_Top10000.dta",clear

drop if legcode_id>2000
keep if year>2000 & year<2012

*City Code Adjustment
gen cityid=int(address_adj/100)
duplicates tag id_in_panel cityid, gen(du_id_in_panel_city)
gsort id_in_panel -du_id_in_panel_city -year
by id_in_panel: replace cityid=cityid[1] if cityid!=cityid[1]

*Municipalities
gen proid=int(cityid/100)
replace cityid=1100 if proid==11
replace cityid=1200 if proid==12
replace cityid=3100 if proid==31
replace cityid=5000 if proid==50
drop proid

*Cross Section Data
gsort id_in_panel -year
duplicates drop id_in_panel,force
keep name legcode_adj legcode_id cityid
ren * top1000_*
ren top1000_legcode_id legcode_id
order legcode_id top1000_name top1000_legcode_adj top1000_cityid
save "$revision/Data/Top1000_City.dta",replace

*Matching QXB Name
use "$revision/Raw_Data/Top1000/Top1000_QXB_ID.dta",clear
merge 1:1 legcode_id using "$revision/Data/Top1000_City.dta"
keep if _merge==3
keep qianjia top1000_cityid
save "$revision/Data/Top1000_City.dta",replace

*----------------------------------------
*  Pre-Treatment: ASIF City Information
*----------------------------------------

use "$revision/Raw_Data/ASIF/ASIF.dta",clear

keep if year>2000 & year<2012

*City Code Adjustment
replace address_adj=220106 if address_adj==22010
gen cityid=int(address_adj/100)
duplicates tag id_in_panel cityid, gen(du_id_in_panel_city)
gsort id_in_panel -du_id_in_panel_city -year
by id_in_panel: replace cityid=cityid[1] if cityid!=cityid[1]

*Municipalities
gen proid=int(cityid/100)
replace cityid=1100 if proid==11
replace cityid=1200 if proid==12
replace cityid=3100 if proid==31
replace cityid=5000 if proid==50
drop proid

keep id_in_panel legcode_in_panel name cityid

*Legal Code Cross Section
preserve
keep id_in_panel legcode_in_panel cityid
ren legcode_in_panel legcode
duplicates tag legcode id_in_panel,gen(du_id_in_panel)
gsort legcode -du_id_in_panel cityid
duplicates drop legcode,force
drop if legcode==""
gen legcode_length=length(legcode)
drop if legcode_length!=9
drop id_in_panel du_id_in_panel legcode_length
ren cityid GQ_cityid
save "$revision/Data/GQ_City_Legcode.dta",replace
restore

*Name Matching 
keep id_in_panel name cityid
duplicates tag name id_in_panel,gen(du_id_in_panel)
gsort name -du_id_in_panel cityid
duplicates drop name,force
drop if name==""
drop id_in_panel du_id_in_panel
ren cityid GQ_cityid
save "$revision/Data/GQ_City_Name.dta",replace

*------------------------------------
*  Add City Information for Related
*------------------------------------

use "$revision/Raw_Data/CARD/Related_Firms.dta",clear

keep if same_ind4==1
keep qianjia related legcode

*Top1000
merge m:1 qianjia using "$revision/Data/Top1000_City.dta"
drop if _merge!=3
drop _merge

*Related
merge m:1 legcode using "$revision/Data/GQ_City_Legcode.dta"
drop if _merge==2
drop _merge

ren related name
merge m:1 name using "$revision/Data/GQ_City_Name.dta" ,update
drop if _merge==2
drop _merge
ren name related

keep qianjia related top1000_cityid GQ_cityid
order qianjia related top1000_cityid GQ_cityid

drop if top1000_cityid==. | GQ_cityid==.

*-----------------------------------------------
*  Add Population Density and Pollution Density
*-----------------------------------------------

*Top1000
ren top1000_cityid cityid
merge m:1 cityid using "$revision/Raw_Data/Density/City_Density.dta"
drop if _merge==2

gen proid=int(cityid/100) if _merge==1
drop _merge
merge m:1 proid using "$revision/Raw_Data/Density/Province_Density.dta",update
drop if _merge==2
drop _merge

merge m:1 cityid using "$revision/Raw_Data/Density/City_Population.dta",update
drop if _merge==1 | _merge==2
drop _merge

ren population_density top1000_population_density
ren so2_density top1000_so2_density
ren population top1000_population

drop cityname proname proid
ren cityid top1000_cityid

*Related

ren GQ_cityid cityid
merge m:1 cityid using "$revision/Raw_Data/Density/City_Density.dta"
drop if _merge==2

gen proid=int(cityid/100) if _merge==1
drop _merge
merge m:1 proid using "$revision/Raw_Data/Density/Province_Density.dta",update
drop if _merge==2
drop _merge

merge m:1 cityid using "$revision/Raw_Data/Density/City_Population.dta",update
drop if _merge==1 | _merge==2
drop _merge

ren population_density related_population_density
ren so2_density related_so2_density
ren population related_population

drop cityname proname proid
ren cityid related_cityid
save "$revision/Data/TableA2_1.dta",replace

* Erase Temp File

erase "$revision/Data/Top1000_City.dta"
erase "$revision/Data/GQ_City_Legcode.dta"
erase "$revision/Data/GQ_City_Name.dta"

*--------------------------------
*  Pre-Treatment: Related Output
*--------------------------------

use "$revision/Raw_Data/ASIF/ASIF.dta",clear

*Sample Period
keep if year>2000 & year<2012

*Drop Top1000
xtset id_in_panel year
replace qianjia_md_dummy=. if qianjia_md_dummy==0
xfill qianjia_md_dummy,i(id_in_panel)
drop if qianjia_md_dummy==1

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
keep if same_ind4==1

*Variables

egen firmid=group(id_in_panel)
ren giovpp output

keep firmid name legcode year output
order firmid name legcode year output

label variable firmid "Firm ID"
label variable legcode "Legal Code"
label variable name "Firm Name"
label variable year "Data Year"
label variable output "Industrial Output"

save "$revision/Data/TableA2_2.dta",replace

*----------------------
*  Related Legal Code
*----------------------

use "$revision/Raw_Data/CARD/Related_Legcode.dta",clear
save "$revision/Data/TableA2_3.dta",replace
