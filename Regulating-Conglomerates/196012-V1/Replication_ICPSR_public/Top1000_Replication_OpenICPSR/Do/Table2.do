
*Table 2: Spillover Effects on the Related Firms

********************************************************
*  Panel A. Spillover Effects on Related Firms: Output
********************************************************

*=================
*  Pre-Treatment 
*=================

*--------
*  Data 
*--------

use "$revision/Data/Table2_1.dta",clear

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

*------------------
*  Keep Variables 
*------------------

keep firmid year output same_ind4 ind4
keep if year<=2006
ren same_ind4 treat
gen exist=1

*--------------
*  Panel Data
*--------------

xtset firmid year
tsfill,full
xfill ind4,i(firmid)
xfill treat,i(firmid)
replace output=-1 if exist!=1
ren output y

keep firmid year treat ind4 y
order firmid year treat ind4 y
sum firmid year treat ind4 y

*------------
*  Reshape
*------------

reshape wide y,i(firmid) j(year)

*-----------------------
*  Drop Useless Sample
*-----------------------

drop if (y2001==0 | y2001==-1) & (y2002==0 | y2002==-1) & (y2003==0 | y2003==-1) ///
& (y2004==0 | y2004==-1) & (y2005==0 | y2005==-1) & (y2006==0 | y2006==-1)

*-------------------------
*  Drop Useless Controls
*-------------------------

duplicates tag ind4 if treat==1,gen(du_ind4)
replace du_ind4=-1 if du_ind4==.
gsort ind4 -du_ind4
by ind4: replace du_ind4=du_ind4[1]
drop if du_ind4==-1

*---------
*  Order
*---------

gsort -treat -du_ind4 ind4 firmid
order firmid treat ind4 y2001 y2002 y2003 y2004 y2005 y2006
drop du_ind4

sum treat if treat==1
sum treat

export delimited using "$revision/Data/Distance_Matching/Pre_Matching_Output.csv", replace

*====================
*  Distance Matching 
*====================

cd "$revision/Data/Distance_Matching/"
$matlab -nosplash -nodisplay -nodesktop -r Distance_Matching_Output; exit
sleep 10000

*----------------
*  Import Data
*----------------

clear
import delimited "$revision/Data/Distance_Matching/Matching_Result_Output.csv"

label variable v1 "Related ID"
label variable v2 "Control ID"
label variable v3 "Absolute Distance"
label variable v4 "Relative Distance"

ren v1 related
ren v2 control
ren v3 distance
ren v4 distance2

save "$revision/Data/Distance_Matching/Matching_Result_Output.dta",replace

*--------------------------
*  Matched Related Firms
*--------------------------

use "$revision/Data/Distance_Matching/Matching_Result_Output.dta",clear

_pctile distance2,p(95)
return list
local a=r(r1)
drop if distance2>=`a'

keep related
gen weight=1
ren related firmid
gen related=1
save "$revision/Data/Distance_Matching/Distance_Matching_Output_Related.dta",replace

*--------------------------
*  Matched Control Firms
*--------------------------

use "$revision/Data/Distance_Matching/Matching_Result_Output.dta",clear

_pctile distance2,p(95)
return list
local a=r(r1)
drop if distance2>=`a'

duplicates tag control,gen(du)
gen weight=du+1
keep control weight
ren control firmid
duplicates drop firmid,force
gen control=1
save "$revision/Data/Distance_Matching/Distance_Matching_Output_Control.dta",replace

*------------------
*  Treat & Control
*------------------

use "$revision/Data/Table2_1.dta",clear

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Output_Related.dta"
drop if _merge==2
drop _merge

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Output_Control.dta",update
drop if _merge==2
drop _merge

keep if related==1 | control==1
replace related=0 if related==.
replace control=0 if control==.

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

