% May, 2021

%%
clear
clc

%% Define parameters
parameters;

%% Evaluate objective func
x0 = [0.5 0.8 1.2];
options = optimoptions('patternsearch','Display','iter');
lb = [0; 0.6; 0]; ub = [2; 1; 2];
[param_opt,fval]=patternsearch(@(x)obj_moments(x,par),x0,[],[],[],[],lb,ub);
%% Report fit
disp('parameters and obj value')
[param_opt fval]

%% Save
save param_opt param_opt

%%
Main_test