% This code compute the case where there is no congl. leakage

% Updated July, 2021

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

%% Define regulation threshold
reg_share = 0.56;  phi_t = solve_phi_t(reg_share,Delta,phi_n,pi_n,coef0,coef1,sigma);

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

%% Loop over the few values of gamma

%vec_gamma = [0.55; 2.179; 7.36; 12.75; 24; 10000000];
vec_gamma = 7.36;
pmat = zeros(size(vec_gamma,1),1); emat = zeros(size(vec_gamma,1),1);  nu_mat=zeros(size(vec_gamma,1),1); measure_mat=zeros(size(vec_gamma,1),1); 

for i=1:1:size(vec_gamma,1)
    
    gamma = vec_gamma(i);

%%%%% Solve price change iteratively%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rel_P = 1; rel_P1 = 1.2; rel_nu = ones(N,1);
while norm(rel_P-rel_P1)> 1e-8
    rel_P = rel_P1*0.2+rel_P*0.8;
% Solve wedges
lambda_n = zeros(N,1);  
for n=1:1:N
lambda_n(n) = wedge_no_leakage(rel_P,Delta(n),rho,alpha_l,xi,gamma,rel_nu(n));
end
rel_nu = ((lambda_n-1)*(1/0.15)+1).^(1/gamma);
% substitute for output loss 
xi_qn = ((xi*rel_nu).^(alpha_l)+(Delta-1).*(rel_P)^((alpha_l*rho)/(1-alpha_l*rho)))./Delta;
% output loss for each interavl phi_n (including phi_t) 
xi_qnt = xi_qn(n_aff);

% Update new price
rel_P1 = solve_P(share_nt,xi_qnt,t_index,rho,alpha_l);
end

% energy (input) loss
xi_en = (xi+(Delta-1).*(rel_P)^((alpha_l*rho)/(1-alpha_l*rho)))./Delta;
xi_ent = xi_en(n_aff);

rel_E = (sum(share_nt(1:t_index))*(rel_P^(rho/(1-alpha_l*rho)))+sum(xi_ent(t_index+1:end).*share_nt(t_index+1:end)));

%% save
pmat(i) = rel_P;  emat(i) = rel_E;  

rel_nut = rel_nu(n_aff); lambda_nt=lambda_n(n_aff);

nu_mat(i)=(log(rel_nut(t_index+1:end))')*share_nt(t_index+1:end)./sum(share_nt(t_index+1:end));

measure_mat(i) = (log(rel_nut(t_index+1:end))'+log(lambda_nt(t_index+1:end))')*share_nt(t_index+1:end)./sum(share_nt(t_index+1:end));
  
end


%% Export data 
results = [vec_gamma , pmat, emat, nu_mat, measure_mat ] ; 

% Write data to text file
save ('results_no_leakage.txt', 'results', '-ascii');




