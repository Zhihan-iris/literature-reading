
*TableA.14: Effects of Policy on the Investment of Regulated Firms

use "$revision/Data/TableA14.dta",clear

local x "treat_post"
local y "investment_em"
local control "soe roa age exp"
local cluster "firmid"
local absorb1 "firmid year"
local absorb2 "firmid ind2_year"
local absorb3 "firmid ind2_year province_year"

eststo `y'_1: reghdfe `y' `x', absorb(`absorb1') cluster(`cluster')
eststo `y'_2: reghdfe `y' `x', absorb(`absorb2') cluster(`cluster')
eststo `y'_3: reghdfe `y' `x', absorb(`absorb3') cluster(`cluster')
eststo `y'_4: reghdfe `y' `x' `control', absorb(`absorb3') cluster(`cluster')

esttab investment_em_?  using "$revision/Appendix_Table/TableA14.tex",  ///
preh("\begin{table} \centering" ///
"\caption{\bf Effects of Policy on Regulated Firms' Investment}" ///
"\begin{tabular}{l c c c c}") ///
stats() posth("\toprule" ///
"Variables & \multicolumn{4}{c}{If Firm Invest} \\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(treat_post) coeflabel(treat_post "Treat $\times$ Post") label /// 
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

