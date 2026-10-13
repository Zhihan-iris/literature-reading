% May 12, updated for robustness

%%
clc;

%% Case I, lower alpha = 0.85
clear; 
load ../Estimation_Menu/menu_parameters;
alpha = 0.85; rho=0.75; parameters;
% phi*
cutoff=m_cutoff(2,1);
% delta refers to delta^(1/(1-alpha)) in model, implies relative size in a conglomerate
delta=m_delta(2,1)^(1/(1-alpha)); 
% g(phi):ln(phi)~N(mu,sigma)
mu=0; 
sigma=m_sigma(2,1);

% summarize baseline did results
run_baseline;
clear phi_n;

% Write data to text file

% save (['did_' num2str(alpha*100) '_' num2str(rho*100) '.txt'], 'did', '-ascii');

% run the counterfactuals
run_counterfactuals;
% Write data to text file

save (['results_' num2str(alpha*100) '_' num2str(rho*100) '.txt'], 'results', '-ascii');

%% Case II, higher alpha = 0.95
clear; 
load ../Estimation_Menu/menu_parameters;
alpha = 0.95; rho=0.75; parameters;
% phi*
cutoff=m_cutoff(2,3);
% delta refers to delta^(1/(1-alpha)) in model, implies relative size in a conglomerate
delta=m_delta(2,3)^(1/(1-alpha)); 
% g(phi):ln(phi)~N(mu,sigma)
mu=0; 
sigma=m_sigma(2,3);

% summarize baseline did results
run_baseline;
clear phi_n;

% Write data to text file

% save (['did_' num2str(alpha*100) '_' num2str(rho*100) '.txt'], 'did', '-ascii');

% run the counterfactuals
run_counterfactuals;
% Write data to text file

save (['results_' num2str(alpha*100) '_' num2str(rho*100) '.txt'], 'results', '-ascii');

%% Case III, lower rho = 0.7
clear; 
load ../Estimation_Menu/menu_parameters;
alpha = 0.9; rho=0.7; parameters;
% phi*
cutoff=m_cutoff(1,2);
% delta refers to delta^(1/(1-alpha)) in model, implies relative size in a conglomerate
delta=m_delta(1,2)^(1/(1-alpha)); 
% g(phi):ln(phi)~N(mu,sigma)
mu=0; 
sigma=m_sigma(1,2);

% summarize baseline did results
run_baseline;
clear phi_n;

% Write data to text file

% save (['did_' num2str(alpha*100) '_' num2str(rho*100) '.txt'], 'did', '-ascii');

% run the counterfactuals
run_counterfactuals;
% Write data to text file

save (['results_' num2str(alpha*100) '_' num2str(rho*100) '.txt'], 'results', '-ascii');

%% Case IV, higher rho = 0.9
clear; 
load ../Estimation_Menu/menu_parameters;
alpha = 0.9; rho=0.9; parameters;
% phi*
cutoff=m_cutoff(3,2);
% delta refers to delta^(1/(1-alpha)) in model, implies relative size in a conglomerate
delta=m_delta(3,2)^(1/(1-alpha)); 
% g(phi):ln(phi)~N(mu,sigma)
mu=0; 
sigma=m_sigma(3,2);

% summarize baseline did results
run_baseline;
clear phi_n;

% Write data to text file

% save (['did_' num2str(alpha*100) '_' num2str(rho*100) '.txt'], 'did', '-ascii');

% run the counterfactuals
run_counterfactuals;
% Write data to text file

save (['results_' num2str(alpha*100) '_' num2str(rho*100) '.txt'], 'results', '-ascii');


