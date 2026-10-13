* Install Packages
ssc install addplot, replace
ssc install binscatter, replace
ssc install reghdfe, replace
ssc install ftools, replace
ssc install fdta, replace
ssc install parmest, replace
ssc install winsor2, replace
ssc install listtex, replace 
ssc install estout, replace 
ssc install ebalance, replace
ssc install texdoc, replace
net from https://www.sealedenvelope.com/ // click on xfill from the tab!

// global revision "I:/Replication_Editor" /* Change this path to run file */
global revision "I:/Replication_Editor"
cd "$revision"
set more off

* log file
log close _all
log using "$revision/Log_stata.smcl", replace

* matlab executable config
global matlab "!/Applications/MATLAB_R2023b.app/bin/matlab"
cd "$revision/Structural_Analysis"
$matlab -nosplash -nodisplay -nodesktop -r config; exit
sleep 10000

*Data Generating Process
cd "$revision"
do "$revision/Data_Generation_Program/Data_for_Table1.do"
do "$revision/Data_Generation_Program/Data_for_Table2.do"
do "$revision/Data_Generation_Program/Data_for_Table3.do"

do "$revision/Data_Generation_Program/Data_for_TableA1.do"
do "$revision/Data_Generation_Program/Data_for_TableA2.do" 
do "$revision/Data_Generation_Program/Data_for_TableA3.do" 
do "$revision/Data_Generation_Program/Data_for_TableA4.do" 
do "$revision/Data_Generation_Program/Data_for_TableA6.do" 
do "$revision/Data_Generation_Program/Data_for_TableA7.do"  
do "$revision/Data_Generation_Program/Data_for_TableA8.do"
do "$revision/Data_Generation_Program/Data_for_TableA9.do"   
do "$revision/Data_Generation_Program/Data_for_TableA14.do"
do "$revision/Data_Generation_Program/Data_for_TableA22.do" 
do "$revision/Data_Generation_Program/Data_for_TableA23.do" 
do "$revision/Data_Generation_Program/Data_for_TableA24.do"  
do "$revision/Data_Generation_Program/Data_for_TableA26.do" 
do "$revision/Data_Generation_Program/Data_for_TableA37.do" 
do "$revision/Data_Generation_Program/Data_for_TableA38.do"

do "$revision/Data_Generation_Program/Data_for_FigureA5.do" 
do "$revision/Data_Generation_Program/Data_for_FigureA12.do"
do "$revision/Data_Generation_Program/Data_for_FigureA13.do" 

do "$revision/Data_Generation_Program/Data_for_Moment1.do"
do "$revision/Data_Generation_Program/Data_for_Moment3.do"
do "$revision/Data_Generation_Program/Data_for_Moment4.do"
do "$revision/Data_Generation_Program/Data_for_Moment5.do"

do "$revision/Data_Generation_Program/Data_for_Scalars.do"


*Data Moments
do "$revision/Data_Moments/Do/Moment1.do"
do "$revision/Data_Moments/Do/Moment2.do"
do "$revision/Data_Moments/Do/Moment3.do"
do "$revision/Data_Moments/Do/Moment4.do"
do "$revision/Data_Moments/Do/Moment5.do"


* Run MATLAB master script for structural estimation
* This also produces Table 4, Table 5, Table A36
cd "$revision/Structural_Analysis"
$matlab -nosplash -nodisplay -nodesktop -r master; exit


*Table
cd "$revision"
do "$revision/Do/Table1.do"
do "$revision/Do/Table2.do"
do "$revision/Do/Table3.do"
/* Table 4 is structurally estimated by Structural_Analysis/master.m - /Output/Table4.m */
/* Table 5 is structurally estimated by Structural_Analysis/master.m - /Output/Table5.m */


*Figure

do "$revision/Do/Figure1.do"
do "$revision/Do/Figure2.do"
do "$revision/Do/Figure3.do"
do "$revision/Do/Figure4.do"
do "$revision/Do/Figure5.do"
do "$revision/Do/Figure6.do"
do "$revision/Do/Figure7.do"

*Scalars

do "$revision/Do/Scalars.do"

*Appendix Table

do "$revision/Do/TableA1.do"
do "$revision/Do/TableA2.do" 
do "$revision/Do/TableA3.do"
do "$revision/Do/TableA4.do" 
do "$revision/Do/TableA5.do" 
do "$revision/Do/TableA6.do" 
do "$revision/Do/TableA7.do" 
do "$revision/Do/TableA8.do" 
do "$revision/Do/TableA9.do" 
do "$revision/Do/TableA10.do" 
do "$revision/Do/TableA11.do" 
do "$revision/Do/TableA12.do" 
do "$revision/Do/TableA13.do" 
do "$revision/Do/TableA14.do" 
do "$revision/Do/TableA15.do" 
do "$revision/Do/TableA16.do" 
do "$revision/Do/TableA17.do" 
do "$revision/Do/TableA18.do" 
do "$revision/Do/TableA19.do" 
do "$revision/Do/TableA20.do" 
do "$revision/Do/TableA21.do" 
do "$revision/Do/TableA22.do"
do "$revision/Do/TableA23.do"
do "$revision/Do/TableA24.do"
do "$revision/Do/TableA25.do" 
do "$revision/Do/TableA26.do"
do "$revision/Do/TableA27.do" 
do "$revision/Do/TableA28.do"
do "$revision/Do/TableA29.do"
do "$revision/Do/TableA30.do"
do "$revision/Do/TableA31.do"
do "$revision/Do/TableA32.do"
do "$revision/Do/TableA33.do"
do "$revision/Do/TableA34.do" 
do "$revision/Do/TableA35.do"
/* Table A36 is structurally estimated by Structural_Analysis/master.m - /Output/TableA36.m */ //
do "$revision/Do/TableA37.do"
do "$revision/Do/TableA38.do"

*Appendix Figure

/* Figure A1 is manually drawn; no replication file */
do "$revision/Do/FigureA2.do"
do "$revision/Do/FigureA3.do" 
/* Figure A4 is manually drawn; no replication file */ 
do "$revision/Do/FigureA5.do" 
do "$revision/Do/FigureA6.do" 
/* Figure A7 is manually drawn; no replication file */ 
do "$revision/Do/FigureA8.do" 
do "$revision/Do/FigureA9.do"
do "$revision/Do/FigureA10.do" 
do "$revision/Do/FigureA11.do"
do "$revision/Do/FigureA12.do"
do "$revision/Do/FigureA13.do"
do "$revision/Do/FigureA14.do" 
do "$revision/Do/FigureA15.do" 
do "$revision/Do/FigureA16.do"
do "$revision/Do/FigureA17.do"
do "$revision/Do/FigureA18.do" 
do "$revision/Do/FigureA19.do"
do "$revision/Do/FigureA20.do"
do "$revision/Do/FigureA21.do"
do "$revision/Do/FigureA22.do" 


log close _all
