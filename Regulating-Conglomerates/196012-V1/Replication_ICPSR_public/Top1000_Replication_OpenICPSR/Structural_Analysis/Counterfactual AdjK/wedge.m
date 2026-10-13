function out = wedge(rel_P,delta,rho,alpha_l,alpha_k,alpha,xi)

% wedge function described in nonlinear equation A.4
options= optimoptions('fsolve','Display','off');
   out = fsolve(@(x) x.^((1-rho*alpha_k)/(1-rho)).*(1+(delta-1).*(x).^(alpha_l/(1-alpha)))-(rel_P^(rho/(1-rho)))*(xi^(-(1-rho*alpha)/(1-rho)))*delta,1,options);