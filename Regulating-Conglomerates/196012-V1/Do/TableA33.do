
clear
set more off

capture: file close tableA33
file open tableA33 using "$revision/Appendix_Table/TableA33.tex", write replace

file write tableA33 "\begin{tabular}{lcccccc} \toprule" _n
file write tableA33 "\multicolumn{1}{c}{(1)} & (2) & (3) & (4) & (5) & (6) & (7) \\ \hline" _n
file write tableA33 "\multicolumn{1}{c}{Source/} & Total Pollution  & Year & \multicolumn{2}{c}{CO\$_2\$ Emissions (Bn tn)} & \multicolumn{2}{c}{Damages  Per Ton}  \\ \cline{4-5} \cline{6-7}" _n

file write tableA33 "\multicolumn{1}{c}{Method}& Damages &  & All  & Coal  & All  & Coal  \\" _n
file write tableA33 "    & (Bn \\$) &   & Sources & Only & Sources & Only\\  \midrule " _n
file write tableA33 "Mohan et al. (2020) & \\$107.99 & 2006 & 6.38 & 4.91 & \\$16.93 & \\$22.00 \\ " _n
file write tableA33 "\multicolumn{2}{l}{Gross External Damage} & \\ \hline" _n
file write tableA33 "World Bank (2007) &  \\$62.79 & 2003 & 4.45 & 3.32 &  \\$13.83 & \\$18.91 \\ " _n
file write tableA33 "\multicolumn{2}{l}{Willingness to Pay}  & \\ \hline" _n
file write tableA33 "World Bank (2007) & \\$19 & 2003  & 4.45  &  3.32 &  \\$4.23 & \\$5.72 \\ " _n
file write tableA33 "\multicolumn{2}{l}{Adjusted Human Capital} & \\ \hline" _n
file write tableA33 " Ito and Zhang (2020b) & \\$55.8 & 2013 & 9.80 & 7.49 &  \\$5.69 & \\$7.45 \\" _n
file write tableA33 "\multicolumn{2}{l}{Willingness to Pay} & \\  \bottomrule " _n
file write tableA33 "\end{tabular}" _n
file close tableA33
