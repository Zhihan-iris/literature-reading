
*Table A.22: Robustness of Spillovers to Related Firms on Output: Entropy Matching

***********************************************************
*  Panel A. Related Spillover on Output: Entropy Matching
***********************************************************

*==============================
*  Pre-Treatment of Balancing
*==============================

*--------
*  Data 
*--------

use "$revision/Data/TableA22.dta",clear
	
*--------------------------
*  Identify Related Firms
*--------------------------

merge m:1 legcode using "$revision/Data/TableA7_2.dta"
drop if _merge==2
drop _merge

merge m:1 name using "$revision/Data/TableA7_1.dta",update
drop if _merge==2
drop _merge

replace same_ind4=. if same_ind4==0
xtset firmid year
xfill same_ind4,i(firmid)
replace same_ind4=0 if same_ind4==.

*----------------------------
*  Keep Matching Variables 
*----------------------------

keep firmid year loutput same_ind4 ind4
keep if year<=2006 & year>=2001
ren same_ind4 treat
ren loutput y

*------------
*  Reshape
*------------

reshape wide y,i(firmid) j(year)

*-----------------------------------------------
*  Drop Controls in Industries Without Related
*-----------------------------------------------

duplicates tag ind4 if treat==1,gen(du_ind4)
replace du_ind4=-1 if du_ind4==.
gsort ind4 -du_ind4
by ind4: replace du_ind4=du_ind4[1]
drop if du_ind4==-1

gsort -treat -du_ind4 ind4 firmid

keep firmid treat ind4 y2001 y2002 y2003 y2004 y2005 y2006
order firmid treat ind4 y2001 y2002 y2003 y2004 y2005 y2006

*=====================
*  Entropy Balancing
*=====================

* Balancing on 2001-2006 Output Level & 4-digit Industry

ebalance treat y2001 y2002 y2003 y2004 y2005 y2006 i.ind4, targets(1)
keep firmid treat _webal
ren treat related
save "$revision/Data/Entropy_Matching/Entropy_Matching_Result_Output.dta",replace

*================================
*  Add Balancing Weight to ASIF 
*================================

use "$revision/Data/TableA22.dta",clear

*---------------------
*  Related & Control
*---------------------

merge m:1 firmid using "$revision/Data/Entropy_Matching/Entropy_Matching_Result_Output.dta"
keep if _merge==3
drop _merge

*------------------------------
*  Difference in Differences
*------------------------------

gen related_post=1 if related==1 & year>=2007
replace related_post=0 if related_post==.
label variable related_post "Related*Post"

*==================
* Panel A. Output
*==================

local y "loutput"
local x "related_post"
local control "soe roa age exp"
local cluster "firmid"
local absorb1 "firmid year"
local absorb2 "firmid ind2_year"
local absorb3 "firmid ind2_year province_year"

