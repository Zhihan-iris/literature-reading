
*Figure A.21 Welfare Effects: Additional Robustness to Differences in Energy Efficiency

****** Import results from matlab model solution 
clear all 
import delimited "$revision/Structural_Analysis/Heterogeneous EE/results_robust.txt", delimiter("  ", asstring) 
****** Clean data and make it into percentage changes
drop v1
rename v2 nu_O
rename v3 nu_R
rename v4 P 
rename v5 E 

foreach var in P E  { 
	replace `var'=-ln(`var')*100
} 

gen SCC = round((-P/E)/(1+-P/E)*.8*(2.752*1000)/6.38)
gen kappa = P/E

twoway  (function y = kappa[5]*x, range(0 8) lcolor(gs11)) /// 	
	(function y = kappa[4]*x, range(0 8) lcolor(gs11)) /// 	
	(function y = kappa[3]*x, range(0 4.1) lcolor(gs11)) /// 	
	(function y = kappa[2]*x, range(0 2.55) lcolor(gs11)) /// 	
	(function y = kappa[1]*x, range(0 8) lcolor(black)) /// 		
	(scatter P E  in 1 , msize(large)  msym(diamond) mcolor(red)  ) ///
	(scatter P E  if _n!= 1 , msize(large)  msym(T) mcolor(navy)  ) ///
	, ytitle("Welfare Cost of Price Increase" "-ln(P/P{sup:*})") ///
	xtitle("Reduction in Energy Use" "ln(E/E{sup:*})") ///
	legend(off)  ///
	graphregion(fcolor(white)) graphregion(color(white)) ///
	plotregion(fcolor(white) lcolor(white)) ///
	xlab(0(2)8) ylab(-8(2)0) ///
	text(-3.5 3.25 "Baseline{&rarr}") text(-4.8 2.95 "{&nu}{sub:R}=0.5") text(-5.4 1.25 "{&nu}{sub:R}=0.5" "{&nu}{sub:O}=0.5") ///
	text(-3 5.75 "{&nu}{sub:R}=1.5") text(-2.1 5.65 "{&nu}{sub:R}=1.5" "{&nu}{sub:O}=1.5") ///
	text(-7.2 7.5 "GWTP=$161") text(-7.9 4.65 "GWTP=$228")  text(-7.9 1.9 "GWTP=$261") ///
	text(-4 7.5 "GWTP=$112")  text(-3 7.5 "GWTP=$107") 	

graph export "$revision/Appendix_Figure/FigureA21.pdf", replace 
