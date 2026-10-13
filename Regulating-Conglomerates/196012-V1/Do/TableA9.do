
*Table A.9 Robustness to Different Samples

use "$revision/Data/TableA8.dta",clear // old TableA4.dta but now TableA8.dta

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

*============
* Regression
*============

*--------------------------
* Robustness 1: All Sample
*--------------------------

local x "treat_post"
local cluster "firmid"
local absorb3 "firmid ind2_year province_year"

eststo Robust1_1: reghdfe lenergy `x', absorb(`absorb3') cluster(`cluster')
eststo Robust1_2: reghdfe loutput `x', absorb(`absorb3') cluster(`cluster')
eststo Robust1_3: reghdfe lefficiency `x', absorb(`absorb3') cluster(`cluster')
unique firmid if  top1000 == 1
local N_sample1 = `r(unique)'
*--------------------------------------
* Robustness 2: Drop Missing Coal Data 
*--------------------------------------

drop if missing>0

eststo Robust2_1: reghdfe lenergy `x', absorb(`absorb3') cluster(`cluster')
eststo Robust2_2: reghdfe loutput `x', absorb(`absorb3') cluster(`cluster')
eststo Robust2_3: reghdfe lefficiency `x', absorb(`absorb3') cluster(`cluster')
unique firmid if  top1000 == 1
local N_sample2 = `r(unique)'

*------------------------------------
* Robustness 3: Drop Extreme Values 
*------------------------------------

drop if energy_right==0

eststo Robust3_1: reghdfe lenergy `x', absorb(`absorb3') cluster(`cluster')
eststo Robust3_2: reghdfe loutput `x', absorb(`absorb3') cluster(`cluster')
eststo Robust3_3: reghdfe lefficiency `x', absorb(`absorb3') cluster(`cluster')
unique firmid if  top1000 == 1
local N_sample3 = `r(unique)'

*------------------------------------------
* Robustness 4: Industry(Electricity<50%) 
*------------------------------------------

keep if electricity50==1

eststo Robust4_1: reghdfe lenergy `x', absorb(`absorb3') cluster(`cluster')
eststo Robust4_2: reghdfe loutput `x', absorb(`absorb3') cluster(`cluster')
eststo Robust4_3: reghdfe lefficiency `x', absorb(`absorb3') cluster(`cluster')
unique firmid if  top1000 == 1
local N_sample4 = `r(unique)'

*------------------------------------------
* Robustness 5: Industry(Electricity<30%)  
*------------------------------------------

keep if electricity30==1

eststo Robust5_1: reghdfe lenergy `x', absorb(`absorb3') cluster(`cluster')
eststo Robust5_2: reghdfe loutput `x', absorb(`absorb3') cluster(`cluster')
eststo Robust5_3: reghdfe lefficiency `x', absorb(`absorb3') cluster(`cluster')
unique firmid if  top1000 == 1
local N_sample5 = `r(unique)'

*------------------------------------------
* Robustness 6: Industry(Electricity<25%)   
*------------------------------------------

keep if electricity25==1

eststo Robust6_1: reghdfe lenergy `x', absorb(`absorb3') cluster(`cluster')
eststo Robust6_2: reghdfe loutput `x', absorb(`absorb3') cluster(`cluster')
eststo Robust6_3: reghdfe lefficiency `x', absorb(`absorb3') cluster(`cluster')
unique firmid if  top1000 == 1
local N_sample6 = `r(unique)'

*--------------
* Robustness 7
*--------------

use "$revision/Data/TableA9_B.dta",clear

local x "treat_post"
local cluster "firmid"
local absorb3 "firmid ind2_year province_year"

eststo Robust7_1: reghdfe lenergy `x', absorb(`absorb3') cluster(`cluster')
eststo Robust7_2: reghdfe loutput `x', absorb(`absorb3') cluster(`cluster')
eststo Robust7_3: reghdfe lefficiency `x', absorb(`absorb3') cluster(`cluster')
unique firmid if  top1000 == 1
local N_sample7 = `r(unique)'

*----------
*  Result
*----------

// esttab Robust1_? using "$revision/Appendix_Table/TableA9.tex",  ///
// preh("\begin{table} \centering" ///
// "\caption{\bf Robustness to Different Samples}" ///
// "\begin{tabular}{l c c c}") ///
// stats() posth("\toprule" ///
// "Variables & ln(Energy Use) & ln(Output) & ln(Energy Efficiency) \\" ///
// "\midrule" ) ///
// nostar /// 
// cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
// noobs nogap ///
// keep(treat_post) coeflabel(treat_post "All Sample") label ///
// prefoot("") postfoot("") replace 
//
// esttab Robust2_?  using "$revision/Appendix_Table/TableA9.tex", preh("") posth("") ///
// cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
// s() noobs nogap keep(treat_post) nostar /// 
// coeflabel(treat_post "Drop Missing Coal Data"  ) label /// 
// prefoot("") postfoot("") append sty(tex)
//
// esttab Robust3_?  using "$revision/Appendix_Table/TableA9.tex", preh("") posth("") ///
// cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
// s() noobs nogap keep(treat_post) nostar /// 
// coeflabel(treat_post "Drop Extreme Values"  ) label /// 
// prefoot("") postfoot("") append sty(tex)
//
// esttab Robust4_?  using "$revision/Appendix_Table/TableA9.tex", preh("") posth("") ///
// cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
// s() noobs nogap keep(treat_post) nostar /// 
// coeflabel(treat_post "Industry(Electricity$<$50\%)"  ) label /// 
// prefoot("") postfoot("") append sty(tex)
//
// esttab Robust5_?  using "$revision/Appendix_Table/TableA9.tex", preh("") posth("") ///
// cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
// s() noobs nogap keep(treat_post) nostar /// 
// coeflabel(treat_post "Industry(Electricity$<$30\%)"  ) label /// 
// prefoot("") postfoot("") append sty(tex)
//
// esttab Robust6_?  using "$revision/Appendix_Table/TableA9.tex", preh("") posth("") ///
// cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
// s() noobs nogap keep(treat_post) nostar /// 
// coeflabel(treat_post "Industry(Electricity$<$25\%)"  ) label /// 
// prefoot("") postfoot("") append sty(tex)
//
// esttab Robust7_? using "$revision/Appendix_Table/TableA9.tex", preh("") posth("") ///
// cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
// s() noobs nogap keep(treat_post) nostar /// 
// coeflabel(treat_post "Infilling Missing Coal Data"  ) label /// 
// prefoot("") postfoot( ///
// "\hline" ///
// "Firm FE & Y & Y & Y \\" ///
// "Industry $\times$ Year FE & Y & Y & Y \\" ///
// "Province $\times$ Year FE & Y & Y & Y \\" ///
// "\bottomrule" ///
// "\end{tabular}" ///
// "\end{table}" ) append sty(tex)


esttab Robust1_?  using "$revision/Appendix_Table/TableA9.txt", ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s() noobs nogap keep(treat_post) nostar label replace

esttab Robust2_?  using "$revision/Appendix_Table/TableA9.txt", ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s() noobs nogap keep(treat_post) nostar  label append

esttab Robust3_?  using "$revision/Appendix_Table/TableA9.txt", ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s() noobs nogap keep(treat_post) nostar  label append

esttab Robust4_?  using "$revision/Appendix_Table/TableA9.txt", ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s() noobs nogap keep(treat_post) nostar  label append

esttab Robust5_?  using "$revision/Appendix_Table/TableA9.txt", ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s() noobs nogap keep(treat_post) nostar  label append

esttab Robust6_?  using "$revision/Appendix_Table/TableA9.txt", ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s() noobs nogap keep(treat_post) nostar  label append

esttab Robust7_?  using "$revision/Appendix_Table/TableA9.txt", ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s() noobs nogap keep(treat_post) nostar  label append


tempname scs
file open `scs' using "$revision/Appendix_Table/TableA9.txt", text write append
forvalues x = 1/7 {
 file write `scs' `" `N_sample`x'' "' _n
}
file close `scs'

*===============================================================================
*===============================================================================
*** Now create the excat same Table A.9 as in the paper

// use "`tableA9_texdoc'", clear

