%% CLEAR
% ####################################################################### %

clear;
close all;
clc;

%% PATHS
% ####################################################################### %

current_dir = fileparts(mfilename('fullpath'));

env_file = fullfile(current_dir, '..', '.env');
env_vars = load_env(env_file);

simulation_dir = env_vars.SIMULATION_SAVE_PATH;
functions_dir = env_vars.FUNCTIONS_PATH;

addpath(simulation_dir);
addpath(functions_dir);

%% MAIN PARAMETERS
% ####################################################################### %

decoder_type = 'MMSE';

amplifiers_type = {'IDEAL', 'SS'};
N_AMP = length(amplifiers_type);

A0 = [0.5, 1.0, 2.0];
% A0 = [0.5, 1.0, 1.5, 2.0, 2.5];
N_A0 = length(A0);

N_BLK = 1000;
N_MC1 = 10;
N_MC2 = 10;

M = 256;
K = 256;

B = 7;
M_QAM = 2^B;

SNR = -10:1:30;
N_SNR = length(SNR);
snr = 10.^(SNR/10);                                      

radial = 1000;
c = 3e8;
f = 1e9;
K_f_dB = 10;
K_f = 10^(K_f_dB/10);

lambda = c / f;
d = lambda / 2;
R = eye(M);

%% MEMORY ALOCATION
% ####################################################################### %

x_user = zeros(K, N_MC1);
y_user = zeros(K, N_MC1);

% y = zeros(K, N_BLK, N_SNR, N_AMP, N_A0, N_MC1, N_MC2);
BER = zeros(K, N_SNR, N_AMP, N_A0, N_MC1, N_MC2);

%% SIMULAÇÃO DE MONTE CARLO
% ####################################################################### %

% for mc_idx1 = 1:N_MC1
for mc_idx1 = 1:N_MC1

    mc_idx1

    [x_user(:,mc_idx1), y_user(:,mc_idx1)] = user_position_generator(K,radial);
    theta_user = atan2(y_user(:,mc_idx1), x_user(:,mc_idx1));

    A_LOS = exp(1i * 2 * pi * (0:M-1)' * 0.5 .* repmat(sin(theta_user'), M, 1));
    H_LOS = sqrt(K_f / (1 + K_f)) * A_LOS;

    for mc_idx2 = 1:N_MC2

        mc_idx2

        H_NLOS = (randn(M, K) + 1i * randn(M, K)) / sqrt(2);
        H = H_LOS + sqrt(1 / (1 + K_f)) * sqrtm(R) * H_NLOS;
    
        bit_array = randi([0, 1], B * N_BLK, K);
        s  = (qammod(bit_array, M_QAM,'InputType','bit')).'; % 1000 16
        Ps = vecnorm(s,2,2).^2/N_BLK;
        
        % Usar uma função aqui é desnecessário por conta do overhead
        % Normalização do sinal transmitido para ter: E{|s_k|^2}=1
        s_normalized = s./sqrt(Ps); % 1000 16 

        v = sqrt(0.5) * (randn(M, N_BLK) + 1i*randn(M, N_BLK)); % 64 1000
        Pv = vecnorm(v,2,2).^2 / N_BLK; %  64 1000
        v_normalized = v./sqrt(Pv);   %  64 1000
    
        parfor snr_idx = 1:N_SNR
            for a_idx = 1:N_A0
                for amp_idx = 1:N_AMP

                    a0 = A0(a_idx);
                    current_amp_type = amplifiers_type{amp_idx};
                    
                    % y = H * sqrt(snr(snr_idx)) * s_normalized + v_normalized; % IDEAL
                        
                    y = H * sqrt(snr(snr_idx)) * amplify_signal(s_normalized, current_amp_type, a0) + v_normalized;

                    decoder = decode_signal(decoder_type, H, snr(snr_idx));
                    s_hat = decoder * y;
                    Ps_hat = vecnorm(s_hat,2,2).^2/N_BLK;
                    s_hat_normalized = s_hat.*sqrt(Ps./Ps_hat);

                    bit_received = qamdemod(s_hat_normalized.', M_QAM, 'OutputType', 'bit');
                    [~, BER(: , snr_idx, amp_idx, a_idx, mc_idx1, mc_idx2)] = biterr(bit_received', bit_array');
                end
            end
        end
    end
end

% scatterplot(s(:));  % Usando o vetor 's' que contém o sinal modulado
% title('Constelação do Sinal Modulado');
% xlabel('Parte Real');
% ylabel('Parte Imaginária');
% 
% scatterplot(s_hat(:));  % Usando o vetor 's_hat' que contém o sinal decodificado
% title('Constelação do Sinal Decodificado');
% xlabel('Parte Real');
% ylabel('Parte Imaginária');

file_name = ['ul_ber_' lower(decoder_type) '_' lower(amplifiers_type{2}) '_' num2str(M) '_' num2str(K) '.mat'];
save(fullfile(simulation_dir, file_name), 'M', 'K', 'SNR', 'BER', 'N_AMP', 'N_A0', 'A0', 'decoder_type', 'amplifiers_type');