
* TableA28. Heterogeneous Spillover Effects on Output by Related Firm Size

*-------------------
*  Treat & Control
*-------------------

use "$revision/Data/Table2_1.dta",clear

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Output_Related.dta"
drop if _merge==2
drop _merge

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Output_Control.dta",update
drop if _merge==2
drop _merge

keep if related==1 | control==1
replace related=0 if related==.
replace control=0 if control==.

gen related_post=1 if related==1 & year>=2007
replace related_post=0 if related_post==.
label variable related_post "Related*Post"

*----------------------
* Drop Extreme Values
*----------------------

replace year=2010 if year==2011
xtset firmid year
gen growth=(output-l.output)/l.output
gen growth_raw=growth
winsor2 growth, trim replace
drop if growth==. & growth_raw!=.
drop growth growth_raw
replace year=2011 if year==2010
xtset firmid year

*------------
*  Quantile
*------------

gen exist=1 if year==2006
xtset firmid year
xfill exist,i(firmid)
drop if exist!=1

duplicates tag ind4 if related==1 & year==2006, gen(frequency)
replace frequency=frequency+1 if frequency!=.
replace frequency=0 if frequency==.

gsort ind4 -frequency
by ind4: replace frequency=frequency[1]
keep if frequency>=3

forvalues i=1(1)3 {
       gen group`i'=0
       }

foreach num of numlist 3111 4411 4420 610 3230 2621 2614 2221 710 2511 2520 2612 3240 2661 3210 3351 2651 2671 3141 3311 4430 2619 2631 3121 3124 3220 3316 {
	   _pctile output if year==2006 & related==1 & ind4==`num', percentiles(30,60)
       local n30_`num'=r(r1)
       local n60_`num'=r(r2)
       replace group1=1 if year==2006 & related==1 & ind4==`num' & output<=`n30_`num'' & output!=.
       replace group2=1 if year==2006 & related==1 & ind4==`num' & output>`n30_`num'' & output<=`n60_`num'' & output!=.
       replace group3=1 if year==2006 & related==1 & ind4==`num' & output>`n60_`num'' & output!=.
	   }

forvalues i=1(1)3 { 
     xtset firmid year
	 replace group`i'=. if group`i'==0
	 xfill group`i',i(firmid)
	 replace group`i'=0 if group`i'==.
	 }

forvalues i=1(1)3 {
       gen related_post_tier`i'=related_post*group`i'
       }
	   
*------------
* Regression
*------------

local y "loutput"
local x "related_post_tier1 related_post_tier2 related_post_tier3"
local control "soe roa age exp"
local cluster "firmid"
local absorb1 "firmid year"
local absorb2 "firmid ind2_year"
local absorb3 "firmid ind2_year province_year"

eststo `y'_1: reghdfe `y' `x' [fweight=weight], absorb(`absorb1') cluster(`cluster')
eststo `y'_2: reghdfe `y' `x' [fweight=weight], absorb(`absorb2') cluster(`cluster')
eststo `y'_3: reghdfe `y' `x' [fweight=weight], absorb(`absorb3') cluster(`cluster')
eststo `y'_4: reghdfe `y' `x' `control' [fweight=weight], absorb(`absorb3') cluster(`cluster')


esttab loutput_?  using "$revision/Appendix_Table/TableA28.tex",  ///
preh("\begin{table} \centering" ///
"\caption{\bf Heterogeneous Spillover Effects on Output by Related Firm Size}" ///
"\begin{tabular}{l c c c c}") ///
stats() posth("\toprule" ///
"Variables & \multicolumn{4}{c}{ln(Output)} \\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(related_post_tier1 related_post_tier2 related_post_tier3 ) ///
coeflabel(related_post_tier1 "Related $\times$ Post(0\%-30\%)" ///
related_post_tier2 "Related $\times$ Post(30\%-60\%)" ///
related_post_tier3 "Related $\times$ Post(60\%-100\%)") label /// 
prefoot("\hline") postfoot( ///
"\hline" ///
"Firm FE & Y & Y & Y & Y \\" ///
"Year FE & Y & Y & Y & Y \\" ///
"Industry $\times$ Year FE & {} & Y & Y & Y \\" ///
"Province $\times$ Year FE & {} & {} & Y & Y \\" ///
"Firm-level Controls & {} & {} & {} & Y \\" ///
"\bottomrule" ///
"\end{tabular}" ///
"\end{table}" ) replace
