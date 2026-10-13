
*Figure A.2 : Welfare Effects of Alternative Policies 

*------------------
* Panel A: Output
*------------------

****** Import results from matlab model solution 
clear
import delimited "$revision/Structural_Analysis/Energy Efficiency/results.txt", delimiter("   ", asstring) 

****** Clean data and make it into percentage changes
drop v1
rename v2 gamma 

foreach var in v3 v4  { 
	replace `var'=-ln(`var')*100
} 
foreach var in v5 v6 { 
	replace `var' = `var'*100
}

gen SCC = round((-v3/v4)/(1+-v3/v4)*.8*(2.752*1000)/6.38)
gen kappa = v3/v4

twoway  (function y = kappa[6]*x, range(0 6.75) lcolor(black)) /// 
	(function y = kappa[4]*x, range(0 9.9) lcolor(gs11)) /// 	
	(function y = kappa[3]*x, range(0 12) lcolor(gs11)) /// 	
	(scatter v3 v4 in 6  , msize(large)  msym(diamond) mcolor(red)  ) ///
	(scatter v3 v4 if gamma > 3 & _n < 5 , msize(large)  msym(T) mcolor(navy)  ) ///
	, ytitle("Welfare Cost of Price Increase" "-ln(P/P{sup:*})") ///
	xtitle("Reduction in Energy Use" "ln(E/E{sup:*})") ///
	legend(off)  ///
	graphregion(fcolor(white)) graphregion(color(white)) ///
	plotregion(fcolor(white) lcolor(white)) ///
	xlab(0(2)12) ylab(-6(2)0) ///
	text(-3.5 2.8 "Baseline{&rarr}") text(-5.6 5.2 "GWTP=$161" "{&gamma}={&infin}") ///
	text(-5.6 10 "GWTP=$130" "{&gamma}=12.8") ///
	text(-4.76 11 "GWTP=$114" "{&gamma}=7.4") ///
	text(-2.7 6.3 "11.6%" )  text(-3.15 5.7 "10.4%" )  
	
graph export "$revision/Appendix_Figure/FigureA2_A.pdf", replace 	

*------------------
* Panel B: Output
*------------------

****** Import results from matlab model solution 
clear all 
import delimited "$revision/Structural_Analysis/Heterogeneous EE/results.txt", delimiter("  ", asstring) 
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

twoway  (function y = kappa[5]*x, range(0 6) lcolor(gs11)) /// 	
	(function y = kappa[4]*x, range(0 6) lcolor(gs11)) /// 	
	(function y = kappa[3]*x, range(0 4.7) lcolor(gs11)) /// 	
	(function y = kappa[2]*x, range(0 4.4) lcolor(gs11)) /// 	
	(function y = kappa[1]*x, range(0 6) lcolor(black)) /// 		
	(scatter P E  in 1 , msize(large)  msym(diamond) mcolor(red)  ) ///
	(scatter P E  if _n!= 1 , msize(large)  msym(T) mcolor(navy)  ) ///
	, ytitle("Welfare Cost of Price Increase" "-ln(P/P{sup:*})") ///
	xtitle("Reduction in Energy Use" "ln(E/E{sup:*})") ///
	legend(off)  ///
	graphregion(fcolor(white)) graphregion(color(white)) ///
	plotregion(fcolor(white) lcolor(white)) ///
	xlab(0(2)6) ylab(-6(2)0) ///
	text(-3.5 3.45 "Baseline{&rarr}") text(-3.9 3.5 "{&nu}{sub:R}=0.8") text(-4.5 2.8 "{&nu}{sub:R}=0.8" "{&nu}{sub:O}=0.8") ///
	text(-3.35 4.7 "{&nu}{sub:R}=1.2") text(-2.6 4.9 "{&nu}{sub:R}=1.2" "{&nu}{sub:O}=1.2") ///
	text(-5.35 5.75 "GWTP=$161") text(-5.9 5.2 "GWTP=$193")  text(-5.9 3.8 "GWTP=$199") ///
	text(-4.1 5.75 "GWTP=$137")  text(-3.2 5.75 "GWTP=$134") 

