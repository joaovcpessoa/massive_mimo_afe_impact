%% CLEAR
% ####################################################################### %

clear;
close all;
clc;

%% PATHS
% ####################################################################### %

current_dir = fileparts(mfilename('fullpath'));

env_file = fullfile(current_dir, '..', '..', '.env');
env_vars = load_env(env_file);

simulation = env_vars.SIMULATION_SAVE_PATH;
functions = env_vars.FUNCTIONS_PATH;

addpath(functions);

%% MAIN PARAMETERS
% ####################################################################### %

decoder_type = 'ZF';
amplifiers_type = {'IDEAL', 'CLIP'};
% amplifiers_type = {'IDEAL', 'CLIP', 'SS', 'TWT'};

A0 = [0.5, 1.0, 1.5, 2.0, 2.5];

N_A0 = length(A0);  
N_AMP = length(amplifiers_type); 

N_BLK = 1000;
N_MC1 = 10;
N_MC2 = 10;

M = 64;
K = 16;

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

% y = zeros(K, N_BLK, N_SNR, N_AMP, N_A0, N_MC1, N_MC2);
BER = zeros(K, N_SNR, N_AMP, N_A0, N_MC1, N_MC2);
x_user = zeros(K, N_MC1);
y_user = zeros(K, N_MC1);

% ####################################################################### %
%% SIMULAÇÃO DE MONTE CARLO
% ####################################################################### %

for mc_idx1 = 1:N_MC1

    mc_idx1

    [x_user(:,mc_idx1), y_user(:,mc_idx1)] = userPositionGenerator(K,radial);
    theta_user = atan2(y_user(:,mc_idx1), x_user(:,mc_idx1));

    A_LOS = exp(1i * 2 * pi * (0:M-1)' * 0.5 .* repmat(sin(theta_user'), M, 1));
    H_LOS = sqrt(K_f / (1 + K_f)) * A_LOS;

    for mc_idx2 = 1:N_MC2

        mc_idx2

        H_NLOS = (randn(M, K) + 1i * randn(M, K)) / sqrt(2);
        H = H_LOS + sqrt(1 / (1 + K_f)) * sqrtm(R) * H_NLOS;
    
        bit_array = randi([0, 1], B * N_BLK, K);
        s = qammod(bit_array, M_QAM, 'InputType', 'bit');
        Ps = vecnorm(s).^2 / N_BLK;
    
        receiver = compute_decoder(decoder_type, H, N_SNR, snr);
        x_normalized = normalize_precoded_signal(receiver, decoder_type, M, s, N_SNR);
    
        v = sqrt(0.5) * (randn(K, N_BLK) + 1i*randn(K, N_BLK));
        Pv = vecnorm(v,2,2).^2 / N_BLK;
        v_normalized = v ./ sqrt(Pv);
    
        for snr_idx = 1:N_SNR
            for a_idx = 1:N_A0
                for amp_idx = 1:N_AMP
                    a0 = A0(a_idx);
                    current_amp_type = amplifiers_type{amp_idx};
    
                    % y(:,:,snr_idx, amp_idx, a_idx, mc_idx1, mc_idx2) = H.' * amplifier(sqrt(snr(snr_idx)) * x_normalized, current_amp_type, a0) + v_normalized;
                    if strcmp(decoder_type, 'MMSE')
                        y = H.' * amplifier(sqrt(snr(snr_idx)) * x_normalized(:, :, snr_idx), current_amp_type, a0) + v_normalized;     
                    else
                        y = H.' * amplifier(sqrt(snr(snr_idx)) * x_normalized, current_amp_type, a0) + v_normalized;
                    end

                    bit_received = zeros(B * N_BLK, K);
    
                    for users_idx = 1:K
                        % s_received = y(users_idx, :, snr_idx, amp_idx, a_idx, mc_idx1, mc_idx2).';
                        s_received = y(users_idx, :).';
                        Ps_received = norm(s_received)^2 / N_BLK;
                        bit_received(:, users_idx) = qamdemod(sqrt(Ps(users_idx) / Ps_received) * s_received, M_QAM, 'OutputType', 'bit');
    
                        [~, bit_error] = biterr(bit_received(:, users_idx), bit_array(:, users_idx));
                        BER(users_idx, snr_idx, amp_idx, a_idx, mc_idx1, mc_idx2) = bit_error;
                    end
                end
            end
        end
    end
end

filename = sprintf('ul_ber_mc_zf_clip_%s_%d_%d.mat', decoder_type, M, K);
save(fullfile(simulation, filename), 'M', 'K', 'SNR', 'BER', 'N_AMP', 'N_A0', 'A0', 'decoder_type', 'amplifiers_type');