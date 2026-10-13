
* Data for Moment 5. Estimation for Energy Share

*-----------------------------
* Top1000 & Related(Top10000)
*-----------------------------

use "$revision/Data/Moment5_1.dta",clear

*Coal Price

gen coal_price=334.78 if year==2001
replace coal_price=349.63 if year==2002
replace coal_price=334.36 if year==2003
replace coal_price=450.44 if year==2004
replace coal_price=535.43 if year==2005
replace coal_price=543.22 if year==2006
replace coal_price=592.85 if year==2007
replace coal_price=928.33 if year==2008
replace coal_price=763.90 if year==2009
replace coal_price=948.53 if year==2010

*Share of Energy Cost 

gen eshare=(coal_price*energy)/(intercost*1000+laborcost*1000)
replace eshare=. if eshare>1
winsor2 eshare,trim replace
label variable eshare "Energy Cost/Variable Input"

sum eshare,d
local eshare_mean=r(mean)
local eshare_p50=r(p50)

clear
set obs 1
gen sample="Top1000&Related(Top10000)"
gen energyshare_mean=`eshare_mean'
gen energyshare_p50=`eshare_p50'

label variable sample "Sample"
label variable energyshare_mean "Mean of Energy Share"
label variable energyshare_p50 "Medium of Energy Share"

save "$revision/Data_Moments/Result/Moment5.dta",replace

*------------------
* Top1000 Industry
*------------------

use "$revision/Data/Moment5_2.dta",clear

*Coal Price

gen coal_price=334.78 if year==2001
replace coal_price=349.63 if year==2002
replace coal_price=334.36 if year==2003
replace coal_price=450.44 if year==2004
replace coal_price=535.43 if year==2005
replace coal_price=543.22 if year==2006
replace coal_price=592.85 if year==2007
replace coal_price=928.33 if year==2008
replace coal_price=763.90 if year==2009
replace coal_price=948.53 if year==2010

*Share of Energy Cost 

gen eshare=(coal_price*energy)/(intercost*1000+laborcost*1000)
replace eshare=. if eshare>1
winsor2 eshare,trim replace

sum eshare,d
local eshare_mean=r(mean)
local eshare_p50=r(p50)
	
clear
set obs 1
gen sample="Top1000 Industry"
gen energyshare_mean=`eshare_mean'
gen energyshare_p50=`eshare_p50'

append using "$revision/Data_Moments/Result/Moment5.dta"
save "$revision/Data_Moments/Result/Moment5.dta",replace
