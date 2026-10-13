%% Revenue shifter
r_ni = zeros(N,N);
for n=1:1:N
    for i=1:1:n
       r_ni (n,i) = 1/(1-rho*alpha)*(wf)*(delta^(i-1)/Delta(n)).*(Delta(n).^coef1)/(cutoff^coef0);
    end
end

%% Define model counterparts to empirical cdf bins
n_bin = size(am,2);
Fm = zeros(n_bin,1);
Sm = zeros(n_bin,1);

%total mass of establishments 
phi_n;
totalest = sum((1:1:N)'.*(normcdf(log(phi_n(2:end))/sigma)-normcdf(log(phi_n(1:end-1))/sigma)));

% Solve the phi(am) for each (n,i)
for m=1:1:n_bin
    mass = zeros(N,N);
    sales = zeros(N,N);
    for n=1:1:N
        for i=1:1:n
         phi_am = (am(m)/r_ni(n,i))^coef2;
         if phi_am<phi_n(n)
             mass(n,i)=0;
         elseif phi_am>phi_n(n+1)
             mass(n,i)=normcdf(log(phi_n(n+1))/sigma)-normcdf(log(phi_n(n))/sigma);
             sales(n,i)=r_ni(n,i)*mean_tln(phi_n(n),phi_n(n+1),mu,sigma,coef0);
         else
             mass(n,i)=normcdf(log(phi_am)/sigma)-normcdf(log(phi_n(n))/sigma);
             sales(n,i)=r_ni(n,i)*mean_tln(phi_n(n),phi_am,mu,sigma,coef0);
         end
        end
    end
    Fm(m) = sum(sum(mass))/totalest;
    Sm(m) = sum(sum(sales));
end

%Check total revenue = E(revenue|\phi^*<=\phi)*M=Sm(end)/Prob(\phi^*<=\phi)*M
%disp(['check total revenue='])
%[Sm(end)/(1-normcdf(log(cutoff)/sigma))*M_data]

Sm = Sm./Sm(end);
