% Solve phi_t and number of affiliates of regulated congl.

reg_share = 0.56;

%% share of top firm in each n categories
share_n = (Delta.^coef1.*pi_n)./sum(Delta.^coef1.*pi_n).*(1./Delta);

%% find the cutoff n
c_share = cumsum(share_n,'reverse');
n_cutoff = find(c_share>reg_share, 1, 'last' );

if isempty(n_cutoff)==1 
    n_cutoff = 1; phi_t = phi_n(1); cs_n =reg_share;
    avg_n = 1;
else
cs_n = c_share(n_cutoff);

%% find the phi_t
a = coef0;
sigma_t = a*sigma;  
RHS = normcdf(a*log(phi_n(n_cutoff))/sigma_t-sigma_t)+...
    (normcdf(a*log(phi_n(n_cutoff+1))/sigma_t-sigma_t)-normcdf(a*log(phi_n(n_cutoff))/sigma_t-sigma_t))*(cs_n-reg_share)/share_n(n_cutoff);
phi_t = exp((norminv(RHS)+sigma_t)*sigma_t/a);

%% average number of affiliates
avg_n = (sum((n_cutoff+1:1:N)'.*(normcdf(log(phi_n(n_cutoff+2:end))/sigma)-normcdf(log(phi_n(n_cutoff+1:end-1))/sigma)))...
    +n_cutoff*(normcdf(log(phi_n(n_cutoff+1))/sigma)-normcdf(log(phi_t)/sigma)))...
    /(1-normcdf(log(phi_t)/sigma));
end

disp('number of affiliates for top 1000')
[avg_n]

