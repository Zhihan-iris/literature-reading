
* Figure A.22 Size Distribution of Firms Related to Top 10,000 Firms

use "$revision/Data/TableA37.dta",clear

keep if year==2011
keep if output!=0
replace output=output/1000
gen loutput=ln(output)

sum loutput if top10000_related==1 & top1000_industry==1 & top1000!=1 & top1000_related!=1,d
local f=r(p90)

tw (hist loutput if top10000_related==1 & top1000_industry==1 & top1000!=1 & top1000_related!=1,bin(50) bcolor(green%20) frac) ///
(hist loutput if top1000_related==1,bin(50) bcolor(blue%20) frac), ///
graphregion(color(white)) xtitle("") legend(r(1) pos(6) label(1 "Top10,000 Related") label(2 "Top1,000 Related")) ///
text(0.085 8.6 "90% of Top10,000 Related",size(small)) ///
xline(`f',lcolor(black) lpattern(dash))

graph export "$revision/Appendix_Figure/FigureA22.pdf", replace
