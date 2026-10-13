
*Table A.31: Robustness to Entry: Market Spillovers

use "$revision/Data/Table3_1.dta",clear

sort firmid year
by firmid: gen start=year[1]
drop if start>2006

local y "loutput"
local x "spillover_post"
local ind_control "loutput_ind2 lenergy_ind2"
local firm_control "soe roa age exp"
local cluster "ind2"
local absorb1 "firmid year"
local if "if top1000_industry==1"

eststo `y'_1: reghdfe `y' `x' `ind_control', absorb(`absorb1') cluster(`cluster')
eststo `y'_2: reghdfe `y' `x' `ind_control' `firm_control', absorb(`absorb1') cluster(`cluster')
eststo `y'_3: reghdfe `y' `x' `ind_control' `if', absorb(`absorb1') cluster(`cluster')
eststo `y'_4: reghdfe `y' `x' `ind_control' `firm_control' `if', absorb(`absorb1') cluster(`cluster')

esttab loutput_?  using "$revision/Appendix_Table/TableA31.tex",  ///
preh("\begin{table} \centering" ///
"\caption{\bf Robustness to Entry: Markert Spillovers}" ///
"\begin{tabular}{l c c c c}") ///
stats() posth("\toprule" ///
"\multirow{2}{*}{Variables} & \multicolumn{4}{c}{ln(Output)} \\" ///
"\cline{2-5}" ///
"{} & \multicolumn{2}{c}{All Sample} & \multicolumn{2}{c}{Energy-Intensive Industries}\\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(spillover_post) coeflabel(spillover_post "Spillover $\times$ Post") label /// 
prefoot("\hline") postfoot( ///
"\hline" ///
"Firm FE & Y & Y & Y & Y \\" ///
"Year FE & Y & Y & Y & Y \\" ///
"Industry-level Controls & Y & Y & Y & Y \\" ///
"Firm-level Controls & {} & Y & {} & Y \\" ///
"\bottomrule" ///
"\end{tabular}" ///
"\end{table}" ) replace 

