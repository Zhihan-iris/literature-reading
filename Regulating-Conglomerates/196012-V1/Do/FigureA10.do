
* Figure A.10 Effects of the Top 1,000 Program on Regulated Firms: Robustness to Trimming Sample Using an Estimated Propensity of Treatment

use "$revision/Data/Table1.dta",clear

* Estimate Propensity Score

preserve 
keep if inrange(year,2003,2005) 
collapse (mean) loutput (max) ind2 (max) province (max) top1000, by(firmid)
logit top1000 i.ind2 i.province c.loutput#i.ind2

predict pscore
keep firmid pscore  
tempfile temp 
save `temp'
restore 

* Merge propensity score 

merge m:1 firmid using `temp'
drop _merge 

centile pscore if top1000 == 0, c(20,40,60) 
local perc1 = r(c_1)
local perc2 = r(c_2)
local perc3 = r(c_3)

centile pscore if top1000 == 1, c(80,60,40)
local perc4 = r(c_1)
local perc5 = r(c_2)
local perc6 = r(c_3)

*Figure

tab year, gen(ydummy)
forvalues i=1(1)10 {
      local j=2000+`i'
      gen treat_year`j'=ydummy`i'*top1000
      }

local treat_yeardummy "treat_year2001-treat_year2005 treat_year2007-treat_year2010"
local absorb3 "firmid ind2_year province_year"
local cluster "firmid"

reghdfe loutput  `treat_yeardummy' , absorb(`absorb3') cluster(`cluster') 
parmest,saving("$revision/Appendix_Figure/dta/PSM_Output_0.dta",replace)
reghdfe lenergy  `treat_yeardummy', absorb(`absorb3') cluster(`cluster') 
parmest,saving("$revision/Appendix_Figure/dta/PSM_Energy_0.dta",replace)

forvalues i=1(1)3 {
	reghdfe loutput  `treat_yeardummy' if (pscore>`perc`i'' & top1000==0) | top1000==1, absorb(`absorb3') cluster(`cluster') 
	parmest,saving("$revision/Appendix_Figure/dta/PSM_Output_`i'.dta",replace)
	reghdfe lenergy  `treat_yeardummy' if (pscore>`perc`i'' & top1000==0) | top1000==1, absorb(`absorb3') cluster(`cluster') 
	parmest,saving("$revision/Appendix_Figure/dta/PSM_Energy_`i'.dta",replace)
}

forvalues i=4(1)6 {
	reghdfe loutput  `treat_yeardummy' if  top1000==0 | (top1000==1 & pscore<`perc`i''), absorb(`absorb3') cluster(`cluster') 
	parmest,saving("$revision/Appendix_Figure/dta/PSM_Output_`i'.dta",replace)
	reghdfe lenergy  `treat_yeardummy' if  top1000==0 | (top1000==1 & pscore<`perc`i''), absorb(`absorb3') cluster(`cluster') 
	parmest,saving("$revision/Appendix_Figure/dta/PSM_Energy_`i'.dta",replace)
}

forvalues i=7(1)9 {
	local j=`i'-6
	local k=`i'-3
	reghdfe loutput  `treat_yeardummy' if  (pscore>`perc`j'' & top1000==0) | (top1000==1 & pscore<`perc`k''), absorb(`absorb3') cluster(`cluster') 
	parmest,saving("$revision/Appendix_Figure/dta/PSM_Output_`i'.dta",replace)
	reghdfe lenergy  `treat_yeardummy' if  (pscore>`perc`j'' & top1000==0) | (top1000==1 & pscore<`perc`k''), absorb(`absorb3') cluster(`cluster') 
	parmest,saving("$revision/Appendix_Figure/dta/PSM_Energy_`i'.dta",replace)
}

use "$revision/Appendix_Figure/dta/PSM_Output_0.dta",clear
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
replace year=year-0.18 if year!=2006
gen type=0
save "$revision/Appendix_Figure/dta/PSM_Output_0.dta",replace

forvalues i=1(3)7 {
	use "$revision/Appendix_Figure/dta/PSM_Output_`i'.dta",clear
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
	replace year=year-0.06 if year!=2006
	gen type=1
	save "$revision/Appendix_Figure/dta/PSM_Output_`i'.dta",replace
}

forvalues i=2(3)8 {
	use "$revision/Appendix_Figure/dta/PSM_Output_`i'.dta",clear
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
	replace year=year+0.06 if year!=2006
	gen type=2
	save "$revision/Appendix_Figure/dta/PSM_Output_`i'.dta",replace
}

