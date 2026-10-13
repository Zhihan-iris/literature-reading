% Report the decomposition of DID 

% Updated 7/2, 2021

%%%%%%%%%%REVENUE%%%%%%%%%%%%%%%%%
%% market demand effect

market_demand_all = rho*log(rel_P);

%% residual revenue change for unregulated conglomerates

residual_rev_control = (rho^2*alpha_l)/(1-rho*alpha_l)*log(rel_P);

%% residual revenue change for regulated conglomerates

residual_rev_regulated = sum(rho*log(xi_qnt(t_index+1:end)).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));

%% residual revenue change for regulated conglomerates
% K_n = Const_Kn(n_phi_reg).*(phi_x_reg).^coef0;
% L_n = ((alpha_l/w)/(alpha_k/rv))*K_n;
% Z_n = (phi_x_reg).*(Delta(n_phi_reg).^(1-alpha)).*(K_n.^(alpha_k));
% 
% % calculate top firm
%     z1 = (phi_x_reg).*(K_n./Delta(n_phi_reg)).^alpha_k;
%     k1 = (K_n./Delta(n_phi_reg));
%     l1 = ((alpha_l/w)/(alpha_k/rv))*k1;
%   
%     % quasi-fixed factor for non-top
%     zn1 = (Z_n.^(1/(1-alpha_l))-z1.^(1/(1-alpha_l))).^(1-alpha_l);
%     ln1 = (zn1./Z_n).^(1/(1-alpha_l)).*L_n;
% 
% % ouput before/after regulation
% %output_regulated_b = Z_n.*(L_n).^(alpha_l);  as a check
% output_regulated_b = z1.*(l1.^alpha_l) + zn1.*ln1.^alpha_l;
% output_regulated_p = z1.*(xi*l1.^alpha_l) + zn1.*l_reg.^alpha_l;
% 
% residual_rev_regulated = rho*log(output_regulated_p./output_regulated_b);
% % average across firms
% residual_rev_regulated = sum(residual_rev_regulated.*phi_w(phi_x>phi_reg))/sum(phi_w(phi_x>phi_reg));

%% within conglomerate top firm share
share_regulated_change = -log(1+(Delta(n_aff)-1).*(lambda_nt.^(alpha_l/(1-alpha_l))))+log(Delta(n_aff));
share_regulated = sum(share_regulated_change(t_index+1:end).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));

share_related_change = log((Delta(n_aff)-1).*(lambda_nt.^(alpha_l/(1-alpha_l))))-log(Delta(n_aff)-1)-(log(1+(Delta(n_aff)-1).*(lambda_nt.^(alpha_l/(1-alpha_l))))-log(Delta(n_aff)));
share_related = sum(share_related_change(t_index+1:end).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));

%% within conglomerate top firm share 
% share_regulated_b = z1.*(l1.^alpha_l)./output_regulated_b;
% share_regulated_p = z1.*(xi*l1.^alpha_l)./output_regulated_p;
% 
% share_related_b = zn1.*ln1.^alpha_l./output_regulated_b;
% share_related_p = zn1.*l_reg.^alpha_l./output_regulated_p;
% 
% share_regulated = log(share_regulated_p./share_regulated_b);
% share_related = log(share_related_p./share_related_b);
% 
% % average across firms
% share_regulated = sum(share_regulated.*phi_w(phi_x>phi_reg))/sum(phi_w(phi_x>phi_reg));
% share_related = sum(share_related.*phi_w(phi_x>phi_reg))/sum(phi_w(phi_x>phi_reg));

%% summarize
%disp('output DID decomposition: share_regulated share_related residual_rev_regulated residual_rev_control market_demand')
%[share_regulated share_related residual_rev_regulated residual_rev_control market_demand_all]


%%%%%%%%%%%%%%%%%INPUT%%%%%%%%%%%%%%%%%%%%
%% residual input change for unregulated conglomerates

residual_input_control = (rho)/(1-rho*alpha_l)*log(rel_P);

%% residual input change for regulated conglomerates

residual_input_regulated = sum(log(xi_ent(t_index+1:end)).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));

%% within conglomerate top firm share
share_input_regulated_change = -log(1+(Delta(n_aff)-1).*(lambda_nt.^(1/(1-alpha_l))))+log(Delta(n_aff));
share_input_regulated = sum(share_regulated_change(t_index+1:end).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));

share_input_related_change = log((Delta(n_aff)-1).*(lambda_nt.^(1/(1-alpha_l))))-log(Delta(n_aff)-1)-(log(1+(Delta(n_aff)-1).*(lambda_nt.^(1/(1-alpha_l))))-log(Delta(n_aff)));
share_input_related = sum(share_related_change(t_index+1:end).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));

%% compute input changes 

% %change of input for control conglomerates (unregulated) is the same as
% %revenue
% input_control = residual_rev_control+market_demand_all;
% 
% %change of input for regulated firm
% input_regulated_b = l1;
% input_regulated_p = (xi*l1);
% input_regulated = sum(log(input_regulated_p./input_regulated_b).*phi_w(phi_x>phi_reg))/sum(phi_w(phi_x>phi_reg));
% 
% %change of input for related firm
% input_related_b = ln1;
% input_related_p = l_reg;
% input_related = sum(log(input_related_p./input_related_b).*phi_w(phi_x>phi_reg))/sum(phi_w(phi_x>phi_reg));

