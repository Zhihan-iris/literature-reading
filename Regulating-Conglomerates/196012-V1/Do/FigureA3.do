
*Figure A.3 : Shadow Cost of Regulation 

****** Import results from matlab model solution 
clear
import delimited "$revision/Structural_Analysis/Counterfactual Baseline/results_graphs.txt", delimiter("   ", asstring) 
****** Clean data and make it into percentage changes
drop v1
rename v3 phi_n
rename v4 phi_t 

foreach var in v2 v5 v6 v7 v8 v9 { 
	replace `var'=(`var'-1)*100
}

gen phi_n2 = phi_n 
replace phi_n2 = phi_t[6] if _n == 6 

foreach var in v2 v5 v6 v7 v8 v9   { 
	replace `var'= 0 if phi_n2 < phi_t
} 

set obs 12
foreach var in v2 v5 v6 v7 v8 v9   { 
	replace `var'= 0 if _n == 12 
} 
replace phi_n2 = phi_n2[6] if _n == 12
replace phi_n2 = 50 if phi_n2 > 50 

sort phi_n2 v2 phi_n 

local phit = phi_t[1]


*------------------
* Panel A: Output
*------------------
twoway (line v2 phi_n2 , lwidth(medthick) lcolor(navy)) /// 
	(line v6 phi_n2 , lwidth(medthick) lcolor(maroon) ) /// 
	(line v7 phi_n2 , lwidth(medthick) lpattern(dash) ) /// 
	(line v8 phi_n2 , lwidth(medthick)  ) /// 
	(line v9 phi_n2 , lwidth(medthick) xline(`phit' , lcolor(black) lpattern(dash) ))   ///
	, ytitle("Shadow Cost of Regulation" "{&lambda}({&phi})") ///
	xtitle("Conglomerate Productivity" "{&phi}") ///
	legend(off) ///
	graphregion(fcolor(white)) graphregion(color(white)) ///  
	plotregion(fcolor(white)) ///
	ylab(0(2.5)20) ///
	text(20 9 "Regulation Threshold") ///
	text(5.4 35 "Conglomerate Regulation") ///
	text(4.3 35 "Energy Tax") ///
	text(9.2 35 "Top 1,000 Program") ///
	text(16.1 35 "No Spillover") /// 
	text(11.8 35 "No Conglomerate Spillover") 

graph export "$revision/Appendix_Figure/FigureA3_A.pdf", replace 

*------------------
* Panel B: Output
*------------------

** variation in shadow cost 		
keep if v2 > 0 	& phi_n < 60
local sc1 = v2[1]
local sc2 = v2[2]
local sc3 = v2[3]
local sc4 = v2[4]

local p1 = phi_n[1]
local p2 = phi_n[2]
local p3 = phi_n[3]
local p4 = phi_n[4]
		
twoway (function y = `sc1'*(x<`p1') + `sc2'*(x<`p2' & x>`p1') + `sc3'*(x<`p3' & x>`p2')  + `sc4'*(x<`p4' & x>`p3')  , ///
	xline(`p1' `p2' `p3' `p4' ) lwidth(medthick) /// 
 	range(9.3 `p4') ) /// 
	, ytitle("Shadow Cost of Regulation" "{&lambda}({&phi})") ///
	xtitle("Conglomerate Productivity" "{&phi}") ///
	legend(off) ///
	graphregion(fcolor(white)) graphregion(color(white)) ///
	plotregion(fcolor(white) lcolor(white)) ylab(8.67(.005)8.7) ///
	text(8.7 30.75 "Conglomerate Size Thresholds") 

graph export "$revision/Appendix_Figure/FigureA3_B.pdf", replace 



