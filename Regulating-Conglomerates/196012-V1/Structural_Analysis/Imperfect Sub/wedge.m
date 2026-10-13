function out = wedge(rel_P,delta,rho,rho_c,alpha_l,xi)

% wedge function described in nonlinear equation A.4 -- adjusted for rho_c!
options= optimoptions('fsolve','Display','off');
out = fsolve(@(x) x.^(1/(1-rho)).*((1+(delta-1).*(x).^(alpha_l*rho_c/(1-alpha_l*rho_c)))/delta).^(1/rho_c)...
    -(rel_P^(rho/(1-rho)))*(xi^(-(1-(rho_c+(rho-1))*alpha_l)/(1-rho))),1,options);