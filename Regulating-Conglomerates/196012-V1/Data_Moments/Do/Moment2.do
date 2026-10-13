
* Moment2: Firm Size Depreciation

use "$revision/Data/Table3_2.dta",clear

*----------
*  Sample
*----------

keep if year==2004

keep firmid name conglomerate ind4 top1000 output
order firmid name conglomerate ind4 top1000 output

*----------------
*  Conglomerate
*----------------

egen group1=group(conglomerate ind4)

duplicates tag group1,gen(frequency)
drop if frequency==0
drop frequency

gsort group1 -top1000
by group1: gen top1000_exist=top1000[1]
drop if top1000_exist!=1
drop top1000_exist

drop group1
sort conglomerate ind4
egen group1=group(conglomerate ind4)
label variable group1 "Group ID for Conglomerate(Within 4-digit Industry)"

*-----------------------
*  Rank & Depreciation
*-----------------------

gsort group1 -output
by group1: gen rank=_n
label variable rank "Size Rank in Group"

sort group1 rank
by group1: gen delta=output/output[1]
label variable delta "Relative Size to Largest Firm in Group"

keep if rank<=10
keep group1 ind4 rank delta
sort group1 ind4 rank delta

reshape wide delta,i(group1) j(rank)

sort group1
order group1 ind4 delta*

forvalues i=1(1)10 {
    label variable delta`i' "Relative Size of `i'th Largest Firm to the Largest"
}

save "$revision/Data/Size_Depreciation.dta",replace

*------------
*  Baseline
*------------

use "$revision/Data/Size_Depreciation.dta",clear

forvalues i=1(1)10 {
	  egen delta_mean`i'=mean(delta`i')
	  }
	  
keep delta_mean*
gen number=0
duplicates drop number,force
order number
save "$revision/Data_Moments/Result/Moment2.dta",replace

*-------------
*  Bootstrap
*-------------

forvalues j=1(1)50 {
    use "$revision/Data/Size_Depreciation.dta",clear
    bsample

    forvalues i=1(1)10 {
	      egen delta_mean`i'=mean(delta`i')
	      }
		  
    keep delta_mean*
    gen number=`j'
	duplicates drop number,force
	order number
    append using "$revision/Data_Moments/Result/Moment2.dta"
    save "$revision/Data_Moments/Result/Moment2.dta",replace
}

*-----------
*  Result
*-----------
	  
use "$revision/Data_Moments/Result/Moment2.dta",clear
sort number

gen type="Baseline" if number==0

forvalues i=1(1)50 {
     replace type="Bootstrap`i'" if number==`i'
	 }
drop number

label variable type "Baseline or Bootstrap"
order type

forvalues i=1(1)10 {
    label variable delta_mean`i' "Relative Size of `i'th Largest Firm to the Largest"
}

save "$revision/Data_Moments/Result/Moment2.dta",replace

*Erase Temp File

erase "$revision/Data/Size_Depreciation.dta"