eststo `y'_1: reghdfe `y' `x' [fweight=weight], absorb(`absorb1') cluster(`cluster')
eststo `y'_2: reghdfe `y' `x' [fweight=weight], absorb(`absorb2') cluster(`cluster')
eststo `y'_3: reghdfe `y' `x' [fweight=weight], absorb(`absorb3') cluster(`cluster')
eststo `y'_4: reghdfe `y' `x' `control' [fweight=weight], absorb(`absorb3') cluster(`cluster')

esttab loutput_?  using "$revision/Table/Table2.tex",  ///
preh("\begin{table} \centering" ///
"\caption{\bf Spillover Effects on Related Firms}" ///
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
"\end{tabular}" ) replace 


**************************************************************
*  Panel B. Spillover Effects on Related Firms: Placebo Test 
**************************************************************

*=================
*  Pre-Treatment 
*=================

*--------
*  Data 
*--------

use "$revision/Data/Table2_1.dta",clear

*--------------------------
*  Identify Placebo Firms
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

*------------------
*  Keep Variables 
*------------------

keep firmid year output same_ind2 ind4
keep if year<=2006
ren same_ind2 treat
gen exist=1

*--------------
*  Panel Data
*--------------

xtset firmid year
tsfill,full
xfill ind4,i(firmid)
xfill treat,i(firmid)
replace output=-1 if exist!=1
ren output y

keep firmid year treat ind4 y
order firmid year treat ind4 y
sum firmid year treat ind4 y

*------------
*  Reshape
*------------

reshape wide y,i(firmid) j(year)

*---------------------
*  Drop Useless Sample
*---------------------

drop if (y2001==0 | y2001==-1) & (y2002==0 | y2002==-1) & (y2003==0 | y2003==-1) ///
& (y2004==0 | y2004==-1) & (y2005==0 | y2005==-1) & (y2006==0 | y2006==-1)

*-------------------------
*  Drop Useless Controls
*-------------------------

duplicates tag ind4 if treat==1,gen(du_ind4)
replace du_ind4=-1 if du_ind4==.
gsort ind4 -du_ind4
by ind4: replace du_ind4=du_ind4[1]
drop if du_ind4==-1

*---------
*  Order
*---------

gsort -treat -du_ind4 ind4 firmid
order firmid treat ind4 y2001 y2002 y2003 y2004 y2005 y2006
drop du_ind4

sum treat if treat==1
sum treat

export delimited using "$revision/Data/Distance_Matching/Pre_Matching_Placebo.csv", replace

*====================
*  Distance Matching 
*====================

cd "$revision/Data/Distance_Matching/"
$matlab -nosplash -nodisplay -nodesktop -r Distance_Matching_Placebo; exit
sleep 10000

*----------------
*  Import Data
*----------------

clear
import delimited "$revision/Data/Distance_Matching/Matching_Result_Placebo.csv"

label variable v1 "Related ID"
label variable v2 "Control ID"
label variable v3 "Absolute Distance"
label variable v4 "Relative Distance"

ren v1 related
ren v2 control
ren v3 distance
ren v4 distance2

save "$revision/Data/Distance_Matching/Matching_Result_Placebo.dta",replace

*-------------------------
*  Matched Related Firms
*-------------------------

use "$revision/Data/Distance_Matching/Matching_Result_Placebo.dta",clear

_pctile distance2,p(95)
return list
local a=r(r1)
drop if distance2>=`a'

keep related
gen weight=1
ren related firmid
gen related=1
save "$revision/Data/Distance_Matching/Distance_Matching_Placebo_Related.dta",replace

*------------------------
*  Matched Control Firms
*------------------------

use "$revision/Data/Distance_Matching/Matching_Result_Placebo.dta",clear

_pctile distance2,p(95)
return list
local a=r(r1)
drop if distance2>=`a'

duplicates tag control,gen(du)
gen weight=du+1
keep control weight
ren control firmid
duplicates drop firmid,force
gen control=1
save "$revision/Data/Distance_Matching/Distance_Matching_Placebo_Control.dta",replace

*-------------------
*  Treat & Control
*-------------------

use "$revision/Data/Table2_1.dta",clear

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Placebo_Related.dta"
drop if _merge==2
drop _merge

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Placebo_Control.dta",update
drop if _merge==2
drop _merge

keep if related==1 | control==1
replace related=0 if related==.
replace control=0 if control==.

gen related_post=1 if related==1 & year>=2007
replace related_post=0 if related_post==.
label variable related_post "Related*Post"

*----------------------
* Drop Extreme Values
*----------------------

replace year=2010 if year==2011
xtset firmid year
gen growth=(output-l.output)/l.output
gen growth_raw=growth
winsor2 growth, trim replace
drop if growth==. & growth_raw!=.
drop growth growth_raw
replace year=2011 if year==2010
xtset firmid year

*==================================
* Panel B. Placebo Test on Output
*==================================

local y "loutput"
local x "related_post"
local control "soe roa age exp"
local cluster "firmid"
local absorb1 "firmid year"
local absorb2 "firmid ind2_year"
local absorb3 "firmid ind2_year province_year"

eststo `y'_1: reghdfe `y' `x' [fweight=weight], absorb(`absorb1') cluster(`cluster')
eststo `y'_2: reghdfe `y' `x' [fweight=weight], absorb(`absorb2') cluster(`cluster')
eststo `y'_3: reghdfe `y' `x' [fweight=weight], absorb(`absorb3') cluster(`cluster')
eststo `y'_4: reghdfe `y' `x' `control' [fweight=weight], absorb(`absorb3') cluster(`cluster')

esttab loutput_?  using "$revision/Table/Table2.tex",  ///
preh("\\ $\;$\\ \\ $\;$\\ {\bf B. Placebo Test on Output} \\ $\;$\\" ///
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

*************************************************************************************
*  Panel C & D. Spillover Effects on Related Firms: Energy Use and Energy Efficiency
*************************************************************************************

*=================
*  Pre-Treatment 
*=================

*--------
*  Data 
*--------

use "$revision/Data/Table2_2.dta",clear

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

*------------------
*  Keep Variables 
*------------------

keep firmid year energy same_ind4 ind4
keep if year<=2006
ren same_ind4 treat
gen exist=1

*--------------
*  Panel Data
*--------------

xtset firmid year
tsfill,full
xfill ind4,i(firmid)
xfill treat,i(firmid)
replace energy=-1 if exist!=1
ren energy y

keep firmid year treat ind4 y
order firmid year treat ind4 y
sum firmid year treat ind4 y

*------------
*  Reshape
*------------

reshape wide y,i(firmid) j(year)

*---------------------
*  Drop Useless Sample
*---------------------

drop if (y2001==0 | y2001==-1) & (y2002==0 | y2002==-1) & (y2003==0 | y2003==-1) ///
& (y2004==0 | y2004==-1) & (y2005==0 | y2005==-1) & (y2006==0 | y2006==-1)

*-------------------------
*  Drop Useless Controls
*-------------------------

duplicates tag ind4 if treat==1,gen(du_ind4)
replace du_ind4=-1 if du_ind4==.
gsort ind4 -du_ind4
by ind4: replace du_ind4=du_ind4[1]
drop if du_ind4==-1

*---------
*  Order
*---------

gsort -treat -du_ind4 ind4 firmid
order firmid treat ind4 y2001 y2002 y2003 y2004 y2005 y2006
drop du_ind4

sum treat if treat==1
sum treat

export delimited using "$revision/Data/Distance_Matching/Pre_Matching_Energy.csv", replace

*====================
*  Distance Matching 
*====================

cd "$revision/Data/Distance_Matching/"
$matlab -nosplash -nodisplay -nodesktop -r Distance_Matching_Energy; exit
sleep 10000

*----------------
*  Import Data
*----------------

clear
import delimited "$revision/Data/Distance_Matching/Matching_Result_Energy.csv"

label variable v1 "Related ID"
label variable v2 "Control ID"
label variable v3 "Absolute Distance"
label variable v4 "Relative Distance"

ren v1 related
ren v2 control
ren v3 distance
ren v4 distance2

save "$revision/Data/Distance_Matching/Matching_Result_Energy.dta",replace

*--------------------------
*  Matched Related Firms
*--------------------------

use "$revision/Data/Distance_Matching/Matching_Result_Energy.dta",clear

_pctile distance2,p(95)
return list
local a=r(r1)
drop if distance2>=`a'

keep related
gen weight=1
ren related firmid
gen related=1
save "$revision/Data/Distance_Matching/Distance_Matching_Energy_Related.dta",replace

*--------------------------
*  Matched Control Firms
*--------------------------

use "$revision/Data/Distance_Matching/Matching_Result_Energy.dta",clear

_pctile distance2,p(95)
return list
local a=r(r1)
drop if distance2>=`a'

duplicates tag control,gen(du)
gen weight=du+1
keep control weight
ren control firmid
duplicates drop firmid,force
gen control=1
save "$revision/Data/Distance_Matching/Distance_Matching_Energy_Control.dta",replace

*------------------
* Treat & Control
*------------------

use "$revision/Data/Table2_2.dta",clear

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Energy_Related.dta"
drop if _merge==2
drop _merge

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Energy_Control.dta",update
drop if _merge==2
drop _merge

keep if related==1 | control==1
replace related=0 if related==.
replace control=0 if control==.

gen related_post=1 if related==1 & year>=2007
replace related_post=0 if related_post==.
label variable related_post "Related*Post"

*=======================
* Panel C. Energy Use 
*=======================

local y "lenergy"
local x "related_post"
local control "soe roa age exp"
local cluster "firmid"
local absorb1 "firmid year"
local absorb2 "firmid ind2_year"
local absorb3 "firmid ind2_year province_year"

eststo `y'_1: reghdfe `y' `x' [fweight=weight], absorb(`absorb1') cluster(`cluster')
eststo `y'_2: reghdfe `y' `x' [fweight=weight], absorb(`absorb2') cluster(`cluster')
eststo `y'_3: reghdfe `y' `x' [fweight=weight], absorb(`absorb3') cluster(`cluster')
eststo `y'_4: reghdfe `y' `x' `control' [fweight=weight], absorb(`absorb3') cluster(`cluster')

esttab lenergy_?  using "$revision/Table/Table2.tex",  ///
preh("\\ $\;$\\ {\bf C. Energy Use} \\ $\;$\\" ///
"\begin{tabular}{l c c c c}") ///
stats() posth("\toprule" ///
"Variables & \multicolumn{4}{c}{ln(Energy Use)} \\" ///
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
"\end{tabular}" )  append sty(tex)

*==============================
* Panel D. Energy Efficiency
*==============================

local z "lefficiency"
local x "related_post"
local control "soe roa age exp"
local cluster "firmid"
local absorb1 "firmid year"
local absorb2 "firmid ind2_year"
local absorb3 "firmid ind2_year province_year"

eststo `z'_1: reghdfe `z' `x' [fweight=weight], absorb(`absorb1') cluster(`cluster')
eststo `z'_2: reghdfe `z' `x' [fweight=weight], absorb(`absorb2') cluster(`cluster')
eststo `z'_3: reghdfe `z' `x' [fweight=weight], absorb(`absorb3') cluster(`cluster')
eststo `z'_4: reghdfe `z' `x' `control' [fweight=weight], absorb(`absorb3') cluster(`cluster')

esttab lefficiency_?  using "$revision/Table/Table2.tex",  ///
preh("\\ $\;$\\ \\ $\;$\\ {\bf D. Energy Efficiency} \\ $\;$\\" ///
"\begin{tabular}{l c c c c}") ///
stats() posth("\toprule" ///
"Variables & \multicolumn{4}{c}{ln(Energy Efficiency)} \\" ///
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
"\end{table}" ) append sty(tex)

