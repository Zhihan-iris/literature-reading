
clear
%% These two are saved from /Sensitivity Analysis/Main_ste.m 

table4_2 = [NaN; 4.00; 0.90; 0.80; NaN; 0.900; 0.003; 1.239; 0.055; 0.609; 0.166; ...
    NaN; 9.289; 0.20];

save table4_2.mat table4_2


input.data = [table4_2;];
disp(input.data)
% Set column labels (use empty string for no label)
input.tableRowLabels = {'1. Fixed Values',...
'Elasticity of substitution $\sigma = \frac{1}{1-\rho}$',...
'Returns to scale $\alpha$',...
'Return to scale (Labor Share) $\alpha_l$',...
'2. Method of Moments',...
'Efficiency depreciation $\delta$',...
'',...
'Dispersion of ln-ability $\phi = {\sigma}_{m}$',...
'',...
'Survival threshold  $\phi_1$',...
'',...
'3. Policy Parameters',...
'Policy threshold $\tilde{\phi}$',...
'Input quota $1 - \xi $'};
input.tableColLabels = {'Value'};
% Determine whether input.dataFormat is applied column or row based:
input.dataFormatMode = 'column'; % use 'column' or 'row'. if not set 'column' is used
input.dataFormat = {'%.3f'}; % uses three digit precision floating point for all data values
% Define how NaN values in input.tableData should be printed in the LaTex table:
input.dataNanString = '';
% Column alignment in Latex table ('l'=left-justified, 'c'=centered,'r'=right-justified):
input.tableColumnAlignment = 'l';
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
writetable(T,'Table4.txt') ;
