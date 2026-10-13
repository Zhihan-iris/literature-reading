
* Table A.2 Heterogeneous Spillover Effects by Local Pollution and Density

*-----------------------------------------------
*  Compare Density between Top1000 & Related
*-----------------------------------------------

* Define Pollution Density

use "$revision/Data/TableA2_1.dta",clear

gen top1000_pollution=top1000_so2_density*top1000_population
gen related_pollution=related_so2_density*related_population

egen related_id=group(related)
sort related_id
by related_id: egen top1000_pollution_mean=mean(top1000_pollution)

keep related top1000_pollution_mean related_pollution

duplicates drop related,force

* Define Pollution Density Transfer

gen diff_pollution=(related_pollution-top1000_pollution_mean)/top1000_pollution_mean

gen pollution=1 if diff_pollution>0.1 & diff_pollution!=.
replace pollution=-1 if diff_pollution<-0.1 & diff_pollution!=. 
replace pollution=0 if diff_pollution>=-0.1 & diff_pollution<=0.1 & diff_pollution!=. 

keep related pollution
gen same_ind4=1
ren related name
order name same_ind4 pollution
save "$revision/Data/Related_Density_Name.dta",replace

merge 1:1 name using "$revision/Data/TableA2_3.dta"
keep if _merge==3
drop if legcode==""
gen legcodelength=length(legcode)
keep if legcodelength==9
keep legcode same_ind4 pollution
order legcode same_ind4 pollution
save "$revision/Data/Related_Density_Legcode.dta",replace

*----------------
*  Output Share 
*----------------

use "$revision/Data/TableA2_2.dta",clear

merge m:1 legcode using "$revision/Data/Related_Density_Legcode.dta"
drop if _merge==2
drop _merge

merge m:1 name using "$revision/Data/Related_Density_Name.dta",update
drop if _merge==2
drop _merge

xtset firmid year
xfill same_ind4,i(firmid)
keep if same_ind4==1

sort firmid pollution
by firmid: replace pollution=pollution[1]

*Price Index
gen price=1 if year==2004
replace price=0.9420 if year==2001
replace price=0.9213 if year==2002
replace price=0.9425 if year==2003
replace price=1.0490 if year==2005
replace price=1.0805 if year==2006
replace price=1.1140 if year==2007
replace price=1.1908 if year==2008
replace price=1.1265 if year==2009
replace price=1.2598 if year==2011

*Output
replace output=0 if output==.

xtset firmid year
gen output_adj=output/price if year==2004
xfill output_adj,i(firmid)
replace output_adj=output/price if year==2003 & output_adj==.
xfill output_adj,i(firmid)
replace output_adj=output/price if year==2002 & output_adj==.
xfill output_adj,i(firmid)
replace output_adj=output/price if year==2001 & output_adj==.
xfill output_adj,i(firmid)
replace output_adj=output/price if year==2005 & output_adj==.
xfill output_adj,i(firmid)
replace output_adj=output/price if year==2006 & output_adj==.
xfill output_adj,i(firmid)
replace output_adj=output/price if year==2007 & output_adj==.
xfill output_adj,i(firmid)
replace output_adj=output/price if year==2008 & output_adj==.
xfill output_adj,i(firmid)
replace output_adj=output/price if year==2009 & output_adj==.
xfill output_adj,i(firmid)
replace output_adj=output/price if year==2011 & output_adj==.
xfill output_adj,i(firmid)

duplicates drop firmid,force

egen output_type1=total(output_adj) if pollution==-1
egen output_type2=total(output_adj) if pollution==0 
egen output_type3=total(output_adj) if pollution==1

forvalues i=1(1)3 {
    gsort -output_type`i'
	replace output_type`i'=output_type`i'[1]
	}

gen output_all=output_type1+output_type2+output_type3

