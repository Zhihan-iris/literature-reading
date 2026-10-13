
*Table A.30 Market Spillovers: Heterogeneous Effects Across 4-Digit Industries with Top 1,000 Firms

use "$revision/Data/Table3_1.dta",clear

* With or Without Top1000 Firms in 4-Digit Industries

gen spillover_post_top1000=spillover_post if top1000_count==1
replace spillover_post_top1000=0 if spillover_post_top1000==.
gen spillover_post_notop1000=spillover_post if top1000_count==0
replace spillover_post_notop1000=0 if spillover_post_notop1000==.

* Regregssion

local y "loutput"
local x1 "spillover_post_top1000 spillover_post_notop1000"
local ind_control "loutput_ind2 lenergy_ind2"
local firm_control "soe roa age exp"
local cluster "ind2"
local absorb1 "firmid year"
local if "if top1000_industry==1"

eststo marketspillover_1: reghdfe `y' `x1' `ind_control', absorb(`absorb1') cluster(`cluster')
eststo marketspillover_2: reghdfe `y' `x1' `ind_control' `firm_control', absorb(`absorb1') cluster(`cluster')
eststo marketspillover_3: reghdfe `y' `x1' `ind_control' `if', absorb(`absorb1') cluster(`cluster')
eststo marketspillover_4: reghdfe `y' `x1' `ind_control' `firm_control' `if', absorb(`absorb1') cluster(`cluster')

esttab marketspillover_?  using "$revision/Appendix_Table/TableA30.tex",  ///
preh("\begin{table} \centering" ///
"\caption{\bf Market Spillovers: Heterogeneous Effects Across 4-Digit Industries with Top 1,000 Firms}" ///
"\begin{tabular}{l c c c c}") ///
stats() posth("\toprule" ///
"\multirow{2}{*}{Variables} & \multicolumn{4}{c}{ln(Output)} \\" ///
"\cline{2-5}" ///
"{} & \multicolumn{2}{c}{All Sample} & \multicolumn{2}{c}{Energy-Intensive Industries}\\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(spillover_post_top1000 spillover_post_notop1000) ///
coeflabel(spillover_post_top1000 "Spillover $\times$ Post $\times$ $\mathbb{I}$[Top 1,000 Firm in 4-Digit Ind)" spillover_post_notop1000 "Spillover $\times$ Post $\times$  $\mathbb{I}$[No Top 1,000 Firm in 4-Digit Ind.]") label /// 
prefoot("\hline") postfoot( ///
"\hline" ///
"Firm FE & Y & Y & Y & Y \\" ///
"Year FE & Y & Y & Y & Y \\" ///
"Industry-level Controls & Y & Y & Y & Y \\" ///
"Firm-level Controls & {} & Y & {} & Y \\" ///
"\bottomrule" ///
"\end{tabular}" ) replace 

