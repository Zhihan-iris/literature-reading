% May 12, 2021

%% Estimate the model for a menu of parameters for alpha (RTS) and rho (EOS)
%%
clear
clc

%% rho\in [0.7,0.9], consider a range of sigma = 3 - 10, alpha \in [0.85,0.95]
vec_rho = [0.7;0.75;0.9];
vec_alpha = [0.85;0.9;0.95];

%% Define matrix to save
m_cutoff = zeros(size(vec_rho,2),size(vec_alpha,2));
m_delta = zeros(size(vec_rho,2),size(vec_alpha,2));
m_sigma = zeros(size(vec_rho,2),size(vec_alpha,2));
m_fval = zeros(size(vec_rho,2),size(vec_alpha,2));

for i = 1:1:size(vec_rho,1)
    for j=1:1:size(vec_alpha,1)
%% Define parameters
    rho = vec_rho(i); alpha = vec_alpha(j);
    parameters;

%% Evaluate objective func
x0=[0.1   0.9    1];
lb = [0; 0; 0]; ub = [1.2; 1; 2];
[param_opt,fval]=patternsearch(@(x)obj_moments(x,par),x0,[],[],[],[],lb,ub);

%% Report fit
    disp('parameters')
    [rho alpha]
    [param_opt fval]
    
m_cutoff(i,j) = param_opt(1); m_delta(i,j) = param_opt(2); m_sigma(i,j) = param_opt(3); m_fval(i,j)=fval;
    end
end

save menu_parameters m_cutoff m_delta m_sigma