% This code compute a range of gamma to fit the DID

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

vec_gamma = [0.55; 2.179; 7.36; 12.75; 24; 10000000];
%vec_gamma = 7.36;

pmat = zeros(size(vec_gamma,1),1); emat = zeros(size(vec_gamma,1),1);  nu_mat=zeros(size(vec_gamma,1),1); measure_mat=zeros(size(vec_gamma,1),1); 

for i=1:1:size(vec_gamma,1)
    
    gamma = vec_gamma(i);

%%%%% Solve price change iteratively%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rel_P = 1; rel_P1 = 1.2; 
while norm(rel_P-rel_P1)> 1e-8
    rel_P = rel_P1*0.2+rel_P*0.8;
% Solve wedges
lambda_n = zeros(N,1);
for n=1:1:N
lambda_n(n) = wedge(rel_P,Delta(n),rho,alpha_l,xi,gamma);
end
rel_nu = ((lambda_n-1)*(1/0.15)+1).^(1/gamma);
% substitute for output loss 
%xi_qn_check = (rel_P)^(rho/(1-rho))*(lambda_n.^(-1/(1-rho)))*(xi^(-(1-alpha_l)/(1-rho)));
xi_qn = (rel_P)^(rho/(1-rho)).*(lambda_n).^(-1/(1-rho)).*(xi*rel_nu).^((alpha_l-1)/(1-rho));
% output loss for each interavl phi_n (including phi_t) 
xi_qnt = xi_qn(n_aff);

% Update new price
rel_P1 = solve_P(share_nt,xi_qnt,t_index,rho,alpha_l);
end

% energy (input) loss
xi_en = xi*(1+rel_nu.*lambda_n.^(1/(1-alpha_l)).*(Delta-1))./Delta;
xi_ent = xi_en(n_aff);

rel_E = (sum(share_nt(1:t_index))*(rel_P^(rho/(1-alpha_l*rho)))+sum(xi_ent(t_index+1:end).*share_nt(t_index+1:end)));

%% save
pmat(i) = rel_P;  emat(i) = rel_E;  

rel_nut = rel_nu(n_aff); lambda_nt=lambda_n(n_aff);

nu_mat(i)=(log(rel_nut(t_index+1:end))')*share_nt(t_index+1:end)./sum(share_nt(t_index+1:end));

measure_mat(i) = (log(rel_nut(t_index+1:end))'+log(lambda_nt(t_index+1:end))')*share_nt(t_index+1:end)./sum(share_nt(t_index+1:end));

%% solve the case of conglomerate regulation (updated July 2021)

% xi_en_C = xi_en;
% 
% %%%%% Solve price change iteratively%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rel_P = 1; rel_P1 = 1.2; 
% while norm(rel_P-rel_P1)> 1e-8
%     rel_P = rel_P1*0.2+rel_P*0.8;
%     
% rel_nu_C = zeros(N,1);
% for n=1:1:N
% % directly solve the rel_nu (common across all regulated)
% options= optimoptions('fsolve','Display','off');
% rel_nu_C(n) = fsolve(@(x) (rel_P^rho)*(xi_en_C(n)*x)^(alpha_l*rho-1)-0.15*(x^gamma-1)-1,1,options);
% end
% 
% % wedges
% lambda_n_C = 1+0.15*(gamma)/(gamma+1)*(rel_nu_C.^(1+gamma)-1);
% 
% % substitute for output loss 
% xi_qn_C = (xi_en_C.*rel_nu_C).^(alpha_l);
% % output loss for each interavl phi_n (including phi_t) 
% xi_qnt_C = xi_qn_C(n_aff);
% 
% % Update new price
% rel_P1 = solve_P(share_nt,xi_qnt_C,t_index,rho,alpha_l);
% end
  
end


%% Export data 
results = [vec_gamma , pmat, emat, nu_mat, measure_mat ] ; 

% Write data to text file
save ('results.txt', 'results', '-ascii');


% %% JC notes: 
% 
% % 0 - Note gamma < infty lowers Lambda 
% % From 0.0808 in case with infity lambda to 0.0675 in case of gamma = 10 
% log(lambda_n(t_index+1:end))'*share_nt(t_index+2:end)./sum(share_nt(t_index+2:end))
% 
% % 1- Matching upper CI in naive comparison 
% % Set gamma = 2.179  
% naive_comparison_CI = [0.032+2*0.042, (log(rel_nu(t_index+1:end))')*share_nt(t_index+2:end)./sum(share_nt(t_index+2:end)) ]
% 
% % 2- Matching point estimate in naive comparison 
% % Set gamma = 12.75  
% naive_comparison_point_estimate = [0.032, (log(rel_nu(t_index+1:end))')*share_nt(t_index+2:end)./sum(share_nt(t_index+2:end)) ]
% 
% % 3- Matching upper CI in better comparison
% % Set gamma = 7.36 
% better_comparison_CI = [0.032+2*0.042, (log(rel_nu(t_index+1:end))'+log(lambda_n(t_index+1:end))')*share_nt(t_index+2:end)./sum(share_nt(t_index+2:end))]
% 
% % 4- Matching point estimate in better comparison. NB: Impossible 
% % gamma = infty doesnt do it  
% %better_comparison_point_estimate = [0.031, (log(rel_nu(t_index+1:end))'+log(lambda_n(t_index+1:end))')*share_nt(t_index+2:end)./sum(share_nt(t_index+2:end))]
% 
% % 5- Assuming Long Term gamma is lower, say 1, allows us to say how much we
% % can expect from this policy. rel_nu increases by 16% and shadow cost is
% % still 2.5% 
% 
% % 6- To do, Plot the welfare price/energy tradeoffs for different gammas 


