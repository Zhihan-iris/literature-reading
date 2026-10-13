
* Moment3: Firm Size Distribution (Census)

use "$revision/Data/Moment3.dta",clear

sort output
keep if output<0.01
egen output_total=total(output)
egen num_total=count(firmid)

keep output_total num_total
gen number=0
duplicates drop number,force
order number

replace output_total=output_total/96517.66
replace num_total=num_total/450671

label variable output_total "revenue share of 0-1000"
label variable num_total "number share of 0-1000"

save "$revision/Data_Moments/Result/Moment3.dta",replace

*-------------
*  Bootstrap
*-------------

forvalues i=1(1)50 {

      use "$revision/Data/Moment3.dta",clear
      bsample
	  
      sort output
      keep if output<0.01
      egen output_total=total(output)
      egen num_total=count(firmid)

      keep output_total num_total
	  gen number=`i'
	  duplicates drop number,force
	  order number

	  replace output_total=output_total/96517.66
	  replace num_total=num_total/450671

	  append using "$revision/Data_Moments/Result/Moment3.dta"
	  save "$revision/Data_Moments/Result/Moment3.dta",replace
	  }

	  
*-----------
*  Result
*-----------
	  
use "$revision/Data_Moments/Result/Moment3.dta",clear

gen type="Baseline" if number==0

forvalues i=1(1)50 {
     replace type="Bootstrap`i'" if number==`i'
	 }

sort number
drop number
label variable type "Baseline or Bootstrap"
order type

save "$revision/Data_Moments/Result/Moment3.dta",replace

