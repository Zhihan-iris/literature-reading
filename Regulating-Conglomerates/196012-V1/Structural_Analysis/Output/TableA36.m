
% total cases: 6 
% Baseline 
% 4 values of different parameters: 
% % alpha = .9 , rho = .7, .9
% % alpha = .85 , .95 , rho = .75 
% Imperfect subsitution \rho_c = 0.9 

% For each specification need: 
% % fixed values (not alpha_l)
% % estimates 
% % standard errors
% % policy parameters 
% % moments 

% 10 parameters (including SEs and fixed values and rho_c) 
% 9 moments 
% --
% 19 rows and 7 columns (including data moments but not 1-\xi) 

clear
%% These two are saved from /Sensitivity Analysis/Main_ste.m 
load tableA36_1
load tableA36_2
load tableA36_3
load tableA36_menu

input.data = [tableA36_1, tableA36_2, tableA36_menu, tableA36_3] ;

% Set column labels (use empty string for no label)
input.tableRowLabels = {'Elasticity of substitution  $\rho$',...
'Within-Conglomerate Elasticity of substitution  $\rho_c$',...    
'Return to scale $\alpha$',...
'Efficiency depreciation  $\delta$',...
'',...
'Dispersion of ln-ability  ${\sigma}_{m}$',...
'',...
'Survival threshold  $\phi_1$',...
'',...
'Policy threshold $\tilde{\phi}$',...
'Share of firms $<1M$',...
'Share of firms $5-20M$',...
'Share of firms $20-100M$',...
'Share of firms $100M+$',...
'Share of Output $5-20M$',...
'Share of Output $20-100M$',...
'Share of Output $100M+$',...
'Relative Output 1st-2nd',...
'Relative Output 2nd-3rd'} ;
input.tableColLabels = {'Data','Baseline','Low $\rho$','High $\rho$','Low $\alpha$','High $\alpha$','Imperfect Substitution'};
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
writetable(T,'TableA36.txt') ;