eststo `y'_1: reghdfe `y' `x' [pweight=_webal], absorb(`absorb1') cluster(`cluster')
eststo `y'_2: reghdfe `y' `x' [pweight=_webal], absorb(`absorb2') cluster(`cluster')
eststo `y'_3: reghdfe `y' `x' [pweight=_webal], absorb(`absorb3') cluster(`cluster')
eststo `y'_4: reghdfe `y' `x' `control' [pweight=_webal], absorb(`absorb3') cluster(`cluster')

esttab loutput_?  using "$revision/Appendix_Table/TableA22.tex",  ///
preh("\begin{table} \centering" ///
"\caption{\bf Robustness of Spillovers to Related Firms on Output Using Entropy Matching}" ///
"\\ $\;$\\ {\bf A. Output} \\ $\;$\\" ///
"\begin{tabular}{l c c c c}") ///
stats() posth("\toprule" ///
"Variables & \multicolumn{4}{c}{ln(Output)} \\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(related_post) coeflabel(related_post "Related $\times$ Post") label /// 
prefoot("\hline") postfoot( ///
"\hline" ///
"Firm FE & Y & Y & Y & Y \\" ///
"Year FE & Y & Y & Y & Y \\" ///
"Industry $\times$ Year FE & {} & Y & Y & Y \\" ///
"Province $\times$ Year FE & {} & {} & Y & Y \\" ///
"Firm-level Controls & {} & {} & {} & Y \\" ///
"\bottomrule" ///
"\end{tabular}" ///
"\end{table}" ) replace 

*******************************************************
*  Panel B. Placebo Test on Output: Entropy Matching
*******************************************************

*==============================
*  Pre-Treatment of Balancing
*==============================

*--------
*  Data 
*--------

use "$revision/Data/TableA22.dta",clear

*--------------------------
*  Identify Related Firms
*--------------------------

merge m:1 legcode using "$revision/Data/TableA7_2.dta"
drop if _merge==2
drop _merge

merge m:1 name using "$revision/Data/TableA7_1.dta",update
drop if _merge==2
drop _merge

replace same_ind4=. if same_ind4==0
xtset firmid year
xfill same_ind4,i(firmid)
replace same_ind4=0 if same_ind4==.
drop if same_ind4==1

replace same_ind2=. if same_ind2==0
xtset firmid year
xfill same_ind2,i(firmid)
replace same_ind2=0 if same_ind2==.

*---------------------------
*  Keep Matching Variables 
*---------------------------

keep firmid year loutput same_ind2 ind4
keep if year<=2006 & year>=2001
ren  same_ind2 treat
ren loutput y

*------------
*  Reshape
*------------

reshape wide y,i(firmid) j(year)

*-----------------------------------------------
*  Drop Controls in Industries Without Related
*-----------------------------------------------

duplicates tag ind4 if treat==1,gen(du_ind4)
replace du_ind4=-1 if du_ind4==.
gsort ind4 -du_ind4
by ind4: replace du_ind4=du_ind4[1]
drop if du_ind4==-1

gsort -treat -du_ind4 ind4 firmid

keep firmid treat ind4 y2001 y2002 y2003 y2004 y2005 y2006
order firmid treat ind4 y2001 y2002 y2003 y2004 y2005 y2006

*=====================
*  Entropy Balancing
*=====================

* Balancing on 2001-2006 Output Level & 4-digit Industry

ebalance treat y2001 y2002 y2003 y2004 y2005 y2006 i.ind4, targets(1)
keep firmid treat _webal
ren treat related
save "$revision/Data/Entropy_Matching/Entropy_Matching_Result_Placebo.dta",replace

*================================
*  Add Balancing Weight to ASIF 
*================================

use "$revision/Data/TableA22.dta",clear

*---------------------
*  Related & Control
*---------------------

merge m:1 firmid using "$revision/Data/Entropy_Matching/Entropy_Matching_Result_Placebo.dta"
keep if _merge==3
drop _merge

*------------------------------
*  Difference in Differences
*------------------------------

gen related_post=1 if related==1 & year>=2007
replace related_post=0 if related_post==.
label variable related_post "Related*Post"

*----------------------
*  Drop Extreme Values
*----------------------

replace year=2010 if year==2011
xtset firmid year
gen growth=(loutput-l.loutput)/l.loutput
gen growth_raw=growth
winsor2 growth, trim replace
drop if growth==. & growth_raw!=.
drop growth growth_raw
replace year=2011 if year==2010
xtset firmid year

*===================================
* Panel B. Placebo Test on Output
*===================================

local y "loutput"
local x "related_post"
local control "soe roa age exp"
local cluster "firmid"
local absorb1 "firmid year"
local absorb2 "firmid ind2_year"
local absorb3 "firmid ind2_year province_year"

eststo `y'_1: reghdfe `y' `x' [pweight=_webal], absorb(`absorb1') cluster(`cluster')
eststo `y'_2: reghdfe `y' `x' [pweight=_webal], absorb(`absorb2') cluster(`cluster')
eststo `y'_3: reghdfe `y' `x' [pweight=_webal], absorb(`absorb3') cluster(`cluster')
eststo `y'_4: reghdfe `y' `x' `control' [pweight=_webal], absorb(`absorb3') cluster(`cluster')

esttab loutput_?  using "$revision/Appendix_Table/TableA22.tex",  ///
preh("\\ $\;$\\ \\ $\;$\\ {\bf B. Placebo on Output} \\ $\;$\\" ///
"\begin{tabular}{l c c c c}") ///
stats() posth("\toprule" ///
"Variables & \multicolumn{4}{c}{ln(Output)} \\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(related_post) coeflabel(related_post "Related $\times$ Post") label /// 
prefoot("\hline") postfoot( ///
"\hline" ///
"Firm FE & Y & Y & Y & Y \\" ///
"Year FE & Y & Y & Y & Y \\" ///
"Industry $\times$ Year FE & {} & Y & Y & Y \\" ///
"Province $\times$ Year FE & {} & {} & Y & Y \\" ///
"Firm-level Controls & {} & {} & {} & Y \\" ///
"\bottomrule" ///
"\end{tabular}" ) append sty(tex)

