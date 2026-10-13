
*Table 3: Industry-level Spillovers and Within-Conglomerate Effects

* Industry-level Spillovers

use "$revision/Data/Table3_1.dta",clear

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

esttab loutput_?  using "$revision/Table/Table3.tex",  ///
preh("\begin{table} \centering" ///
"\caption{\bf Industry-Level Spillovers and Within-Conglomerate Effects}" ///
"\\ $\;$\\ {\bf A. Industry-Level Spillovers} \\ $\;$\\" ///
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

* Within-Conglomerate Difference-in-Differences

use "$revision/Data/Table3_2.dta",clear

local y "loutput"
local x "treat_post top1000"
local control "soe roa age exp"
local cluster "conglomerate"
local absorb1 "conglomerate_year"
local absorb2 "conglomerate_year ind2_year"
local absorb3 "conglomerate_year ind2_year province_year"

eststo `y'_1: reghdfe `y' `x', absorb(`absorb1') cluster(`cluster')
eststo `y'_2: reghdfe `y' `x', absorb(`absorb2') cluster(`cluster')
eststo `y'_3: reghdfe `y' `x', absorb(`absorb3') cluster(`cluster')
eststo `y'_4: reghdfe `y' `x' `control', absorb(`absorb3') cluster(`cluster')

esttab loutput_?  using "$revision/Table/Table3.tex",  ///
preh("\\ $\;$\\ \\ $\;$\\ {\bf B. Within-Conglomerate Difference-in-Differences} \\ $\;$\\" ///
"\begin{tabular}{l c c c c}") ///
stats() posth("\toprule" ///
"Variables & \multicolumn{4}{c}{ln(Output)} \\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(treat_post) coeflabel(treat_post "Treat $\times$ Post") label /// 
prefoot("\hline") postfoot( ///
"\hline" ///
"Treat & Y & Y & Y & Y \\" ///
"Conglomerate $\times$ Year FE & Y & Y & Y & Y \\" ///
"Industry $\times$ Year FE & {} & Y & Y & Y \\" ///
"Province $\times$ Year FE & {} & {} & Y & Y \\" ///
"Firm-level Controls & {} & {} & {} & Y \\" ///
"\bottomrule" ///
"\end{tabular}" ///
"\end{table}" ) append sty(tex)
