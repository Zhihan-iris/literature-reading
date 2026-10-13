
* Figure A.9 Effects of the Top 1,000 Program on Regulated Firms: Robustness to Trimming Sample by Top 10,000 Rank

use "$revision/Data/Table1.dta",clear

local x "treat_post"
local cluster "firmid"
local absorb3 "firmid ind2_year province_year"

local if0 ""
local if1 "if top10000_rank<8000"
local if2 "if top10000_rank<5000"
local if3 "if top10000_rank<3000"

local if4 "if top10000_rank>300"
local if5 "if top10000_rank>500"
local if6 "if top10000_rank>800"

local if7 "if top10000_rank>300 & top10000_rank<8000"
local if8 "if top10000_rank>500 & top10000_rank<5000"
local if9 "if top10000_rank>800 & top10000_rank<3000"

tab year, gen(ydummy)
forvalues i=1(1)10 {
      local j=2000+`i'
      gen treat_year`j'=ydummy`i'*top1000
      }

local treat_yeardummy "treat_year2001-treat_year2005 treat_year2007-treat_year2010"
local absorb3 "firmid ind2_year province_year"
local cluster "firmid"

reghdfe loutput  `treat_yeardummy' , absorb(`absorb3') cluster(`cluster') 
parmest,saving("$revision/Appendix_Figure/dta/Top10000_Rank_Output_0.dta",replace)
reghdfe lenergy  `treat_yeardummy', absorb(`absorb3') cluster(`cluster') 
parmest,saving("$revision/Appendix_Figure/dta/Top10000_Rank_Energy_0.dta",replace)

forvalues i=1(1)9 {
	reghdfe loutput  `treat_yeardummy' `if`i'', absorb(`absorb3') cluster(`cluster') 
	parmest,saving("$revision/Appendix_Figure/dta/Top10000_Rank_Output_`i'.dta",replace)
	reghdfe lenergy  `treat_yeardummy' `if`i'', absorb(`absorb3') cluster(`cluster') 
	parmest,saving("$revision/Appendix_Figure/dta/Top10000_Rank_Energy_`i'.dta",replace)
}

use "$revision/Appendix_Figure/dta/Top10000_Rank_Output_0.dta",clear
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
save "$revision/Appendix_Figure/dta/Top10000_Rank_Output_0.dta",replace

forvalues i=1(3)7 {
	use "$revision/Appendix_Figure/dta/Top10000_Rank_Output_`i'.dta",clear
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
	save "$revision/Appendix_Figure/dta/Top10000_Rank_Output_`i'.dta",replace
}

forvalues i=2(3)8 {
	use "$revision/Appendix_Figure/dta/Top10000_Rank_Output_`i'.dta",clear
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
	save "$revision/Appendix_Figure/dta/Top10000_Rank_Output_`i'.dta",replace
}

forvalues i=3(3)9 {
	use "$revision/Appendix_Figure/dta/Top10000_Rank_Output_`i'.dta",clear
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
	save "$revision/Appendix_Figure/dta/Top10000_Rank_Output_`i'.dta",replace
}

use "$revision/Appendix_Figure/dta/Top10000_Rank_Energy_0.dta",clear
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
save "$revision/Appendix_Figure/dta/Top10000_Rank_Energy_0.dta",replace

forvalues i=1(3)7 {
	use "$revision/Appendix_Figure/dta/Top10000_Rank_Energy_`i'.dta",clear
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
	save "$revision/Appendix_Figure/dta/Top10000_Rank_Energy_`i'.dta",replace
}

forvalues i=2(3)8 {
	use "$revision/Appendix_Figure/dta/Top10000_Rank_Energy_`i'.dta",clear
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
	save "$revision/Appendix_Figure/dta/Top10000_Rank_Energy_`i'.dta",replace
}

forvalues i=3(3)9 {
	use "$revision/Appendix_Figure/dta/Top10000_Rank_Energy_`i'.dta",clear
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
	save "$revision/Appendix_Figure/dta/Top10000_Rank_Energy_`i'.dta",replace
}

