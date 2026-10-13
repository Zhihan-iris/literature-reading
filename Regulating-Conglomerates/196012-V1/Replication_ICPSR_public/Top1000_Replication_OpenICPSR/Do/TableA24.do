
* Table A.24 Spillover Effects on the Output of Related Firms: Robustness to Different Definitions of Related Parties

********************************************************************************
*              Scalars: Output Share of Related to Top1000
********************************************************************************

*======================================================
*  Column(2): Drop Samples with Shareholding Changes
*======================================================

use "$revision/Data/TableA24_3.dta",clear

keep if year==2006
keep if output!=0

sum output if top1000==1
local a=r(mean)

sum output if top1000_related==1
local b=r(mean)

local resultII = `b'/`a'
dis `resultII'

*=============================
*  Column(3): Six Level 20%
*=============================

use "$revision/Data/TableA24_4.dta",clear

keep if year==2006
keep if output!=0

sum output if top1000==1
local a=r(mean)

sum output if top1000_related==1
local b=r(mean)

local resultIII = `b'/`a'
dis `resultIII'

*=============================
*  Column(4): Two Level 20%
*=============================

use "$revision/Data/TableA24_5.dta",clear

keep if year==2006
keep if output!=0

sum output if top1000==1
local a=r(mean)

sum output if top1000_related==1
local b=r(mean)

local resultIV = `b'/`a'
dis `resultIV'

*=============================
*  Column(5): Two Level 51%
*=============================

use "$revision/Data/TableA24_6.dta",clear

keep if year==2006
keep if output!=0

sum output if top1000==1
local a=r(mean)

sum output if top1000_related==1
local b=r(mean)

local resultV = `b'/`a'
dis `resultV'

clear
mat A=(`resultII',`resultIII',`resultIV',`resultV')
svmat A
gen rank=1

tostring A1, force replace format(%9.3f)
tostring A2, force replace format(%9.3f)
tostring A3, force replace format(%9.3f)
tostring A4, force replace format(%9.3f)

set obs 2

replace A1="Without Shareholding Changes" in 2
replace A2="Six Level 20%" in 2
replace A3="Two Level 20%" in 2
replace A4="Two Level 51%" in 2
replace rank=2 in 2

gsort -rank
drop rank

listtex * using "$revision/Appendix_Table/TableA24.tex", replace rstyle(tabular)

************************
*  Column(1): Baseline
************************

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

local y "loutput"
local x "related_post"
local control "soe roa age exp"
local cluster "firmid"
local absorb3 "firmid ind2_year province_year"

eststo Definition_1: reghdfe `y' `x' `control' [fweight=weight], absorb(`absorb3') cluster(`cluster')


*******************************************************
*  Column(2): Drop Samples with Shareholding Changes
*******************************************************

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

merge m:1 legcode using "$revision/Data/TableA24_2.dta"
drop if _merge==2
drop _merge

merge m:1 name using "$revision/Data/TableA24_1.dta",update
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

export delimited using "$revision/Data/Distance_Matching/Pre_Matching_Relation.csv", replace

*====================
*  Distance Matching 
*====================

cd "$revision/Data/Distance_Matching/"
$matlab -nosplash -nodisplay -nodesktop -r Distance_Matching_Relation; exit
sleep 10000

*----------------
*  Import Data
*----------------

clear
import delimited "$revision/Data/Distance_Matching/Matching_Result_Relation.csv"

label variable v1 "Related ID"
label variable v2 "Control ID"
label variable v3 "Absolute Distance"
label variable v4 "Relative Distance"

ren v1 related
ren v2 control
ren v3 distance
ren v4 distance2

save "$revision/Data/Distance_Matching/Matching_Result_Relation.dta",replace

*--------------------------
*  Matched Related Firms
*--------------------------

use "$revision/Data/Distance_Matching/Matching_Result_Relation.dta",clear

_pctile distance2,p(95)
return list
local a=r(r1)
drop if distance2>=`a'

keep related
gen weight=1
ren related firmid
gen related=1
save "$revision/Data/Distance_Matching/Distance_Matching_Relation_Related.dta",replace

*--------------------------
*  Matched Control Firms
*--------------------------

use "$revision/Data/Distance_Matching/Matching_Result_Relation.dta",clear

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
save "$revision/Data/Distance_Matching/Distance_Matching_Relation_Control.dta",replace

*------------------
*  Treat & Control
*------------------

use "$revision/Data/Table2_1.dta",clear

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Relation_Related.dta"
drop if _merge==2
drop _merge

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Relation_Control.dta",update
drop if _merge==2
drop _merge

keep if related==1 | control==1
replace related=0 if related==.
replace control=0 if control==.

gen related_post=1 if related==1 & year>=2007
replace related_post=0 if related_post==.
label variable related_post "Related*Post"

*------------
* Regression
*------------

local y "loutput"
local x "related_post"
local control "soe roa age exp"
local cluster "firmid"
local absorb3 "firmid ind2_year province_year"

eststo Definition_2: reghdfe `y' `x' `control' [fweight=weight], absorb(`absorb3') cluster(`cluster')

