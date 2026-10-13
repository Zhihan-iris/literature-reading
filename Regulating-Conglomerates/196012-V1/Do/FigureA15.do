
*Figure A.15: Robustness of Spillovers to Related Firms: Entropy Matching

*------------------
* Panel A: Output
*------------------

use "$revision/Data/TableA22.dta",clear

*Treat & Control

merge m:1 firmid using "$revision/Data/Entropy_Matching/Entropy_Matching_Result_Output.dta"
keep if _merge==3
drop _merge

*Dynamics

tab year, gen (ydummy)

forvalues i=1(1)10 {
   local j=2000+`i'
   gen related_year`j'=ydummy`i'*related
}

reghdfe loutput related_year2001-related_year2005 related_year2007-related_year2010 ///
[pweight=_webal] ,absorb(firmid ind2_year province_year) cluster(firmid)
parmest,saving("$revision/Appendix_Figure/dta/FigureA15_A.dta",replace)

*Figure

use "$revision/Appendix_Figure/dta/FigureA15_A.dta",clear
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
graph export "$revision/Appendix_Figure/FigureA15_A.pdf", replace

*-------------------
* Panel B: Placebo
*-------------------

use "$revision/Data/TableA22.dta",clear

*Treat & Control

merge m:1 firmid using "$revision/Data/Entropy_Matching/Entropy_Matching_Result_Placebo.dta"
keep if _merge==3
drop _merge

*Drop Extreme Values

replace year=2010 if year==2011
xtset firmid year
gen growth=(loutput-l.loutput)/l.loutput
gen growth2=growth
winsor2 growth, trim replace
drop if growth==. & growth2!=.
drop growth growth2
replace year=2011 if year==2010
xtset firmid year

*Dynamics

set more off
tab year, gen (ydummy)

forvalues i=1(1)10 {
   local j=2000+`i'
   gen related_year`j'=ydummy`i'*related
}

reghdfe loutput related_year2001-related_year2005 related_year2007-related_year2010 ///
[pweight=_webal] ,absorb(firmid ind2_year province_year) cluster(firmid)
parmest,saving("$revision/Appendix_Figure/dta/FigureA15_B.dta",replace)

*Figure

use "$revision/Appendix_Figure/dta/FigureA15_B.dta",clear
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
graph export "$revision/Appendix_Figure/FigureA15_B.pdf", replace

*----------------------
* Panel C: Energy Use
*----------------------

use "$revision/Data/TableA23.dta",clear

*Treat & Control

merge m:1 firmid using "$revision/Data/Entropy_Matching/Entropy_Matching_Result_Energy.dta"
keep if _merge==3
drop _merge

*Dynamics

set more off
tab year, gen (ydummy)

forvalues i=1(1)10 {
   local j=2000+`i'
   gen related_year`j'=ydummy`i'*related
}

reghdfe lenergy related_year2001-related_year2005 related_year2007-related_year2010 ///
[pweight=_webal] ,absorb(firmid ind2_year province_year) cluster(firmid)
parmest,saving("$revision/Appendix_Figure/dta/FigureA15_C.dta",replace)

*Figure

use "$revision/Appendix_Figure/dta/FigureA15_C.dta",clear
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
xlabel(2001(1)2010,valuelabel) ylabel(-0.3(0.3)0.6,valuelabel)  ///
xtitle("") ytitle("") legend( label(1 "Estimate") label(2 "95% CI"))
graph export "$revision/Appendix_Figure/FigureA15_C.pdf", replace

*----------------------------
* Panel D: Energy Efficiency
*----------------------------

use "$revision/Data/TableA23.dta",clear

*Treat & Control

merge m:1 firmid using "$revision/Data/Entropy_Matching/Entropy_Matching_Result_Energy.dta"
keep if _merge==3
drop _merge

*Dynamics

set more off
tab year, gen (ydummy)

forvalues i=1(1)10 {
   local j=2000+`i'
   gen related_year`j'=ydummy`i'*related
}

reghdfe lefficiency related_year2001-related_year2005 related_year2007-related_year2010 ///
[pweight=_webal] ,absorb(firmid ind2_year province_year) cluster(firmid)
parmest,saving("$revision/Appendix_Figure/dta/FigureA15_D.dta",replace)

*Figure

use "$revision/Appendix_Figure/dta/FigureA15_D.dta",clear
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
xlabel(2001(1)2010,valuelabel) ylabel(-0.6(0.3)0.6,valuelabel)  ///
xtitle("") ytitle("") legend( label(1 "Estimate") label(2 "95% CI"))
graph export "$revision/Appendix_Figure/FigureA15_D.pdf", replace

