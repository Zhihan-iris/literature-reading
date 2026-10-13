
********************************************************************************
*                          Replicate Scalars
********************************************************************************

clear all

global output "./" 
sysuse auto , clear 

capture: program drop jc_stat_out0
program jc_stat_out
syntax , number(real) name(string) replace(real) deci(real) figs(real)

if `replace' == 1 {
file open myfile using "$revision/Table/scalars.txt", write replace
file write myfile "\newcommand{\" "`name'" "}[1]{" %`figs'.`deci'fc (`number') "}" _n
file close myfile
}

if `replace' != 1 {
file open myfile using "$revision/Table/scalars.txt", write append
file write myfile "\newcommand{\" "`name'" "}[1]{" %`figs'.`deci'fc (`number') "}" _n
file close myfile
}
end

****************************************************
*  Output Share of Related Firms to Top1000 Firms
****************************************************

use "$revision/Data/Scalars.dta",clear

keep if year==2006
keep if output!=0

sum output if top1000==1
local a=r(mean)

sum output if top1000_related==1
local b=r(mean)

local resultI = `b'/`a'
dis `resultI'
jc_stat_out, number(`resultI') name("RESULTnumI") replace(1) deci(3) figs(6)

