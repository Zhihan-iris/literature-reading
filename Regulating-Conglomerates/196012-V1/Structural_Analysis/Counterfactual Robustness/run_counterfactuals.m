
%% Define delta_n, phi_n
%Delta refers to Delta^(1/(1-alpha)) in model
[phi_n, Delta] = phi_n(cutoff,delta,N,coef1,coef2);

%% Solve pi_n
pi_n = mean_tln(phi_n(1:end-1),phi_n(2:end),0,sigma,coef0);

%% Solve for the phi_t such that regulated firms accounting for energy share 56%
reg_share = 0.56;  phi_t_baseline = solve_phi_t(reg_share,Delta,phi_n,pi_n,coef0,coef1,sigma);

%% Solve for the higher threshold
reg_share = 0.5;   phi_t_high = solve_phi_t(reg_share,Delta,phi_n,pi_n,coef0,coef1,sigma);

%% Solve for the lower threshold
reg_share = 0.6;  phi_t_low = solve_phi_t(reg_share,Delta,phi_n,pi_n,coef0,coef1,sigma);

%% Loop over phi_t, xi

vec_phi_t = [phi_t_low; phi_t_baseline; phi_t_high]; 
vec_xi = [0.95;0.9;0.85;0.8;0.75;.70];

% define matrix to save values 
% for all 
share_top_1000 = zeros(3,1); share_top_1000cong = zeros(3,1);
% for Top 1,000 regulation 
pmat = zeros(3,6); emat = zeros(3,6); lambda_mat = zeros(3,6); xi_qn_mat = zeros(3,6); xi_en_mat = zeros(3,6);
% for Conglomerate regulation 
pmat_c = zeros(3,6); emat_c = zeros(3,6); lambda_mat_c = zeros(3,6); xi_qn_mat_c = zeros(3,6); xi_en_mat_c = zeros(3,6);
% for tax  
pmat_t = zeros(3,6); emat_t = zeros(3,6); lambda_mat_t = zeros(3,6); xi_qn_mat_t = zeros(3,6); xi_en_mat_t = zeros(3,6);
% no market leakage 
pmat_nm = zeros(3,6); emat_nm = zeros(3,6); lambda_mat_nm = zeros(3,6); xi_qn_mat_nm = zeros(3,6); xi_en_mat_nm = zeros(3,6); lambda_mat_nm2 = zeros(3,6);
% no conglomerate leakage
pmat_nc = zeros(3,6); emat_nc = zeros(3,6); lambda_mat_nc = zeros(3,6); xi_qn_mat_nc = zeros(3,6); xi_en_mat_nc = zeros(3,6);
% no both 
pmat_nb = zeros(3,6); emat_nb = zeros(3,6); lambda_mat_nb = zeros(3,6); xi_qn_mat_nb = zeros(3,6); xi_en_mat_nb = zeros(3,6);

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

share_top_1000(i) = sum(share_top(t_index+1:end)); share_top_1000cong(i) = sum(share_nt(t_index+1:end));
disp('output/energy share of top 1000 firms')
[sum(share_top(t_index+1:end)) sum(share_nt(t_index+1:end))]

%%
for j=1:1:size(vec_xi,1)
    
    xi = vec_xi(j);
   
% Report iteration
 disp('iteration of (phi_t,xi)')
 [phi_t xi]

%%%%%%%%%%%%%
%% Case 1 - Top 1,000 Regulation with equilibrium price adjustment
%%%%%%%%%%%%%
 
% Solve price change iteratively%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rel_P = 1; rel_P1 = 1.2; 
while norm(rel_P-rel_P1)> 1e-8
    rel_P = rel_P1*0.2+rel_P*0.8;
% Solve wedges
lambda_n = zeros(N,1);
for n=1:1:N
lambda_n(n) = wedge(rel_P,Delta(n),rho,alpha_l,xi);
end
% substitute for output loss using equation A.2
%xi_qn_check = (rel_P)^(rho/(1-rho))*(lambda_n.^(-1/(1-rho)))*(xi^(-(1-alpha_l)/(1-rho)));
xi_qn = xi^alpha_l*((1+(Delta-1).*lambda_n.^(alpha_l/(1-alpha_l)))./Delta);

% output loss for each interavl phi_n (including phi_t) 
xi_qnt = xi_qn(n_aff);
% Update new price
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

% Save this for the conglomerate regulations
xi_en_C = xi_en ; 
% Save this for the tax case 
mxi_ent_T = mxi_ent ; 

%%%%%%%%%%%%%
%% Case 2 - Conglomerate Regulation 
%%%%%%%%%%%%%

% Note: based on the updated appendix, there is NO wedge/relative price
% iterations! 

% substitute for output loss
xi_qn = (xi_en_C).^(alpha_l);
% output loss
xi_qnt = xi_qn(n_aff);
% Update new price
rel_P = solve_P(share_nt,xi_qnt,t_index,rho,alpha_l);

% Solve wedges
lambda_n = zeros(N,1);
for n=1:1:N
lambda_n(n) = (rel_P^(rho))*(xi_en_C(n))^(-(1-rho*alpha_l)) ;
end

