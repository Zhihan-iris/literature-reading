% Define all the common fixed parameters

%% Fixed Parameters
% decreasing return to scale
alpha=0.9; 
% share of variable inputs
alpha_k = 0.1;
alpha_l = alpha-alpha_k;
% elasticity of substitution (1-1/sig)
rho=0.75; 
% elasticity of substiution within
rho_c = 0.9;

% Simplification Expression
coef0=rho/(1-alpha*rho);
coef1=coef0*((1-alpha*rho_c)/rho_c); %adjust to \Delta_n^C
coef2=1/coef0;

% define parameters string
par{1} = alpha;
par{2} = alpha_l;
par{3} = alpha_k;
par{4} = rho; 
par{12} = rho_c;

%% Fixed equilibrium objects
% total expenditure normalize to 1, aggregate output value of the main 9 energy-intensive industries=91887.48922*10^8RMB
R=1; 
% total mass of firms (affiliates)
Mest_data=450671; 
% Mest_data=450189; 
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

par{10} = C_pi;
par{11} = C_R;

%% Parameters to estimate
%load estimated parameters
%load('C:\Users\yx42\Dropbox\Top 1000\Program\Calibration 2021\Estimation\param_opt')
load param_opt;

% phi*
cutoff=param_opt(1);

% delta refers to delta^(rho_c/(1-alpha*rho_c)) in model, implies relative size in a conglomerate
delta=param_opt(2)^(rho_c/(1-alpha*rho_c)); 

% g(phi):ln(phi)~N(mu,sigma)
mu=0; 
sigma=param_opt(3);

% regulation
xi = 0.8;
 

 