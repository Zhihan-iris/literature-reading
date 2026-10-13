
*Table A.16 Heterogeneity Effects on Regulated Firms by Ownership

use "$revision/Data/Table1.dta",clear

* Definition for SOE
gen soe_policy=soe if year>=2007
gsort firmid -soe_policy
by firmid: replace soe_policy=soe_policy[1]
drop if soe_policy==.

egen soe_year=group(soe_policy year)

gen soe_post=soe_policy if year>=2007
replace soe_post=0 if year<2007

gen treat_soe_post=soe_policy*treat_post

local x "treat_post treat_soe_post"
local cluster "firmid"
local absorb4 "firmid ind2_year province_year soe_year"

eststo soe_1: reghdfe lenergy `x', absorb(`absorb4') cluster(`cluster')
eststo soe_2: reghdfe loutput `x', absorb(`absorb4') cluster(`cluster')
eststo soe_3: reghdfe lefficiency `x', absorb(`absorb4') cluster(`cluster')

esttab soe_?  using "$revision/Appendix_Table/TableA16.tex",  ///
preh("\begin{table} \centering" ///
"\caption{\bf Heterogeneous Effects on Regulated Firms by Ownership}" ///
"\begin{tabular}{l c c c}") ///
stats() posth("\toprule" ///
"Variables & ln(Energy Use) & ln(Output) & ln(Energy Efficiency) \\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(treat_post treat_soe_post) ///
coeflabel(treat_post "Treat $\times$ Post" treat_soe_post "Treat $\times$ SOE $\times$ Post" ) label /// 
prefoot("\hline") postfoot( ///
"\hline" ///
"Firm FE & Y & Y & Y \\" ///
"Industry $\times$ Year FE & Y & Y & Y \\" ///
"Province $\times$ Year FE & Y & Y & Y \\" ///
"SOE $\times$ Year FE & Y & Y & Y \\" ///
"\bottomrule" ///
"\end{tabular}" ///
"\end{table}") replace 
