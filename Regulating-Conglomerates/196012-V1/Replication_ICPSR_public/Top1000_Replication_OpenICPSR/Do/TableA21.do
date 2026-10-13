
*Table A.21: Effects of the Top 1,000 Program on Input Substitution of Regulated Firms

use "$revision/Data/Table1.dta",clear

keep if lnkl!=. & lnel!=. & lnek!=. 

local x "treat_post"
local cluster "firmid"
local absorb3 "firmid ind2_year province_year"

eststo Substitution_1: reghdfe lnkl `x', absorb(`absorb3') cluster(`cluster')
eststo Substitution_2: reghdfe lnel `x', absorb(`absorb3') cluster(`cluster')
eststo Substitution_3: reghdfe lnek `x', absorb(`absorb3') cluster(`cluster')

esttab Substitution_?  using "$revision/Appendix_Table/TableA21.tex",  ///
preh("\begin{table} \centering" ///
"\caption{\bf Effects of the Top 1,000 Program on Input Substitution in Regulated Firms}" ///
"\begin{tabular}{l c c c}") ///
posth("\toprule" ///
"Variables & ln(Capital/Labor) & ln(Energy/Labor) & ln(Energy/Capital) \\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(treat_post) coeflabel(treat_post "Treat $\times$ Post") label /// 
prefoot("\hline") postfoot( ///
"\hline" ///
"Firm FE & Y & Y & Y   \\" ///
"Industry $\times$ Year FE & Y & Y & Y   \\" ///
"Province $\times$ Year FE & Y & Y  & Y  \\" ///
"\bottomrule" ///
"\end{tabular}" ///
"\end{table}" ) replace