% energy (input) loss
xi_en = xi_en_C ; 
xi_ent = xi_en(n_aff);

rel_E = (sum(share_nt(1:t_index))*(rel_P^(rho/(1-alpha_l*rho)))+sum(xi_ent(t_index+1:end).*share_nt(t_index+1:end)));

% average shadow cost for regulated conglomerates
lambda_nt = lambda_n(n_aff);
mlambda_nt = sum(lambda_nt(t_index+1:end).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));

% average output and input loss for regulated conglomerates
mxi_qnt = sum(xi_qnt(t_index+1:end).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));
mxi_ent = sum(xi_ent(t_index+1:end).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));

%% Save 

pmat_c(i,j) = rel_P; emat_c(i,j) = rel_E; lambda_mat_c(i,j) = mlambda_nt; xi_qn_mat_c(i,j) = mxi_qnt; xi_en_mat_c(i,j) = mxi_ent;


%%%%%%%%%%%%%
%% Case 3 - Taxation
%%%%%%%%%%%%%
 
% Note: based on the updated appendix, there is NO wedge/relative price
% iterations! 

% substitute for output loss
xi_qn = (mxi_ent_T).^(alpha_l);
% output loss
xi_qnt = xi_qn*ones(size(n_aff,1),1);
% Update new price
rel_P = solve_P(share_nt,xi_qnt,t_index,rho,alpha_l);

% Solve wedges
lambda_n = zeros(N,1);
for n=1:1:N
lambda_n(n) = (rel_P^(rho))*(mxi_ent_T)^(-(1-rho*alpha_l)) ;
end

% energy (input) loss
xi_en = mxi_ent_T;
xi_ent = xi_en*ones(size(n_aff,1),1);

rel_E = (sum(share_nt(1:t_index))*(rel_P^(rho/(1-alpha_l*rho)))+sum(xi_ent(t_index+1:end).*share_nt(t_index+1:end)));

% average shadow cost for regulated conglomerates
lambda_nt = lambda_n(n_aff);
mlambda_nt = sum(lambda_nt(t_index+1:end).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));

% average output and input loss for regulated conglomerates
mxi_qnt = sum(xi_qnt(t_index+1:end).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));
mxi_ent = sum(xi_ent(t_index+1:end).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));

%% Save 

pmat_t(i,j) = rel_P; emat_t(i,j) = rel_E; lambda_mat_t(i,j) = mlambda_nt; xi_qn_mat_t(i,j) = mxi_qnt; xi_en_mat_t(i,j) = mxi_ent;

%%%%%%%%%%%%%
%% Case 4 - No Market Leakage
%%%%%%%%%%%%%

% Solve wedges, with perceived rel_P = 1
lambda_n = zeros(N,1);
for n=1:1:N
lambda_n(n) = wedge(1,Delta(n),rho,alpha_l,xi);
end
% substitute for output loss
xi_qn = (lambda_n.*(1^(-rho))).^((rho*alpha_l)/(-(1-rho*alpha_l))) ;
% output loss
xi_qnt = xi_qn(n_aff);

% energy (input) loss
xi_en = xi*(1+lambda_n.^(1/(1-alpha_l)).*(Delta-1))./Delta;
xi_ent = xi_en(n_aff);

rel_E = (sum(share_nt(1:t_index))+sum(xi_ent(t_index+1:end).*share_nt(t_index+1:end)));

% direct compute the implied price
rel_P = (sum(share_nt(1:t_index))+sum((xi_qnt(t_index+1:end).^rho).*share_nt(t_index+1:end)))^(-1/rho);

% Solve for wedges with equilibrium price 
lambda_n2 = zeros(N,1);
for n=1:1:N
lambda_n2(n) = wedge(rel_P,Delta(n),rho,alpha_l,xi);
end

% average shadow cost for regulated conglomerates
lambda_nt = lambda_n(n_aff);
mlambda_nt = sum(lambda_nt(t_index+1:end).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));

% average shadow cost for regulated conglomerates with eq price 
lambda_nt2 = lambda_n2(n_aff);
mlambda_nt2 = sum(lambda_nt2(t_index+1:end).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));

% average output and input loss for regulated conglomerates
mxi_qnt = sum(xi_qnt(t_index+1:end).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));
mxi_ent = sum(xi_ent(t_index+1:end).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));

%% Save 

pmat_nm(i,j) = rel_P; emat_nm(i,j) = rel_E; lambda_mat_nm(i,j) = mlambda_nt; xi_qn_mat_nm(i,j) = mxi_qnt; xi_en_mat_nm(i,j) = mxi_ent;
% This is a version of the lambdas that takes into account the equilibrium price change 
lambda_mat_nm2(i,j) = mlambda_nt2;

%%%%%%%%%%%%%
%% Case 5 - No Conglomerate Leakage
%%%%%%%%%%%%%

% output loss
xi_qn = ((xi^(alpha_l)+(Delta-1)*(rel_P)^(rho*alpha_l/(1-alpha_l*rho)))./Delta);

% output loss
xi_qnt = xi_qn(n_aff);

