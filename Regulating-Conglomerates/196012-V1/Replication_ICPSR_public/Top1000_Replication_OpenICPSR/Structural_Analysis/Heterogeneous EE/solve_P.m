function out = solve_P(share_nt,xi_qnt,t_index,rho,alpha_l)

%solve relative price, given output loss, using equation A.7
   out = fsolve(@(x) x^(-rho)-(sum(share_nt(1:t_index))*(x^(rho^2*alpha_l/(1-alpha_l*rho)))+sum((xi_qnt(t_index+1:end).^rho).*share_nt(t_index+1:end))),1,optimoptions('fsolve','Display','off'));
   

