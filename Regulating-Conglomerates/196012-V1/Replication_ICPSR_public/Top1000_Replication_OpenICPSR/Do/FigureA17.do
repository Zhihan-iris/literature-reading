
*Figure A.17 Data Quality Robustness

*===========================
* Panel A. Regulated Firms
*===========================

use "$revision/Data/Table1.dta",clear

*Data Cleaning

winsor2 loutput loutput_robust2, trim replace cut(5 95)

gen diff=(exp(loutput_robust2)-exp(loutput))/exp(loutput)
_pctile diff, p(5 95)
local a=r(r1)
local b=r(r2)
gen outlier=1 if (diff<`a'| diff>`b') & diff!=.
xtset firmid year
xfill outlier
drop if outlier==1

tab year, gen(ydummy)
forvalues i=1(1)10 {
      local j=2000+`i'
      gen treat_year`j'=ydummy`i'*top1000
      }
	  
local treat_yeardummy "treat_year2001-treat_year2005 treat_year2007-treat_year2010"
local absorb3 "firmid ind2_year province_year"
local cluster "firmid"

reghdfe loutput_ASIF `treat_yeardummy' if year<2009, absorb(`absorb3') cluster(`cluster')
parmest,saving("$revision/Appendix_Figure/dta/FigureA17_A1.dta",replace)

reghdfe loutput_robust2 `treat_yeardummy' , absorb(`absorb3') cluster(`cluster')
parmest,saving("$revision/Appendix_Figure/dta/FigureA17_A2.dta",replace)

*========================
* Panel B. Related Firms
*========================

*------------
* Drop 2009
*------------

use "$revision/Data/Table2_1.dta",clear

drop if year==2009

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Output_Related.dta"
drop if _merge==2
drop _merge

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Output_Control.dta",update
drop if _merge==2
drop _merge

keep if related==1 | control==1
replace related=0 if related==.
replace control=0 if control==.

tab year, gen (ydummy)

forvalues i=1(1)9 {
   local j=2000+`i'
   gen related_year`j'=ydummy`i'*related
}

reghdfe loutput related_year2001-related_year2005 related_year2007-related_year2009 ///
[fweight=weight] ,absorb(firmid year) cluster(firmid)
parmest,saving("$revision/Appendix_Figure/dta/FigureA17_B1.dta",replace)

*----------------------------------
* Fill in 2009-2010 with Tax Data
*----------------------------------

use "$revision/Data/TableA26_B.dta",clear

tab year, gen (ydummy)

forvalues i=1(1)11 {
   local j=2000+`i'
   gen related_year`j'=ydummy`i'*related
}

reghdfe loutput related_year2001-related_year2005 related_year2007-related_year2011 ///
[fweight=weight] ,absorb(firmid year) cluster(firmid)
parmest,saving("$revision/Appendix_Figure/dta/FigureA17_B2.dta",replace)

*==================
* Panel C. Placebo
*==================

*------------
* Drop 2009
*------------

use "$revision/Data/Table2_1.dta",clear

drop if year==2009

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Placebo_Related.dta"
drop if _merge==2
drop _merge

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Placebo_Control.dta",update
drop if _merge==2
drop _merge

keep if related==1 | control==1
replace related=0 if related==.
replace control=0 if control==.

*Drop Outliers

replace year=2009 if year==2011
xtset firmid year
gen growth=(output-l.output)/l.output
gen growth_raw=growth
winsor2 growth, trim replace
drop if growth==. & growth_raw!=.
drop growth growth_raw
replace year=2011 if year==2009
xtset firmid year

tab year, gen (ydummy)

forvalues i=1(1)9 {
   local j=2000+`i'
   gen related_year`j'=ydummy`i'*related
}

reghdfe loutput related_year2001-related_year2005 related_year2007-related_year2009 ///
[fweight=weight] ,absorb(firmid year) cluster(firmid)
parmest,saving("$revision/Appendix_Figure/dta/FigureA17_C1.dta",replace)


*----------------------------------
* Fill in 2009-2010 with Tax Data
*----------------------------------

use "$revision/Data/TableA26_C.dta",clear

tab year, gen (ydummy)

