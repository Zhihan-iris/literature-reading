
* Data for Figure A.5 Innovation in Top 1,000 Firms: Energy-Saving Patent Applications

*Import Patent Data
use "$revision/Raw_Data/Patent/Patent_Top1000_Top10000.dta",clear

*Drop 4-digit related firms
merge m:1 name using "$revision/Raw_Data/CARD/related_firms_name.dta",update
drop if _merge==2
drop _merge

replace same_ind4=. if same_ind4==0
xtset id year
xfill same_ind4,i(id)
replace same_ind4=. if top1000==1
drop if same_ind4==1

*Variable
keep id name year top1000 patent lpatent
order id name year top1000 patent lpatent

xtset id year
save "$revision/Data/FigureA5.dta",replace
