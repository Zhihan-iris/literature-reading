

clear
%% These two are saved from /Sensitivity Analysis/Main_ste.m 
load table5

input.data = [  NaN , NaN, NaN , NaN ; 
                decomposition_results(1:3,:) ; 
                NaN , NaN, NaN , NaN ; 
                NaN , NaN, NaN , NaN ; 
                decomposition_results(4:6,:) ;
                NaN , NaN, NaN , NaN ;
                NaN , NaN, NaN , NaN ;
                decomposition_results(7,:)] ;

% Set column labels (use empty string for no label)
input.tableRowLabels = {'A. Effect on Regulated Firms',...
'Top 1,000 Firms',...    
'Control Firms',...
'Difference-in-Differences',...
'',...
'B. Effect on Related Firms',...
'Related Firms',...    
'Control Firms',...
'Difference-in-Differences',...
'',...
'C. Within-Conglomerate Effect',...
'Difference-in-Differences'} ;
input.tableColLabels = {'Allocation Effect','Residual Revenue Effect','Market Effect','Total Effect'};
% Determine whether input.dataFormat is applied column or row based:
input.dataFormatMode = 'column'; % use 'column' or 'row'. if not set 'column' is used
input.dataFormat = {'%.3f'}; % uses three digit precision floating point for all data values
% Define how NaN values in input.tableData should be printed in the LaTex table:
input.dataNanString = '';
% Column alignment in Latex table ('l'=left-justified, 'c'=centered,'r'=right-justified):
input.tableColumnAlignment = 'c';
% Switch table borders on/off:
input.tableBorders = 1;
% Switch table booktabs on/off:
input.booktabs = 1;
% LaTex table caption:
input.tableCaption = 'MyTableCaption';
% LaTex table label:
input.tableLabel = 'MyTableLabel';
% Switch to generate a complete LaTex document or just a table:
input.makeCompleteLatexDocument = 0;

% % Now call the function to generate LaTex code:
latex = latexTable(input);
% Save as text file
T = cell2table(latex) ;
writetable(T,'Table5.txt') ;
