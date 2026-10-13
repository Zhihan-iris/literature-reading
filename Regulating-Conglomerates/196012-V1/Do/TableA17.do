
*Table A.17: Robustness to Consideration of Concurrent Policies

use "$revision/Data/Table1.dta",clear

local x1 "treat_post"
local x2 "monitor_post"
local cluster "firmid"
local absorb3 "firmid ind2_year province_year"

eststo y1_1: reghdfe lenergy `x2' if top1000==1 , absorb(`absorb3') cluster(`cluster')
eststo y1_2: reghdfe loutput `x2' if top1000==1 , absorb(`absorb3') cluster(`cluster')
eststo y1_3: reghdfe lefficiency `x2' if top1000==1 , absorb(`absorb3') cluster(`cluster')

eststo y2_1: reghdfe lenergy `x1' if (monitor!=1 | top1000!=1) , absorb(`absorb3') cluster(`cluster')
eststo y2_2: reghdfe loutput `x1' if (monitor!=1 | top1000!=1) , absorb(`absorb3') cluster(`cluster')
eststo y2_3: reghdfe lefficiency `x1' if (monitor!=1 | top1000!=1) , absorb(`absorb3') cluster(`cluster')

************************************************************
* Panel A: Effects of Concurrent Policies on Top1000 Firms
************************************************************

esttab y1_? using "$revision/Appendix_Table/TableA17.tex",  ///
preh("\begin{table} \centering" ///
"\caption{\bf Robustness to Consideration of Concurrent Policies}" ///
"\label{tab:competing_policy}" ///
"\\ $\;$\\ {\bf A. Effects of Concurrent Policies on Top1000 Firms} \\ $\;$\\" ///
"\begin{tabular}{l c c c}") ///
stats() posth("\toprule" ///
"Variables & ln(Energy Use) & ln(Output) & ln(Energy Efficiency) \\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(monitor_post) ///
coeflabel(monitor_post "Monitor $\times$ Post") label /// 
prefoot("\hline") postfoot( ///
"\hline" ///
"Firm FE & Y & Y & Y \\" ///
"Industry $\times$ Year FE & Y & Y & Y \\" ///
"Province $\times$ Year FE & Y & Y & Y \\" ///
"\bottomrule" ///
"\end{tabular}" ) replace 

***************************************************
* Panel B: Robustness to Effects on Top1000 Firms
***************************************************

esttab y2_?  using "$revision/Appendix_Table/TableA17.tex",  ///
preh("\\ $\;$\\ \\ $\;$\\ {\bf B. Robustness to Effects on Top1000 Firms} \\ $\;$\\" ///
"\begin{tabular}{l c c c}") ///
stats() posth("\toprule" ///
"Variables & ln(Energy Use) & ln(Output) & ln(Energy Efficiency) \\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(treat_post) ///
coeflabel(treat_post "Treat $\times$ Post") label /// 
prefoot("\hline") postfoot( ///
"\hline" ///
"Firm FE & Y & Y & Y \\" ///
"Industry $\times$ Year FE & Y & Y & Y \\" ///
"Province $\times$ Year FE & Y & Y & Y \\" ///
"\bottomrule" ///
"\end{tabular}" ///
"\end{table}" ) append sty(tex)

