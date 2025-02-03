%% LIMPEZA
% ####################################################################### %

clear;
close all;
clc;

%% PARÂMETROS PRINCIPAIS
% ####################################################################### %

addpath('./functions/');

N_BLK = 1000;
N_MC1 = 10;
N_MC2 = 10;

M = 128;
K = 64;
      
radial = 1000;
c = 3e8;
f = 1e9;
K_f_dB = 10;
K_f = 10^(K_f_dB/10);

lambda = c / f;
d = lambda / 2;
R = eye(M);

%% ALOCANDO MEMÓRIA
% ####################################################################### %

x_user = zeros(K, N_MC1);
y_user = zeros(K, N_MC1);
H = zeros(M, K, N_MC1, N_MC2);

%% SIMULAÇÃO DE MONTE CARLO
% ####################################################################### %

for mc_idx1 = 1:N_MC1
    [x_user(:,mc_idx1), y_user(:,mc_idx1)] = userPositionGenerator(K, radial);
    theta_user = atan2(y_user(:,mc_idx1), x_user(:,mc_idx1));
    A_LOS = exp(1i * 2 * pi * (0:M-1)' * 0.5 .* repmat(sin(theta_user'), M, 1));
    H_LOS = sqrt(K_f / (1 + K_f)) * A_LOS;
    
    for mc_idx2 = 1:N_MC2
        H_NLOS = (randn(M, K) + 1i * randn(M, K)) / sqrt(2);
        H(:, :, mc_idx1, mc_idx2) = H_LOS + sqrt(1 / (1 + K_f)) * sqrtm(R) * H_NLOS;
    end
end

filename = sprintf('channel_%d_%d.mat', M, K);
save(filename, 'H');
