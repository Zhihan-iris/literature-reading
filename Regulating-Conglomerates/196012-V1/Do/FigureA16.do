
*Figure A.16: Robustness to Dropping Electric Power Generation and Supply

*Treat & Control

use "$revision/Data/Table2_1.dta",clear

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Output_Related.dta"
drop if _merge==2
drop _merge

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Output_Control.dta",update
drop if _merge==2
drop _merge

keep if related==1 | control==1
replace related=0 if related==.
replace control=0 if control==.

*Drop Electric Power Generation and Supply Industry

gen ind3=int(ind4/10)
keep if ind3!=441 & ind3!=442

*Dynamics

tab year, gen (ydummy)

forvalues i=1(1)10 {
   local j=2000+`i'
   gen related_year`j'=ydummy`i'*related
}

reghdfe loutput related_year2001-related_year2005 related_year2007-related_year2010 ///
[fweight=weight],absorb(firmid year) cluster(firmid)
parmest,saving("$revision/Appendix_Figure/dta/FigureA16.dta",replace)

*Figure

use "$revision/Appendix_Figure/dta/FigureA16.dta",clear
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
xlabel(2001(1)2011,valuelabel) ylabel(-0.1(0.1)0.4,valuelabel)  ///
xtitle("") ytitle("") legend( label(1 "Estimate") label(2 "95% CI"))
graph export "$revision/Appendix_Figure/FigureA16.pdf", replace
