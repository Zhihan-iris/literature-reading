
* Table A.19: Heterogeneous Effects on Regulated Firms by Electricity Consumption Increase

use "$revision/Data/Table1.dta",clear

* Annual Electricity Consumption Change Rate during 2007-2010

xtset firmid year

gen electricity_change=(f3.electricity-electricity)/(3*electricity) if year==2007 & top1000==1
replace electricity_change=(f2.electricity-electricity)/(2*electricity) if electricity_change==. & year==2007 & top1000==1
replace electricity_change=(f.electricity-electricity)/(electricity) if electricity_change==. & year==2007 & top1000==1

gsort ind4
by ind4: egen electricity_change_mean=mean(electricity_change) if top1000==1

gen electricity_increase=1 if electricity_change>electricity_change_mean & electricity_change!=. & year==2007 & top1000==1
replace electricity_increase=0 if electricity_change<=electricity_change_mean & electricity_change!=. & year==2007 & top1000==1
xfill electricity_increase,i(firmid)

drop if electricity_increase==. & top1000==1

gen electricity_post=electricity_increase if year>=2007
replace electricity_post=0 if electricity_post==.

local x "electricity_post treat_post"
local cluster "firmid"
local absorb3 "firmid ind2_year province_year"

eststo electricity_1: reghdfe lenergy `x', absorb(`absorb3') cluster(`cluster')
eststo electricity_2: reghdfe loutput `x', absorb(`absorb3') cluster(`cluster')
eststo electricity_3: reghdfe lefficiency `x', absorb(`absorb3') cluster(`cluster')

esttab electricity_?  using "$revision/Appendix_Table/TableA19.tex",  ///
preh("\begin{table} \centering" ///
"\caption{\bf Heterogeneous Effects on Regulated Firms by Change in Electricity Use}" ///
"\begin{tabular}{l c c c}") ///
stats() posth("\toprule" ///
"Variables & ln(Energy) & ln(Output) & ln(Efficiency) \\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(electricity_post treat_post) coeflabel(electricity_post "Treat $\times$ Post $\times$ Electricity-Increase" ///
treat_post "Treat $\times$ Post") label /// 
prefoot("\hline") postfoot( ///
"\hline" ///
"Firm FE & Y & Y & Y \\" ///
"Industry $\times$ Year FE & Y & Y & Y \\" ///
"Province $\times$ Year FE & Y & Y & Y \\" ///
"\bottomrule" ///
"\end{tabular}"  ///
"\end{table}" ) replace