******************************
*  Column(3): Six Level 20%
******************************

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

merge m:1 legcode using "$revision/Data/TableA7_4.dta"
drop if _merge==2
drop _merge

merge m:1 name using "$revision/Data/TableA7_3.dta",update
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

export delimited using "$revision/Data/Distance_Matching/Pre_Matching_Relation.csv", replace

*====================
*  Distance Matching 
*====================

cd "$revision/Data/Distance_Matching/"
$matlab -nosplash -nodisplay -nodesktop -r Distance_Matching_Relation; exit
sleep 10000

*----------------
*  Import Data
*----------------

clear
import delimited "$revision/Data/Distance_Matching/Matching_Result_Relation.csv"

label variable v1 "Related ID"
label variable v2 "Control ID"
label variable v3 "Absolute Distance"
label variable v4 "Relative Distance"

ren v1 related
ren v2 control
ren v3 distance
ren v4 distance2

save "$revision/Data/Distance_Matching/Matching_Result_Relation.dta",replace

*--------------------------
*  Matched Related Firms
*--------------------------

use "$revision/Data/Distance_Matching/Matching_Result_Relation.dta",clear

_pctile distance2,p(95)
return list
local a=r(r1)
drop if distance2>=`a'

keep related
gen weight=1
ren related firmid
gen related=1
save "$revision/Data/Distance_Matching/Distance_Matching_Relation_Related.dta",replace

*--------------------------
*  Matched Control Firms
*--------------------------

use "$revision/Data/Distance_Matching/Matching_Result_Relation.dta",clear

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
save "$revision/Data/Distance_Matching/Distance_Matching_Relation_Control.dta",replace

*------------------
*  Treat & Control
*------------------

use "$revision/Data/Table2_1.dta",clear

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Relation_Related.dta"
drop if _merge==2
drop _merge

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Relation_Control.dta",update
drop if _merge==2
drop _merge

keep if related==1 | control==1
replace related=0 if related==.
replace control=0 if control==.

gen related_post=1 if related==1 & year>=2007
replace related_post=0 if related_post==.
label variable related_post "Related*Post"

*------------
* Regression
*------------

local y "loutput"
local x "related_post"
local control "soe roa age exp"
local cluster "firmid"
local absorb3 "firmid ind2_year province_year"

eststo Definition_3: reghdfe `y' `x' `control' [fweight=weight], absorb(`absorb3') cluster(`cluster')

******************************
*  Column(4): Two Level 20%
******************************

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

merge m:1 legcode using "$revision/Data/TableA7_6.dta"
drop if _merge==2
drop _merge

merge m:1 name using "$revision/Data/TableA7_5.dta",update
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

export delimited using "$revision/Data/Distance_Matching/Pre_Matching_Relation.csv", replace

*====================
*  Distance Matching 
*====================

cd "$revision/Data/Distance_Matching/"
$matlab -nosplash -nodisplay -nodesktop -r Distance_Matching_Relation; exit
sleep 10000

*----------------
*  Import Data
*----------------

clear
import delimited "$revision/Data/Distance_Matching/Matching_Result_Relation.csv"

label variable v1 "Related ID"
label variable v2 "Control ID"
label variable v3 "Absolute Distance"
label variable v4 "Relative Distance"

ren v1 related
ren v2 control
ren v3 distance
ren v4 distance2

save "$revision/Data/Distance_Matching/Matching_Result_Relation.dta",replace

*--------------------------
*  Matched Related Firms
*--------------------------

use "$revision/Data/Distance_Matching/Matching_Result_Relation.dta",clear