forvalues i=3(3)9 {
	use "$revision/Appendix_Figure/dta/PSM_Output_`i'.dta",clear
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
	replace year=year+0.18 if year!=2006
	gen type=3
	save "$revision/Appendix_Figure/dta/PSM_Output_`i'.dta",replace
}

use "$revision/Appendix_Figure/dta/PSM_Energy_0.dta",clear
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
replace year=year-0.18 if year!=2006
gen type=0
save "$revision/Appendix_Figure/dta/PSM_Energy_0.dta",replace

forvalues i=1(3)7 {
	use "$revision/Appendix_Figure/dta/PSM_Energy_`i'.dta",clear
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
	replace year=year-0.06 if year!=2006
	gen type=1
	save "$revision/Appendix_Figure/dta/PSM_Energy_`i'.dta",replace
}

forvalues i=2(3)8 {
	use "$revision/Appendix_Figure/dta/PSM_Energy_`i'.dta",clear
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
	replace year=year+0.06 if year!=2006
	gen type=2
	save "$revision/Appendix_Figure/dta/PSM_Energy_`i'.dta",replace
}

forvalues i=3(3)9 {
	use "$revision/Appendix_Figure/dta/PSM_Energy_`i'.dta",clear
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
	replace year=year+0.18 if year!=2006
	gen type=3
	save "$revision/Appendix_Figure/dta/PSM_Energy_`i'.dta",replace
}

use "$revision/Appendix_Figure/dta/PSM_Energy_0.dta",clear
append using "$revision/Appendix_Figure/dta/PSM_Energy_1.dta"
append using "$revision/Appendix_Figure/dta/PSM_Energy_2.dta"
append using "$revision/Appendix_Figure/dta/PSM_Energy_3.dta"

graph tw (scatter estimate year if type==0, color(navy) msymbol(smcircle)) ///
(rcap min95 max95 year if type==0,lp(solid) msymbol(none) color(navy)) ///
(scatter estimate year if type==1, color(orange) msymbol(smsquare_hollow)) ///
(rcap min95 max95 year if type==1,lp(solid) msymbol(none) color(orange)) ///
(scatter estimate year if type==2, color(green) msymbol(smtriangle)) ///
(rcap min95 max95 year if type==2,lp(solid) msymbol(none) color(green)) ///
(scatter estimate year if type==3, color(sienna) msymbol(smdiamond_hollow)) ///
(rcap min95 max95 year if type==3,lp(solid) msymbol(none) color(sienna)) ///
, scheme(s1mono) graphregion(fcolor(white) lcolor(none) ifcolor(white) ///
ilcolor(none)) plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
xline(2006,lp(solid)) yline(0,lp(solid) lcolor(cranberry)) ///
xlabel(2001(1)2010,valuelabel)  ylabel(-0.6(0.2)0.4,valuelabel)  ///
xtitle("") ytitle("") legend( label(1 "Estimate for Baseline") label(2 "95% CI for Baseline") ///
label(3 "Estimate for Control>20%") label(4 "95% CI for Control>20%") ///
label(5 "Estimate for Control>40%") label(6 "95% CI for Control>40%") ///
label(7 "Estimate for Control>60%") label(8 "95% CI for Control>60%") )
graph export "$revision/Appendix_Figure/FigureA10_A.pdf", replace

use "$revision/Appendix_Figure/dta/PSM_Output_0.dta",clear
append using "$revision/Appendix_Figure/dta/PSM_Output_1.dta"
append using "$revision/Appendix_Figure/dta/PSM_Output_2.dta"
append using "$revision/Appendix_Figure/dta/PSM_Output_3.dta"

