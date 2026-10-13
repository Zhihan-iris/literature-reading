
* Table A.18: Heterogeneous Effects on Regulated Firms by Electricity Consumption

use "$revision/Data/Table1.dta",clear

egen electricity_mid=median(electricity) if year==2007 & top1000==1

gen electricity_intensive=1 if electricity>electricity_mid & electricity!=. & year==2007 & top1000==1
replace electricity_intensive=0 if electricity<=electricity_mid & electricity!=. & year==2007 & top1000==1
xfill electricity_intensive,i(firmid)

drop if electricity_intensive==. & top1000==1

gen large_post=electricity_intensive if year>=2007
replace large_post=0 if large_post==.

local x "large_post treat_post"
local cluster "firmid"
local absorb3 "firmid ind2_year province_year"

eststo electricity_1: reghdfe lenergy `x', absorb(`absorb3') cluster(`cluster')
eststo electricity_2: reghdfe loutput `x', absorb(`absorb3') cluster(`cluster')
eststo electricity_3: reghdfe lefficiency `x', absorb(`absorb3') cluster(`cluster')

esttab electricity_?  using "$revision/Appendix_Table/TableA18.tex",  ///
preh("\begin{table} \centering" ///
"\caption{\bf Heterogeneous Effects on Regulated Firms by Electricity Consumption}" ///
"\begin{tabular}{l c c c}") ///
stats() posth("\toprule" ///
"Variables & ln(Energy) & ln(Output) & ln(Efficiency) \\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(large_post treat_post) coeflabel(large_post "Treat $\times$ Post $\times$ Electricity-Intensive" ///
treat_post "Treat $\times$ Post") label /// 
prefoot("\hline") postfoot( ///
"\hline" ///
"Firm FE & Y & Y & Y \\" ///
"Industry $\times$ Year FE & Y & Y & Y \\" ///
"Province $\times$ Year FE & Y & Y & Y \\" ///
"\bottomrule" ///
"\end{tabular}"  ///
"\end{table}" ) replace