forvalues i=1(1)11 {
   local j=2000+`i'
   gen related_year`j'=ydummy`i'*related
}

reghdfe loutput related_year2001-related_year2005 related_year2007-related_year2011 ///
[fweight=weight] ,absorb(firmid year) cluster(firmid)
parmest,saving("$revision/Appendix_Figure/dta/FigureA17_C2.dta",replace)

*-----------
*  Figure
*-----------

use "$revision/Appendix_Figure/dta/FigureA17_A1.dta",clear
gen x=length( parm )
keep if x==14
gen year=substr(parm,11,.)
destring year,replace
keep year estimate min95 max95
set obs 10
replace year = 2006 in 10
replace estimate = 0 if year==2006
order year estimate min95 max95
sort year
replace year=year-0.15 if year!=2006
gen type=2
save "$revision/Appendix_Figure/dta/FigureA17_A1.dta",replace

use "$revision/Appendix_Figure/dta/FigureA17_A2.dta",clear
gen x=length( parm )
keep if x==14
gen year=substr(parm,11,.)
destring year,replace
keep year estimate min95 max95
set obs 10
replace year = 2006 in 10
replace estimate = 0 if year==2006
order year estimate min95 max95
sort year
replace year=year+0.15 if year!=2006
gen type=3
save "$revision/Appendix_Figure/dta/FigureA17_A2.dta",replace

use "$revision/Figure/dta/Figure3_C.dta",clear
gen x=length(parm)
keep if x==14
gen year=substr(parm,11,.)
destring year,replace
keep year estimate min95 max95
set obs 10
replace year = 2006 in 10
replace estimate = 0 if year==2006
order year estimate min95 max95
sort year
gen type=1

append using "$revision/Appendix_Figure/dta/FigureA17_A1.dta"
append using "$revision/Appendix_Figure/dta/FigureA17_A2.dta"

graph tw (scatter estimate year if type==1, color(navy) msymbol(smcircle)) ///
(rcap min95 max95 year if type==1,lp(solid) msymbol(none) color(navy)) ///
(scatter estimate year if type==2, color(orange) msymbol(smsquare_hollow)) ///
(rcap min95 max95 year if type==2,lp(solid) msymbol(none) color(orange)) ///
(scatter estimate year if type==3, color(green) msymbol(smtriangle)) ///
(rcap min95 max95 year if type==3,lp(solid) msymbol(none) color(green)) ///
, scheme(s1mono) graphregion(fcolor(white) lcolor(none) ifcolor(white) ///
ilcolor(none)) plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
xline(2006,lp(solid)) yline(0,lp(solid) lcolor(cranberry)) ///
xlabel(2001(1)2010,valuelabel)  ylabel(-0.5(0.1)0.3,valuelabel)  ///
xtitle("") ytitle("") legend( label(1 "Estimate for Baseline") label(2 "95% CI for Baseline") ///
label(3 "Estimate for Leaving out 2009") label(4 "95% CI for Leaving out 2009") ///
label(5 "Estimate for Filling in 2009-2010") label(6 "95% CI for Filling in 2009-2010"))
graph export "$revision/Appendix_Figure/FigureA17_A.pdf", replace


use "$revision/Appendix_Figure/dta/FigureA17_B1.dta",clear
gen x=length( parm )
keep if x==16
gen year=substr(parm,13,.)
destring year,replace
keep year estimate min95 max95
replace year=2011 if year==2009
set obs 9
replace year = 2006 in 9
replace estimate = 0 if year==2006
order year estimate min95 max95
sort year
replace year=year-0.15 if year!=2006
gen type=2
save "$revision/Appendix_Figure/dta/FigureA17_B1.dta",replace

use "$revision/Appendix_Figure/dta/FigureA17_B2.dta",clear
gen x=length( parm )
keep if x==16
gen year=substr(parm,13,.)
destring year,replace
keep year estimate min95 max95
set obs 11
replace year = 2006 in 11
replace estimate = 0 if year==2006
order year estimate min95 max95
sort year
replace year=year+0.15 if year!=2006
gen type=3
save "$revision/Appendix_Figure/dta/FigureA17_B2.dta",replace


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
gen type=1

