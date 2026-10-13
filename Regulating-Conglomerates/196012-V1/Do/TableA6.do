
* Table A.6 Dataset Matching (2001-2011)

*--------
*  ASIF
*--------

use "$revision/Data/TableA6_1.dta", clear

duplicates drop firmid,force

sum firmid if top1000==1
local a=r(N)
local a2=`a'/1008

sum firmid if top10000==1
local b=r(N)
local b2=`b'/14641

*--------
*  CESD
*--------

use "$revision/Data/TableA6_2.dta", clear

duplicates drop firmid,force

sum firmid if top1000==1
local c=r(N)
local c2=`c'/1008

sum firmid if top10000==1
local d=r(N)
local d2=`d'/14641


*---------------
*  ASIF & CESD
*---------------

use "$revision/Data/TableA6_2.dta", clear

keep if merge_ASIF==3

duplicates drop firmid,force

sum firmid if top1000==1 
local e=r(N)
local e2=`e'/1008

sum firmid if top10000==1
local f=r(N)
local f2=`f'/14641

*---------
*  Table
*---------

clear
mat A = (`a', `a2', `b', `b2' \ `c', `c2', `d', `d2' \ `e', `e2', `f', `f2' )
svmat A

gen rank=_n

gen Datasets=""
replace Datasets="ASIF" in 1
replace Datasets="CESD" in 2
replace Datasets="ASIF\&CESD" in 3

ren A1 Top1000_Number
ren A2 Top1000_Ratio
ren A3 Top10000_Number
ren A4 Top10000_Ratio

set obs 4
replace Datasets="List" in 4
replace Top1000_Number=1008 in 4
replace Top10000_Number=14641 in 4
replace rank=0 in 4

sort rank
keep Datasets Top1000_Number Top1000_Ratio Top10000_Number Top10000_Ratio
order Datasets Top1000_Number Top1000_Ratio Top10000_Number Top10000_Ratio

tostring Top1000_Number, force replace format(%9.0f)
tostring Top1000_Ratio, force replace format(%7.4f)
tostring Top10000_Number, force replace format(%9.0f)
tostring Top10000_Ratio, force replace format(%7.4f)

listtex * using "$revision/Appendix_Table/TableA6.tex", replace rstyle(tabular)