graph export "$revision/Appendix_Figure/FigureA2_B.pdf", replace 


*------------------
* Panel C: Output
*------------------

****** Imperfect Subsitution 
clear all 
import delimited "$revision/Structural_Analysis/Imperfect Sub/results.txt", delimiter("   ", asstring) 
****** Clean data and make it into percentage changes
drop v1
rename v2 v4 
rename v3 v5 
gen rho = 0.75
gen alpha = 0.9 
gen xi = 0.8
gen phi = 11.0
gen rho_c = 0.9

tempfile RC 
save `RC'

******************** R1
****** Import results from matlab model
clear
import delimited "$revision/Structural_Analysis/Counterfactual Robustness/results_85_75.txt", delimiter("  ", asstring) 
****** Clean data and make it into percentage changes
drop v1
rename v2 phi 
rename v3 xi 
gen rho = 0.75
gen alpha = 0.85 

tempfile R1 
save `R1'


******************** R2
****** Import results from matlab model
clear
import delimited "$revision/Structural_Analysis/Counterfactual Robustness/results_90_70.txt", delimiter("  ", asstring) 
****** Clean data and make it into percentage changes
drop v1
rename v2 phi 
rename v3 xi 
gen rho = 0.70
gen alpha = 0.90 

tempfile R2 
save `R2'

******************** R3
****** Import results from matlab model
clear
import delimited "$revision/Structural_Analysis/Counterfactual Robustness/results_90_90.txt", delimiter("  ", asstring) 
****** Clean data and make it into percentage changes
drop v1
rename v2 phi 
rename v3 xi 
gen rho = 0.90
gen alpha = 0.90 

tempfile R3 
save `R3'

******************** R4
****** Import results from matlab model
clear
import delimited "$revision/Structural_Analysis/Counterfactual Robustness/results_95_75.txt", delimiter("  ", asstring) 
****** Clean data and make it into percentage changes
drop v1
rename v2 phi 
rename v3 xi 
gen rho = 0.75
gen alpha = 0.95 

tempfile R4
save `R4'

********************MODEL ADJUSTING CAPITAL
****** Import results from matlab model
clear 
import delimited "$revision/Structural_Analysis/Counterfactual AdjK/results.txt", delimiter("  ", asstring) 
****** Clean data and make it into percentage changes
drop v1
rename v2 phi 
rename v3 xi 
gen rho = 0.75
gen alpha = 0.9 
gen adj_K = 1 

tempfile R5
save `R5'

********************MODEL WITHOUT CONGLOMERATES
****** Import results from matlab model
clear 
import delimited "$revision/Structural_Analysis/No Conglomerate/results.txt", delimiter("  ", asstring) 
****** Clean data and make it into percentage changes
drop v1
rename v2 share_reg
rename v4 v5 
rename v3 v4 
gen rho = 0.75
gen alpha = 0.9 
gen nocong = 1 
gen xi = 0.8 

tempfile R6
save `R6'

********************BASELINE
****** Import results from matlab model
clear 
import delimited "$revision/Structural_Analysis/Counterfactual Baseline/results.txt", delimiter("  ", asstring) 
****** Clean data and make it into percentage changes
drop v1
rename v2 phi 
rename v3 xi 
gen rho = 0.75
gen alpha = 0.9 


*** Append files 
append using `R1'
append using `R2'
append using `R3'
append using `R4'
append using `RC'
append using `R5'
append using `R6'

foreach var in v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15  { 
	replace `var'=-ln(`var')*100
} 

** Generate breakeven kappa 
gen kb = -v4/v5
gen kb2 = kb
replace kb = kb/(1+kb)
gen ssc = round(kb/(6.38/(2.752*1000)*1.25 ))

drop  if inrange(share_reg,.84,.87)

keep if inrange(xi,.78,.81)

bys alpha rho: egen min_phi=min(phi)
bys alpha rho: egen max_phi=max(phi)

drop if phi == min_phi | phi == max_phi 

gen agg_e = 670/.56*v5/100
gen agg_e_cr = 670/.56*(-v4)/(100*(alpha-.1))

