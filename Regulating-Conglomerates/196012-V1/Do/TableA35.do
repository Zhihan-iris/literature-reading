
*Table A.35: Robustness of Effects on the Energy Efficiency of Related Firms

use "$revision/Data/Table2_2.dta",clear

*Treat & Control

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Energy_Related.dta"
drop if _merge==2
drop _merge

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Energy_Control.dta",update
drop if _merge==2
drop _merge

keep if related==1 | control==1
replace related=0 if related==.
replace control=0 if control==.

*Difference in Differences

gen related_post=1 if related==1 & year>=2007
replace related_post=0 if related_post==.
label variable related_post "Related*Post"

*Regression

local y "lefficiency_robust"
local x "related_post"
local control "soe roa age exp"
local cluster "firmid"
local absorb1 "firmid year"
local absorb2 "firmid ind2_year"
local absorb3 "firmid ind2_year province_year"

eststo `y'_1: reghdfe `y' `x' [fweight=weight], absorb(`absorb1') cluster(`cluster')
eststo `y'_2: reghdfe `y' `x' [fweight=weight], absorb(`absorb2') cluster(`cluster')
eststo `y'_3: reghdfe `y' `x' [fweight=weight], absorb(`absorb3') cluster(`cluster')
eststo `y'_4: reghdfe `y' `x' `control' [fweight=weight], absorb(`absorb3') cluster(`cluster')

esttab lefficiency_robust_?  using "$revision/Appendix_Table/TableA35.tex",  ///
preh("\begin{table} \centering" ///
"\caption{\bf Robustness of Effects on the Energy Efficiency of Related Firms}" ///
"\begin{tabular}{l c c c c}") ///
stats() posth("\toprule" ///
"Variables & \multicolumn{4}{c}{ln(Variable Input/Energy)} \\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(related_post) coeflabel(related_post "Related $\times$ Post") label /// 
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

