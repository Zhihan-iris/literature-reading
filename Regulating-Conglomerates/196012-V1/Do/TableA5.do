
* Table A.5: Heterogeneity Effects on Regulated Firms by Reported Compliance Status

use "$revision/Data/Table1.dta",clear

gen noncompliance_post=1 if noncompliance==1 & year>=2007
replace noncompliance_post=0 if noncompliance_post==.

gen compliance_post=1 if treat_post==1 & noncompliance_post!=1
replace compliance_post=0 if compliance_post==.

* Regression

local x "compliance_post noncompliance_post"
local control "soe roa age exp"
local cluster "firmid"
local absorb1 "firmid year"
local absorb2 "firmid ind2_year"
local absorb3 "firmid ind2_year province_year"

eststo noncompliance_1: reghdfe lenergy `x', absorb(`absorb1') cluster(`cluster')
eststo noncompliance_2: reghdfe lenergy `x', absorb(`absorb2') cluster(`cluster')
eststo noncompliance_3: reghdfe lenergy `x', absorb(`absorb3') cluster(`cluster')
eststo noncompliance_4: reghdfe lenergy `x' `control', absorb(`absorb3') cluster(`cluster')

esttab noncompliance_?  using "$revision/Appendix_Table/TableA5.tex",  ///
preh("\begin{table} \centering" ///
"\caption{\bf Heterogeneous Effects on Regulated Firms by Reported Compliance Status}" ///
"\begin{tabular}{l c c c c}") ///
stats() posth("\toprule" ///
"Variables & \multicolumn{4}{c}{ln(Energy Use)} \\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(compliance_post noncompliance_post) coeflabel(compliance_post "Compliance $\times$ Post" noncompliance_post "Non-Compliance $\times$ Post") label /// 
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
