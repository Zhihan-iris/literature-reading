% Define data moments
Nmom = 9;
%% relative size

%% ASIF Data in Four bins, units in thousands of RMB
am=zeros(1,5);
am(1)=1000/(96517.66*10^5);
am(2)=5000/(96517.66*10^5);
am(3)=20000/(96517.66*10^5);
am(4)=100000/(96517.66*10^5);
am(5)=+Inf;
% 91887.48922 -> 96517.66

% pra=[0.7903903,0.9018235,0.9752882,1];
% pra_output=[0.0734002,0.1304509,0.2876726,1];

output_pdf=[0.0513950,0.1459273,0.7222460];
%output_stddev=[0.0001895,0.0007183,0.0315387];

number_pdf=[0.1052675,0.0714912,0.0245257];  %.0863867
%number_stddev=[0.0003063,0.0002849,0.0002600];
% [50-,500-2000,2000-10000,10000+]

%% Within conglomerate size dist.
size_dep = [0.2890569,0.2033759]; %0.1732111
size_dep_stddev = [0.0177651,0.0157502,0.0197552];

%% Moments
data_m = [number_pdf'; output_pdf';size_dep';0.335857]; %.335857

%% Define weighting matrix
%Wmatrix = diag([number_stddev.^2 output_stddev.^2 size_dep_stddev.^2]);
Wmatrix = eye(Nmom); 

