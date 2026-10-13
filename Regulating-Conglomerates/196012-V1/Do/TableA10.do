
* Table A.10 Effects of the Top 1,000 Program on Regulated Firms: Robustness to Trimming Sample by Top 10,000 Rank

use "$revision/Data/Table1.dta",clear

local x "treat_post"
local cluster "firmid"
local absorb3 "firmid ind2_year province_year"

local if0 ""
local if1 "if top10000_rank<8000"
local if2 "if top10000_rank<5000"
local if3 "if top10000_rank<3000"

local if4 "if top10000_rank>300"
local if5 "if top10000_rank>500"
local if6 "if top10000_rank>800"

local if7 "if top10000_rank>300 & top10000_rank<8000"
local if8 "if top10000_rank>500 & top10000_rank<5000"
local if9 "if top10000_rank>800 & top10000_rank<3000"

forvalues i=0(1)9 {
eststo rank`i'_1 : reghdfe lenergy `x' `if`i'', absorb(`absorb3') cluster(`cluster')
eststo rank`i'_2 : reghdfe loutput `x' `if`i'', absorb(`absorb3') cluster(`cluster')
eststo rank`i'_3 : reghdfe lefficiency `x' `if`i'', absorb(`absorb3') cluster(`cluster')
}

esttab rank0_?  using "$revision/Appendix_Table/TableA10.tex",  ///
preh("\begin{table} \centering" ///
"\caption{\bf Effects of the Top 1,000 Program on Regulated Firms: Robustness to Trimming the Sample by Top 10,000 Rank}" ///
"\begin{tabular}{l c c c}") ///
stats() posth("\toprule" ///
"Variables & ln(Energy Use) & ln(Output) & ln(Energy Efficiency) \\" ///
"\midrule" ) ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s() noobs nogap keep(treat_post) nostar coeflabel(treat_post "Baseline") label ///
prefoot("") postfoot("") replace 

esttab rank1_?  using "$revision/Appendix_Table/TableA10.tex", preh("") posth("") ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s() noobs nogap keep(treat_post) nostar ///  
coeflabel(treat_post "Rank $<$ 8000"  ) label /// 
prefoot("") postfoot("") append sty(tex)

esttab rank2_?  using "$revision/Appendix_Table/TableA10.tex", preh("") posth("") ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s() noobs nogap keep(treat_post) nostar /// 
coeflabel(treat_post "Rank $<$ 5000"  ) label /// 
prefoot("") postfoot("") append sty(tex)

esttab rank3_?  using "$revision/Appendix_Table/TableA10.tex", preh("") posth("") ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s() noobs nogap keep(treat_post) nostar /// 
coeflabel(treat_post "Rank $<$ 3000"  ) label /// 
prefoot("") postfoot("") append sty(tex)

esttab rank4_?  using "$revision/Appendix_Table/TableA10.tex", preh("") posth("") ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s() noobs nogap keep(treat_post) nostar ///  
coeflabel(treat_post "Rank $>$ 300"  ) label /// 
prefoot("") postfoot("") append sty(tex)

esttab rank5_?  using "$revision/Appendix_Table/TableA10.tex", preh("") posth("") ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s() noobs nogap keep(treat_post) nostar /// 
coeflabel(treat_post "Rank $>$ 500"  ) label /// 
prefoot("") postfoot("") append sty(tex)

esttab rank6_?  using "$revision/Appendix_Table/TableA10.tex", preh("") posth("") ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s() noobs nogap keep(treat_post) nostar /// 
coeflabel(treat_post "Rank $>$ 800"  ) label /// 
prefoot("") postfoot("") append sty(tex)

esttab rank7_?  using "$revision/Appendix_Table/TableA10.tex", preh("") posth("") ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s() noobs nogap keep(treat_post) nostar /// 
coeflabel(treat_post "300 $<$ Rank $<$ 8000"  ) label /// 
prefoot("") postfoot("") append sty(tex)

esttab rank8_?  using "$revision/Appendix_Table/TableA10.tex", preh("") posth("") ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s() noobs nogap keep(treat_post) nostar /// 
coeflabel(treat_post "500 $<$ Rank $<$ 5000"  ) label /// 
prefoot("") postfoot("") append sty(tex)

esttab rank9_?  using "$revision/Appendix_Table/TableA10.tex", preh("") posth("") ///
cells(b(fmt(3)) se(fmt(3) par) p(fmt(3) par([ ])))  mlab(none) coll(none) nonum ///
s() noobs nogap keep(treat_post) nostar /// 
coeflabel(treat_post "800 $<$ Rank $<$ 3000"  ) label /// 
prefoot("") postfoot( ///
"\hline" ///
"Firm FE & Y & Y & Y \\" ///
"Industry $\times$ Year FE & Y & Y & Y \\" ///
"Province $\times$ Year FE & Y & Y & Y \\" ///
"\bottomrule" ///
"\end{tabular}" ///
"\end{table}" ) append sty(tex)

