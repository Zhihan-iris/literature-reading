
* Table A.8  Waterfall Table

use "$revision/Data/TableA8.dta",clear

keep if top1000==1

*------------------------------------
* Top1000 (2004) & CESD (2001-2010)
*------------------------------------

preserve
duplicates drop firmid,force
sum firmid
local a2=r(N)
restore

*--------------------------------------------------------
* Drop Firms That Do Not Report Energy Data After 2006
*--------------------------------------------------------

*Drop Firms That Never Report Energy Data 

gen energy_data=1 if coal!=0 | oil!=0 | gas!=0
xfill energy_data
drop if energy_data==.

*Drop Firepower Firms (Firepower firms are separated from the CESD data after 2006)

gen firepower=(ind4==4411)
drop if firepower==1

preserve
duplicates drop firmid,force
sum firmid
local a3=r(N)
restore

*-----------------------------------------------------
* Drop Firms That Did Not Report Coal Data Annually
*-----------------------------------------------------

sort firmid coal
by firmid: egen missing=count(firmid) if coal==0

xtset firmid year
xfill missing, i(firmid)
replace missing=0 if missing==.

drop if missing>0

preserve
duplicates drop firmid,force
sum firmid if top1000==1
local a4=r(N)
restore

*----------------------
* Drop Extreme Values
*----------------------

xtset firmid year
gen growth_energy=D.energy/L.energy
bysort firmid:egen total_energy=total(energy) 
bysort firmid:gen mean_energy=(total_energy-energy)/(_N-1)
gen energy_level=energy/mean_energy
gen energy_right=(growth_energy<10 | energy_level<10 )

drop if energy_right==0

preserve
duplicates drop firmid,force
sum firmid
local a5=r(N)
restore

*--------------------
* Electricity Share
*--------------------

drop if power_type==.
drop if electricity50==.

*Drop Firms in 4-Digit Industries with Electricity>50%

keep if electricity50==1
preserve
duplicates drop firmid,force
sum firmid if top1000==1
local a6=r(N)
restore

*Drop Firms in 4-Digit Industries with Electricity>30%

keep if electricity30==1
preserve
duplicates drop firmid,force
sum firmid if top1000==1
local a7=r(N)
restore

*Drop Firms in 4-Digit Industries with Electricity>25%

keep if electricity25==1
preserve
duplicates drop firmid,force
sum firmid if top1000==1
local a8=r(N)
restore

*------------------
* Waterfall Table
*------------------

clear
set obs 8
gen var1=""
gen var2=.

label var var1 "Data Cleaning Process"
label var var2 "Firm Number"

replace var1="Top1000 (2004)" in 1
replace var1="Top1000 (2004) \& CESD (2001-2010)" in 2
replace var1="Drop firms that do not report energy data after 2006" in 3
replace var1="Drop firms that did not report coal data annually" in 4
replace var1="Drop extreme energy values" in 5
replace var1="Drop firms in 4-digit industries with electricity share$>$50\%" in 6
replace var1="Drop firms in 4-digit industries with electricity share$>$30\%" in 7
replace var1="Drop firms in 4-digit industries with electricity share$>$25\%" in 8

replace var2=1008 in 1
forvalues i=2(1)8 {
replace var2=`a`i'' in `i'
}

listtex * using "$revision/Appendix_Table/TableA8.tex", replace rstyle(tabular)