graph tw (scatter estimate year if type==0, color(navy) msymbol(smcircle)) ///
(rcap min95 max95 year if type==0,lp(solid) msymbol(none) color(navy)) ///
(scatter estimate year if type==1, color(orange) msymbol(smsquare_hollow)) ///
(rcap min95 max95 year if type==1,lp(solid) msymbol(none) color(orange)) ///
(scatter estimate year if type==2, color(green) msymbol(smtriangle)) ///
(rcap min95 max95 year if type==2,lp(solid) msymbol(none) color(green)) ///
(scatter estimate year if type==3, color(sienna) msymbol(smdiamond_hollow)) ///
(rcap min95 max95 year if type==3,lp(solid) msymbol(none) color(sienna)) ///
, scheme(s1mono) graphregion(fcolor(white) lcolor(none) ifcolor(white) ///
ilcolor(none)) plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
xline(2006,lp(solid)) yline(0,lp(solid) lcolor(cranberry)) ///
xlabel(2001(1)2010,valuelabel)  ylabel(-0.6(0.2)0.4,valuelabel)  ///
xtitle("") ytitle("") legend( label(1 "Estimate for Baseline") label(2 "95% CI for Baseline") ///
label(3 "Estimate for Control>20%") label(4 "95% CI for Control>20%") ///
label(5 "Estimate for Control>40%") label(6 "95% CI for Control>40%") ///
label(7 "Estimate for Control>60%") label(8 "95% CI for Control>60%") )
graph export "$revision/Appendix_Figure/FigureA10_B.pdf", replace

use "$revision/Appendix_Figure/dta/PSM_Energy_0.dta",clear
append using "$revision/Appendix_Figure/dta/PSM_Energy_4.dta"
append using "$revision/Appendix_Figure/dta/PSM_Energy_5.dta"
append using "$revision/Appendix_Figure/dta/PSM_Energy_6.dta"

graph tw (scatter estimate year if type==0, color(navy) msymbol(smcircle)) ///
(rcap min95 max95 year if type==0,lp(solid) msymbol(none) color(navy)) ///
(scatter estimate year if type==1, color(orange) msymbol(smsquare_hollow)) ///
(rcap min95 max95 year if type==1,lp(solid) msymbol(none) color(orange)) ///
(scatter estimate year if type==2, color(green) msymbol(smtriangle)) ///
(rcap min95 max95 year if type==2,lp(solid) msymbol(none) color(green)) ///
(scatter estimate year if type==3, color(sienna) msymbol(smdiamond_hollow)) ///
(rcap min95 max95 year if type==3,lp(solid) msymbol(none) color(sienna)) ///
, scheme(s1mono) graphregion(fcolor(white) lcolor(none) ifcolor(white) ///
ilcolor(none)) plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
xline(2006,lp(solid)) yline(0,lp(solid) lcolor(cranberry)) ///
xlabel(2001(1)2010,valuelabel)  ylabel(-0.6(0.2)0.4,valuelabel)  ///
xtitle("") ytitle("") legend( label(1 "Estimate for Baseline") label(2 "95% CI for Baseline") ///
label(3 "Estimate for Treat<80%") label(4 "95% CI for Treat<80%") ///
label(5 "Estimate for Treat<60%") label(6 "95% CI for Treat<60%") ///
label(7 "Estimate for Treat<40%") label(8 "95% CI for Treat<40%") )
graph export "$revision/Appendix_Figure/FigureA10_C.pdf", replace

use "$revision/Appendix_Figure/dta/PSM_Output_0.dta",clear
append using "$revision/Appendix_Figure/dta/PSM_Output_4.dta"
append using "$revision/Appendix_Figure/dta/PSM_Output_5.dta"
append using "$revision/Appendix_Figure/dta/PSM_Output_6.dta"

graph tw (scatter estimate year if type==0, color(navy) msymbol(smcircle)) ///
(rcap min95 max95 year if type==0,lp(solid) msymbol(none) color(navy)) ///
(scatter estimate year if type==1, color(orange) msymbol(smsquare_hollow)) ///
(rcap min95 max95 year if type==1,lp(solid) msymbol(none) color(orange)) ///
(scatter estimate year if type==2, color(green) msymbol(smtriangle)) ///
(rcap min95 max95 year if type==2,lp(solid) msymbol(none) color(green)) ///
(scatter estimate year if type==3, color(sienna) msymbol(smdiamond_hollow)) ///
(rcap min95 max95 year if type==3,lp(solid) msymbol(none) color(sienna)) ///
, scheme(s1mono) graphregion(fcolor(white) lcolor(none) ifcolor(white) ///
ilcolor(none)) plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
xline(2006,lp(solid)) yline(0,lp(solid) lcolor(cranberry)) ///
xlabel(2001(1)2010,valuelabel)  ylabel(-0.6(0.2)0.4,valuelabel)  ///
xtitle("") ytitle("") legend( label(1 "Estimate for Baseline") label(2 "95% CI for Baseline") ///
label(3 "Estimate for Treat<80%") label(4 "95% CI for Treat<80%") ///
label(5 "Estimate for Treat<60%") label(6 "95% CI for Treat<60%") ///
label(7 "Estimate for Treat<40%") label(8 "95% CI for Treat<40%") )
graph export "$revision/Appendix_Figure/FigureA10_D.pdf", replace

