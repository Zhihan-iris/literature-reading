% This code compute counterfactual using a set of nonlinear equations based on number of affiliates
% Updated May, 2021

%%
clear
clc

%% Define parameters
parameters;

%% Define delta_n, phi_n
%Delta refers to Delta^(1/(1-alpha)) in model
[phi_n, Delta] = phi_n(cutoff,delta,N,coef1,coef2);

%% Solve pi_n
pi_n = mean_tln(phi_n(1:end-1),phi_n(2:end),0,sigma,coef0);

%% Solve for the phi_t such that regulated firms accounting for energy share 56%
reg_share = 0.56;  phi_t_baseline = solve_phi_t(reg_share,Delta,phi_n,pi_n,coef0,coef1,sigma);

%% Solve for the higher threshold
%reg_share = 0.5;   phi_t_high = solve_phi_t(reg_share,Delta,phi_n,pi_n,coef0,coef1,sigma);

%% Solve for the lower threshold
%reg_share = 0.6;  phi_t_low = solve_phi_t(reg_share,Delta,phi_n,pi_n,coef0,coef1,sigma);

%% Loop over phi_t, xi

vec_phi_t = [phi_t_baseline]; 
vec_xi = [0.8];

% define matrix to save values
share_top_1000 = zeros(size(vec_phi_t,1),1); share_top_1000cong = zeros(size(vec_phi_t,1),1);
pmat = zeros(size(vec_phi_t,1),size(vec_xi,1)); emat = zeros(size(vec_phi_t,1),size(vec_xi,1)); 
lambda_mat = zeros(size(vec_phi_t,1),size(vec_xi,1)); xi_qn_mat = zeros(size(vec_phi_t,1),size(vec_xi,1)); xi_en_mat = zeros(size(vec_phi_t,1),size(vec_xi,1));

market_mat= zeros(size(vec_phi_t,1),size(vec_xi,1)); resdiual_treat_mat= zeros(size(vec_phi_t,1),size(vec_xi,1)); resdiual_control_mat= zeros(size(vec_phi_t,1),size(vec_xi,1));
share_regulated_mat= zeros(size(vec_phi_t,1),size(vec_xi,1));share_related_mat= zeros(size(vec_phi_t,1),size(vec_xi,1));

did_input_regulated_mat = zeros(size(vec_phi_t,1),size(vec_xi,1)); did_input_related_mat = zeros(size(vec_phi_t,1),size(vec_xi,1));

% Start the loop
for i = 1:1:size(vec_phi_t,1)
    phi_t = vec_phi_t(i);
 
%% Find the n associated with regulation threshold 

t_index = find(phi_n<phi_t, 1, 'last' );
% number of affliates
n_aff = [find(phi_n<phi_t);find(phi_n<phi_t, 1, 'last' );find(phi_n>phi_t)]; n_aff = n_aff(1:end-1);
% average profit pi
phi_nt = [phi_n((phi_n<phi_t));phi_t;phi_n((phi_n>phi_t))];
pi_nt = mean_tln(phi_nt(1:end-1),phi_nt(2:end),0,sigma,coef0);
% ex-ante share of each size n conglomerates
share_nt = (Delta(n_aff).^coef1).*pi_nt./sum((Delta(n_aff).^coef1).*pi_nt);

% share of top 1000 firms
share_top = share_nt./Delta(n_aff);
%share_top_1000(i) = sum(share_top(t_index+1:end)); share_top_1000cong(i) = sum(share_nt(t_index+1:end));
disp('output/energy share of top 1000 firms and conglomerates')
[sum(share_top(t_index+1:end)) sum(share_nt(t_index+1:end))]


for j=1:1:size(vec_xi,1)
    
   xi = vec_xi(j);
    
% Report iteration
 disp('iteration of (phi_t,xi)')
 [phi_t xi]

% Solve price change iteratively%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rel_P = 1; rel_P1 = 1.2; 
while norm(rel_P-rel_P1)> 1e-8
    
    rel_P = rel_P1*0.2+rel_P*0.8;