append using "$revision/Appendix_Figure/dta/FigureA17_B1.dta"
append using "$revision/Appendix_Figure/dta/FigureA17_B2.dta"

graph tw (scatter estimate year if type==1, color(navy) msymbol(smcircle)) ///
(rcap min95 max95 year if type==1,lp(solid) msymbol(none) color(navy)) ///
(scatter estimate year if type==2, color(orange) msymbol(smsquare_hollow)) ///
(rcap min95 max95 year if type==2,lp(solid) msymbol(none) color(orange)) ///
(scatter estimate year if type==3, color(green) msymbol(smtriangle)) ///
(rcap min95 max95 year if type==3,lp(solid) msymbol(none) color(green)) ///
, scheme(s1mono) graphregion(fcolor(white) lcolor(none) ifcolor(white) ///
ilcolor(none)) plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
xline(2006,lp(solid)) yline(0,lp(solid) lcolor(cranberry)) ///
xlabel(2001(1)2011,valuelabel)  ylabel(-0.1(0.1)0.4,valuelabel)  ///
xtitle("") ytitle("") legend( label(1 "Estimate for Baseline") label(2 "95% CI for Baseline") ///
label(3 "Estimate for Leaving out 2009") label(4 "95% CI for Leaving out 2009") ///
label(5 "Estimate for Filling in 2009-2010") label(6 "95% CI for Filling in 2009-2010"))
graph export "$revision/Appendix_Figure/FigureA17_B.pdf", replace


*Placebo
use "$revision/Appendix_Figure/dta/FigureA17_C1.dta",clear
gen x=length( parm )
keep if x==16
gen year=substr(parm,13,.)
destring year,replace
keep year estimate min95 max95
replace year=2011 if year==2009
set obs 9
replace year = 2006 in 9
replace estimate = 0 if year==2006
order year estimate min95 max95
sort year
replace year=year-0.15 if year!=2006
gen type=2
save "$revision/Appendix_Figure/dta/FigureA17_C1.dta",replace

use "$revision/Appendix_Figure/dta/FigureA17_C2.dta",clear
gen x=length( parm )
keep if x==16
gen year=substr(parm,13,.)
destring year,replace
keep year estimate min95 max95
set obs 11
replace year = 2006 in 11
replace estimate = 0 if year==2006
order year estimate min95 max95
sort year
replace year=year+0.15 if year!=2006
gen type=3
save "$revision/Appendix_Figure/dta/FigureA17_C2.dta",replace

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
gen type=1

append using "$revision/Appendix_Figure/dta/FigureA17_C1.dta"
append using "$revision/Appendix_Figure/dta/FigureA17_C2.dta"

graph tw (scatter estimate year if type==1, color(navy) msymbol(smcircle)) ///
(rcap min95 max95 year if type==1,lp(solid) msymbol(none) color(navy)) ///
(scatter estimate year if type==2, color(orange) msymbol(smsquare_hollow)) ///
(rcap min95 max95 year if type==2,lp(solid) msymbol(none) color(orange)) ///
(scatter estimate year if type==3, color(green) msymbol(smtriangle)) ///
(rcap min95 max95 year if type==3,lp(solid) msymbol(none) color(green)) ///
, scheme(s1mono) graphregion(fcolor(white) lcolor(none) ifcolor(white) ///
ilcolor(none)) plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
xline(2006,lp(solid)) yline(0,lp(solid) lcolor(cranberry)) ///
xlabel(2001(1)2011,valuelabel)  ylabel(-0.1(0.1)0.4,valuelabel)  ///
xtitle("") ytitle("") legend( label(1 "Estimate for Baseline") label(2 "95% CI for Baseline") ///
label(3 "Estimate for Leaving out 2009") label(4 "95% CI for Leaving out 2009") ///
label(5 "Estimate for Filling in 2009-2010") label(6 "95% CI for Filling in 2009-2010"))
graph export "$revision/Appendix_Figure/FigureA17_C.pdf", replace

*Erase Temp File

erase "$revision/Data/TableA26_B.dta"
erase "$revision/Data/TableA26_C.dta"
