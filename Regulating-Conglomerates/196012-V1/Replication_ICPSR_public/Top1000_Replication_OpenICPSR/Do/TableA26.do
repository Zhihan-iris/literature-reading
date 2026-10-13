
*Table A.26: Data Quality Robustness

*-------------------
*  Regulated Firms
*-------------------

use "$revision/Data/Table1.dta",clear

* Data Cleaning

winsor2 loutput loutput_robust2, trim replace cut(5 95)

gen diff=(exp(loutput_robust2)-exp(loutput))/exp(loutput)
_pctile diff, p(5 95)
local a=r(r1)
local b=r(r2)
gen outlier=1 if (diff<`a'| diff>`b') & diff!=.
xtset firmid year
xfill outlier
drop if outlier==1

* Regression

local x "treat_post"
local control "soe roa age exp"
local cluster "firmid"
local absorb1 "firmid year"
local absorb2 "firmid ind2_year"
local absorb3 "firmid ind2_year province_year"
local if "if year<2009"

foreach y of varlist loutput_ASIF {
       eststo regulated1_1: reghdfe `y' `x' `if', absorb(`absorb1') cluster(`cluster')
       eststo regulated1_2: reghdfe `y' `x' `if', absorb(`absorb2') cluster(`cluster')
       eststo regulated1_3: reghdfe `y' `x' `if', absorb(`absorb3') cluster(`cluster')
       eststo regulated1_4: reghdfe `y' `x' `control' `if', absorb(`absorb3') cluster(`cluster')
      }
	  
foreach y of varlist loutput_robust2 {
       eststo regulated2_1: reghdfe `y' `x', absorb(`absorb1') cluster(`cluster')
       eststo regulated2_2: reghdfe `y' `x', absorb(`absorb2') cluster(`cluster')
       eststo regulated2_3: reghdfe `y' `x', absorb(`absorb3') cluster(`cluster')
       eststo regulated2_4: reghdfe `y' `x' `control', absorb(`absorb3') cluster(`cluster')
      }

*------------------------------------------------------
*  Related Firms. Output: Leave out 2009 in ASIF Data
*------------------------------------------------------

use "$revision/Data/Table2_1.dta",clear

drop if year==2009

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
local absorb1 "firmid year"
local absorb2 "firmid ind2_year"
local absorb3 "firmid ind2_year province_year"

eststo related1_1: reghdfe `y' `x' [fweight=weight], absorb(`absorb1') cluster(`cluster')
eststo related1_2: reghdfe `y' `x' [fweight=weight], absorb(`absorb2') cluster(`cluster')
eststo related1_3: reghdfe `y' `x' [fweight=weight], absorb(`absorb3') cluster(`cluster')
eststo related1_4: reghdfe `y' `x' `control' [fweight=weight], absorb(`absorb3') cluster(`cluster')


*----------------------------------------------------------
*  Related Firms. Output: Fill in 2009-2010 with Tax Data
*----------------------------------------------------------

*Legcode & Name of Sample

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

preserve
keep legcode firmid
sort legcode firmid
duplicates drop legcode,force
save "$revision/Data/ATS_Related_Legcode.dta",replace
restore

preserve
keep name firmid
sort name firmid
duplicates drop name,force
save "$revision/Data/ATS_Related_Name.dta",replace
restore

*Match Tax Data with Legcode and Name

use "$revision/Data/ATS_Related_Legcode.dta",clear
merge 1:m legcode using "$revision/Data/TableA26_1.dta"
keep if _merge==3
drop _merge
gen legcode_match=1
save "$revision/Data/ATS_Related_2009_2010.dta",replace

use "$revision/Data/ATS_Related_Name.dta",clear
merge 1:m name using "$revision/Data/TableA26_2.dta"
keep if _merge==3
drop _merge
gen legcode_match=0

append using "$revision/Data/ATS_Related_2009_2010.dta"
gsort firmid year -legcode_match name
duplicates drop firmid year,force
drop legcode_match
save "$revision/Data/ATS_Related_2009_2010.dta",replace

*Append to ASIF Data

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

drop if year==2009

append using "$revision/Data/ATS_Related_2009_2010.dta"

*Drop Outliers

gen bp=1 if year==2009

xtset firmid year
gen exist2009=1 if year==2009
xfill exist2009,i(firmid)

replace bp=1 if year==2010 & exist2009!=1

gsort firmid year
by firmid: gen rank=_n
xtset firmid rank
gen diff=(output-l.output)/l.output if bp==1

xtset firmid year
xfill diff,i(firmid)

drop if (diff>9 | diff<-0.9) & diff!=. & year>=2009 & year<=2010
drop bp exist2009 diff

*Industry & Province Adjustment

drop ind2_year province_year

duplicates tag firmid ind2,gen(du_ind2)
gsort firmid -du_ind2 year
by firmid: replace ind2=ind2[1]
drop du_ind2

egen ind2_year=group(ind2 year)

duplicates tag firmid province,gen(du_province)
gsort firmid -du_province year
by firmid: replace province=province[1]
drop du_province

egen province_year=group(province year)

*Treat & Weight

xtset firmid year
xfill related,i(firmid)
xfill weight,i(firmid)

*Difference in Differences

gen related_post=1 if related==1 & year>=2007
replace related_post=0 if related_post==.
label variable related_post "Related*Post"

save "$revision/Data/TableA26_B.dta",replace

*Table

local y "loutput"
local x "related_post"
local control "soe roa age exp"
local cluster "firmid"
local absorb1 "firmid year"
local absorb2 "firmid ind2_year"
local absorb3 "firmid ind2_year province_year"

eststo related2_1: reghdfe `y' `x' [fweight=weight], absorb(`absorb1') cluster(`cluster')
eststo related2_2: reghdfe `y' `x' [fweight=weight], absorb(`absorb2') cluster(`cluster')
eststo related2_3: reghdfe `y' `x' [fweight=weight], absorb(`absorb3') cluster(`cluster')
eststo related2_4: reghdfe `y' `x' `control' [fweight=weight], absorb(`absorb3') cluster(`cluster')

*---------------------------------------------------------
*  Placebo on Related Firms: Leave out 2009 in ASIF Data
*---------------------------------------------------------

use "$revision/Data/Table2_1.dta",clear

drop if year==2009

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

*Drop Outliers

replace year=2009 if year==2011
xtset firmid year
gen growth=(output-l.output)/l.output
gen growth_raw=growth
winsor2 growth, trim replace
drop if growth==. & growth_raw!=.
drop growth growth_raw
replace year=2011 if year==2009
xtset firmid year

local y "loutput"
local x "related_post"
local control "soe roa age exp"
local cluster "firmid"
local absorb1 "firmid year"
local absorb2 "firmid ind2_year"
local absorb3 "firmid ind2_year province_year"

eststo placebo1_1: reghdfe `y' `x' [fweight=weight], absorb(`absorb1') cluster(`cluster')
eststo placebo1_2: reghdfe `y' `x' [fweight=weight], absorb(`absorb2') cluster(`cluster')
eststo placebo1_3: reghdfe `y' `x' [fweight=weight], absorb(`absorb3') cluster(`cluster')
eststo placebo1_4: reghdfe `y' `x' `control' [fweight=weight], absorb(`absorb3') cluster(`cluster')

*-------------------------------------------------------------
*  Placebo on Related Firms: Fill in 2009-2010 with Tax Data
*-------------------------------------------------------------

*Legcode & Name of Sample

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

preserve
keep legcode firmid
sort legcode firmid
duplicates drop legcode,force
save "$revision/Data/ATS_Placebo_Legcode.dta",replace
restore

preserve
keep name firmid
sort name firmid
duplicates drop name,force
save "$revision/Data/ATS_Placebo_Name.dta",replace
restore

*Match Tax Data
use "$revision/Data/ATS_Placebo_Legcode.dta",clear // legcode is unique
merge 1:m legcode using "$revision/Data/TableA26_1.dta" // legcode-year unique id
keep if _merge==3
drop _merge
gen legcode_match=1

save "$revision/Data/ATS_Placebo_2009_2010.dta",replace

use "$revision/Data/ATS_Placebo_Name.dta",clear // name unique id
merge 1:m name using "$revision/Data/TableA26_2.dta" // name - year unique
keep if _merge==3
drop _merge
gen legcode_match=0
append using "$revision/Data/ATS_Placebo_2009_2010.dta"
gsort firmid year -legcode_match name

duplicates drop firmid year,force
drop legcode_match

save "$revision/Data/ATS_Placebo_2009_2010.dta",replace


*Append to ASIF Data

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

drop if year==2009

append using "$revision/Data/ATS_Placebo_2009_2010.dta"

*Drop Outliers

gen bp=1 if year==2009

xtset firmid year
gen exist2009=1 if year==2009

xfill exist2009,i(firmid)

replace bp=1 if year==2010 & exist2009!=1

gsort firmid year
by firmid: gen rank=_n
xtset firmid rank
gen diff=(output-l.output)/l.output if bp==1

xtset firmid year
xfill diff,i(firmid)

drop if (diff>9 | diff<-0.9) & diff!=. & year>=2009 & year<=2010
drop bp exist2009 diff

*Industry & Province Adjustment

drop ind2_year province_year

duplicates tag firmid ind2,gen(du_ind2)
gsort firmid -du_ind2 year
by firmid: replace ind2=ind2[1]
drop du_ind2

egen ind2_year=group(ind2 year)

duplicates tag firmid province,gen(du_province)
gsort firmid -du_province year
by firmid: replace province=province[1]
drop du_province

egen province_year=group(province year)

*Treat & Weight

xtset firmid year
xfill related,i(firmid)
xfill weight,i(firmid)

*Difference in Differences

gen related_post=1 if related==1 & year>=2007
replace related_post=0 if related_post==.
label variable related_post "Related*Post"

save "$revision/Data/TableA26_C.dta",replace

*Table

local y "loutput"
local x "related_post"
local control "soe roa age exp"
local cluster "firmid"
local absorb1 "firmid year"
local absorb2 "firmid ind2_year"
local absorb3 "firmid ind2_year province_year"

eststo placebo2_1: reghdfe `y' `x' [fweight=weight], absorb(`absorb1') cluster(`cluster')
eststo placebo2_2: reghdfe `y' `x' [fweight=weight], absorb(`absorb2') cluster(`cluster')
eststo placebo2_3: reghdfe `y' `x' [fweight=weight], absorb(`absorb3') cluster(`cluster')
eststo placebo2_4: reghdfe `y' `x' `control' [fweight=weight], absorb(`absorb3') cluster(`cluster')



esttab regulated1_?  using "$revision/Appendix_Table/TableA26.tex",  ///
preh("\begin{table}[ht] \centering" ///
"\vspace{-1.2cm}\caption{Data Quality Robustness}  \label{tab:rob_data_spill}" ///
"\small" ///
"{A. Leave out 2009 in ASIF Data} \\ " ///
"\begin{tabular}{l c c c c}") ///
stats() posth("\toprule" ///
"Variables & \multicolumn{4}{c}{ln(Output)} \\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(treat_post) coeflabel(treat_post "Treat $\times$ Post") label /// 
prefoot("") postfoot("\hline") replace 

esttab related1_?  using "$revision/Appendix_Table/TableA26.tex",  ///
preh("") ///
stats() posth("") ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(related_post) coeflabel(related_post "Related $\times$ Post") label /// 
prefoot("") postfoot("\hline") append sty(tex)

esttab placebo1_?  using "$revision/Appendix_Table/TableA26.tex",  ///
preh("") ///
stats() posth("") ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(related_post) coeflabel(related_post "Placebo $\times$ Post") label /// 
prefoot("") postfoot("\hline") append sty(tex)

esttab regulated2_?  using "$revision/Appendix_Table/TableA26.tex",  ///
preh("\\ \multicolumn{5}{c}{B. Fill in 2009--2010 with Tax Data} \\") ///
stats() posth("\toprule" ///
"Variables & \multicolumn{4}{c}{ln(Output)} \\" ///
"\midrule" ) ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(treat_post) coeflabel(treat_post "Treat $\times$ Post") label /// 
prefoot("") postfoot("\hline") append 

esttab related2_?  using "$revision/Appendix_Table/TableA26.tex",  ///
preh("") ///
stats() posth("") ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(related_post) coeflabel(related_post "Related $\times$ Post") label /// 
prefoot("") postfoot("\hline") append sty(tex)

esttab placebo2_?  using "$revision/Appendix_Table/TableA26.tex",  ///
preh("") ///
stats() posth("") ///
nostar ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s(N r2, label("Observations" "$ R^2$") fmt(%9.0fc %9.3f)) noobs nogap ///
keep(related_post) coeflabel(related_post "Placebo $\times$ Post") label /// 
prefoot("") postfoot( ///
"\hline" ///
"Firm FE & Y & Y & Y & Y \\" ///
"Year FE & Y & Y & Y & Y \\" ///
"Industry $\times$ Year FE & {} & Y & Y & Y \\" ///
"Province $\times$ Year FE & {} & {} & Y & Y \\" ///
"Firm-level Controls & {} & {} & {} & Y \\" ///
"\bottomrule" ///
"\end{tabular}" ///
"\end{table} \\ $\;$\\" ) append sty(tex)

*Erase Temp File

erase "$revision/Data/ATS_Related_Legcode.dta"
erase "$revision/Data/ATS_Related_Name.dta"
erase "$revision/Data/ATS_Related_2009_2010.dta"
erase "$revision/Data/ATS_Placebo_Legcode.dta"
erase "$revision/Data/ATS_Placebo_Name.dta"
erase "$revision/Data/ATS_Placebo_2009_2010.dta"