% Update new price
rel_P = solve_P(share_nt,xi_qnt,t_index,rho,alpha_l);
lambda_n = (rel_P^(rho))*(xi_qn.^(-(1-rho)))*(xi^(-(1-alpha_l)));

% energy (input) loss
xi_en = ((xi+(Delta-1)*(rel_P)^(rho*alpha_l/(1-alpha_l*rho)))./Delta);
xi_ent = xi_en(n_aff);

rel_E = (sum(share_nt(1:t_index))*(rel_P^(rho/(1-alpha_l*rho)))+sum(xi_ent(t_index+1:end).*share_nt(t_index+1:end)));

% average shadow cost for regulated conglomerates
lambda_nt = lambda_n(n_aff);
mlambda_nt = sum(lambda_nt(t_index+1:end).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));

% average output and input loss for regulated conglomerates
mxi_qnt = sum(xi_qnt(t_index+1:end).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));
mxi_ent = sum(xi_ent(t_index+1:end).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));

%% Save 

pmat_nc(i,j) = rel_P; emat_nc(i,j) = rel_E; lambda_mat_nc(i,j) = mlambda_nt; xi_qn_mat_nc(i,j) = mxi_qnt; xi_en_mat_nc(i,j) = mxi_ent;

%%%%%%%%%%%%%
%% Case 6 - No Leakage
%%%%%%%%%%%%%

% output loss
xi_qn = ((xi^(alpha_l)-1+Delta)./Delta);

% output loss
xi_qnt = xi_qn(n_aff);
lambda_n = (xi_qn.^(-(1-rho)))*(xi^(-(1-alpha_l)));

% directly compute price
rel_P = (sum(share_nt(1:t_index))+sum((xi_qnt(t_index+1:end).^rho).*share_nt(t_index+1:end)))^(-1/rho);


% energy (input) loss
xi_en = ((xi-1+Delta)./Delta);
xi_ent = xi_en(n_aff);
rel_E = (sum(share_nt(1:t_index))+sum(xi_ent(t_index+1:end).*share_nt(t_index+1:end)));

% average shadow cost for regulated conglomerates
lambda_nt = lambda_n(n_aff);
mlambda_nt = sum(lambda_nt(t_index+1:end).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));

% average output and input loss for regulated conglomerates
mxi_qnt = sum(xi_qnt(t_index+1:end).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));
mxi_ent = sum(xi_ent(t_index+1:end).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));

%% Save 

pmat_nb(i,j) = rel_P; emat_nb(i,j) = rel_E; lambda_mat_nb(i,j) = mlambda_nt; xi_qn_mat_nb(i,j) = mxi_qnt; xi_en_mat_nb(i,j) = mxi_ent;

end


end
% This version of the no leakage lambdas adjusts for the equilibrium price change 
lambda_mat_nb2 = pmat_nb.^(rho).*lambda_mat_nb ; 

% pmat is relative price 
% emat is relative energy 
% lambda_mat is 1+shadow cost 
% xi_qn_mat is reduction in output 
% xi_en_mat is reduction in energy  
% share_top_1000
% share_top_1000cong

% % computes break even k/(1-k) for Top 1,000 regulation 
% rel_k = -log(1+(pmat-1))./log(emat) ; 
% k = (rel_k./(1+rel_k))*2.725*1000/6.28 ; 
% 
% % computes break even k/(1-k) for Conglomerate regulation 
% rel_k_c = -log(1+(pmat_c-1))./log(emat_c) ; 
% k_c = (rel_k_c./(1+rel_k_c))*2.725*1000/6.28 ; 
% 
% % computes break even k/(1-k) for Taxation 
% rel_k_t = -log(1+(pmat_t-1))./log(emat_t) ; 
% k_t = (rel_k_t./(1+rel_k_t))*2.725*1000/6.28 ; 
% 
%% Export data 
results = [ vec_phi_t(1)*ones(size(vec_xi)) , vec_xi , pmat(1,:)' , emat(1,:)', pmat_c(1,:)' , emat_c(1,:)', pmat_t(1,:)' , emat_t(1,:)', pmat_nm(1,:)' , emat_nm(1,:)' , pmat_nc(1,:)' , emat_nc(1,:)' , pmat_nb(1,:)' , emat_nb(1,:)'  ;
            vec_phi_t(2)*ones(size(vec_xi)) , vec_xi , pmat(2,:)' , emat(2,:)', pmat_c(2,:)' , emat_c(2,:)', pmat_t(2,:)' , emat_t(2,:)', pmat_nm(2,:)' , emat_nm(2,:)' , pmat_nc(2,:)' , emat_nc(2,:)' , pmat_nb(2,:)' , emat_nb(2,:)' ;
            vec_phi_t(3)*ones(size(vec_xi)) , vec_xi , pmat(3,:)' , emat(3,:)', pmat_c(3,:)' , emat_c(3,:)', pmat_t(3,:)' , emat_t(3,:)', pmat_nm(3,:)' , emat_nm(3,:)' , pmat_nc(3,:)' , emat_nc(3,:)' , pmat_nb(3,:)' , emat_nb(3,:)' ] ;

