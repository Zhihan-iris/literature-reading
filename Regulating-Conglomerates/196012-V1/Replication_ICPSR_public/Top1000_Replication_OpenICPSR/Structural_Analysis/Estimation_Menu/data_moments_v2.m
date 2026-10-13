% Define data moments
Nmom = 9;

%% ASIF Data in Four bins, units in thousands of RMB
am=zeros(1,5);
am(1)=1000/(96517.66*10^5);
am(2)=5000/(96517.66*10^5);
am(3)=20000/(96517.66*10^5);
am(4)=100000/(96517.66*10^5);
am(5)=+Inf;

output_pdf=[0.0513950,0.1459273,0.7222460];
number_pdf=[0.1052675,0.0714912,0.0245257];  


%% Within conglomerate size dist.
size_dep = [0.2890569,0.2033759]; 

%% Moments
data_m = [number_pdf'; output_pdf';size_dep';0.335857]; 

%% Define weighting matrix
Wmatrix = eye(Nmom); 

