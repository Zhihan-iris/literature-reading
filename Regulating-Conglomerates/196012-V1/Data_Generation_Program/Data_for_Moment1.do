 
* Data for Firm Size Distribution Moments

use "$revision/Raw_Data/ASIF/ASIF.dta",clear

keep if year==2004
duplicates drop name,force

gen output=giovpp/(10^5)
label variable output "Industrial Output(Unit: 100 Million Yuan)"

keep if output>=0.05

gen ind4=cic03
gen ind2=int(ind4/100)
keep if ind2==26 | ind2==32 | ind2==44 | ind2==31 | ind2==25 | ind2==33 | ind2==6 | ind2==22 | ind2==17 | ind2==7

sort name
gen firmid=_n

keep firmid name ind4 ind2 output
order firmid name ind4 ind2 output

label variable firmid "Firm ID"
label variable name "Firm Name"
label variable ind4 "4-digit Industry"
label variable ind2 "2-digit Industry"

save "$revision/Data/Moment1.dta",replace