use "$revision/Appendix_Figure/dta/Top10000_Rank_Energy_0.dta",clear
append using "$revision/Appendix_Figure/dta/Top10000_Rank_Energy_1.dta"
append using "$revision/Appendix_Figure/dta/Top10000_Rank_Energy_2.dta"
append using "$revision/Appendix_Figure/dta/Top10000_Rank_Energy_3.dta"

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
label(3 "Estimate for Rank<8000") label(4 "95% CI for Rank<8000") ///
label(5 "Estimate for Rank<5000") label(6 "95% CI for Rank<5000") ///
label(7 "Estimate for Rank<3000") label(8 "95% CI for Rank<3000") )
graph export "$revision/Appendix_Figure/FigureA9_A.pdf", replace

use "$revision/Appendix_Figure/dta/Top10000_Rank_Output_0.dta",clear
append using "$revision/Appendix_Figure/dta/Top10000_Rank_Output_1.dta"
append using "$revision/Appendix_Figure/dta/Top10000_Rank_Output_2.dta"
append using "$revision/Appendix_Figure/dta/Top10000_Rank_Output_3.dta"

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
label(3 "Estimate for Rank<8000") label(4 "95% CI for Rank<8000") ///
label(5 "Estimate for Rank<5000") label(6 "95% CI for Rank<5000") ///
label(7 "Estimate for Rank<3000") label(8 "95% CI for Rank<3000") )
graph export "$revision/Appendix_Figure/FigureA9_B.pdf", replace

use "$revision/Appendix_Figure/dta/Top10000_Rank_Energy_0.dta",clear
append using "$revision/Appendix_Figure/dta/Top10000_Rank_Energy_4.dta"
append using "$revision/Appendix_Figure/dta/Top10000_Rank_Energy_5.dta"
append using "$revision/Appendix_Figure/dta/Top10000_Rank_Energy_6.dta"

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
label(3 "Estimate for Rank>300") label(4 "95% CI for Rank>800") ///
label(5 "Estimate for Rank>500") label(6 "95% CI for Rank>500") ///
label(7 "Estimate for Rank>800") label(8 "95% CI for Rank>300") )
graph export "$revision/Appendix_Figure/FigureA9_C.pdf", replace

use "$revision/Appendix_Figure/dta/Top10000_Rank_Output_0.dta",clear
append using "$revision/Appendix_Figure/dta/Top10000_Rank_Output_4.dta"
append using "$revision/Appendix_Figure/dta/Top10000_Rank_Output_5.dta"
append using "$revision/Appendix_Figure/dta/Top10000_Rank_Output_6.dta"

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
label(3 "Estimate for Rank>300") label(4 "95% CI for Rank>800") ///
label(5 "Estimate for Rank>500") label(6 "95% CI for Rank>500") ///
label(7 "Estimate for Rank>800") label(8 "95% CI for Rank>300") )
graph export "$revision/Appendix_Figure/FigureA9_D.pdf", replace

use "$revision/Appendix_Figure/dta/Top10000_Rank_Energy_0.dta",clear
append using "$revision/Appendix_Figure/dta/Top10000_Rank_Energy_7.dta"
append using "$revision/Appendix_Figure/dta/Top10000_Rank_Energy_8.dta"
append using "$revision/Appendix_Figure/dta/Top10000_Rank_Energy_9.dta"

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
label(3 "Estimate for 300<Rank<8000") label(4 "95% CI for 300<Rank<8000") ///
label(5 "Estimate for 500<Rank<5000") label(6 "95% CI for 500<Rank<5000") ///
label(7 "Estimate for 800<Rank<3000") label(8 "95% CI for 800<Rank<3000") ) 
graph export "$revision/Appendix_Figure/FigureA9_E.pdf", replace

use "$revision/Appendix_Figure/dta/Top10000_Rank_Output_0.dta",clear
append using "$revision/Appendix_Figure/dta/Top10000_Rank_Output_7.dta"
append using "$revision/Appendix_Figure/dta/Top10000_Rank_Output_8.dta"
append using "$revision/Appendix_Figure/dta/Top10000_Rank_Output_9.dta"

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
label(3 "Estimate for 300<Rank<8000") label(4 "95% CI for 300<Rank<8000") ///
label(5 "Estimate for 500<Rank<5000") label(6 "95% CI for 500<Rank<5000") ///
label(7 "Estimate for 800<Rank<3000") label(8 "95% CI for 800<Rank<3000") ) 
graph export "$revision/Appendix_Figure/FigureA9_F.pdf", replace

forvalues i=0(1)9 {
	erase "$revision/Appendix_Figure/dta/Top10000_Rank_Output_`i'.dta"
	erase "$revision/Appendix_Figure/dta/Top10000_Rank_Energy_`i'.dta"
}
