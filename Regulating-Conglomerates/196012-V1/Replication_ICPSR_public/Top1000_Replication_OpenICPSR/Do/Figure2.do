
*Figure 2: Conglomerate Size and Production Allocation

**********************************
* Figure 2-A: Relative Firm Size
**********************************

use "$revision/Data_Moments/Result/Moment2.dta",clear

keep if type=="Baseline"
drop type
gen id=1
reshape long delta_mean,i(id) j(rank)

twoway (scatter delta_mean rank if rank<=5,msize(large)), ///
ylabel(0(0.2)1,nogrid) xlabel(1(1)5) ///
xscale(range(0.5 5.5)) graphregion(color(white)) ///
ytitle("Relative Size") xtitle("Rank")  

graph export "$revision/Figure/Figure2_A.pdf", replace


********************************************
* Figure 2-B: Output and Conglomerate Size
********************************************

use "$revision/Data/Table3_2.dta",clear

*Conglomerate Firm Number

egen groupid=group(conglomerate ind4 year)

bysort groupid: egen number=count(firmid)
drop if number==1

gsort groupid -top1000
by groupid: gen top1000_exist=top1000[1]
drop if top1000_exist!=1

*Largest Firm Output

gsort groupid -loutput
by groupid: gen rank=_n
keep if rank==1

winsor2 loutput,trim replace
ren loutput loutput1
drop if number==. | loutput1==. | ind4==.

*Labels

label variable groupid "Group ID for Conglomerate(Within 4-digit Industry)"
label variable number "Number of Firms in Conglomerate"
label variable loutput1 "ln(Output) of the Largerst Firm in Conglomerate"

*Figure

binscatter number loutput1, absorb(ind4) nq(30) ///
xtitle("ln(Output of the Largest Firm in Conglomerate)") ///
ytitle("Number of Firms in the Conglomerate") ///
ylabel(,nogrid) graphregion(color(white))

graph export "$revision/Figure/Figure2_B.pdf", replace
