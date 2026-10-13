
* Table A.32 Heterogeneous Effects on Regulated Firms by Firm Size and Energy Consumption

****************
* By Firm Size
****************

use "$revision/Data/Table1.dta",clear

gsort ind4 loutput
by ind4: egen loutput_mid=median(loutput) if year==2004 & top1000==1

gen large=1 if loutput>loutput_mid & loutput!=. & year==2004 & top1000==1
replace large=0  if loutput<=loutput_mid & loutput!=. & year==2004 & top1000==1
xfill large,i(firmid)

drop if large==. & top1000==1

gen large_post=large if year>=2007
replace large_post=0 if large_post==.

local x "large_post treat_post"
local control "soe roa age exp"
local cluster "firmid"
local absorb1 "firmid year"
local absorb2 "firmid ind2_year"
local absorb3 "firmid ind2_year province_year"

eststo loutput1_1: reghdfe loutput `x', absorb(`absorb1') cluster(`cluster')
eststo loutput1_2: reghdfe loutput `x', absorb(`absorb2') cluster(`cluster')
eststo loutput1_3: reghdfe loutput `x', absorb(`absorb3') cluster(`cluster')
eststo loutput1_4: reghdfe loutput `x' `control', absorb(`absorb3') cluster(`cluster')

esttab loutput1_?  using "$revision/Appendix_Table/TableA32.tex",  ///
preh("\begin{table} \centering" ///
"\caption{\bf Heterogeneous Effects on Regulated Firms by Firm Size and Energy Consumption}" ///
"\\ $\;$\\ {\bf A. Heterogeneous Effects on Output by Firm Size} \\ $\;$\\" ///
"\begin{tabular}{l c c c c}") ///
stats() posth("\toprule" ///
"Variables & \multicolumn{4}{c}{ln(Output)} \\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(large_post treat_post) coeflabel(large_post "Treat $\times$ Post $\times$ Large" ///
treat_post "Treat $\times$ Post") label /// 
prefoot("\hline") postfoot( ///
"\bottomrule" ///
"\end{tabular}"  ) replace

*************************
* By Energy Consumption
*************************

use "$revision/Data/Table1.dta",clear

gsort ind4 lenergy
by ind4: egen lenergy_mid=median(lenergy) if year==2004 & top1000==1

gen high=1 if lenergy>lenergy_mid & lenergy!=. & year==2004 & top1000==1
replace high=0  if lenergy<=lenergy_mid & lenergy!=. & year==2004 & top1000==1
xfill high,i(firmid)

drop if high==. & top1000==1

gen high_post=high if year>=2007
replace high_post=0 if high_post==.

local x "high_post treat_post"
local control "soe roa age exp"
local cluster "firmid"
local absorb1 "firmid year"
local absorb2 "firmid ind2_year"
local absorb3 "firmid ind2_year province_year"

eststo loutput2_1: reghdfe loutput `x', absorb(`absorb1') cluster(`cluster')
eststo loutput2_2: reghdfe loutput `x', absorb(`absorb2') cluster(`cluster')
eststo loutput2_3: reghdfe loutput `x', absorb(`absorb3') cluster(`cluster')
eststo loutput2_4: reghdfe loutput `x' `control', absorb(`absorb3') cluster(`cluster')

eststo lefficiency2_1: reghdfe lefficiency `x', absorb(`absorb1') cluster(`cluster')
eststo lefficiency2_2: reghdfe lefficiency `x', absorb(`absorb2') cluster(`cluster')
eststo lefficiency2_3: reghdfe lefficiency `x', absorb(`absorb3') cluster(`cluster')
eststo lefficiency2_4: reghdfe lefficiency `x' `control', absorb(`absorb3') cluster(`cluster')

esttab loutput2_?   using "$revision/Appendix_Table/TableA32.tex",  ///
preh("\\ $\;$\\ \\ $\;$\\ {\bf B. Heterogeneous Effects on Output by Energy Consumption} \\ $\;$\\" ///
"\begin{tabular}{l c c c c}") ///
stats() posth("\toprule" ///
"Variables & \multicolumn{4}{c}{ln(Output)} \\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(high_post treat_post) coeflabel(high_post "Treat $\times$ Post $\times$ High Energy Consumption" ///
treat_post "Treat $\times$ Post") label /// 
prefoot("\hline") postfoot( ///
"\bottomrule" ///
"\end{tabular}" ) append sty(tex)

esttab lefficiency2_?  using "$revision/Appendix_Table/TableA32.tex",  ///
preh("\\ $\;$\\ \\ $\;$\\ {\bf C. Heterogeneous Effects on Energy Efficiency by Energy Consumption} \\ $\;$\\" ///
"\begin{tabular}{l c c c c}") ///
stats() posth("\toprule" ///
"Variables & \multicolumn{4}{c}{ln(Energy Efficiency)} \\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(high_post treat_post) coeflabel(high_post "Treat $\times$ Post $\times$ High Energy Consumption" ///
treat_post "Treat $\times$ Post") label /// 
prefoot("\hline") postfoot( ///
"\hline" ///
"Firm FE & Y & Y & Y & Y \\" ///
"Year FE & Y & Y & Y & Y \\" ///
"Industry $\times$ Year FE & {} & Y & Y & Y \\" ///
"Province $\times$ Year FE & {} & {} & Y & Y \\" ///
"Firm-level Controls & {} & {} & {} & Y \\" ///
"\bottomrule" ///
"\end{tabular}" ///
"\end{table}" ) append sty(tex)
