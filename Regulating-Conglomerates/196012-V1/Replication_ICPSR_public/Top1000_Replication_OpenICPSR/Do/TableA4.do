
*Table A.4: Policy Compliance

* Noncompliant firms in Estimation Sample

use "$revision/Data/Table1.dta",clear

duplicates drop firmid,force

sum noncompliance2007
local b1=r(N)
sum noncompliance2008
local b2=r(N)
sum noncompliance2009
local b3=r(N)
sum noncompliance
local b4=r(N)

* Noncompliant firms

use "$revision/Data/TableA4.dta",clear

set obs 4
destring evaluation*,replace

replace type="Noncompliant firms in Estimation Sample" in 4 
replace orig_list="- " in 4
replace evaluation2007=`b1' in 4
replace evaluation2008=`b2' in 4
replace evaluation2009=`b3' in 4
replace evaluation2010=`b4' in 4

listtex * using "$revision/Appendix_Table/TableA4.tex", replace rstyle(tabular)
