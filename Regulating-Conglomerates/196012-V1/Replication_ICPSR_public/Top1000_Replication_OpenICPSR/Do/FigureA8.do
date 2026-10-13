
*Figure A.8:  Effects of the Top 1,000 Program on Regulated Firms: Robustness to Different Samples

use "$revision/Data/TableA8.dta",clear

*===============
* Data Cleaning
*===============

*-------------------------------------------------------
* Drop Firms That Do Not Report Energy Data After 2006
*-------------------------------------------------------

* Drop Firms That Never Report Energy Data 

gen energy_data=1 if coal!=0 | oil!=0 | gas!=0
xfill energy_data
drop if energy_data==.

* Drop Firepower Firms (Firepower firms are separated from the CESD data after 2006)

gen firepower=(ind4==4411)
drop if firepower==1

*---------------------------------
* Drop Missing and Extreme Values
*---------------------------------

* Missing Energy Type

drop if power_type==.
drop if electricity50==.

* Untreated

gen untreated=(energy>18*10^4 & energy!=. & top1000==0 & year==2004)
gsort firmid -untreated
by firmid: replace untreated=untreated[1]
drop if untreated==1

* Comparable Energy and Output

replace loutput=. if lenergy==.

* Extreme Values

xtset firmid year
gen growth_energy=D.energy/L.energy
bysort firmid:egen total_energy=total(energy) 
bysort firmid:gen mean_energy=(total_energy-energy)/(_N-1)
gen energy_level=energy/mean_energy
gen energy_right=(growth_energy<10 | energy_level<10 )

drop if energy_right==0 & top1000!=1

*----------------------------------------------------
* Drop Firms That Did Not Report Coal Data Annually
*----------------------------------------------------

sort firmid coal
by firmid: egen missing=count(firmid) if coal==0

xtset firmid year
xfill missing, i(firmid)
replace missing=0 if missing==.

drop if missing>0 & top1000!=1

*==========
* Dynamics
*==========

*All Sample

tab year, gen(ydummy)
forvalues i=1(1)10 {
     local j=2000+`i'
     gen treat_year`j'=ydummy`i'*top1000
     }

local absorb3 "firmid ind2_year province_year"
local cluster "firmid"

