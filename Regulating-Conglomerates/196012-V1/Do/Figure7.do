
*Figure 7: Welfare Effects of Alternative Policies 

****** Import results from matlab model solution 
clear
import delimited "$revision/Structural_Analysis/Counterfactual Baseline/results.txt", delimiter("   ", asstring) 
****** Clean data and make it into percentage changes
drop v1
rename v2 phi 
rename v3 xi 

foreach var in v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15  { 
	replace `var'=-ln(`var')*100
} 

****** Some computations 
** Recall overall emissions in China 6.38 billion tons of carbon 
** And national income ($2.752 trillion, USD)

** Determine Break even Kappa
local kb = -v4[10]/v5[10] 
di `kb'
local kb = `kb'/(1+`kb')
di `kb'
** GWTP for Top 1,000 program 
local kb = round(`kb'/(  6.38/(2.752*1000)*1.25  ) ,1)
di `kb'


***** Aggregate savings 
* aggregate energy use in industry 
di 670/.56
* aggregate saving from Top 1000 
di 670/.56*v5[10]/100
* aggregate saving from conglomerate level regulation at same price increase 
di 670/.56*(-v4[10])/(100*.8)


local kappa1 = 51*6.38/(2.725*1000)*1.25
local kappa2 = 125*6.38/(2.752*1000)*1.25
local kappa3 = `kb'*6.38/(2.752*1000)*1.25
local kappa4 = 210*6.38/(2.752*1000)*1.25
di `kappa1'

** 151 number from universal energy tax 
di .8/(1+.8)/(6.38/(2.752*1000)*1.25)


*------------------
* Panel A: Output
*------------------

* 4 Or vary both   with double labels 
twoway  (function y = -(`kappa1'/(1-`kappa1'))*x, range(0 7) lcolor(black) ) ///
	(function y = -(`kappa2'/(1-`kappa2'))*x, range(0 7) lcolor(black) ) ///
	(function y = -(`kappa3'/(1-`kappa3'))*x, range(0 7) lcolor(black) ) ///
	(function y = -(`kappa4'/(1-`kappa4'))*x, range(0 3.75) lcolor(black) ) ///
	(scatter v4 v5 if inrange(xi,.78,.82), connect(line) msize(large) mcolor(navy) lcolor(navy) lwidth(thick)) ///
	(scatter v4 v5 if inrange(phi,9.3,9.4), connect(line) msize(large) msym(square) mcolor(maroon) lcolor(maroon) lpattern(dash) lwidth(medthick)) ///
	(scatter v4 v5 if inrange(phi,9.3,9.4) & inrange(xi,.78,.82) , connect(line)  msize(vlarge)  msym(diamond) mcolor(red) connect(line) lwidth(thick) ) ///
	, ytitle("Welfare Cost of Price Increase" "-ln(P/P{sup:*})") ///
	xtitle("Reduction in Energy Use" "ln(E/E{sup:*})") ///
	legend(pos(6) order(5 "Varying Regulation" "Threshold {&phi}{sup:{&sim}}" ///
	6 "Varying Regulation" "Intensity {&xi}" ) ///
	cols(2) region(col(white))  ) ///
	graphregion(fcolor(white)) graphregion(color(white)) ///
	plotregion(fcolor(white) lcolor(white)) ///
	text(-.9 6.65 "GWTP=$51") text(-3.25 6.65 "GWTP=$125") text(-5.1 6.65 "GWTP=$161") text(-6 4.3 "GWTP=$210") ///
	text(-3.5 3.25 "Top 1,000{&rarr}") xlab(0(2)7) ///
	text(-3.8 3.75 "20%")  text(-5.275 5.2 "30%")  text(-1.15 1 "5%") ///
	text(-3.15 4.1 "56%")  text(-3.8 4.76 "60%")  text(-2.7 3.55 "50%")
	
graph export "$revision/Figure/Figure7_A.pdf", replace 	
	
local y1 = v4[10]
di `y1'
local x1 = round(v5[10],.01)
local x2 = round(-v4[10]/.80,.01)
di `x1'
di `x2'

*------------------
* Panel B: Output
*------------------

* 7 - Compare to regulation of conglomerate and taxes 
twoway  (function y = -(`kappa3'/(1-`kappa3'))*x, range(0 7) lcolor(black) yline(`y1', lcolor(gs11) lpattern(dash)) ///
	xline(`x1', lcolor(gs11) lpattern(dash)) xline(`x2', lcolor(gs11) lpattern(dash))) ///
	(scatter v6 v7 if inrange(phi,9.3,9.4) & v7<10, connect(line)  msize(huge) msym(plus) mcolor(orange) lcolor(orange) ) ///
	(scatter v8 v9 if inrange(phi,9.3,9.4) & v9<10, connect(line) msize(large) msym(Oh) mcolor(green) lcolor(green) lpattern(dash) lwidth(medthick)) ///
	(scatter v4 v5 if inrange(phi,9.3,9.4) & inrange(xi,.78,.82) , connect(line)  msize(vlarge)  msym(diamond) mcolor(red) connect(line) lwidth(thick) ) ///
	(function y = -0.8*x, range(0 7) lcolor(black) lpattern(dash) lwidth(medthick)) ///
	, ytitle("Welfare Cost of Price Increase" "-ln(P/P{sup:*})") ///
	xtitle("Reduction in Energy Use" "ln(E/E{sup:*})") ///
	legend(pos(6) order(2 "Conglomerate-level" "Regulation"  ///
	3 "Size-dependent" "Energy Tax" ) ///
	cols(2) region(col(white))  ) ///
	graphregion(fcolor(white)) graphregion(color(white)) ///
	plotregion(fcolor(white) lcolor(white)) ///
	text(-6 5.95 "GWTP=$161{&rarr}")  ///
	text(-3.5 3.25 "Top 1,000{&rarr}") xlab(0(2)7) ///
	text(-0.1 3.65 "3.96{&rarr}") text(-0.1 4.65 "{&larr}4.36") ///
	text(-4.25 6.25 "Universal" "{&larr}Energy Tax" "       GWTP=$153")

graph export "$revision/Figure/Figure7_B.pdf", replace 


** Generate breakeven kappa 
gen kb_firm = -v4/v5
gen kb_cong = -v6/v7
gen kb_tax = -v8/v9

gen kb2_firm = kb_firm/(1+kb_firm)
gen kb2_cong = kb_cong/(1+kb_cong)
gen kb2_tax = kb_tax/(1+kb_tax)

gen ssc_firm = round(kb2_firm/(6.38/(2.752*1000)*1.25 ))
gen ssc_cong = round(kb2_cong/(6.38/(2.752*1000)*1.25 ))
gen ssc_tax = round(kb2_tax/(6.38/(2.752*1000)*1.25 ))

li ssc* if inrange(xi,0.79,0.81) & inrange(phi,9,10)

** 151 number from universal energy tax 
di round(.8/(1+.8)/(6.38/(2.752*1000)*1.25))
