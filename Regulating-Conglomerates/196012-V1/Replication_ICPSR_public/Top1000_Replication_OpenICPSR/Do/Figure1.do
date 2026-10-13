
*Figure 1: Cross Country Comparison using data from IEA 

** Source for data: https://www.iea.org/data-and-statistics?country=CHINAREG&fuel=Energy%20consumption&indicator=TFCShareBySector

clear all 

** Input data and save in temp files 
insheet using "$revision/IEA_Data/Total final consumption (TFC) by sector - China (People's Republic of China and Hong Kong China).csv", clear comma
keep if _n >4
gen country = "China"
tempfile China 
save `China'

insheet using "$revision/IEA_Data/Total final consumption (TFC) by sector - United States.csv", clear comma
keep if _n >4
gen country = "US"
tempfile US 
save `US'

insheet using "$revision/IEA_Data/Total final consumption (TFC) by sector - India.csv", clear comma
keep if _n >4
gen country = "India"
tempfile India 
save `India'

insheet using "$revision/IEA_Data/Total final consumption (TFC) by sector - Asia excluding China.csv", clear comma
keep if _n >4
gen country = "Asia"
tempfile Asia 
save `Asia'

insheet using "$revision/IEA_Data/Total final consumption (TFC) by sector - Japan.csv", clear comma
keep if _n >4
gen country = "Japan"
tempfile Japan 
save `Japan'

insheet using "$revision/IEA_Data/Total final consumption (TFC) by sector - Europe.csv", clear comma
keep if _n >4
gen country = "EU"

** Append data 
append using `China'
append using `US'
append using `Asia'
append using `India'
append using `Japan'


drop v3-v10 
rename v2 KTOE
rename v1 year 
destring KTOE, replace 
destring year, replace 

egen countryid=group(country)

xtset countryid year

** MTOE is an acronym that may refer to: Million Tonnes of Oil Equivalent

gen MTOE=KTOE/10^3

** Change from Oil equivalent to Coal Equivalent. 
** Conversion rate is 1.4286

gen MTCE=MTOE*1.4286

tw ///
(scatter MTCE year if country=="US",connect(l) xline(2007)) ///
(scatter MTCE year if country=="China",connect(l) msymbol(D)) ///
(scatter MTCE year if country=="EU",connect(l) msymbol(S)) ///
(scatter MTCE year if country=="India",connect(l) msymbol(Oh)) ///
, xtitle("Year") ytitle("Energy Consumption (MTCE)") xlabel(1990(5)2020) ylabel(0 250 500 1000 1500) scheme(s2color) ///
text(1360 2015 "China" 543 2015 "EU"  330 2015 "USA"  190 2015 "India") ///
legend(off) graphregion(fcolor(white)) graphregion(color(white)) 

graph export "$revision/Figure/Figure1.pdf", replace 	

