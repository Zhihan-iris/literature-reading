
* Data for Firm Size Distribution Moments (Census)

use "$revision/Raw_Data/Census/Census_2004.dta",clear

keep dm b07 b14 v207

gen output=v207/(10^5)
replace output=0 if output==.
label variable output "Industrial Output(Unit: 100 Million Yuan)"

gen ind4=b07
gen ind2=int(ind4/100)
keep if ind2==26 | ind2==32 | ind2==44 | ind2==31 | ind2==25 | ind2==33 | ind2==6 | ind2==22 | ind2==17 | ind2==7
label variable ind4 "4-digit Industry"
label variable ind2 "2-digit Industry"

gen status="营业" if b14==1
replace status="停业(歇业)" if b14==2
replace status="筹建" if b14==3
replace status="当年关闭" if b14==4
replace status="当年破产" if b14==5
replace status="其他" if b14==9
label variable status "Operating Status"

ren dm surveyid
label variable surveyid "Survey Firm ID"

sort surveyid
gen firmid=_n
label variable firmid "Firm ID"

keep firmid surveyid status ind4 ind2 output
order firmid surveyid status ind4 ind2 output

save "$revision/Data/Moment3.dta",replace
