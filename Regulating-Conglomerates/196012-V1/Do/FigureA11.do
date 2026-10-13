
*Figure A.11: Effects of Policy on the Investment of Regulated Firms

use "$revision/Data/TableA14.dta",clear

tab year, gen(ydummy)
forvalues i=1(1)10 {
      local j=2000+`i'
      gen treat_year`j'=ydummy`i'*top1000
      }

local treat_yeardummy "treat_year2001-treat_year2005 treat_year2007-treat_year2010"
local absorb3 "firmid ind2_year province_year"
local cluster "firmid"

reghdfe investment_em `treat_yeardummy', absorb(`absorb3') cluster(`cluster')
parmest,saving("$revision/Appendix_Figure/dta/FigureA11.dta",replace)

use "$revision/Appendix_Figure/dta/FigureA11.dta",clear
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
graph tw (scatter estimate year, color(navy) msymbol(circle)) ///
(rcap min95 max95 year, lp(solid) msymbol(none) color(navy)) ///
, scheme(s1mono) graphregion(fcolor(white) lcolor(none) ifcolor(white) ///
ilcolor(none)) plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
xline(2006,lp(solid)) yline(0,lp(solid) lcolor(cranberry)) ///
xlabel(2001(1)2010,valuelabel)  ylabel(-0.2(0.1)0.2,valuelabel) ///
xtitle("") ytitle("") legend( label(1 "Estimate") label(2 "95% CI"))
graph export "$revision/Appendix_Figure/FigureA11.pdf", replace
