
*Data for Table A.4  Policy Compliance

use "$revision/Raw_Data/Top1000/Top1000_Compliance.dta",clear

drop if type=="Non-compliant rate "

save "$revision/Data/TableA4.dta",replace


