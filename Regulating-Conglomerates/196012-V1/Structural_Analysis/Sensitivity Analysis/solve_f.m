% Solve fixed cost 

%% Calculate fixed cost f, given \phi*, G(\phi)
%Delta refers to Delta^(1/(1-alpha)) in model
[phi_n, Delta] = phi_n(cutoff,delta,N,coef1,coef2);

pi_n = mean_tln(phi_n(1:end-1),phi_n(2:end),0,sigma,coef0);

%% fixed cost and mass of firms
%average number of establishments per active conglomerate
Mest = sum((1:1:N)'.*(normcdf(log(phi_n(2:end))/sigma)-normcdf(log(phi_n(1:end-1))/sigma)))/(1-normcdf(log(cutoff)/sigma));
%number of conglomerates
M_data = Mest_data/Mest;
%compute fixed cost using Product Market Clearing
LHS= sum(pi_n.*Delta.^coef1)/(cutoff^coef0);
RHS = (1-alpha*rho)*(1-normcdf(log(cutoff)/sigma))*(R/M_data);
wf = RHS/LHS;
