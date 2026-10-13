
*Figure A.6: Data Comparison: ASIF, CESD, Tax Data

**********************************************
*Panel A. Comparison of Output Data,2001-2010
**********************************************

use "$revision/Data/Table1.dta",clear

keep if loutput!=. & loutput_robust!=.
winsor2 loutput loutput_robust, trim replace cut(5 99)

binscatter loutput_robust loutput, nq(100) ///
ytitle("ln(Output): ASIF & Tax Data") xtitle("ln(Output): CESD Data") ///
xlabel(8(2)16,valuelabel) ylabel(8(2)16,valuelabel nogrid) linetype(none)
addplot: function y=x,range(8 16) lp(dash) ///
text(8.7 10 "45 degree line", color(maroon)) ///
graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))

graph export "$revision/Appendix_Figure/FigureA6_A.pdf",replace

********************************************************
*Panel B. Comparison of Coal Consumption Data,2007-2010
********************************************************

use "$revision/Data/Table1.dta",clear

keep if lcoal!=. & lcoal_robust!=.
winsor2 lcoal lcoal_robust, trim replace cut(5 99)

binscatter lcoal_robust lcoal , nq(100) ///
ytitle("ln(Coal Consumption): Tax Data") xtitle("ln(Coal Consumption): CESD Data") ///
xlabel(6(2)16,valuelabel) ylabel(6(2)16,valuelabel nogrid) linetype(none)
addplot: function y=x,range(6 16) lp(dash) ///
text(7 8.5 "45 degree line", color(maroon)) ///
graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))

graph export "$revision/Appendix_Figure/FigureA6_B.pdf",replace
