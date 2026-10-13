
* Table A.20 Effects of the Program on Regulated Firms' Energy Mix

use "$revision/Data/Table1.dta",clear

local x "treat_post"
local cluster "firmid"
local absorb3 "firmid ind2_year province_year"

eststo type_1: reghdfe coal_share `x', absorb(`absorb3') cluster(`cluster')
eststo type_2: reghdfe oil_share `x', absorb(`absorb3') cluster(`cluster')
eststo type_3: reghdfe gas_share `x', absorb(`absorb3') cluster(`cluster')

esttab type_?  using "$revision/Appendix_Table/TableA20.tex",  ///
preh("\begin{table} \centering" ///
"\caption{\bf Effects of the Program on Regulated Firms' Energy Mix}" ///
"\begin{tabular}{l c c c }") ///
stats() posth("\toprule" ///
"Variables & Coal Share & Petroleum Share & Gas Share \\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(treat_post) coeflabel(treat_post "Treat $\times$ Post") label /// 
prefoot("\hline") postfoot( ///
"\hline" ///
"Firm FE & Y & Y & Y  \\" ///
"Industry $\times$ Year FE & Y & Y & Y \\" ///
"Province $\times$ Year FE & Y & Y & Y \\" ///
"\bottomrule" ///
"\end{tabular}" ///
"\end{table}") replace 
