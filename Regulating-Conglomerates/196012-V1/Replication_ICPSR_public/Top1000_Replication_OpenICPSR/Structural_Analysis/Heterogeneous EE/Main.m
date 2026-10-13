% This code compute counterfactual using a set of nonlinear equations based on number of affiliates

%%
clear
clc

%% Define parameters
parameters;

%% Loop over several scenarios

vec_nu_O = [1 0.8 1 1 1.2];   
vec_nu_R = [1 0.8 0.8 1.2 1.2];
vec_phi_t = [9.3443 10.95 11.25 8.35 8.7];

vec_rel_P = zeros(size(vec_nu_O,1),1); vec_rel_E = zeros(size(vec_nu_O,1),1);

for i = 1:1:size(vec_nu_O,2)
    
nu_O = vec_nu_O(i); nu_R = vec_nu_R(i); phi_t = vec_phi_t(i);

dO = 1+s_e*(1/nu_O-1);
dR = 1+s_e*(1/nu_R-1);

%% Define the two sets of Delta_n and thresholds for related firms for regulated vs non-regulated conglomerates
%Delta refers to Delta^(1/(1-alpha)) in model
[phi_n_base, Delta_base] = phi_n(cutoff,delta,alpha_l,N,coef1,coef2,1); %baseline value

[phi_n_R, Delta_R] = phi_n(cutoff,delta,alpha_l,N,coef1,coef2,dR^(1/(1-alpha)));  %regulated conglomerate

[phi_n_O, Delta_O] = phi_n2(cutoff,delta,alpha_l,N,coef1,coef2,dO^(1/(1-alpha)));  %non-regulated conglomerate

%double check with baseline formula -- definition of Delta_R, Delta_O
Delta_O_check = dO^(-alpha_l/(1-alpha))*Delta_base;
Delta_R_check = 1+dR^(-alpha_l/(1-alpha))*(Delta_base-1);

%% Solve pi_n for regulated vs non-regulated conglomerates
pi_n_base = mean_tln(phi_n_base(1:end-1),phi_n_base(2:end),0,sigma,coef0);

pi_n_O = mean_tln(phi_n_O(1:end-1),phi_n_O(2:end),0,sigma,coef0);

pi_n_R = mean_tln(phi_n_R(1:end-1),phi_n_R(2:end),0,sigma,coef0);

%% Find the n associated with regulation threshold 

t_index = find(phi_n_O<phi_t, 1, 'last' ); 

% number of affliates
n_aff = [find(phi_n_O<phi_t);t_index;find(phi_n_R>phi_t)]; n_aff = n_aff(1:end-1);

% average profit pi
phi_nt = [phi_n_O((phi_n_O<phi_t));phi_t;phi_n_R((phi_n_R>phi_t))];
pi_nt = mean_tln(phi_nt(1:end-1),phi_nt(2:end),0,sigma,coef0);

%% ex-ante share of each size n conglomerates
Delta_nt = [Delta_O(n_aff(1:t_index));Delta_R(n_aff(t_index+1:end))];

share_nt = (Delta_nt.^coef1).*pi_nt./sum((Delta_nt.^coef1).*pi_nt);

% share of top 1000 firms
share_top = share_nt./Delta_nt;

disp('output/input share of top 1000 firms and conglomerates')
[sum(share_top(t_index+1:end)) sum(share_nt(t_index+1:end))]

%%%%%%%%%%%%%
%% Case 1 - Top 1,000 Regulation with equilibrium price adjustment
%%%%%%%%%%%%%
 
%% Solve price change iteratively%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rel_P = 1; rel_P1 = 1.2; 
while norm(rel_P-rel_P1)> 1e-8
    rel_P = rel_P1*0.2+rel_P*0.8;
% Solve wedges
lambda_n = zeros(N,1);
for n=1:1:N
lambda_n(n) = wedge(rel_P,Delta_R(n),rho,alpha_l,xi);
end

xi_qn = xi^alpha_l*((1+(Delta_R-1).*lambda_n.^(alpha_l/(1-alpha_l)))./Delta_R);

% output loss for each interavl phi_n (including phi_t) 
xi_qnt = xi_qn(n_aff);
% Update new price
rel_P1 = solve_P(share_nt,xi_qnt,t_index,rho,alpha_l);
end

%% energy (input) loss

% define the energy-efficiency adjustment factors
Adj_O_e = dO^(-(1-alpha_k*rho)/(1-alpha*rho))/nu_O*ones(size(Delta_base));
Adj_R_e = (1+dR^(-(1-alpha_k)/(1-alpha))/nu_R*(Delta_base-1))./(1+dR^(-(1-alpha_k)/(1-alpha))*(Delta_base-1));
Adj_nt = [Adj_O_e(n_aff(1:t_index));Adj_R_e(n_aff(t_index+1:end))];

share_nt_e = (Delta_nt.^coef1).*(Adj_nt).*pi_nt./sum((Delta_nt.^coef1).*(Adj_nt).*pi_nt);

share_top_e = 1./(1+dR^(-(1-alpha_k)/(1-alpha))/nu_R*(Delta_base-1)); share_top_et = share_top_e(n_aff);

disp('energy share of top 1000 firms and conglomerates')
[sum(share_nt_e(t_index+1:end).*share_top_et(t_index+1:end)) sum(share_nt_e(t_index+1:end))]

%compute relative variable inputs for regulated conglomerate
xi_en = xi*(nu_R+dR^(-(1-alpha_k)/(1-alpha))*(Delta_base-1).*lambda_n.^(1/(1-alpha_l)))./(nu_R+dR^(-(1-alpha_k)/(1-alpha))*(Delta_base-1));
xi_ent = xi_en(n_aff);

rel_E = (sum(share_nt_e(1:t_index))*(rel_P^(rho/(1-alpha_l*rho)))+sum(xi_ent(t_index+1:end).*share_nt_e(t_index+1:end)));

vec_rel_P(i) = rel_P; vec_rel_E(i) = rel_E;

end


%% Export data 
results = [vec_nu_O' , vec_nu_R', vec_rel_P', vec_rel_E'] ; 

% Write data to text file
save ('results.txt', 'results', '-ascii');
