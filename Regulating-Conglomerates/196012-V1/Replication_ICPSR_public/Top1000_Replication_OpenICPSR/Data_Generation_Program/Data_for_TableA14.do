
*Data for TableA.14: Effects of Policy on Investment in Regulated Firms

*********************************************
* Data for Investment of Top1000 & Top10000
*********************************************

use "$revision/Raw_Data/ATS/ATS_Top1000_Top10000.dta",clear

*Rename Variables

ren legcode_id id_in_panel
ren interaction_md_2007 treat_post
ren SOE soe
ren qianjia_md_dummy top1000
ren invest_dummy investment_em

*Controls Variables

gen age=year-GQ_fyear+1
destring TAX_info40,replace force
replace age=year-TAX_info40+1 if year>2008
replace age=. if age<1
replace age=. if age>200

gen exp=1 if GQ_edv>0 & GQ_edv!=.
replace exp=1 if TAX_x50>0 & TAX_x50!=.
replace exp=0 if exp==.

*Sample

keep if qianjia_md_wanjia==1 & year>2000
drop if investment_em==.

*Drop 4-digit related firms

gen name=GQ_name
replace name=TAX_name if year>2008

gen legcode=GQ_legcode_in_panel
replace legcode=TAX_legcode_in_panel if year>2008

merge m:1 legcode using "$revision/Raw_Data/CARD/related_firms_legcode.dta"
drop if _merge==2
drop _merge

merge m:1 name using "$revision/Raw_Data/CARD/related_firms_name.dta",update
drop if _merge==2
drop _merge

replace same_ind4=. if same_ind4==0
xtset id_in_panel year
xfill same_ind4,i(id_in_panel)
replace same_ind4=. if top1000==1
drop if same_ind4==1

*Variable

keep id_in_panel year legcode name ind2 province top1000 investment_em treat_post soe roa age exp

xtset id_in_panel year
egen firmid=group(id_in_panel)
drop id_in_panel

egen ind2_year=group(ind2 year)
egen province_year=group(province year)

order firmid year legcode name ind2 province top1000 investment_em treat_post soe roa age exp ind2_year province_year

*Label

label variable firmid "Firm ID"
label variable year "Data Year"
label variable legcode "Legal Code"
label variable name "Firm name"
label variable ind2 "2-digit Industry"
label variable province "Province ID"
label variable top1000 "Treat"
label variable investment_em "Investment(Extensive Margin)"
label variable treat_post "Treat*Post"
label variable soe "State Owned"
label variable roa "Return to Asset"
label variable age "Firm Age"
label variable exp "Export Status"
label variable ind2_year "2-digit Industry*Year"
label variable province_year "Province*Year"

save "$revision/Data/TableA14.dta",replace
