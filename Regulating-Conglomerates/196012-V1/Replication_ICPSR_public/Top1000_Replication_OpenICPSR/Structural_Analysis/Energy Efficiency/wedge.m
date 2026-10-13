function out = wedge(rel_P,delta,rho,alpha_l,xi,gamma)

% wedge function described in nonlinear equation A.16
options= optimoptions('fsolve','Display','off');

out = fsolve(@(x) x.^(1/(1-rho)).*(1+(delta-1).*(x).^(alpha_l/(1-alpha_l)))-(rel_P^(rho/(1-rho)))*(xi*((x-1)*(1/0.15)+1).^(1/gamma))^(-(1-rho*alpha_l)/(1-rho))*delta,1,options);