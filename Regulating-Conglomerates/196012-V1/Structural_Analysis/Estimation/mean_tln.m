% This code calculates the mean of RV X^a, with LN(mu,sigma), truncted at (lb,ub)

function out = mean_tln(lb,ub,mu,sigma,a)

mu_t = a*mu; sigma_t = a*sigma;  
out = exp(a*mu_t+0.5*(sigma_t)^2)*(normcdf((a*log(ub)-mu_t)/sigma_t-sigma_t)...
    -normcdf((a*log(lb)-mu_t)/sigma_t-sigma_t));
%./...
%    (normcdf((a*log(ub)-mu_t)/sigma_t)-normcdf((a*log(lb)-mu_t)/sigma_t));



