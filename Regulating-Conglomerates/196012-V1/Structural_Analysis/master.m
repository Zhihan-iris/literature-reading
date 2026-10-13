
%% July 2021 

% This is the master file to run all the structural analysis
clear; clc;

% 1. Estimate the model baseline parameters and report moments
define_directory;
run([dropbox '/Estimation/Main_test.m']);

% 2. Standard errors for estimates
define_directory;
run([dropbox '/Sensitivity Analysis/Main_ste.m']);

define_directory;
run([dropbox '/Sensitivity Analysis/Main_ste_menu.m']);

define_directory;
run([dropbox '/Estimation ImpSub/Main_ste.m']);


% 3. Run the baseline counterfactuals, compare w/data DID
define_directory;
run([dropbox '/Counterfactual Baseline/Main.m']);
% run alternative baseline counterfactuals, save shadow costs/aggregates
define_directory;
run([dropbox '/Counterfactual Baseline/Main_compare.m']);

% 4. Run the counterfactuals for robustness (alternative values of rho,alpha)

define_directory;
run([dropbox '/Counterfactual Robustness/Main_compare.m']);

% 5. Run the counterfactuals for robustness (imperfect subsitution)
define_directory;
run([dropbox '/Imperfect Sub/Main.m']);

% 6. Run the counterfactuals for endogenous energy efficiency

define_directory;
run([dropbox '/Energy Efficiency/Main.m']);

define_directory;
run([dropbox '/Energy Efficiency/Main_No_Leakage.m']);

% 7. Run the counterfactuals for heterogeneous energy efficiency

define_directory;
run([dropbox '/Heterogeneous EE/Main.m']);

define_directory;
run([dropbox '/Heterogeneous EE/Main_robust.m']);

% 8. Generate tex file for tables
define_directory;
run([dropbox '/Output/Table4.m']);

define_directory;
run([dropbox '/Output/Table5.m']);

define_directory;
run([dropbox '/Output/TableA36.m']);
