
*Table A.13: Approximately Balanced Panel: Regulated Firm Response

use "$revision/Data/Table1.dta",clear

*Approximately Balanced Panel
duplicates tag firmid,gen(frequency)
keep if frequency>=8
drop frequency

local x "treat_post"
local cluster "firmid"
local absorb3 "firmid ind2_year province_year"

eststo y_1: reghdfe lenergy `x', absorb(`absorb3') cluster(`cluster')
eststo y_2: reghdfe loutput `x', absorb(`absorb3') cluster(`cluster')
eststo y_3: reghdfe lefficiency `x', absorb(`absorb3') cluster(`cluster')

esttab y_?  using "$revision/Appendix_Table/TableA13.tex",  ///
preh("\begin{table} \centering" ///
"\caption{\bf Regulated Firm Response using an Approximately Balanced Panel}" ///
"\begin{tabular}{l c c c}") ///
stats() posth("\toprule" ///
"Variables & ln(Energy Use) & ln(Output) & ln(Energy Efficiency) \\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(treat_post) coeflabel(treat_post "Treat $\times$ Post") label /// 
prefoot("\hline") postfoot( ///
"\hline" ///
"Firm FE & Y & Y & Y \\" ///
"Industry $\times$ Year FE  & Y & Y & Y \\" ///
"Province $\times$ Year FE  & Y & Y & Y \\" ///
"\bottomrule" ///
"\end{tabular}" ///
"\end{table}" ) replace 
