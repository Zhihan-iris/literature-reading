
*Table A.38 Direct and Spillover Effects of Top10,000 Program

*****************************
*  Panel A: Regulated Firms
*****************************

use "$revision/Data/TableA38_A.dta",clear

local x "treat_post"
local control "soe roa age exp"
local cluster "firmid"
local absorb1 "firmid year"
local absorb2 "firmid ind2_year"
local absorb3 "firmid ind2_year province_year"

foreach y of varlist loutput {
       eststo `y'_1: reghdfe `y' `x', absorb(`absorb1') cluster(`cluster')
       eststo `y'_2: reghdfe `y' `x', absorb(`absorb2') cluster(`cluster')
       eststo `y'_3: reghdfe `y' `x', absorb(`absorb3') cluster(`cluster')
       eststo `y'_4: reghdfe `y' `x' `control', absorb(`absorb3') cluster(`cluster')
      }

esttab loutput_?  using "$revision/Appendix_Table/TableA38.tex",  ///
preh("\begin{table} \centering" ///
"\caption{\bf Direct and Spillover Effects of the Top 10,000 Program}" ///
"\\ $\;$\\ {\bf A. Regulated Firms} \\ $\;$\\" ///
"\begin{tabular}{l c c c c}") ///
stats() posth("\toprule" ///
"Variables & \multicolumn{4}{c}{ln(Output)} \\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(treat_post) coeflabel(treat_post "Treat $\times$ Post") label /// 
prefoot("\hline") postfoot( ///
"\hline" ///
"Firm FE & Y & Y & Y & Y \\" ///
"Year FE & Y & Y & Y & Y \\" ///
"Industry $\times$ Year FE & {} & Y & Y & Y \\" ///
"Province $\times$ Year FE & {} & {} & Y & Y \\" ///
"Firm-level Controls & {} & {} & {} & Y \\" ///
"\bottomrule" ///
"\end{tabular}" ) replace 

***************************
*  Panel B: Related Firms
***************************

*=================
*  Pre-Treatment 
*=================

use "$revision/Data/TableA38_B.dta",clear

*------------------
*  Keep Variables 
*------------------

keep firmid year output top10000_related ind4
keep if year<=2011
ren top10000_related treat
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

drop y2010
drop if (y2009==0 | y2009==-1) & (y2011==0 | y2011==-1) 

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
order firmid treat ind4 y2009 y2011
drop du_ind4

sum treat if treat==1
sum treat

export delimited using "$revision/Data/Distance_Matching/Pre_Matching_Top10000.csv", replace

*====================
*  Distance Matching 
*====================

cd "$revision/Data/Distance_Matching/"
$matlab -nosplash -nodisplay -nodesktop -r Distance_Matching_Top10000; exit
sleep 30000

*----------------
*  Import Data
*----------------

clear
import delimited "$revision/Data/Distance_Matching/Matching_Result_Top10000.csv"

label variable v1 "Related ID"
label variable v2 "Control ID"
label variable v3 "Absolute Distance"
label variable v4 "Relative Distance"

ren v1 related
ren v2 control
ren v3 distance
ren v4 distance2

save "$revision/Data/Distance_Matching/Matching_Result_Top10000.dta",replace

*--------------------------
*  Matched Related Firms
*--------------------------

use "$revision/Data/Distance_Matching/Matching_Result_Top10000.dta",clear

_pctile distance2,p(99)
return list
local a=r(r1)
drop if distance2>=`a'

keep related
gen weight=1
ren related firmid
gen related=1
save "$revision/Data/Distance_Matching/Distance_Matching_Top10000_Related.dta",replace

*--------------------------
*  Matched Control Firms
*--------------------------

use "$revision/Data/Distance_Matching/Matching_Result_Top10000.dta",clear

_pctile distance2,p(99)
return list
local a=r(r1)
drop if distance2>=`a'

duplicates tag control,gen(du)
gen weight=du+1
keep control weight
ren control firmid
duplicates drop firmid,force
gen control=1
save "$revision/Data/Distance_Matching/Distance_Matching_Top10000_Control.dta",replace

*------------------
*  Treat & Control
*------------------

use "$revision/Data/TableA38_B.dta",clear

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Top10000_Related.dta",update
drop if _merge==2
drop _merge

merge m:1 firmid using "$revision/Data/Distance_Matching/Distance_Matching_Top10000_Control.dta",update
drop if _merge==2
drop _merge

keep if related==1 | control==1
replace related=0 if related==.
replace control=0 if control==.

gen related_post=1 if related==1 & year>=2012
replace related_post=0 if related_post==.
label variable related_post "Related*Post"

*--------------
*  Size Group
*--------------

_pctile output if year==2011 & top10000_related==1, p(90)
local a=r(r1)
dis `a'

gen group1=1 if year==2011 & top10000_related==1 & output<=`a'
gen group2=1 if year==2011 & top10000_related==1 & output>`a'

xtset firmid year
forvalues i=1(1)2 {
	xfill group`i',i(firmid)
	replace group`i'=0 if group`i'==.
	gen related_post_tier`i'=related_post*group`i'
}

*--------------
*  Regression
*--------------

local y "loutput"
local x "related_post_tier1 related_post_tier2"
local control "soe roa age exp"
local cluster "firmid"
local absorb1 "firmid year"
local absorb2 "firmid ind2_year"
local absorb3 "firmid ind2_year province_year"

eststo `y'_1: reghdfe `y' `x' [fweight=weight], absorb(`absorb1') cluster(`cluster')
eststo `y'_2: reghdfe `y' `x' [fweight=weight], absorb(`absorb2') cluster(`cluster')
eststo `y'_3: reghdfe `y' `x' [fweight=weight], absorb(`absorb3') cluster(`cluster')
eststo `y'_4: reghdfe `y' `x' `control' [fweight=weight], absorb(`absorb3') cluster(`cluster')

esttab loutput_?  using "$revision/Appendix_Table/TableA38.tex",  ///
preh("\\ $\;$\\ \\ $\;$\\ {\bf B. Related Firms} \\ $\;$\\" ///
"\begin{tabular}{l c c c c}") ///
stats() posth("\toprule" ///
"Variables & \multicolumn{4}{c}{ln(Output)} \\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(related_post_tier1 related_post_tier2) ///
coeflabel(related_post_tier1 "Related(0\%-90\%) $\times$ Post" ///
related_post_tier2 "Related(90\%-100\%) $\times$ Post" ) label /// 
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

*******************************
*  Panel C: Market Spillover
*******************************

use "$revision/Data/TableA38_C.dta",clear

local y "loutput"
local x "spillover_post"
local ind_control "loutput_ind2 lenergy_ind2"
local firm_control "soe roa age exp"
local cluster "ind2"
local absorb1 "firmid year"
local if "if top1000_industry==1"

eststo `y'_1: reghdfe `y' `x' `ind_control', absorb(`absorb1') cluster(`cluster')
eststo `y'_2: reghdfe `y' `x' `ind_control' `firm_control', absorb(`absorb1') cluster(`cluster')
eststo `y'_3: reghdfe `y' `x' `ind_control' `if', absorb(`absorb1') cluster(`cluster')
eststo `y'_4: reghdfe `y' `x' `ind_control' `firm_control' `if', absorb(`absorb1') cluster(`cluster')

esttab loutput_?  using "$revision/Appendix_Table/TableA38.tex",  ///
preh("\\ $\;$\\ \\ $\;$\\ {\bf C. Market Spillover} \\ $\;$\\" ///
"\begin{tabular}{l c c c c}") ///
stats() posth("\toprule" ///
"\multirow{2}{*}{Variables} & \multicolumn{4}{c}{ln(Output)} \\" ///
"\cline{2-5}" ///
"{} & \multicolumn{2}{c}{All Sample} & \multicolumn{2}{c}{Energy-Intensive Industries}\\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(spillover_post) coeflabel(spillover_post "Spillover $\times$ Post") label /// 
prefoot("\hline") postfoot( ///
"\hline" ///
"Firm FE & Y & Y & Y & Y \\" ///
"Year FE & Y & Y & Y & Y \\" ///
"Industry-level Controls & Y & Y & Y & Y \\" ///
"Firm-level Controls & {} & Y & {} & Y \\" ///
"\bottomrule" ///
"\end{tabular}" ///
"\end{table}" ) append sty(tex)
