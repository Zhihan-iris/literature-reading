
*Table A.29: Spillover Effects on the Output of Related Firms: Heterogeneous Effects by Industry

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

local y "loutput"
local x "related_post"
local cluster "firmid"
local absorb3 "firmid ind2_year province_year"

eststo Heterogeneity_1: reghdfe `y' `x' [fweight=weight], absorb(`absorb3') cluster(`cluster')
eststo Heterogeneity_2: reghdfe `y' `x' if ind2!=44 [fweight=weight], absorb(`absorb3') cluster(`cluster')
eststo Heterogeneity_3: reghdfe `y' `x' if ind2==32 | ind2==33 | ind2==25 [fweight=weight], absorb(`absorb3') cluster(`cluster')
eststo Heterogeneity_4: reghdfe `y' `x' if ind2==26 | ind2==31 [fweight=weight], absorb(`absorb3') cluster(`cluster')
eststo Heterogeneity_5: reghdfe `y' `x' if ind2==6 | ind2==7 [fweight=weight], absorb(`absorb3') cluster(`cluster')

esttab Heterogeneity_?  using "$revision/Appendix_Table/TableA29.tex",  ///
preh("\begin{table} \centering" ///
"\caption{\bf Spillover Effects on the Output of Related Firms: Heterogeneous Effects by Industry}" ///
"\begin{tabular}{l c c c c c}") ///
stats() posth("\toprule" ///
"\multirow{2}*{Variables} & \multicolumn{5}{c}{ln(Output)} \\" ///
"\cline{2-6}" ///
"{} & Baseline & Drop Power & Processing & Materials & Mining \\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(related_post) coeflabel(related_post "Related $\times$ Post") label /// 
prefoot("\hline") postfoot( ///
"\hline" ///
"Firm FE & Y & Y & Y & Y & Y \\" ///
"Industry $\times$ Year FE & Y & Y & Y & Y & Y \\" ///
"Province $\times$ Year FE & Y & Y & Y & Y & Y \\" ///
"\bottomrule" ///
"\end{tabular}" ///
"\end{table}") replace 

