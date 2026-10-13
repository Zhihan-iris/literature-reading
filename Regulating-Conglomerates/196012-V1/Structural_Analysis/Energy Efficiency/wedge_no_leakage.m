function out = wedge_no_leakage(rel_P,delta,rho,alpha_l,xi,gamma,rel_nu)

% wedge function described in nonlinear equation A.16
options= optimoptions('fsolve','Display','off');

%rel_nu = ((x-1).*(1/0.15)+1).^(1/gamma);  s_e = (nu^*)^gamma = 0.15;

out = fsolve(@(x) rel_P^rho*(((xi*rel_nu).^(alpha_l)+(delta-1)*rel_P^(alpha_l*rho/(1-alpha_l*rho)))./delta).^(rho-1)*(xi*rel_nu).^(alpha_l-1)-x,1,options);