order ssc alpha rho agg*


gen rho_in = 1 if inrange(alpha,0.89,.91) & rho <.75
replace rho_in = 2 if inrange(alpha,0.89,.91) & rho >.74 & rho <.76
replace rho_in = 3 if inrange(alpha,0.89,.91) & rho >.76


gen alpha_in = 4 if inrange(rho,0.74,.76) & alpha <.9
replace alpha_in = 5 if inrange(rho,0.74,.76) & alpha >.89 & alpha <.91
replace alpha_in = 6 if inrange(rho,0.74,.76) & alpha >.91


****** Some computations 
** Recall overall emissions in China 6.38 billion tons of carbon 
** And national income ($2.752 trillion, USD)

sort ssc 

local kappa1 = ssc[1]*6.38/(2.752*1000)*1.25
local kappa2 = ssc[3]*6.38/(2.752*1000)*1.25
local kappa3 = ssc[7]*6.38/(2.752*1000)*1.25
local kappa_AdjK = ssc[8]*6.38/(2.752*1000)*1.25
di `kappa3'


twoway  (function y = -(`kappa1'/(1-`kappa1'))*x, range(0 7) lcolor(gs11) ) ///
	(function y = -(`kappa2'/(1-`kappa2'))*x, range(0 7) lcolor(black) ) ///
	(function y = -(`kappa3'/(1-`kappa3'))*x, range(0 7) lcolor(gs11) ) ///
	(function y = -(`kappa_AdjK'/(1-`kappa_AdjK'))*x, range(0 7) lcolor(gs11) ) ///	
	(scatter v4 v5 if inrange(alpha,.89,.91) & inrange(rho,.74,.76) & rho_c == . & adj_K == . & nocong == ., msize(large)  msym(Dh) mcolor(red) ) ///
	(scatter v4 v5 if inrange(alpha,.89,.91) & ~inrange(rho,.74,.76) & adj_K == ., msize(large)  msym(Oh) mcolor(dkgreen) ) ///
	(scatter v4 v5 if inrange(rho,.74,.76) & ~inrange(alpha,.89,.91) & adj_K == .  , msize(large)  msym(Th) mcolor(navy) ) ///
	(scatter v4 v5 if rho_c != .  , msize(large)  msym(Sh) mcolor(black) ) ///
	(scatter v4 v5 if adj_K == 1 , msize(large)  msym(X) ) ///
	(scatter v4 v5 if nocong == 1 , msize(large)  msym(+)  mcolor(red)  ) ///
	, ytitle("Welfare Cost of Price Increase" "-ln(P/P{sup:*})") ///
	xtitle("Reduction in Energy Use" "ln(E/E{sup:*})") ///
	legend(pos(6) order(5 "Baseline {&alpha}=0.9, {&rho}=0.75               " ///
	6  "Vary {&rho}{&isin}{0.7,0.9}       " ///
	7  "Vary {&alpha}{&isin}{0.85,0.95}" ///
	8 "{&rho}{sub:C}=0.9" ///
	9 "K not fixed" ///
	10 "No Conglomerates" ///
	) rows(3)  region(col(white)))   ///
	graphregion(fcolor(white)) graphregion(color(white)) ///
	plotregion(fcolor(white) lcolor(white)) ///
	xlab(0(2)7) ylab(-6(2)0) ///
	xlab(0(2)7) ///
	 text(-6.4 5.9 "GWTP=$170{&rarr}") text(-5.85 5.55 "GWTP=$167{&rarr}") text(-5.25 5.3 "GWTP=$161{&rarr}") text(-4.7 6.5 "{&larr}GWTP=$156") ///
	text(-3.2 3 "{&alpha}=0.95") text(-3.5 4.8 "{&alpha}=0.85") text(-4.5 4.6 "{&rho}{sub:C}=0.9") ///
	text(-2.6 2.2 "K not" "fixed")  text(-5.7 6.75 "No" "Cong") 


graph export "$revision/Appendix_Figure/FigureA2_C.pdf", replace 

