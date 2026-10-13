
*Table A.15: Heterogeneous Effects on Regulated Firms by Industry

use "$revision/Data/Table1.dta",clear

local y "loutput"
local x "treat_post"
local cluster "firmid"
local absorb3 "firmid ind2_year province_year"

eststo Heterogeneity_1: reghdfe `y' `x' , absorb(`absorb3') cluster(`cluster')
eststo Heterogeneity_2: reghdfe `y' `x' if ind2!=44, absorb(`absorb3') cluster(`cluster')
eststo Heterogeneity_3: reghdfe `y' `x' if ind2==32 | ind2==33 | ind2==25, absorb(`absorb3') cluster(`cluster')
eststo Heterogeneity_4: reghdfe `y' `x' if ind2==26 | ind2==31, absorb(`absorb3') cluster(`cluster')
eststo Heterogeneity_5: reghdfe `y' `x' if ind2==6 | ind2==7, absorb(`absorb3') cluster(`cluster')

esttab Heterogeneity_?  using "$revision/Appendix_Table/TableA15.tex",  ///
preh("\begin{table} \centering" ///
"\caption{\bf Heterogeneous Effects on Regulated Firms by Industry}" ///
"\begin{tabular}{l c c c c c}") ///
stats() posth("\toprule" ///
"\multirow{2}*{Variables} & \multicolumn{5}{c}{ln(Output)} \\" ///
"\cline{2-6}" ///
"{} & Baseline & Drop Power & Processing & Materials & Mining \\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(treat_post) coeflabel(treat_post "Treat $\times$ Post") label /// 
prefoot("\hline") postfoot( ///
"\hline" ///
"Firm FE & Y & Y & Y & Y & Y  \\" ///
"Industry $\times$ Year FE & Y & Y & Y & Y & Y  \\" ///
"Province $\times$ Year FE & Y & Y & Y & Y & Y  \\" ///
"\bottomrule" ///
"\end{tabular}" ///
"\end{table}") replace 
