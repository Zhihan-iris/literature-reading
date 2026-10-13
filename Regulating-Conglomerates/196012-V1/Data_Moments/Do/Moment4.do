
* Estimation of alpha_l

use "$revision/Data/Moment4.dta",clear

gen interest_rate=1/0.95-1
gen depreciation_rate=0.1
gen capital_cost=(fasset+depreciation)*(interest_rate+depreciation_rate)

gen alpha_l=(interinput+twagepay)/(interinput+twagepay+capital_cost)
label variable alpha_l "Variable Input/(Variable Input+Capital Cost)"

* alpha_l

sum alpha_l,d
local alpha_l_mean_all=r(mean)
local alpha_l_p50_all=r(p50)

foreach num of numlist 6 7 17 22 25 26 31 32 33 44 {
   sum alpha_l if ind2==`num',d
   local alpha_l_mean_`num'=r(mean)
   local alpha_l_p50_`num'=r(p50)
	}
	
clear
set obs 11
gen rank=_n

gen ind2=0 if rank==1
replace ind2=32 if rank==2
replace ind2=44 if rank==3
replace ind2=26 if rank==4
replace ind2=25 if rank==5
replace ind2=7 if rank==6
replace ind2=6 if rank==7
replace ind2=31 if rank==8
replace ind2=33 if rank==9
replace ind2=22 if rank==10
replace ind2=17 if rank==11

gen industry="Energy-Intensive Industries" if ind2==0
replace industry="Iron & Steel" if ind2==32
replace industry="Electric Power" if ind2==44
replace industry="Chemical" if ind2==26
replace industry="Petroleum(Processing)" if ind2==25
replace industry="Petroleum(Exploitation)" if ind2==7
replace industry="Mining" if ind2==6
replace industry="Building Materials" if ind2==31
replace industry="Non-Ferrous" if ind2==33
replace industry="Pulp & Paper Making" if ind2==22
replace industry="Textile" if ind2==17

gen alpha_l_mean=`alpha_l_mean_all' if rank==1
gen alpha_l_p50=`alpha_l_p50_all' if rank==1

foreach num of numlist 6 7 17 22 25 26 31 32 33 44 {
     replace alpha_l_mean=`alpha_l_mean_`num'' if ind2==`num'
	 replace alpha_l_p50=`alpha_l_p50_`num'' if ind2==`num'
	 }

drop rank
label variable ind2 "2-digit Industry"
label variable industry "Industry Name"
label variable alpha_l_mean "Mean of alpha_l"
label variable alpha_l_p50 "Medium of alpha_l"

save "$revision/Data_Moments/Result/Moment4.dta",replace
