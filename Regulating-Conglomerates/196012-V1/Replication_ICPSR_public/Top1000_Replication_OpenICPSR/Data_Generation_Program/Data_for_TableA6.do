
* Data for Table A.6: Dataset Matching

*--------
*  ASIF
*--------

use "$revision/Raw_Data/ASIF/ASIF.dta", clear

* Top1000 & Top10000

gsort id_in_panel -qianjia_md_dummy
by id_in_panel: replace qianjia_md_dummy=qianjia_md_dummy[1]

gsort id_in_panel -wanjia_dummy
by id_in_panel: replace wanjia_dummy=wanjia_dummy[1]

keep if qianjia_md_dummy==1 | wanjia_dummy==1

* Sample Period

keep if year>=2001 & year<=2011

* Variable Label

keep id_in_panel year name legcode_in_panel qianjia_md_dummy wanjia_dummy
order id_in_panel year name legcode_in_panel qianjia_md_dummy wanjia_dummy

ren id_in_panel firmid
ren legcode_in_panel legcode
ren qianjia_md_dummy top1000
ren wanjia_dummy top10000

label variable firmid "Firm ID"
label variable year "Data Year"
label variable legcode "Firm Legal Code"
label variable name "Firm Name"
label variable top1000 "Top1000"
label variable top10000 "Top10000"

save "$revision/Data/TableA6_1.dta",replace

*--------
*  CESD
*--------

use "$revision/Raw_Data/CESD/CESD_Top1000_Top10000_Raw.dta", clear

* Data Cleaning

drop if id_original==323957

* Top1000 & Top10000

gsort id_in_panel -qianjia_md_dummy
by id_in_panel: replace qianjia_md_dummy=qianjia_md_dummy[1]

gsort id_in_panel -wanjia_dummy
by id_in_panel: replace wanjia_dummy=wanjia_dummy[1]

* Sample Period

keep if year>=2001 & year<=2010

* Variable Label

keep id_in_panel year name legcode_in_panel qianjia_md_dummy wanjia_dummy merge_GQ
order id_in_panel year name legcode_in_panel qianjia_md_dummy wanjia_dummy merge_GQ

ren id_in_panel firmid
ren legcode_in_panel legcode
ren qianjia_md_dummy top1000
ren wanjia_dummy top10000
ren merge_GQ merge_ASIF

label variable firmid "Firm ID"
label variable year "Data Year"
label variable legcode "Firm Legal Code"
label variable name "Firm Name"
label variable top1000 "Top1000"
label variable top10000 "Top10000"
label variable merge_ASIF "Matched with ASIF"

save "$revision/Data/TableA6_2.dta",replace

