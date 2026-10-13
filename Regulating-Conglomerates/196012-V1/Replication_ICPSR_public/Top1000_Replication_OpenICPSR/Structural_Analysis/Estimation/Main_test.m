% May, 2021

%%
clear
clc

%% Define parameters
parameters;

%% read in parameter estimates
load param_opt
cutoff = param_opt(1); 
delta = param_opt(2)^(1/(1-alpha)); 
sigma = param_opt(3);
mu = 0; %mean normalized

%% solve the fixed cost wf
solve_f; 

%% solve the phi_t and the average number of affiliates per regulated conglomerate
solve_n;

%% define data moments
data_moments_v2; 

%% solve model moments counterpart;
solve_size;

%% solve model moments
model_m = [Fm(3:end)-Fm(2:end-1);Sm(3:end)-Sm(2:end-1);(delta.^(1:1:2))';Fm(1)];

fprintf('\n');

fprintf('Moments used : Left = Model, Right = Data  \n');   
fprintf('\n');
fprintf('\n');
fprintf('Fraction of firms 5M-20M RMB               = %9.3f %9.3f\n',  [model_m(1),    data_m(1)]);
fprintf('Fraction of firms 20M-100M RMB             = %9.3f %9.3f\n',  [model_m(2),    data_m(2)]);
fprintf('Fraction of firms 100M+ RMB                = %9.3f %9.3f\n',  [model_m(3),    data_m(3)]);
fprintf('\n')
fprintf('Sales share firms 5M-20M RMB               = %9.3f %9.3f\n',  [model_m(4),    data_m(4)]);
fprintf('Sales share firms 20M-100M RMB             = %9.3f %9.3f\n',  [model_m(5),    data_m(5)]);
fprintf('Sales share firms 100M+ RMB                = %9.3f %9.3f\n',  [model_m(6),    data_m(6)]);
fprintf('\n');
fprintf('Size depreciation 2nd affiliate            = %9.3f %9.3f\n',  [model_m(7),    data_m(7)]);
fprintf('Size depreciation 3rd affiliate            = %9.3f %9.3f\n',  [model_m(8),    data_m(8)]);
%fprintf('Size depreciation 4th affiliate            = %9.3f %9.3f\n',  [model_m(9),    data_m(9)]);
fprintf('\n');
fprintf('Fraction of small firms <1M RMB            = %9.3f %9.3f\n',  [model_m(9),   data_m(9)]);

fprintf('\n');

%% fixed cost
disp('fixed cost in thousands RMB')
[wf*96517.66*10^5]

%% output
% Write data to text file
moments = [data_m model_m];
save ('moments.txt', 'moments', '-ascii');
