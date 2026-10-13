% This calculates the threshold phi for conglomerate of each size n=1,2,...
function [phi_n, Delta] = phi_nt(cutoff,delta,N,coef1,coef2)

  phi_n = zeros(N+1,1); Delta = zeros(N,1); Delta_t = zeros(N,1);
  for i=1:1:N
    if i==1 
    Delta(i) = 1; Delta_t(i)=1; phi_n (i) = cutoff;
    else
    Delta(i) = Delta(i-1)+(delta^(i-1));
    Delta_t (i) = (Delta(i)^coef1-Delta(i-1)^coef1)^coef2;
    end      
    phi_n (i) = cutoff/Delta_t(i);
  end
phi_n(end) = +Inf;