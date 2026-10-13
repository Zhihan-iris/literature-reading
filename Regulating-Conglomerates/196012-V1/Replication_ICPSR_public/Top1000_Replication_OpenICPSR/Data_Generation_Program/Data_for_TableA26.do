
* Data for Table A.26 Data Quality Robustness

use "$revision/Raw_Data/ATS/ATS_Supplement_Legcode.dta",clear
save "$revision/Data/TableA26_1.dta",replace

use "$revision/Raw_Data/ATS/ATS_Supplement_Name.dta",clear
save "$revision/Data/TableA26_2.dta",replace
