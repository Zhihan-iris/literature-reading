
%% July 2021 

% This is the master file to run all the structural analysis
clear; clc;

% 1. Estimate the model parameters and report moments

define_directory;
run([dropbox '/Estimation/Main.m']);

define_directory;
run([dropbox '/Estimation_Menu/Main.m']);

define_directory;
run([dropbox '/Estimation_ImpSub/Main.m']);

% 2. Standard errors for estimates

define_directory;
run([dropbox '/Sensitivity Analysis/Main_ste.m']);

define_directory;
run([dropbox '/Sensitivity Analysis/Main_ste_menu.m']);

define_directory;
run([dropbox '/Estimation_ImpSub/Main_ste.m']);


% 3. Run counterfactuals, compare w/data DID

define_directory;
run([dropbox '/Counterfactual Baseline/Main.m']);

define_directory;
run([dropbox '/Counterfactual Baseline/Main_compare.m']);

define_directory;
run([dropbox '/Counterfactual Robustness/Main_compare.m']);

define_directory;
run([dropbox '/Counterfactual AdjK/Main.m']);

define_directory;
run([dropbox '/Imperfect Sub/Main.m']);

define_directory;
run([dropbox '/Energy Efficiency/Main.m']);

define_directory;
run([dropbox '/Heterogeneous EE/Main.m']);

define_directory;
run([dropbox '/Heterogeneous EE/Main_robust.m']);

define_directory;
run([dropbox '/No Conglomerate/Main.m']);

% 4. Generate tex file for tables

define_directory;
run([dropbox '/Output/Table4.m']);

define_directory;
run([dropbox '/Output/Table5.m']);

define_directory;
run([dropbox '/Output/TableA36.m']);