% Solve wedges
lambda_n = zeros(N,1);
for n=1:1:N
lambda_n(n) = wedge(rel_P,Delta(n),rho,alpha_l,xi);
end
% substitute for output loss
xi_qn = (rel_P)^(rho/(1-rho))*(lambda_n.^(-1/(1-rho)))*(xi^(-(1-alpha_l)/(1-rho)));
% output loss
xi_qnt = xi_qn(n_aff);
%% Update new price
%rel_P1 = fsolve(@(x) x^(-rho)-(sum(share_nt(1:t_index))*(x^(rho*alpha*coef0))+sum((xi_qnt(t_index+1:end).^rho).*share_nt(t_index+1:end))),1);
rel_P1 = solve_P(share_nt,xi_qnt,t_index,rho,alpha_l);
end

% energy (input) loss
xi_en = xi*(1+lambda_n.^(1/(1-alpha_l)).*(Delta-1))./Delta;
xi_ent = xi_en(n_aff);

rel_E = (sum(share_nt(1:t_index))*(rel_P^(rho/(1-alpha_l*rho)))+sum(xi_ent(t_index+1:end).*share_nt(t_index+1:end)));

% average shadow cost for regulated conglomerates
lambda_nt = lambda_n(n_aff);
mlambda_nt = sum(lambda_nt(t_index+1:end).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));

% average output and input loss for regulated conglomerates
mxi_qnt = sum(xi_qnt(t_index+1:end).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));
mxi_ent = sum(xi_ent(t_index+1:end).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));

%% Save 

    pmat(i,j) = rel_P; emat(i,j) = rel_E; lambda_mat(i,j) = mlambda_nt; xi_qn_mat(i,j) = mxi_qnt; xi_en_mat(i,j) = mxi_ent;
    
%% DID decomposition
    decomposition;
    
    market_mat(i,j) = market_demand_all;  resdiual_treat_mat(i,j) = residual_rev_regulated; resdiual_control_mat(i,j) = residual_rev_control;
    share_regulated_mat(i,j) = share_regulated; share_related_mat(i,j) = share_related;
    
    did_input_regulated_mat(i,j) = (share_input_regulated+residual_input_regulated)-(residual_input_control); 
    did_input_related_mat(i,j) = (share_input_related+residual_input_regulated)-(residual_input_control); 
    
end

end

%%% Save results for Table 5
% These are the same by definition since they are in the same conglomerate
residual_rev_related = residual_rev_regulated ; 

decomposition_results = [ share_regulated , residual_rev_regulated , market_demand_all , share_regulated+residual_rev_regulated+market_demand_all; ...
                                0         , residual_rev_control   , market_demand_all ,  0+residual_rev_control+market_demand_all; ...
                           share_regulated, residual_rev_regulated-residual_rev_control, 0 , share_regulated+residual_rev_regulated-residual_rev_control; ... 
                         share_related    , residual_rev_related , market_demand_all , share_related+residual_rev_related+market_demand_all; ...
                                0         , residual_rev_control   , market_demand_all ,  0+residual_rev_control+market_demand_all; ...
                           share_related  , residual_rev_related-residual_rev_control, 0 , share_related+residual_rev_related-residual_rev_control; ...    
                             share_regulated-share_related, 0 , 0 ,    share_regulated-share_related ] ;  
                
save  ../Output/table5.mat  decomposition_results     


%%% Save results for Figure 7 
model_fit_results = [ share_regulated+residual_rev_regulated-residual_rev_control; ... 
                      share_related+residual_rev_related-residual_rev_control; ...   
                      residual_rev_control+market_demand_all ; 
                      share_regulated-share_related ; ... 
                      did_input_regulated_mat ; ... 
                      did_input_related_mat ; 
                      share_regulated+residual_rev_regulated-residual_rev_control-did_input_regulated_mat; ... 
                      share_related+residual_rev_related-residual_rev_control-did_input_related_mat] ;  

% Write data to text file
save ('results_figure_6B.txt', 'model_fit_results', '-ascii');


