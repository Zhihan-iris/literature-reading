
* Table A.27: Additional Spillover Effects of the Program

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

local x "related_post"
local control "soe roa age exp"
local cluster "firmid"
local absorb3 "firmid ind2_year province_year"

eststo Others_1: reghdfe lsales `x' `control' [fweight=weight], absorb(`absorb3') cluster(`cluster')
eststo Others_2: reghdfe lprofit `x' `control' [fweight=weight], absorb(`absorb3') cluster(`cluster')
eststo Others_3: reghdfe lfasset `x' `control' [fweight=weight], absorb(`absorb3') cluster(`cluster')
eststo Others_4: reghdfe lemp `x' `control' [fweight=weight], absorb(`absorb3') cluster(`cluster')

esttab Others_?  using "$revision/Appendix_Table/TableA27.tex",  ///
preh("\begin{table} \centering" ///
"\caption{\bf Additional Spillover Effects of the Program}" ///
"\begin{tabular}{l c c c c}") ///
stats() posth("\toprule" ///
"Variables & ln(Sale) & ln(Profit) & ln(Capital) & ln(Labor) \\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(related_post) coeflabel(related_post "Related $\times$ Post") label /// 
prefoot("\hline") postfoot( ///
"\hline" ///
"Firm FE & Y & Y & Y & Y  \\" ///
"Industry $\times$ Year FE & Y & Y & Y & Y  \\" ///
"Province $\times$ Year FE & Y & Y & Y & Y  \\" ///
"Firm-level Controls & Y & Y & Y & Y  \\" ///
"\bottomrule" ///
"\end{tabular}" ///
"\end{table}" )  replace