_pctile distance2,p(95)
return list
local a=r(r1)
drop if distance2>=`a'

keep related
gen weight=1
ren related firmid
gen related=1
save "$revision/Data/Distance_Matching/Distance_Matching_Relation_Related.dta",replace

*--------------------------
*  Matched Control Firms
*--------------------------

use "$revision/Data/Distance_Matching/Matching_Result_Relation.dta",clear

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
save "$revision/Data/Distance_Matching/Distance_Matching_Relation_Control.dta",replace

*------------------
*  Treat & Control
*------------------

use "$revision/Data/Table2_1.dta",clear

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Relation_Related.dta"
drop if _merge==2
drop _merge

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Relation_Control.dta",update
drop if _merge==2
drop _merge

keep if related==1 | control==1
replace related=0 if related==.
replace control=0 if control==.

gen related_post=1 if related==1 & year>=2007
replace related_post=0 if related_post==.
label variable related_post "Related*Post"

*------------
* Regression
*------------

local y "loutput"
local x "related_post"
local control "soe roa age exp"
local cluster "firmid"
local absorb3 "firmid ind2_year province_year"

eststo Definition_4: reghdfe `y' `x' `control' [fweight=weight], absorb(`absorb3') cluster(`cluster')

******************************
*  Column(5): Two Level 51%
******************************

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

merge m:1 legcode using "$revision/Data/TableA7_8.dta"
drop if _merge==2
drop _merge

merge m:1 name using "$revision/Data/TableA7_7.dta",update
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

export delimited using "$revision/Data/Distance_Matching/Pre_Matching_Relation.csv", replace

*====================
*  Distance Matching 
*====================

cd "$revision/Data/Distance_Matching/"
$matlab -nosplash -nodisplay -nodesktop -r Distance_Matching_Relation; exit
sleep 10000

*----------------
*  Import Data
*----------------

clear
import delimited "$revision/Data/Distance_Matching/Matching_Result_Relation.csv"

label variable v1 "Related ID"
label variable v2 "Control ID"
label variable v3 "Absolute Distance"
label variable v4 "Relative Distance"

ren v1 related
ren v2 control
ren v3 distance
ren v4 distance2

save "$revision/Data/Distance_Matching/Matching_Result_Relation.dta",replace

*--------------------------
*  Matched Related Firms
*--------------------------

use "$revision/Data/Distance_Matching/Matching_Result_Relation.dta",clear

_pctile distance2,p(95)
return list
local a=r(r1)
drop if distance2>=`a'

keep related
gen weight=1
ren related firmid
gen related=1
save "$revision/Data/Distance_Matching/Distance_Matching_Relation_Related.dta",replace

*--------------------------
*  Matched Control Firms
*--------------------------

use "$revision/Data/Distance_Matching/Matching_Result_Relation.dta",clear

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
save "$revision/Data/Distance_Matching/Distance_Matching_Relation_Control.dta",replace

*------------------
*  Treat & Control
*------------------

use "$revision/Data/Table2_1.dta",clear

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Relation_Related.dta"
drop if _merge==2
drop _merge

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Relation_Control.dta",update
drop if _merge==2
drop _merge

keep if related==1 | control==1
replace related=0 if related==.
replace control=0 if control==.

gen related_post=1 if related==1 & year>=2007
replace related_post=0 if related_post==.
label variable related_post "Related*Post"

*------------
* Regression
*------------

local y "loutput"
local x "related_post"
local control "soe roa age exp"
local cluster "firmid"
local absorb1 "firmid year"
local absorb2 "firmid ind2_year"
local absorb3 "firmid ind2_year province_year"

eststo Definition_5: reghdfe `y' `x' `control' [fweight=weight], absorb(`absorb3') cluster(`cluster')


esttab Definition_?  using "$revision/Appendix_Table/TableA24.tex",  ///
preh("\begin{table} \centering" ///
"\caption{\bf Spillover Effects on the Output of Related Firms: Robustness to Different Definitions of Related Parties}" ///
"\begin{tabular}{l c c c c}") ///
stats() posth("\toprule" ///
"Variables & \multicolumn{5}{c}{ln(Output)} \\" ///
" & Baseline & Drop Changes & 6 Level, 20\% & 2 Level, 20\% & 2 Level, 51\% \\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(related_post) coeflabel(related_post "Related $\times$ Post") label /// 
prefoot("\hline") postfoot( ///
"\hline" ///
"Firm FE & Y & Y & Y & Y & Y \\" ///
"Industry $\times$ Year FE & Y & Y & Y & Y & Y \\" ///
"Province $\times$ Year FE & Y & Y & Y & Y & Y \\" ///
"Firm-level Controls & Y & Y & Y & Y & Y \\" ///
"\bottomrule" ///
"\end{tabular}" ///
"\end{table}" ) append