import delimited "$revision/Appendix_Table/TableA9.txt", ///
clear varnames(nonames) delimiter(" ", collapse)

drop v1 
drop if missing(v2)

gen name = ""
gen row = _n
replace name = "All Sample" if row == 1
replace name = "Drop Missing Coal Data" if row == 4
replace name = "Drop Extreme Values" if row == 7
replace name = "Industry(Electricity$<$50\%)" if row == 10
replace name = "Industry(Electricity$<$30\%)" if row == 13
replace name = "Industry(Electricity$<$25\%)" if row == 16
replace name = "Infilling Missing Coal Data" if row == 19 
order name v* row




texdoc init "$revision/Appendix_Table/TableA9.tex", replace force
tex \begin{tabular}{lcccc} \toprule

tempfile full_Table
save `full_Table', replace

* Title Row
tex  & ln(Energy Use) & ln(Output) & ln(Energy Efficiency) & Top1000 \\
tex \midrule \\
tex \multicolumn{5}{l}{\textbf{Panel A: CESD Data}} \\

* Panels
local Nobs_ctr = 22

forval j = 1/6 {
// local j = 1
// local Nobs_ctr = 22
texdoc local start = 3*(`j'-1) + 1
texdoc local end   = 3*`j'
keep if (row >= `start' & row <= `end') | row == `Nobs_ctr'

* loop over all the estimated coefficients & p-values for each outcome
foreach num in 2 3 4 {
// local num = 2
texdoc local _desc = name[1] 
texdoc local _b`j'_`num'  = v`num'[1] // coefficients
texdoc local _SE`j'_`num' = v`num'[2] // se
texdoc local _p`j'_`num'  = v`num'[3] // p-value
texdoc local _N`j'  = v2[4] // observation count
}
tex & & & & \\
tex  `_desc' & `_b`j'_2'  & `_b`j'_3'   & `_b`j'_4' & `_N`j'' \\
tex          & `_SE`j'_2' & `_SE`j'_3' & `_SE`j'_4' & \\
tex          & `_p`j'_2'  & `_p`j'_3'   & `_p`j'_4' & \\
tex          &            &         & & \\
use `full_Table', clear
texdoc local Nobs_ctr = `Nobs_ctr' + 1
}

tex \hline \\
tex \multicolumn{5}{l}{\textbf{Panel B: CESD and ATS Data}} \\
foreach num in 2 3 4 {
keep if (row >= 19 & row <= 21) | row == 28
texdoc local _desc = name[1] 
texdoc local _b`j'_`num'  = v`num'[1] // coefficients
texdoc local _SE`j'_`num' = v`num'[2] // se
texdoc local _p`j'_`num'  = v`num'[3] // p-value
texdoc local _N`j'  = v2[4] // observation count
}
tex & & & & \\
tex  `_desc' & `_b`j'_2'  & `_b`j'_3'   & `_b`j'_4' & `_N`j'' \\
tex          & `_SE`j'_2' & `_SE`j'_3' & `_SE`j'_4' & \\
tex          & `_p`j'_2'  & `_p`j'_3'   & `_p`j'_4' & \\
tex          &            &         & & \\
use `full_Table', clear


* report fixed effects & controls - [CHANGE] for correct # of coefficients
tex \midrule
tex Firm FE    & Y & Y & Y \\
tex Industry\hspace{.00001em} $\times$ \hspace{.00001em}Year FE & Y & Y & Y \\
tex Province\hspace{.00001em} $\times$ \hspace{.00001em}Year FE & Y & Y & Y \\
tex \bottomrule
tex \end{tabular}
texdoc close

