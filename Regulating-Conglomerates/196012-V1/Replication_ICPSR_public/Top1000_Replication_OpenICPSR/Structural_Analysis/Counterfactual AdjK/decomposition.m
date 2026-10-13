% Report the decomposition of DID 

% Updated June, 2022

%%%%%%%%%%REVENUE%%%%%%%%%%%%%%%%%
%% market demand effect

market_demand_all = rho*log(rel_P);

%% residual revenue change for unregulated conglomerates

residual_rev_control = (rho^2*alpha)/(1-rho*alpha)*log(rel_P);

%% residual revenue change for regulated conglomerates

residual_rev_regulated = sum(rho*log(xi_qnt(t_index+1:end)).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));

%% within conglomerate top firm share
share_regulated_change = -log(1+(Delta(n_aff)-1).*(lambda_nt.^(alpha_l/(1-alpha))))+log(Delta(n_aff));
share_regulated = sum(share_regulated_change(t_index+1:end).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));

share_related_change = log((Delta(n_aff)-1).*(lambda_nt.^(alpha_l/(1-alpha))))-log(Delta(n_aff)-1)-(log(1+(Delta(n_aff)-1).*(lambda_nt.^(alpha_l/(1-alpha))))-log(Delta(n_aff)));
share_related = sum(share_related_change(t_index+1:end).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));


%%%%%%%%%%%%%%%%%INPUT%%%%%%%%%%%%%%%%%%%%
%% residual input change for unregulated conglomerates

residual_input_control = (rho)/(1-rho*alpha)*log(rel_P);

%% residual input change for regulated conglomerates

residual_input_regulated = sum(log(xi_ent(t_index+1:end)).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));

%% within conglomerate top firm share
share_input_regulated_change = -log(1+(Delta(n_aff)-1).*(lambda_nt.^((1-alpha_k)/(1-alpha))))+log(Delta(n_aff));
share_input_regulated = sum(share_regulated_change(t_index+1:end).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));

share_input_related_change = log((Delta(n_aff)-1).*(lambda_nt.^((1-alpha_k)/(1-alpha))))-log(Delta(n_aff)-1)-(log(1+(Delta(n_aff)-1).*(lambda_nt.^((1-alpha_k)/(1-alpha))))-log(Delta(n_aff)));
share_input_related = sum(share_related_change(t_index+1:end).*share_nt(t_index+1:end))/sum(share_nt(t_index+1:end));
