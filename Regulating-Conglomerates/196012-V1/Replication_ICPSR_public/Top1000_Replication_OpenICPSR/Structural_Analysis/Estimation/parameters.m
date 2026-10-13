% Define all the common fixed parameters

%% Fixed Parameters
% decreasing return to scale
alpha=0.9; 
% share of variable inputs
alpha_k = 0.1;
alpha_l = alpha-alpha_k;
rho=0.75; 


% Simplification Expression
coef0=rho/(1-alpha*rho);
coef1=coef0*(1-alpha);
coef2=1/coef0;
coef3=(rho-1)/(1-alpha*rho);

% define parameters string
par{1} = alpha;
par{2} = alpha_l;
par{3} = alpha_k;
par{4} = rho; 

%% Fixed equilibrium objects
% total expenditure normalize to 1
R=1; 
% total mass of firms (affiliates)
Mest_data=450671; 
% max number of affiliates
N=10;
% input prices
w=1; %variable input cost, which includes baseline variable input (w+pe/v)
rv=1; % effective capital price 

% define parameters string
par{5} = R;
par{6} = Mest_data;
par{7} = N;
par{8} = w;
par{9} = rv;

%% The few useful constant
%Define C_pi, C_R
C_pi = (1-rho*alpha)*(rho*alpha_l/w)^(rho*alpha_l/(1-rho*alpha))*(rho*alpha_k/rv)^(rho*alpha_k/(1-rho*alpha));
C_R = C_pi/(1-rho*alpha);
C_pi_l = (1-rho*alpha_l)*(rho*alpha_l/w)^(rho*alpha_l/(1-rho*alpha_l));
C_l = (rho*alpha_l/w)^((1-alpha_k*rho)/(1-rho*alpha))*(rho*alpha_k/rv)^(rho*alpha_k/(1-rho*alpha));

par{10} = C_pi;
par{11} = C_R;
par{12} = C_pi_l;
par{13} = C_l;

