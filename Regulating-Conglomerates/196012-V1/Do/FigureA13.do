
* Figure A.13 Energy Mix of Nine Energy-Intensive Industries

use "$revision/Data/FigureA13.dta",clear

graph bar (mean) coalproducts (mean) petroleumproducts (mean) naturegas (mean) heat (mean) electricity , over(year) stack legend(r(1) pos(6) label(1 "Coal Products") label(2 "Petroleum Products") label(3 "Natural Gas") label(4 "Heat") label(5 "Electricity") cols(3)) graphregion(color(white)) bar(1, fcolor(165 194 230) lw(none)) bar(2, fcolor(245 179 151) lw(none)) bar(3, fcolor(197 197 197) lw(none)) bar(4, fcolor(255 215 142) lw(none)) bar(5, fcolor(152 169 217) lw(none))

graph export "$revision/Appendix_Figure/FigureA13.pdf",replace
