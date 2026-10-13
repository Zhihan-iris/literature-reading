% Calculate the standard errors
clear; clc;

%% loop over the four cases (low rho, high rho, low alpha, high alpha)
tableA36_menu = zeros(19,4);

for i = 1:1:4
 %%
 %clear

 Nmom = 9; 
 nparm = 3; 

 %% Define parameters
 data_moments_v2;

 %% read in parameter estimates
 load menu_parameters

  if i==1
      rho = 0.7; alpha = 0.9;
      cutoff = m_cutoff(1,2);
      delta = m_delta(1,2)^(1/(1-alpha));
      sigma = m_sigma(1,2);
  end
  if i==2
      rho = 0.9; alpha = 0.9;
      cutoff = m_cutoff(3,2);
      delta = m_delta(3,2)^(1/(1-alpha));
      sigma = m_sigma(3,2);
  end
  if i==3
      rho = 0.75; alpha=0.85; 
      cutoff = m_cutoff(2,1);
      delta = m_delta(2,1)^(1/(1-alpha));
      sigma = m_sigma(2,1);
  end
  if i==4
      rho = 0.75; alpha = 0.95; 
      cutoff = m_cutoff(2,3);
      delta = m_delta(2,3)^(1/(1-alpha));
      sigma = m_sigma(2,3);
  end

parameters_menu;

%% Define delta_n, phi_n
%Delta refers to Delta^(1/(1-alpha)) in model
[phi_n_menu, Delta] = phi_n(cutoff,delta,N,coef1,coef2);

%% Solve pi_n
pi_n = mean_tln(phi_n_menu(1:end-1),phi_n_menu(2:end),0,sigma,coef0);

%% Solve for the phi_t such that regulated firms accounting for energy share 56%
reg_share = 0.56;  phi_t = solve_phi_t(reg_share,Delta,phi_n_menu,pi_n,coef0,coef1,sigma);

%% Compute the Jacobian matrix (rows: moments, columns: parameters)

theta=[cutoff;delta^(1-alpha);sigma]; 
moments_menu=moments(theta,par); 

G=zeros(Nmom,nparm);

h = 0.05*theta;  %around 5% pertubation

for j=1:1:nparm
    thetah=theta; thetah(j)=theta(j)+h(j);
    thetal=theta; thetal(j)=theta(j)-h(j);
    momentsh=moments(thetah,par);
    momentsl=moments(thetal,par);
    G(:,j)=(momentsh-momentsl)./(2*h(j))';
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

tableA36_menu(:,i) = [rho; NaN ; alpha ; theta(2) ; ste(2) ;  theta(3) ; ste(3);  theta(1) ; ste(1) ; phi_t;  moments_menu([9,1:8]) ] ;

end

save ../Output/tableA36_menu tableA36_menu

