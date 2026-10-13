
*Figure A.14: Substitution Effects of the Program on Regulated Firms

use "$revision/Data/Table1.dta",clear

keep if lnkl!=. & lnel!=. & lnek!=. 

tab year, gen(ydummy)
forvalues i=1(1)9 {
      local j=2000+`i'
      gen treat_year`j'=ydummy`i'*top1000
      }

local treat_yeardummy "treat_year2001-treat_year2005 treat_year2007-treat_year2009"
local absorb3 "firmid ind2_year province_year"
local cluster "firmid"

reghdfe lnkl `treat_yeardummy', absorb(`absorb3') cluster(`cluster')
parmest,saving("$revision/Appendix_Figure/dta/FigureA14_A.dta",replace)

reghdfe lnel `treat_yeardummy', absorb(`absorb3') cluster(`cluster')
parmest,saving("$revision/Appendix_Figure/dta/FigureA14_B.dta",replace)

reghdfe lnek `treat_yeardummy', absorb(`absorb3') cluster(`cluster')
parmest,saving("$revision/Appendix_Figure/dta/FigureA14_C.dta",replace)

********************************
* Panel A. Capital Labor Ratio
********************************

use "$revision/Appendix_Figure/dta/FigureA14_A.dta",clear
gen x=length(parm)
keep if x==14
gen year=substr(parm,11,.)
destring year,replace
keep year estimate min95 max95
set obs 9
replace year = 2006 in 9
replace estimate = 0 if year==2006
order year estimate min95 max95
sort year
graph tw (scatter estimate year, color(navy) msymbol(circle)) ///
(rcap min95 max95 year, lp(solid) msymbol(none) color(navy)) ///
, scheme(s1mono) graphregion(fcolor(white) lcolor(none) ifcolor(white) ///
ilcolor(none)) plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
xline(2006,lp(solid)) yline(0,lp(solid) lcolor(cranberry)) ///
xlabel(2001(1)2009,valuelabel) ylabel(-0.3(0.1)0.3,valuelabel) ///
xtitle("") ytitle("") legend( label(1 "Estimate") label(2 "95% CI"))
graph export "$revision/Appendix_Figure/FigureA14_A.pdf", replace

********************************
* Panel B: Energy Labor Ratio
********************************

use "$revision/Appendix_Figure/dta/FigureA14_B.dta",clear
gen x=length(parm)
keep if x==14
gen year=substr(parm,11,.)
destring year,replace
keep year estimate min95 max95
set obs 9
replace year = 2006 in 9
replace estimate = 0 if year==2006
order year estimate min95 max95
sort year
graph tw (scatter estimate year, color(navy) msymbol(circle)) ///
(rcap min95 max95 year, lp(solid) msymbol(none) color(navy)) ///
, scheme(s1mono) graphregion(fcolor(white) lcolor(none) ifcolor(white) ///
ilcolor(none)) plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
xline(2006,lp(solid)) yline(0,lp(solid) lcolor(cranberry)) ///
xlabel(2001(1)2009,valuelabel) ylabel(-0.3(0.1)0.3,valuelabel) ///
xtitle("") ytitle("") legend( label(1 "Estimate") label(2 "95% CI"))
graph export "$revision/Appendix_Figure/FigureA14_B.pdf", replace

********************************
* Panel C: Energy Capital Ratio
********************************

use "$revision/Appendix_Figure/dta/FigureA14_C.dta",clear
gen x=length(parm)
keep if x==14
gen year=substr(parm,11,.)
destring year,replace
keep year estimate min95 max95
set obs 9
replace year = 2006 in 9
replace estimate = 0 if year==2006
order year estimate min95 max95
sort year
graph tw (scatter estimate year, color(navy) msymbol(circle)) ///
(rcap min95 max95 year, lp(solid) msymbol(none) color(navy)) ///
, scheme(s1mono) graphregion(fcolor(white) lcolor(none) ifcolor(white) ///
ilcolor(none)) plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
xline(2006,lp(solid)) yline(0,lp(solid) lcolor(cranberry)) ///
xlabel(2001(1)2009,valuelabel) ylabel(-0.3(0.1)0.3,valuelabel) ///
xtitle("") ytitle("") legend( label(1 "Estimate") label(2 "95% CI"))
graph export "$revision/Appendix_Figure/FigureA14_C.pdf", replace
