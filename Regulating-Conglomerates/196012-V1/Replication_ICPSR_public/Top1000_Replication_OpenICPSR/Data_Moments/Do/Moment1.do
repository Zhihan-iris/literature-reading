
* Moment1: Firm Size Distribution

*------------
*  Baseline
*------------

use "$revision/Data/Moment1.dta",clear

sort output
egen output_total1=total(output) if output<0.2 & output>=0.05 
egen output_total2=total(output) if output<1 & output>=0.2
egen output_total3=total(output) if output>=1

egen num_total1=count(firmid) if output<0.2 & output>=0.05
egen num_total2=count(firmid) if output<1 & output>=0.2
egen num_total3=count(firmid) if output>=1

forvalues j=1(1)3 {
    sort output_total`j'
    replace output_total`j'=output_total`j'[1]
	sort num_total`j'
    replace num_total`j'=num_total`j'[1]
	}
	
keep output_total* num_total*
gen number=0
duplicates drop number,force
order number

save "$revision/Data_Moments/Result/Moment1.dta",replace

*-------------
*  Bootstrap
*-------------

forvalues i=1(1)50 {

      use "$revision/Data/Moment1.dta",clear
      bsample

      sort output
      egen output_total1=total(output) if output<0.2 & output>=0.05 
      egen output_total2=total(output) if output<1 & output>=0.2
      egen output_total3=total(output) if output>=1

      egen num_total1=count(firmid) if output<0.2 & output>=0.05 
      egen num_total2=count(firmid) if output<1 & output>=0.2
      egen num_total3=count(firmid) if output>=1

      forvalues j=1(1)3 {
          sort output_total`j'
          replace output_total`j'=output_total`j'[1]
      	  sort num_total`j'
          replace num_total`j'=num_total`j'[1]
	      }
	
	  keep output_total* num_total*
	  gen number=`i'
	  duplicates drop number,force
	  order number
	  append using "$revision/Data_Moments/Result/Moment1.dta"
	  save "$revision/Data_Moments/Result/Moment1.dta",replace
	  }

*-----------
*  Result
*-----------
	  
use "$revision/Data_Moments/Result/Moment1.dta",clear

sort number
forvalues k=1(1)3 {
     replace output_total`k'=output_total`k'/96517.66
	 replace num_total`k'=num_total`k'/450671
	 }
sum output_total* num_total*

label variable output_total1 "revenue share of 5000-20000"
label variable output_total2 "revenue share of 20000-100000"
label variable output_total3 "revenue share of 100000-Inf"
label variable num_total1 "number share of 5000-20000"
label variable num_total2 "number share of 20000-100000"
label variable num_total3 "number share of 100000-Inf"

gen type="Baseline" if number==0

forvalues i=1(1)50 {
     replace type="Bootstrap`i'" if number==`i'
	 }
drop number
label variable type "Baseline or Bootstrap"
order type

save "$revision/Data_Moments/Result/Moment1.dta",replace

