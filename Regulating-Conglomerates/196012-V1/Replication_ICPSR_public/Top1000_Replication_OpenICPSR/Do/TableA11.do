
* Table A.11 Effects of the Top 1,000 Program on Regulated Firms: Robustness to Trimming Sample Estimated Propensity of Treatment

use "$revision/Data/Table1.dta",clear

* Estimate Propensity Score

preserve 
keep if inrange(year,2003,2005) 
collapse (mean) loutput (max) ind2 (max) province (max) top1000, by(firmid)
logit top1000 i.ind2 i.province c.loutput#i.ind2

predict pscore
keep firmid pscore  
tempfile temp 
save `temp'
restore 

* Merge propensity score 

merge m:1 firmid using `temp'
drop _merge 

centile pscore if top1000 == 0, c(20,40,60) 
local perc1 = r(c_1)
local perc2 = r(c_2)
local perc3 = r(c_3)

centile pscore if top1000 == 1, c(80,60,40)
local perc4 = r(c_1)
local perc5 = r(c_2)
local perc6 = r(c_3)

* Regression

local x "treat_post"
local cluster "firmid"
local absorb3 "firmid ind2_year province_year"

eststo rank0_1: reghdfe lenergy `x' , absorb(`absorb3') cluster(`cluster')
eststo rank0_2: reghdfe loutput `x' , absorb(`absorb3') cluster(`cluster')
eststo rank0_3: reghdfe lefficiency `x' , absorb(`absorb3') cluster(`cluster')

forvalues i=1(1)3 {
	eststo rank`i'_1: reghdfe lenergy `x' if (pscore>`perc`i'' & top1000==0) | top1000==1, absorb(`absorb3') cluster(`cluster')
	eststo rank`i'_2: reghdfe loutput `x' if (pscore>`perc`i'' & top1000==0) | top1000==1, absorb(`absorb3') cluster(`cluster')
	eststo rank`i'_3: reghdfe lefficiency `x' if (pscore>`perc`i'' & top1000==0) | top1000==1, absorb(`absorb3') cluster(`cluster')
}

forvalues i=4(1)6 {
	eststo rank`i'_1: reghdfe lenergy `x' if top1000==0 | (top1000==1 & pscore<`perc`i''), absorb(`absorb3') cluster(`cluster')
	eststo rank`i'_2: reghdfe loutput `x' if top1000==0 | (top1000==1 & pscore<`perc`i''), absorb(`absorb3') cluster(`cluster')
	eststo rank`i'_3: reghdfe lefficiency `x' if top1000==0 | (top1000==1 & pscore<`perc`i''), absorb(`absorb3') cluster(`cluster')
}

forvalues i=7(1)9 {
	local j=`i'-6
	local k=`i'-3
	eststo rank`i'_1: reghdfe lenergy `x' if (pscore>`perc`j'' & top1000==0) | (top1000==1 & pscore<`perc`k''), absorb(`absorb3') cluster(`cluster')
	eststo rank`i'_2: reghdfe loutput `x' if (pscore>`perc`j'' & top1000==0) | (top1000==1 & pscore<`perc`k''), absorb(`absorb3') cluster(`cluster')
	eststo rank`i'_3: reghdfe lefficiency `x' if (pscore>`perc`j'' & top1000==0) | (top1000==1 & pscore<`perc`k''), absorb(`absorb3') cluster(`cluster')
}

esttab rank0_?  using "$revision/Appendix_Table/TableA11.tex",  ///
preh("\begin{table} \centering" ///
"\caption{\bf Effects of the Top 1,000 Program on Regulated Firms: Robustness to Trimming the Sample Estimated Propensity of Treatment}" ///
"\begin{tabular}{l c c c}") ///
stats() posth("\toprule" ///
"Variables & ln(Energy Use) & ln(Output) & ln(Energy Efficiency) \\" ///
"\midrule" ) ///
nostar /// 
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
noobs nogap ///
keep(treat_post) coeflabel(treat_post "Baseline") label ///
prefoot("") postfoot("") replace 

esttab rank1_?  using "$revision/Appendix_Table/TableA11.tex", preh("") posth("") ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s() noobs nogap keep(treat_post) nostar /// 
coeflabel(treat_post "Control $>$ 20\%"  ) label /// 
prefoot("") postfoot("") append sty(tex)

esttab rank2_?  using "$revision/Appendix_Table/TableA11.tex", preh("") posth("") ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s() noobs nogap keep(treat_post) nostar /// 
coeflabel(treat_post "Control $>$ 40\%"  ) label /// 
prefoot("") postfoot("") append sty(tex)

esttab rank3_?  using "$revision/Appendix_Table/TableA11.tex", preh("") posth("") ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s() noobs nogap keep(treat_post) nostar /// 
coeflabel(treat_post "Control $>$ 60\%"  ) label /// 
prefoot("") postfoot("") append sty(tex)

esttab rank4_?  using "$revision/Appendix_Table/TableA11.tex", preh("") posth("") ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s() noobs nogap keep(treat_post) nostar /// 
coeflabel(treat_post "Treat $<$ 80\%"  ) label /// 
prefoot("") postfoot("") append sty(tex)

esttab rank5_?  using "$revision/Appendix_Table/TableA11.tex", preh("") posth("") ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s() noobs nogap keep(treat_post) nostar /// 
coeflabel(treat_post "Treat $<$ 60\%"  ) label /// 
prefoot("") postfoot("") append sty(tex)

esttab rank6_?  using "$revision/Appendix_Table/TableA11.tex", preh("") posth("") ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s() noobs nogap keep(treat_post) nostar /// 
coeflabel(treat_post "Treat $<$ 40\%"  ) label /// 
prefoot("") postfoot("") append sty(tex)

esttab rank7_?  using "$revision/Appendix_Table/TableA11.tex", preh("") posth("") ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s() noobs nogap keep(treat_post) nostar /// 
coeflabel(treat_post "Control $>$ 20\% \& Treat $<$ 80\%"  ) label /// 
prefoot("") postfoot("") append sty(tex)

esttab rank8_?  using "$revision/Appendix_Table/TableA11.tex", preh("") posth("") ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s() noobs nogap keep(treat_post) nostar /// 
coeflabel(treat_post "Control $>$ 40\% \& Treat $<$ 60\%"  ) label /// 
prefoot("") postfoot("") append sty(tex)

esttab rank9_?  using "$revision/Appendix_Table/TableA11.tex", preh("") posth("") ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s() noobs nogap keep(treat_post) nostar /// 
coeflabel(treat_post "Control $>$ 60\% \& Treat $<$ 40\%"  ) label /// 
prefoot("") postfoot( ///
"\hline" ///
"Firm FE & Y & Y & Y \\" ///
"Industry $\times$ Year FE & Y & Y & Y \\" ///
"Province $\times$ Year FE & Y & Y & Y \\" ///
"\bottomrule" ///
"\end{tabular}" ///
"\end{table}" ) append sty(tex)
