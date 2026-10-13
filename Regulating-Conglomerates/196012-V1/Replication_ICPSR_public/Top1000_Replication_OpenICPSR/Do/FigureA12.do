
* Figure A.12 Lack of Entry Effect

*------------------------------------------
* Panel A: Relative Size of New Affiliates
*------------------------------------------

use "$revision/Data/FigureA12_A.dta",clear

* Total Capital

egen capital1=total(capital) if (startyear<=2006 & type=="Related") | type=="Top1000"
egen capital2=total(capital) if startyear>2006 & type=="Related"

gen totalcapital=capital1 if startyear<=2006
replace totalcapital=capital2 if startyear>2006

duplicates drop totalcapital,force

gen type1="Registered Capital Before Policy" if startyear<=2006
replace type1="Registered Capital After Policy"  if startyear>2006

* Figure

graph pie totalcapital, over(type1) sort descending ///
pie(1,color("118 152 160")) pie(2,color("231 222 212")) ///
plabel(_all percent, color(navy) size(small) format(%2.0f) gap(5)) ///
legend(r(1) pos(6) color(navy) region(lcolor(white)) bmargin(medium)) ///
graphregion(fcolor(white)) 
graph export "$revision/Appendix_Figure/FigureA12_A.pdf", replace

*----------------------------------
* Panel B: New Affiliates by Year
*----------------------------------

use "$revision/Data/FigureA12_B.dta",clear

graph bar top1000_num top10000_num, over(startyear) ///
ytitle("Number of New Firms",size(medium small) margin(small)) ///
blabel(bar, position(outside) color(black)) ///
ylabel(0(50)200,nogrid) graphregion(color(white)) ///
legend(r(1) pos(6) label(1 "Top1,000 Related") label(2 "Top10,000 Related"))

graph export "$revision/Appendix_Figure/FigureA12_B.pdf", replace

*----------------------------------
* Panel C: Entry Rate Event Study
*----------------------------------

use "$revision/Data/FigureA12_C.dta",clear

tab startyear, gen(ydummy)
forvalues i=1(1)10 {
      local j=2000+`i'
      gen treat_year`j'=ydummy`i'*top1000
      }

local treat_yeardummy "treat_year2001-treat_year2005 treat_year2007-treat_year2010"

reghdfe entry_rate `treat_yeardummy', absorb(id ind2_year province_year) cluster(id)
parmest,saving("$revision/Appendix_Figure/dta/FigureA12_C.dta",replace)

use "$revision/Appendix_Figure/dta/FigureA12_C.dta",clear
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
xlabel(2001(1)2010,valuelabel) ylabel(-0.2(0.05)0.1,valuelabel) ///
xtitle("") ytitle("") legend(r(1) pos(6)  label(1 "Estimate") label(2 "95% CI"))
graph export "$revision/Appendix_Figure/FigureA12_C.pdf", replace
