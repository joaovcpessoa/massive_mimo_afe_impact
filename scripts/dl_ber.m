%% CLEAR
% ####################################################################### %

% clear;
% close all;
% clc;

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

precoder_type = 'ZF';
amplifiers_type = {'IDEAL', 'SS'};
N_AMP = length(amplifiers_type);

A0 = [0.5, 1.0, 2.0];
N_A0 = length(A0);  

N_BLK = 1000;
N_MC1 = 10;
N_MC2 = 10;

M = 16;
K = 4;

B = 4;
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

% Parâmetros para os amplificadores CLIP e SS
% y = zeros(K, N_BLK, N_SNR, N_AMP, N_A0, N_MC1, N_MC2);
BER = zeros(K, N_SNR, N_AMP, N_A0, N_MC1, N_MC2);

%% TX/RX MONTE CARLO (CLIP & SS)
% ####################################################################### %

parfor mc_idx1 = 1:N_MC1

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
        s = qammod(bit_array, M_QAM, 'InputType', 'bit').';
        Ps = vecnorm(s,2,2).^2/N_BLK;

        precoder = precode_signal(precoder_type, H, N_SNR, snr);
        x_normalized = normalize_precoded_signal(precoder, precoder_type, M, s, N_SNR)/sqrt(M);

        v = sqrt(0.5) * (randn(K, N_BLK) + 1i*randn(K, N_BLK));
        Pv = vecnorm(v,2,2).^2 / N_BLK;
        v_normalized = v ./ sqrt(Pv);
 
        for snr_idx = 1:N_SNR
            for a_idx = 1:N_A0
                for amp_idx = 1:N_AMP
                    a0 = A0(a_idx);
                    current_amp_type = amplifiers_type{amp_idx};

                    if strcmp(precoder_type, 'MMSE')
                        y = H.' * sqrt(snr(snr_idx)) * amplify_signal(x_normalized(:, :, snr_idx), current_amp_type, a0) + v_normalized;     
                    else
                        y = H.' * sqrt(snr(snr_idx)) * amplify_signal(x_normalized, current_amp_type, a0) + v_normalized;  
                    end

                    s_received = y;
                    Ps_received = vecnorm(s_received,2,2).^2/N_BLK;
                    s_received_normalized = s_received.*sqrt(Ps./Ps_received);

                    bit_received = qamdemod(s_received_normalized.', M_QAM, 'OutputType', 'bit');
                    [~, BER(:, snr_idx, amp_idx, a_idx, mc_idx1, mc_idx2)] = biterr(bit_received', bit_array');
                end
            end
        end
    end
end

file_name = ['dl_ber_' lower(precoder_type) '_' lower(amplifiers_type{2}) '_' num2str(M) '_' num2str(K) '.mat'];
save(fullfile(simulation_dir, file_name), 'M', 'K', 'SNR', 'BER', 'N_AMP', 'N_A0', 'A0', 'precoder_type', 'amplifiers_type');