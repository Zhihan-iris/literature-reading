
function out = obj_moments(in,par)

%% fixed parameters
alpha = par{1};
rho = par{4};
R = par{5};
Mest_data = par{6};
N = par{7};
w = par{8};
rv = par{9};
C_pi = par{10};
C_R = par{11};
rho_c = par{12};

% Simplification Expression
coef0=rho/(1-alpha*rho);
coef1=coef0*((1-alpha*rho_c)/rho_c); %adjust to \Delta_n^C
coef2=1/coef0;

%% read in parameter estimates
cutoff = in(1); 
delta = in(2)^(rho_c/(1-alpha*rho_c)); 
sigma = in(3);
mu = 0; %mean normalized

%% solve the fixed cost wf
solve_f; 

%% define data moments
data_moments_v2; 

%% solve model moments counterpart;
solve_size;

%% solve model moments
model_m = [Fm(3:end)-Fm(2:end-1);Sm(3:end)-Sm(2:end-1);(delta.^(1:1:2))';Fm(1)];

%% objective function
out = ((model_m - data_m))'*inv(Wmatrix)*((model_m - data_m))*100;
