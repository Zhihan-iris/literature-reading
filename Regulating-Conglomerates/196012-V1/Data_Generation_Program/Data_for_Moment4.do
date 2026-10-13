
* Data for Estimation of alpha_l

use "$revision/Raw_Data/ASIF/ASIF.dta",clear

keep if year==2004
duplicates drop name,force

gen ind4=cic03
gen ind2=int(ind4/100)
keep if ind2==26 | ind2==32 | ind2==44 | ind2==31 | ind2==25 | ind2==33 | ind2==6 | ind2==22 | ind2==17 | ind2==7

sort name
gen firmid=_n

keep firmid name ind4 ind2 interinput twagepay fasset depreciation
order firmid name ind4 ind2 interinput twagepay fasset depreciation

label variable firmid "Firm ID"
label variable name "Firm Name"
label variable ind4 "4-digit Industry"
label variable ind2 "2-digit Industry"
label variable interinput "Intermediate Inputs"
label variable twagepay "Total Wage Pay"
label variable fasset "Capital(End of Year)"
label variable depreciation "Depreciation(Current Year)"

save "$revision/Data/Moment4.dta",replace
