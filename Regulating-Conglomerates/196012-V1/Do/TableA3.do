
* Table A.3 Heterogeneous Spillover Effects by Location

*----------------------
* Transfer Definition
*----------------------

use "$revision/Data/TableA3_1.dta",clear 

*Identify 4-Digit Related
gsort related -same_ind4
by related: replace same_ind4=same_ind4[1]
keep if same_ind4==1

*Top1000 and Related Region
gen top1000_west=1 if top1000_province==15 | top1000_province==45 | top1000_province==50 | top1000_province==51 | ///
top1000_province==52 | top1000_province==53 | top1000_province==54 | top1000_province==61 | top1000_province==62 | ///
top1000_province==63 | top1000_province==64 | top1000_province==65
replace top1000_west=0 if top1000_west==.

gen GQ_west=1 if GQ_province==15 | GQ_province==45 | GQ_province==50 | GQ_province==51 | ///
GQ_province==52 | GQ_province==53 | GQ_province==54 | GQ_province==61 | GQ_province==62 | ///
GQ_province==63 | GQ_province==64 | GQ_province==65
replace GQ_west=0 if GQ_west==.

*Define Transfer
gsort related 
by related: egen top1000_west_mean=mean(top1000_west)

duplicates drop related,force

gen diff=top1000_west_mean-GQ_west

gen transfer=0 if diff<=0.3 & diff>=-0.3
replace transfer=-1 if diff<-0.3
replace transfer=1 if diff>0.3

*Temp File
preserve
keep related same_ind4 transfer
ren related name
order name same_ind4 transfer
save "$revision/Data/Related_Transfer_Name.dta",replace
restore

drop if legcode==""
gen legcodelength=length(legcode)
keep if legcodelength==9
keep legcode same_ind4 transfer
order legcode same_ind4 transfer
save "$revision/Data/Related_Transfer_Legcode.dta",replace

*----------------
*  Output Share 
*----------------

*Import ASIF Data
use "$revision/Data/TableA3_2.dta",clear

merge m:1 legcode using "$revision/Data/Related_Transfer_Legcode.dta",update
drop if _merge==2
drop _merge

merge m:1 name using "$revision/Data/Related_Transfer_Name.dta",update
drop if _merge==2
drop _merge

xtset id_in_panel year
xfill same_ind4,i(id_in_panel)
keep if same_ind4==1

sort id_in_panel transfer
by id_in_panel: replace transfer=transfer[1]

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
replace giovpp=0 if giovpp==.

xtset id_in_panel year
gen output=giovpp/price if year==2004
xfill output,i(id_in_panel)
replace output=giovpp/price if year==2003 & output==.
xfill output,i(id_in_panel)
replace output=giovpp/price if year==2002 & output==.
xfill output,i(id_in_panel)
replace output=giovpp/price if year==2001 & output==.
xfill output,i(id_in_panel)
replace output=giovpp/price if year==2005 & output==.
xfill output,i(id_in_panel)
replace output=giovpp/price if year==2006 & output==.
xfill output,i(id_in_panel)
replace output=giovpp/price if year==2007 & output==.
xfill output,i(id_in_panel)
replace output=giovpp/price if year==2008 & output==.
xfill output,i(id_in_panel)
replace output=giovpp/price if year==2009 & output==.
xfill output,i(id_in_panel)
replace output=giovpp/price if year==2011 & output==.
xfill output,i(id_in_panel)

*Aggregate Output
duplicates drop id_in_panel,force

egen output_type1=total(output) if transfer==-1
egen output_type2=total(output) if transfer==0 
egen output_type3=total(output) if transfer==1

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
listtex * using "$revision/Appendix_Table/TableA3.tex", replace rstyle(tabular)
destring *, replace
local outputshare1 = 100*output_type_pro1[1]
local outputshare2 = 100*output_type_pro2[1]
local outputshare3 = 100*output_type_pro3[1]
*--------------------
*  Related Spillover
*--------------------
local i = 1
foreach transfer_type of numlist -1 0 1 {
    
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

merge m:1 legcode using "$revision/Data/Related_Transfer_Legcode.dta"
drop if _merge==2
drop _merge

merge m:1 name using "$revision/Data/Related_Transfer_Name.dta",update
drop if _merge==2
drop _merge

keep if transfer==`transfer_type'
duplicates drop firmid,force
keep firmid control

preserve
keep firmid
gen weight=1
gen related=1
save "$revision/Data/Distance_Matching_Output_Related_Transfer.dta",replace
restore

keep control
duplicates tag control,gen(du)
gen weight=du+1
keep control weight
ren control firmid
duplicates drop firmid,force
gen control=1
save "$revision/Data/Distance_Matching_Output_Control_Transfer.dta",replace

use "$revision/Data/Table2_1.dta",clear

gen ind3=int(ind4/10)
keep if ind3!=441 & ind3!=442

merge m:1 firmid using "$revision/Data/Distance_Matching_Output_Related_Transfer.dta",update
drop if _merge==2
drop _merge

merge m:1 firmid using "$revision/Data/Distance_Matching_Output_Control_Transfer.dta",update
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
local absorb3 "firmid ind2_year province_year"

local j=`transfer_type'+1
eststo Location_`j': reghdfe `y' `x' `control' [fweight=weight], absorb(`absorb3') cluster(`cluster')
local AggEffect `outputshare`i'' *  _b[related_post]
estadd local OutputShare = string(`outputshare`i'', "%8.2fc")
estadd local AggregateEffect = string(`AggEffect', "%8.2fc")
local i = `i' + 1
}

esttab Location_?  using "$revision/Appendix_Table/TableA3.tex",  ///
preh("\begin{table} \centering" ///
"\caption{\bf Heterogeneous Spillover Effects by Location'}" ///
"\begin{tabular}{l c c c}") ///
stats() posth("\toprule" ///
"Variables & East\&Mid to West &  Within Region & West to East\&Mid \\" ///
"\midrule \hline" ) ///
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

erase "$revision/Data/Related_Transfer_Legcode.dta"
erase "$revision/Data/Related_Transfer_Name.dta"
erase "$revision/Data/Distance_Matching_Output_Related_Transfer.dta"
erase "$revision/Data/Distance_Matching_Output_Control_Transfer.dta"
