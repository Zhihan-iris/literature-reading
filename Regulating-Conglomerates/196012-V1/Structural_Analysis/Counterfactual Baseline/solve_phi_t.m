% Solve the regulation threshold for a fraction
function out = solve_phi_t(reg_share,Delta,phi_n,pi_n,coef0,coef1,sigma)

% Solve phi_t and number of affiliates of regulated congl.

%% share of top firm in each n categories
share_n = (Delta.^coef1.*pi_n)./sum(Delta.^coef1.*pi_n).*(1./Delta);

%% find the cutoff n
c_share = cumsum(share_n,'reverse');
n_cutoff = find(c_share>reg_share, 1, 'last' );

if isempty(n_cutoff)==1 
     disp('total share is below regulation threshold')
     phi_t = [];
else
cs_n = c_share(n_cutoff);
%disp('n_cutoff')
%[n_cutoff]

%% find the phi_t
a = coef0;
sigma_t = a*sigma;  
RHS = normcdf(a*log(phi_n(n_cutoff))/sigma_t-sigma_t)+...
    (normcdf(a*log(phi_n(n_cutoff+1))/sigma_t-sigma_t)-normcdf(a*log(phi_n(n_cutoff))/sigma_t-sigma_t))*(cs_n-reg_share)/share_n(n_cutoff);
phi_t = exp((norminv(RHS)+sigma_t)*sigma_t/a);
end

disp('regulation threshold phi_t')
[phi_t]

out = phi_t;