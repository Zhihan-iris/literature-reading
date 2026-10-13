
* Table A.37 Summary Statistics for Top10,000 & Top10,000 Related Firms

use "$revision/Data/TableA37.dta",clear

*----------
*  Number
*----------

/* Number of Top10000 Firms in ASIF */
preserve 
keep if top10000==1
duplicates drop firmid,force
sum firmid
local a1=r(N)
restore

/* Number of Top10000 Firms in ASIF in Energy-Intensive Industries */
preserve 
keep if top10000==1 & top1000_industry==1
duplicates drop firmid,force
sum firmid
local a2=r(N)
restore

/* Number of Top10000 Firms in ASIF Exclude Top1000 and Top1000 Related */
preserve 
keep if top10000==1 & top1000!=1 & top1000_related!=1
duplicates drop firmid,force
sum firmid
local a3=r(N)
restore

/* Number of Top10000 Firms in ASIF in Energy-Intensive Industries Exclude Top1000 and Top1000 Related */
preserve 
keep if top10000==1 & top1000_industry==1  & top1000!=1 & top1000_related!=1
duplicates drop firmid,force
sum firmid
local a4=r(N)
restore

/* Number of Top10000 Related Firms */
preserve 
keep if top10000_related==1
duplicates drop firmid,force
sum firmid
local c1=r(N)
restore

/* Number of Top10000 Related Firms in Energy-Intensive Industries */
preserve
keep if top10000_related==1 & top1000_industry==1
duplicates drop firmid,force
sum firmid
local c2=r(N)
restore

/* Number of Top10000 Related Firms Exclude Top1000 and Top1000 Related */
preserve 
keep if top10000_related==1 & top1000!=1 & top1000_related!=1
duplicates drop firmid,force
sum firmid
local c3=r(N)
restore

/* Number of Top10000 Related Firms in Energy-Intensive Industries Exclude Top1000 and Top1000 Related */
preserve 
keep if top10000_related==1 & top1000_industry==1 & top1000!=1 & top1000_related!=1
duplicates drop firmid,force
sum firmid
local c4=r(N)
restore

*----------
*  Output
*----------

keep if year==2011
keep if output!=0
replace output=output/1000

/* Output of Top10000 Firms in ASIF */
sum output if top10000==1
local b1=r(mean)

/* Output of Top10000 Firms in ASIF in Energy-Intensive Industries */
sum output if top10000==1 & top1000_industry==1
local b2=r(mean)

/* Output of Top10000 Firms in ASIF Exclude Top1000 and Top1000 Related */
sum output if top10000==1 & top1000!=1 & top1000_related!=1
local b3=r(mean)

/* Output of Top10000 Firms in ASIF in Energy-Intensive Industries Exclude Top1000 and Top1000 Related */
sum output if top10000==1 & top1000_industry==1 & top1000!=1 & top1000_related!=1
local b4=r(mean)

/* Output of Top10000 Related Firms */
sum output if top10000_related==1
local d1=r(mean)

/* Output of Top10000 Related Firms in Energy-Intensive Industries */
sum output if top10000_related==1 & top1000_industry==1
local d2=r(mean)

/* Output of Top10000 Related Firms Exclude Top1000 and Top1000 Related */
sum output if top10000_related==1 & top1000!=1 & top1000_related!=1
local d3=r(mean)

/* Output of Top10000 Related Firms in Energy-Intensive Industries Exclude Top1000 and Top1000 Related */
sum output if top10000_related==1 & top1000_industry==1 & top1000!=1 & top1000_related!=1
local d4=r(mean)

*----------
*  Table
*----------

clear

set obs 5

forvalues i=1(1)4 {
	gen var`i'=.
}

forvalues i=1(1)4 {
	replace var1=`a`i'' in `i'
	replace var2=`b`i'' in `i'
	replace var3=`c`i'' in `i'
	replace var4=`d`i'' in `i'
}

tostring var1 var3 , force replace format(%9.0f)
tostring var2 var4, force replace format(%9.2f)

replace var1="Top10000 Number" in 5
replace var2="Top10000 Output(2011)" in 5
replace var3="Top10000 Related Number" in 5
replace var4="Top10000 Related Output(2011)" in 5

gen var5=""
replace var5="All Industries" in 1
replace var5="Energy-Intensive Industries" in 2
replace var5="All Industries (Exclude Top1000 and Top1000 Related)" in 3
replace var5="Energy-Intensive Industries (Exclude Top1000 and Top1000 Related)" in 4

gen rank=_n
replace rank=0 if rank==5
gsort rank
drop rank
order var5 var1-var4

listtex * using "$revision/Appendix_Table/TableA37.tex", replace rstyle(tabular)
