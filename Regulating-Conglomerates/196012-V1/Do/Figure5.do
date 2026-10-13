
*Figure 5 : Industry-Level Spillovers and Within-Conglomerate Effects

* Industry-Level Spillovers

use "$revision/Data/Table3_1.dta",clear

tab year, gen(ydummy)
forvalues i=1(1)10 {
      local j=2000+`i'
      gen treat_year`j'=ydummy`i'*spillover
      }

local treat_yeardummy "treat_year2001-treat_year2005 treat_year2007-treat_year2010"
local absorb "firmid year"
local control "loutput_ind2 lenergy_ind2 soe roa age exp"
local if "if top1000_industry==1"
local cluster "ind2"

reghdfe loutput `treat_yeardummy' `control' `if', absorb(`absorb') cluster(`cluster')
parmest,saving("$revision/Figure/dta/Figure5_A.dta",replace)

use "$revision/Figure/dta/Figure5_A.dta",clear
gen x=length(parm)
keep if x==14
gen year=substr(parm,11,.)
destring year,replace
keep year estimate min95 max95
replace year=2011 if year==2010
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
xlabel(2001(1)2011,valuelabel)  ylabel(-0.2(0.1)0.3,valuelabel) ///
xtitle("") ytitle("") legend( label(1 "Estimate") label(2 "95% CI"))
graph export "$revision/Figure/Figure5_A.pdf", replace


* Within-Conglomerate Difference-in-Differences

use "$revision/Data/Table3_2.dta",clear

tab year, gen (ydummy)
forvalues i=1(1)10 {
local j=2000+`i'
gen treat_year`j'=ydummy`i'*top1000
}

local treat_yeardummy "treat_year2001-treat_year2005 treat_year2007-treat_year2010"
local absorb "conglomerate_year ind2_year province_year"
local cluster "conglomerate"

reghdfe loutput `treat_yeardummy' top1000, absorb(`absorb') cluster(`cluster')
parmest,saving("$revision/Figure/dta/Figure5_B.dta",replace)

use "$revision/Figure/dta/Figure5_B.dta",clear
gen x=length( parm )
keep if x==14
gen year=substr(parm,11,.)
destring year,replace
keep year estimate min95 max95
replace year=2011 if year==2010
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
xlabel(2001(1)2011,valuelabel)  ylabel(-0.6(0.3)0.6,valuelabel) ///
xtitle("") ytitle("") legend( label(1 "Estimate") label(2 "95% CI"))
graph export "$revision/Figure/Figure5_B.pdf", replace