reghdfe lenergy treat_year2001-treat_year2005 treat_year2007-treat_year2010 ,absorb(`absorb3') cluster(`cluster')
parmest,saving("$revision/Appendix_Figure/dta/Sample_Robustness_Energy1.dta",replace)
reghdfe loutput treat_year2001-treat_year2005 treat_year2007-treat_year2010 ,absorb(`absorb3') cluster(`cluster')
parmest,saving("$revision/Appendix_Figure/dta/Sample_Robustness_Output1.dta",replace)
reghdfe lefficiency treat_year2001-treat_year2005 treat_year2007-treat_year2010 ,absorb(`absorb3') cluster(`cluster')
parmest,saving("$revision/Appendix_Figure/dta/Sample_Robustness_Efficiency1.dta",replace)

*Drop Missing Coal Data

drop if missing>0

reghdfe lenergy treat_year2001-treat_year2005 treat_year2007-treat_year2010 ,absorb(`absorb3') cluster(`cluster')
parmest,saving("$revision/Appendix_Figure/dta/Sample_Robustness_Energy2.dta",replace)
reghdfe loutput treat_year2001-treat_year2005 treat_year2007-treat_year2010 ,absorb(`absorb3') cluster(`cluster')
parmest,saving("$revision/Appendix_Figure/dta/Sample_Robustness_Output2.dta",replace)
reghdfe lefficiency treat_year2001-treat_year2005 treat_year2007-treat_year2010 ,absorb(`absorb3') cluster(`cluster')
parmest,saving("$revision/Appendix_Figure/dta/Sample_Robustness_Efficiency2.dta",replace)

*Drop Extreme Values

drop if energy_right==0

reghdfe lenergy treat_year2001-treat_year2005 treat_year2007-treat_year2010 ,absorb(`absorb3') cluster(`cluster')
parmest,saving("$revision/Appendix_Figure/dta/Sample_Robustness_Energy3.dta",replace)
reghdfe loutput treat_year2001-treat_year2005 treat_year2007-treat_year2010 ,absorb(`absorb3') cluster(`cluster')
parmest,saving("$revision/Appendix_Figure/dta/Sample_Robustness_Output3.dta",replace)
reghdfe lefficiency treat_year2001-treat_year2005 treat_year2007-treat_year2010 ,absorb(`absorb3') cluster(`cluster')
parmest,saving("$revision/Appendix_Figure/dta/Sample_Robustness_Efficiency3.dta",replace)

* Electricity Intensitive 50%

keep if electricity50==1

reghdfe lenergy treat_year2001-treat_year2005 treat_year2007-treat_year2010 ,absorb(`absorb3') cluster(`cluster')
parmest,saving("$revision/Appendix_Figure/dta/Sample_Robustness_Energy4.dta",replace)
reghdfe loutput treat_year2001-treat_year2005 treat_year2007-treat_year2010 ,absorb(`absorb3') cluster(`cluster')
parmest,saving("$revision/Appendix_Figure/dta/Sample_Robustness_Output4.dta",replace)
reghdfe lefficiency treat_year2001-treat_year2005 treat_year2007-treat_year2010 ,absorb(`absorb3') cluster(`cluster')
parmest,saving("$revision/Appendix_Figure/dta/Sample_Robustness_Efficiency4.dta",replace)

* Electricity Intensitive 30%

keep if electricity30==1

reghdfe lenergy treat_year2001-treat_year2005 treat_year2007-treat_year2010 ,absorb(`absorb3') cluster(`cluster')
parmest,saving("$revision/Appendix_Figure/dta/Sample_Robustness_Energy5.dta",replace)
reghdfe loutput treat_year2001-treat_year2005 treat_year2007-treat_year2010 ,absorb(`absorb3') cluster(`cluster')
parmest,saving("$revision/Appendix_Figure/dta/Sample_Robustness_Output5.dta",replace)
reghdfe lefficiency treat_year2001-treat_year2005 treat_year2007-treat_year2010 ,absorb(`absorb3') cluster(`cluster')
parmest,saving("$revision/Appendix_Figure/dta/Sample_Robustness_Efficiency5.dta",replace)

* Electricity Intensitive 25%

keep if electricity25==1

reghdfe lenergy treat_year2001-treat_year2005 treat_year2007-treat_year2010 ,absorb(`absorb3') cluster(`cluster')
parmest,saving("$revision/Appendix_Figure/dta/Sample_Robustness_Energy6.dta",replace)
reghdfe loutput treat_year2001-treat_year2005 treat_year2007-treat_year2010 ,absorb(`absorb3') cluster(`cluster')
parmest,saving("$revision/Appendix_Figure/dta/Sample_Robustness_Output6.dta",replace)
reghdfe lefficiency treat_year2001-treat_year2005 treat_year2007-treat_year2010 ,absorb(`absorb3') cluster(`cluster')
parmest,saving("$revision/Appendix_Figure/dta/Sample_Robustness_Efficiency6.dta",replace)

*=======================
* Infill with Tax Data
*=======================

use "$revision/Data/TableA9_B.dta",clear

tab year, gen(ydummy)
forvalues i=1(1)10 {
     local j=2000+`i'
     gen treat_year`j'=ydummy`i'*top1000
     }

reghdfe lenergy treat_year2001-treat_year2005 treat_year2007-treat_year2010 ,absorb(`absorb3') cluster(`cluster')
parmest,saving("$revision/Appendix_Figure/dta/Sample_Robustness_Energy_Tax.dta",replace)
reghdfe loutput treat_year2001-treat_year2005 treat_year2007-treat_year2010 ,absorb(`absorb3') cluster(`cluster')
parmest,saving("$revision/Appendix_Figure/dta/Sample_Robustness_Output_Tax.dta",replace)
reghdfe lefficiency treat_year2001-treat_year2005 treat_year2007-treat_year2010 ,absorb(`absorb3') cluster(`cluster')
parmest,saving("$revision/Appendix_Figure/dta/Sample_Robustness_Efficiency_Tax.dta",replace)

*=========
* Figure
*=========

*Energy

use "$revision/Appendix_Figure/dta/Sample_Robustness_Energy5.dta",clear
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
replace year=year-0.22 if year!=2006
gen type=1
save "$revision/Appendix_Figure/dta/Sample_Robustness_Energy5.dta",replace

use "$revision/Appendix_Figure/dta/Sample_Robustness_Energy1.dta",clear
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
replace year=year-0.11 if year!=2006
gen type=2
save "$revision/Appendix_Figure/dta/Sample_Robustness_Energy1.dta",replace

use "$revision/Appendix_Figure/dta/Sample_Robustness_Energy4.dta",clear
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
gen type=3
save "$revision/Appendix_Figure/dta/Sample_Robustness_Energy4.dta",replace

use "$revision/Appendix_Figure/dta/Sample_Robustness_Energy6.dta",clear
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
replace year=year+0.11 if year!=2006
gen type=4
save "$revision/Appendix_Figure/dta/Sample_Robustness_Energy6.dta",replace

use "$revision/Appendix_Figure/dta/Sample_Robustness_Energy_Tax.dta",clear
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
replace year=year+0.22 if year!=2006
gen type=5
save "$revision/Appendix_Figure/dta/Sample_Robustness_Energy_Tax.dta",replace


use "$revision/Appendix_Figure/dta/Sample_Robustness_Energy5.dta",clear
append using "$revision/Appendix_Figure/dta/Sample_Robustness_Energy1.dta"
append using "$revision/Appendix_Figure/dta/Sample_Robustness_Energy4.dta"
append using "$revision/Appendix_Figure/dta/Sample_Robustness_Energy6.dta"
append using "$revision/Appendix_Figure/dta/Sample_Robustness_Energy_Tax.dta"

graph tw (scatter estimate year if type==1, color(navy) msymbol(smcircle)) ///
(rcap min95 max95 year if type==1,lp(solid) msymbol(none) color(navy)) ///
(scatter estimate year if type==2, color(orange) msymbol(smsquare_hollow)) ///
(rcap min95 max95 year if type==2,lp(solid) msymbol(none) color(orange)) ///
(scatter estimate year if type==3, color(green) msymbol(smtriangle)) ///
(rcap min95 max95 year if type==3,lp(solid) msymbol(none) color(green)) ///
(scatter estimate year if type==4, color(sienna) msymbol(smdiamond_hollow)) ///
(rcap min95 max95 year if type==4,lp(solid) msymbol(none) color(sienna)) ///
(scatter estimate year if type==5, color(gs7) msymbol(X)) ///
(rcap min95 max95 year if type==5,lp(solid) msymbol(none) color(gs7)) ///
, scheme(s1mono) graphregion(fcolor(white) lcolor(none) ifcolor(white) ///
ilcolor(none)) plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
xline(2006,lp(solid)) yline(0,lp(solid) lcolor(cranberry)) ///
xlabel(2001(1)2010,valuelabel)  ylabel(-0.5(0.1)0.3,valuelabel)  ///
xtitle("") ytitle("") legend( label(1 "Estimate for Baseline") label(2 "95% CI for Baseline") ///
label(3 "Estimate for All Sample") label(4 "95% CI for All Sample") ///
label(5 "Estimate for Electricity<50%") label(6 "95% CI for Electricity<50%") ///
label(7 "Estimate for Electricity<25%") label(8 "95% CI for Electricity<25%") ///
label(9 "Estimate for Infilling with ATS") label(10 "95% CI for Infilling with ATS"))
graph export "$revision/Appendix_Figure/FigureA8_A.pdf", replace

*Output

use "$revision/Appendix_Figure/dta/Sample_Robustness_Output5.dta",clear
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
replace year=year-0.22 if year!=2006
gen type=1
save "$revision/Appendix_Figure/dta/Sample_Robustness_Output5.dta",replace

use "$revision/Appendix_Figure/dta/Sample_Robustness_Output1.dta",clear
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
replace year=year-0.11 if year!=2006
gen type=2
save "$revision/Appendix_Figure/dta/Sample_Robustness_Output1.dta",replace

use "$revision/Appendix_Figure/dta/Sample_Robustness_Output4.dta",clear
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
gen type=3
save "$revision/Appendix_Figure/dta/Sample_Robustness_Output4.dta",replace

use "$revision/Appendix_Figure/dta/Sample_Robustness_Output6.dta",clear
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
replace year=year+0.11 if year!=2006
gen type=4
save "$revision/Appendix_Figure/dta/Sample_Robustness_Output6.dta",replace

use "$revision/Appendix_Figure/dta/Sample_Robustness_Output_Tax.dta",clear
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
replace year=year+0.22 if year!=2006
gen type=5
save "$revision/Appendix_Figure/dta/Sample_Robustness_Output_Tax.dta",replace

use "$revision/Appendix_Figure/dta/Sample_Robustness_Output5.dta",clear
append using "$revision/Appendix_Figure/dta/Sample_Robustness_Output1.dta"
append using "$revision/Appendix_Figure/dta/Sample_Robustness_Output4.dta"
append using "$revision/Appendix_Figure/dta/Sample_Robustness_Output6.dta"
append using "$revision/Appendix_Figure/dta/Sample_Robustness_Output_Tax.dta"

graph tw (scatter estimate year if type==1, color(navy) msymbol(smcircle)) ///
(rcap min95 max95 year if type==1,lp(solid) msymbol(none) color(navy)) ///
(scatter estimate year if type==2, color(orange) msymbol(smsquare_hollow)) ///
(rcap min95 max95 year if type==2,lp(solid) msymbol(none) color(orange)) ///
(scatter estimate year if type==3, color(green) msymbol(smtriangle)) ///
(rcap min95 max95 year if type==3,lp(solid) msymbol(none) color(green)) ///
(scatter estimate year if type==4, color(sienna) msymbol(smdiamond_hollow)) ///
(rcap min95 max95 year if type==4,lp(solid) msymbol(none) color(sienna)) ///
(scatter estimate year if type==5, color(gs7) msymbol(X)) ///
(rcap min95 max95 year if type==5,lp(solid) msymbol(none) color(gs7)) ///
, scheme(s1mono) graphregion(fcolor(white) lcolor(none) ifcolor(white) ///
ilcolor(none)) plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
xline(2006,lp(solid)) yline(0,lp(solid) lcolor(cranberry)) ///
xlabel(2001(1)2010,valuelabel)  ylabel(-0.5(0.1)0.3,valuelabel)  ///
xtitle("") ytitle("") legend( label(1 "Estimate for Baseline") label(2 "95% CI for Baseline") ///
label(3 "Estimate for All Sample") label(4 "95% CI for All Sample") ///
label(5 "Estimate for Electricity<50%") label(6 "95% CI for Electricity<50%") ///
label(7 "Estimate for Electricity<25%") label(8 "95% CI for Electricity<25%") ///
label(9 "Estimate for Infilling with ATS") label(10 "95% CI for Infilling with ATS"))
graph export "$revision/Appendix_Figure/FigureA8_B.pdf", replace

*Efficiency

use "$revision/Appendix_Figure/dta/Sample_Robustness_Efficiency5.dta",clear
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
replace year=year-0.22 if year!=2006
gen type=1
save "$revision/Appendix_Figure/dta/Sample_Robustness_Efficiency5.dta",replace

use "$revision/Appendix_Figure/dta/Sample_Robustness_Efficiency1.dta",clear
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
replace year=year-0.11 if year!=2006
gen type=2
save "$revision/Appendix_Figure/dta/Sample_Robustness_Efficiency1.dta",replace

use "$revision/Appendix_Figure/dta/Sample_Robustness_Efficiency4.dta",clear
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
gen type=3
save "$revision/Appendix_Figure/dta/Sample_Robustness_Efficiency4.dta",replace

use "$revision/Appendix_Figure/dta/Sample_Robustness_Efficiency6.dta",clear
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
replace year=year+0.11 if year!=2006
gen type=4
save "$revision/Appendix_Figure/dta/Sample_Robustness_Efficiency6.dta",replace

use "$revision/Appendix_Figure/dta/Sample_Robustness_Efficiency_Tax.dta",clear
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
replace year=year+0.22 if year!=2006
gen type=5
save "$revision/Appendix_Figure/dta/Sample_Robustness_Efficiency_Tax.dta",replace

use "$revision/Appendix_Figure/dta/Sample_Robustness_Efficiency5.dta",clear
append using "$revision/Appendix_Figure/dta/Sample_Robustness_Efficiency1.dta"
append using "$revision/Appendix_Figure/dta/Sample_Robustness_Efficiency4.dta"
append using "$revision/Appendix_Figure/dta/Sample_Robustness_Efficiency6.dta"
append using "$revision/Appendix_Figure/dta/Sample_Robustness_Efficiency_Tax.dta"

graph tw (scatter estimate year if type==1, color(navy) msymbol(smcircle)) ///
(rcap min95 max95 year if type==1,lp(solid) msymbol(none) color(navy)) ///
(scatter estimate year if type==2, color(orange) msymbol(smsquare_hollow)) ///
(rcap min95 max95 year if type==2,lp(solid) msymbol(none) color(orange)) ///
(scatter estimate year if type==3, color(green) msymbol(smtriangle)) ///
(rcap min95 max95 year if type==3,lp(solid) msymbol(none) color(green)) ///
(scatter estimate year if type==4, color(sienna) msymbol(smdiamond_hollow)) ///
(rcap min95 max95 year if type==4,lp(solid) msymbol(none) color(sienna)) ///
(scatter estimate year if type==5, color(gs7) msymbol(X)) ///
(rcap min95 max95 year if type==5,lp(solid) msymbol(none) color(gs7)) ///
, scheme(s1mono) graphregion(fcolor(white) lcolor(none) ifcolor(white) ///
ilcolor(none)) plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
xline(2006,lp(solid)) yline(0,lp(solid) lcolor(cranberry)) ///
xlabel(2001(1)2010,valuelabel)  ylabel(-0.4(0.1)0.4,valuelabel)  ///
xtitle("") ytitle("") legend( label(1 "Estimate for Baseline") label(2 "95% CI for Baseline") ///
label(3 "Estimate for All Sample") label(4 "95% CI for All Sample") ///
label(5 "Estimate for Electricity<50%") label(6 "95% CI for Electricity<50%") ///
label(7 "Estimate for Electricity<25%") label(8 "95% CI for Electricity<25%") ///
label(9 "Estimate for Infilling with ATS") label(10 "95% CI for Infilling with ATS"))
graph export "$revision/Appendix_Figure/FigureA8_C.pdf", replace

* Erase Temp File

forvalues i=1(1)6 {
	erase "$revision/Appendix_Figure/dta/Sample_Robustness_Energy`i'.dta"
	erase "$revision/Appendix_Figure/dta/Sample_Robustness_Output`i'.dta"
	erase "$revision/Appendix_Figure/dta/Sample_Robustness_Efficiency`i'.dta"
}

erase "$revision/Appendix_Figure/dta/Sample_Robustness_Energy_Tax.dta"
erase "$revision/Appendix_Figure/dta/Sample_Robustness_Output_Tax.dta"
erase "$revision/Appendix_Figure/dta/Sample_Robustness_Efficiency_Tax.dta"