use "$revision/Appendix_Figure/dta/PSM_Energy_0.dta",clear
append using "$revision/Appendix_Figure/dta/PSM_Energy_7.dta"
append using "$revision/Appendix_Figure/dta/PSM_Energy_8.dta"
append using "$revision/Appendix_Figure/dta/PSM_Energy_9.dta"

graph tw (scatter estimate year if type==0, color(navy) msymbol(smcircle)) ///
(rcap min95 max95 year if type==0,lp(solid) msymbol(none) color(navy)) ///
(scatter estimate year if type==1, color(orange) msymbol(smsquare_hollow)) ///
(rcap min95 max95 year if type==1,lp(solid) msymbol(none) color(orange)) ///
(scatter estimate year if type==2, color(green) msymbol(smtriangle)) ///
(rcap min95 max95 year if type==2,lp(solid) msymbol(none) color(green)) ///
(scatter estimate year if type==3, color(sienna) msymbol(smdiamond_hollow)) ///
(rcap min95 max95 year if type==3,lp(solid) msymbol(none) color(sienna)) ///
, scheme(s1mono) graphregion(fcolor(white) lcolor(none) ifcolor(white) ///
ilcolor(none)) plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
xline(2006,lp(solid)) yline(0,lp(solid) lcolor(cranberry)) ///
xlabel(2001(1)2010,valuelabel)  ylabel(-0.6(0.2)0.4,valuelabel)  ///
xtitle("") ytitle("") legend( label(1 "Estimate for Baseline") label(2 "95% CI for Baseline") ///
label(3 "Estimate for Control>20% & Treat<80%") label(4 "95% CI for Control>20% & Treat<80%") ///
label(5 "Estimate for Control>40% & Treat<60%") label(6 "95% CI for Control>40% & Treat<60%") ///
label(7 "Estimate for Control>60% & Treat<40%") label(8 "95% CI for Control>60% & Treat<40%") size(small) ) 
graph export "$revision/Appendix_Figure/FigureA10_E.pdf", replace

use "$revision/Appendix_Figure/dta/PSM_Output_0.dta",clear
append using "$revision/Appendix_Figure/dta/PSM_Output_7.dta"
append using "$revision/Appendix_Figure/dta/PSM_Output_8.dta"
append using "$revision/Appendix_Figure/dta/PSM_Output_9.dta"

graph tw (scatter estimate year if type==0, color(navy) msymbol(smcircle)) ///
(rcap min95 max95 year if type==0,lp(solid) msymbol(none) color(navy)) ///
(scatter estimate year if type==1, color(orange) msymbol(smsquare_hollow)) ///
(rcap min95 max95 year if type==1,lp(solid) msymbol(none) color(orange)) ///
(scatter estimate year if type==2, color(green) msymbol(smtriangle)) ///
(rcap min95 max95 year if type==2,lp(solid) msymbol(none) color(green)) ///
(scatter estimate year if type==3, color(sienna) msymbol(smdiamond_hollow)) ///
(rcap min95 max95 year if type==3,lp(solid) msymbol(none) color(sienna)) ///
, scheme(s1mono) graphregion(fcolor(white) lcolor(none) ifcolor(white) ///
ilcolor(none)) plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
xline(2006,lp(solid)) yline(0,lp(solid) lcolor(cranberry)) ///
xlabel(2001(1)2010,valuelabel)  ylabel(-0.6(0.2)0.4,valuelabel)  ///
xtitle("") ytitle("") legend( label(1 "Estimate for Baseline") label(2 "95% CI for Baseline") ///
label(3 "Estimate for Control>20% & Treat<80%") label(4 "95% CI for Control>20% & Treat<80%") ///
label(5 "Estimate for Control>40% & Treat<60%") label(6 "95% CI for Control>40% & Treat<60%") ///
label(7 "Estimate for Control>60% & Treat<40%") label(8 "95% CI for Control>60% & Treat<40%") size(small) ) 
graph export "$revision/Appendix_Figure/FigureA10_F.pdf", replace

forvalues i=0(1)9 {
	erase "$revision/Appendix_Figure/dta/PSM_Output_`i'.dta"
	erase "$revision/Appendix_Figure/dta/PSM_Energy_`i'.dta"
	}
