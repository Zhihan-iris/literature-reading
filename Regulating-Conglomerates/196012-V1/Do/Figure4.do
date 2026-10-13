
*Figure 4: Spillover Effects on Related Firms

*------------------
* Panel A: Output
*------------------

use "$revision/Data/Table2_1.dta",clear

*Treat & Control

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Output_Related.dta"
drop if _merge==2
drop _merge

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Output_Control.dta",update
drop if _merge==2
drop _merge

keep if related==1 | control==1
replace related=0 if related==.
replace control=0 if control==.

*Dynamics

tab year, gen (ydummy)

forvalues i=1(1)10 {
   local j=2000+`i'
   gen related_year`j'=ydummy`i'*related
}

reghdfe loutput related_year2001-related_year2005 related_year2007-related_year2010 ///
[fweight=weight] ,absorb(firmid year) cluster(firmid)
parmest,saving("$revision/Figure/dta/Figure4_A.dta",replace)

*Figure

use "$revision/Figure/dta/Figure4_A.dta",clear
gen x=length( parm )
keep if x==16
gen year=substr(parm,13,.)
destring year,replace
keep year estimate min95 max95
replace year=2011 if year==2010
set obs 10
replace year = 2006 in 10
replace estimate = 0 if year==2006
order year estimate min95 max95
sort year
graph tw (scatter estimate year , color(navy) msymbol(circle)) ///
(rcap min95 max95 year ,lp(solid) msymbol(none) color(navy)) ///
, scheme(s1mono) graphregion(fcolor(white) lcolor(none) ifcolor(white) ///
ilcolor(none)) plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
xline(2006,lp(solid)) yline(0,lp(solid) lcolor(cranberry)) ///
xlabel(2001(1)2011,valuelabel)  ylabel(-0.1(0.1)0.3,valuelabel)  ///
xtitle("") ytitle("") legend( label(1 "Estimate") label(2 "95% CI"))
graph export "$revision/Figure/Figure4_A.pdf", replace

*-------------------
* Panel B: Placebo
*-------------------

use "$revision/Data/Table2_1.dta",clear

*Treat & Control

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Placebo_Related.dta"
drop if _merge==2
drop _merge

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Placebo_Control.dta",update
drop if _merge==2
drop _merge

keep if related==1 | control==1
replace related=0 if related==.
replace control=0 if control==.

*Drop Extreme Values

replace year=2010 if year==2011
xtset firmid year
gen growth=(output-l.output)/l.output
gen growth_raw=growth
winsor2 growth, trim replace
drop if growth==. & growth_raw!=.
drop growth growth_raw
replace year=2011 if year==2010
xtset firmid year

*Dynamics

tab year, gen (ydummy)

forvalues i=1(1)10 {
   local j=2000+`i'
   gen related_year`j'=ydummy`i'*related
}

reghdfe loutput related_year2001-related_year2005 related_year2007-related_year2010 ///
[fweight=weight] ,absorb(firmid year) cluster(firmid)
parmest,saving("$revision/Figure/dta/Figure4_B.dta",replace)

*Figure

use "$revision/Figure/dta/Figure4_B.dta",clear
gen x=length( parm )
keep if x==16
gen year=substr(parm,13,.)
destring year,replace
keep year estimate min95 max95
replace year=2011 if year==2010
set obs 10
replace year = 2006 in 10
replace estimate = 0 if year==2006
order year estimate min95 max95
sort year
graph tw (scatter estimate year , color(navy) msymbol(circle)) ///
(rcap min95 max95 year ,lp(solid) msymbol(none) color(navy)) ///
, scheme(s1mono) graphregion(fcolor(white) lcolor(none) ifcolor(white) ///
ilcolor(none)) plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
xline(2006,lp(solid)) yline(0,lp(solid) lcolor(cranberry)) ///
xlabel(2001(1)2011,valuelabel)  ylabel(-0.2(0.1)0.2,valuelabel)  ///
xtitle("") ytitle("") legend( label(1 "Estimate") label(2 "95% CI"))
graph export "$revision/Figure/Figure4_B.pdf", replace

*----------------------
* Panel C: Energy Use
*----------------------

use "$revision/Data/Table2_2.dta",clear

*Treat & Control

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Energy_Related.dta"
drop if _merge==2
drop _merge

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Energy_Control.dta",update
drop if _merge==2
drop _merge

keep if related==1 | control==1
replace related=0 if related==.
replace control=0 if control==.

*Dynamics

tab year, gen (ydummy)

forvalues i=1(1)10 {
   local j=2000+`i'
   gen related_year`j'=ydummy`i'*related
}

reghdfe lenergy related_year2001-related_year2005 related_year2007-related_year2010 ///
[fweight=weight] ,absorb(firmid year) cluster(firmid)
parmest,saving("$revision/Figure/dta/Figure4_C.dta",replace)

*Figure

use "$revision/Figure/dta/Figure4_C.dta",clear
gen x=length( parm )
keep if x==16
gen year=substr(parm,13,.)
destring year,replace
keep year estimate min95 max95
set obs 10
replace year = 2006 in 10
replace estimate = 0 if year==2006
order year estimate min95 max95
sort year
graph tw (scatter estimate year , color(navy) msymbol(circle)) ///
(rcap min95 max95 year ,lp(solid) msymbol(none) color(navy)) ///
, scheme(s1mono) graphregion(fcolor(white) lcolor(none) ifcolor(white) ///
ilcolor(none)) plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
xline(2006,lp(solid)) yline(0,lp(solid) lcolor(cranberry)) ///
xlabel(2001(1)2010,valuelabel)  ylabel(-0.4(0.2)0.6,valuelabel)  ///
xtitle("") ytitle("") legend( label(1 "Estimate") label(2 "95% CI"))
graph export "$revision/Figure/Figure4_C.pdf", replace

*----------------------------
* Panel D: Energy Efficiency
*----------------------------

use "$revision/Data/Table2_2.dta",clear

*Treat & Control

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Energy_Related.dta"
drop if _merge==2
drop _merge

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Energy_Control.dta",update
drop if _merge==2
drop _merge

keep if related==1 | control==1
replace related=0 if related==.
replace control=0 if control==.

*Dynamics

tab year, gen (ydummy)

forvalues i=1(1)10 {
   local j=2000+`i'
   gen related_year`j'=ydummy`i'*related
}

reghdfe lefficiency related_year2001-related_year2005 related_year2007-related_year2010 ///
[fweight=weight] ,absorb(firmid year) cluster(firmid)
parmest,saving("$revision/Figure/dta/Figure4_D.dta",replace)

*Figure

use "$revision/Figure/dta/Figure4_D.dta",clear
gen x=length( parm )
keep if x==16
gen year=substr(parm,13,.)
destring year,replace
keep year estimate min95 max95
set obs 10
replace year = 2006 in 10
replace estimate = 0 if year==2006
order year estimate min95 max95
sort year
graph tw (scatter estimate year , color(navy) msymbol(circle)) ///
(rcap min95 max95 year ,lp(solid) msymbol(none) color(navy)) ///
, scheme(s1mono) graphregion(fcolor(white) lcolor(none) ifcolor(white) ///
ilcolor(none)) plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
xline(2006,lp(solid)) yline(0,lp(solid) lcolor(cranberry)) ///
xlabel(2001(1)2010,valuelabel)  ylabel(-0.4(0.2)0.6,valuelabel)  ///
xtitle("") ytitle("") legend( label(1 "Estimate") label(2 "95% CI"))
graph export "$revision/Figure/Figure4_D.pdf", replace