forvalues i=1(1)3 {
    gen output_type_pro`i'=output_type`i'/output_all
	tostring output_type_pro`i', force replace format(%7.3f)
	}

duplicates drop output_all,force
keep output_type_pro*
listtex * using "$revision/Appendix_Table/TableA2.tex", replace rstyle(tabular)

destring *, replace
local outputshare1 = 100*output_type_pro1[1]
local outputshare2 = 100*output_type_pro2[1]
local outputshare3 = 100*output_type_pro3[1]

*--------------------
*  Related Spillover
*--------------------
local i = 1
foreach pollution_type of numlist -1 0 1 {

*Matching

use "$revision/Data/Distance_Matching/Matching_Result_Output.dta",clear

_pctile distance2,p(95)
return list
local a=r(r1)
drop if distance2>=`a'

keep related control
ren related firmid
merge 1:m firmid using "$revision/Data/Table2_1.dta"
drop if _merge==2
drop _merge

merge m:1 legcode using "$revision/Data/Related_Density_Legcode.dta"
drop if _merge==2
drop _merge

merge m:1 name using "$revision/Data/Related_Density_Name.dta",update
drop if _merge==2
drop _merge

keep if pollution==`pollution_type'
duplicates drop firmid,force
keep firmid control

preserve
keep firmid
gen weight=1
gen related=1
save "$revision/Data/Distance_Matching_Output_Related_Pollution_Density.dta",replace
restore

keep control
duplicates tag control,gen(du)
gen weight=du+1
keep control weight
ren control firmid
duplicates drop firmid,force
gen control=1
save "$revision/Data/Distance_Matching_Output_Control_Pollution_Density.dta",replace

*Regression

use "$revision/Data/Table2_1.dta",clear

merge m:1 firmid using "$revision/Data/Distance_Matching_Output_Related_Pollution_Density.dta"
drop if _merge==2
drop _merge

merge m:1 firmid using "$revision/Data/Distance_Matching_Output_Control_Pollution_Density.dta",update
drop if _merge==2
drop _merge

keep if related==1 | control==1
replace related=0 if related==.
replace control=0 if control==.

gen related_post=1 if related==1 & year>=2007
replace related_post=0 if related_post==.
label variable related_post "Related*Post"

local y "loutput"
local x "related_post"
local control "soe roa age exp"
local cluster "firmid"
local absorb1 "firmid year"
local absorb2 "firmid ind2_year"
local absorb3 "firmid ind2_year province_year"

local j=`pollution_type'+1
eststo Pollution_`j': reghdfe `y' `x' `control' [fweight=weight], absorb(`absorb3') cluster(`cluster')
local AggEffect `outputshare`i'' *  _b[related_post]
estadd local OutputShare = string(`outputshare`i'', "%8.1fc")
estadd local AggregateEffect = string(`AggEffect', "%8.2fc")
local i = `i' + 1
}

esttab Pollution_?  using "$revision/Appendix_Table/TableA2.tex",  ///
preh("\begin{table} \centering" ///
"\caption{\bf Heterogeneous Spillover Effects by Local Pollution and Density'}" ///
"\begin{tabular}{l c c c c}") ///
stats() posth("\toprule" ///
"Variables &  High to Low & Horizontal &Low to High \\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2 OutputShare AggregateEffect, /// 
label("Observations" "$ R^2$" "Output Share" "Aggregate Effect") /// 
fmt(%9.0fc %9.3f)) noobs nogap ///
keep(related_post) coeflabel(related_post "Related $\times$ Post") label /// 
prefoot("\hline") postfoot( ///
"\hline" ///
"Firm FE & Y & Y & Y \\" ///
"Industry $\times$ Year FE & Y & Y & Y \\" ///
"Province $\times$ Year FE & Y & Y & Y \\" ///
"Firm-level Controls & Y & Y & Y \\" ///
"\bottomrule" ///
"\end{tabular}" ///
"\end{table}" ) replace

*Erase Temp File

erase "$revision/Data/Related_Density_Legcode.dta"
erase "$revision/Data/Related_Density_Name.dta"
erase "$revision/Data/Distance_Matching_Output_Related_Pollution_Density.dta"
erase "$revision/Data/Distance_Matching_Output_Control_Pollution_Density.dta"
