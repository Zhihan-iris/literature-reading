% This calculates the threshold phi for conglomerate of each size n=1,2,...
function [out1, out2] = phi_n2(cutoff,delta,alpha_l,N,coef1,coef2,d)

  out1 = zeros(N+1,1); out2 = zeros(N,1); Delta_t = zeros(N,1);
  for i=1:1:N
    if i==1 
    out2(i) = d^(-alpha_l); Delta_t(i)=1; out1(i) = cutoff;
    else
    out2(i) = out2(i-1)+(d^(-alpha_l)*delta^(i-1));
    Delta_t (i) = (out2(i)^coef1-out2(i-1)^coef1)^coef2;
    end      
    out1 (i) = cutoff/Delta_t(i);
  end
out1(end) = +Inf;