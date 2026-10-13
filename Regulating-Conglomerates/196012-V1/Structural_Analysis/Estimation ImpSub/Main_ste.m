% Calculate the standard errors

%%
clear
clc

Nmom = 9; 
nparm = 3; 

%% Define parameters
parameters;
data_moments_v2;

%% read in parameter estimates
load param_opt


%% Define delta_n, phi_n
%Delta refers to Delta^(1/(1-alpha)) in model
cutoff = param_opt(1);
delta = param_opt(2)^(rho_c/(1-alpha*rho_c)); 
sigma = param_opt(3);
[phi_n, Delta] = phi_n(cutoff,delta,N,coef1,coef2);

%% Solve pi_n
pi_n = mean_tln(phi_n(1:end-1),phi_n(2:end),0,sigma,coef0);

%% Solve for the phi_t such that regulated firms accounting for energy share 56%
reg_share = 0.56;  phi_t_baseline = solve_phi_t(reg_share,Delta,phi_n,pi_n,coef0,coef1,sigma);

%% Compute the Jacobian matrix (rows: moments, columns: parameters)

theta=param_opt; 
moments_baseline=moments(theta,par); 

G=zeros(Nmom,nparm);

h = 0.05*param_opt;  %around 5% pertubation

for i=1:1:nparm
    thetah=theta; thetah(i)=theta(i)+h(i);
    thetal=theta; thetal(i)=theta(i)-h(i);
    momentsh=moments(thetah,par);
    momentsl=moments(thetal,par);
    G(:,i)=(momentsh-momentsl)./(2*h(i))';
end

%save jacobian G

%load jacobian

%% Weight
weight=Wmatrix;
Lambda=(G'*weight*G)\(G'*weight);

%% Standard errors
disp('standard errors')
ste = [(diag(Lambda*Variance*Lambda').^0.5)']


%% output for table A36 

tableA36_3 = [rho; rho_c ; alpha ; param_opt(2) ; ste(2) ;  param_opt(3) ;...
    ste(3);  param_opt(1) ; ste(1) ; phi_t_baseline;  moments_baseline([9,1:8]) ] ;
save ../Output/tableA36_3 tableA36_3





