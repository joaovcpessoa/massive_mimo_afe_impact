%% LIMPEZA
% ####################################################################### %

clear;
close all;
clc;

%% PARÂMETROS PRINCIPAIS
% ####################################################################### %

addpath('./functions/');
load('channels_128_128.mat', 'H');

precoder_type = 'ZF';
amplifiers_type = {'IDEAL', 'CLIP', 'TWT', 'SS'};

N_BLK = 1000;
N_MC1 = 10;
N_MC2 = 10;

M = 128;
K = 128;

B = 4;
M_QAM = 2^B;

SNR = -10:1:30;
N_SNR = length(SNR);
snr = 10.^(SNR/10);

% A0 = [0.5, 1.0, 1.5, 2.0, 2.5];
A0 = [2.5];
N_A0 = 1;                                         
N_AMP = 4;                                 

% ####################################################################### %
%% ALOCANDO MEMÓRIA
% ####################################################################### %

y = zeros(K, N_BLK, N_SNR, N_AMP, N_MC1, N_MC2);
BER = zeros(K, N_SNR, N_AMP, N_MC1, N_MC2);

% ####################################################################### %
%% SIMULAÇÃO DE MONTE CARLO
% ####################################################################### %

for mc_idx1 = 1:N_MC1

    mc_idx1

    for mc_idx2 = 1:N_MC2

        mc_idx2

        H_current = H(:, :, mc_idx1, mc_idx2);

        bit_array = randi([0, 1], B * N_BLK, K);
        s = qammod(bit_array, M_QAM, 'InputType', 'bit');
        Ps = vecnorm(s).^2 / N_BLK;
        
        precoder = compute_precoder(precoder_type, H_current, N_SNR, snr);
        x_normalized = normalize_precoded_signal(precoder, precoder_type, M, s, N_SNR);

        v = sqrt(0.5) * (randn(K, N_BLK) + 1i*randn(K, N_BLK));
        Pv = vecnorm(v,2,2).^2 / N_BLK;
        v_normalized = v ./ sqrt(Pv);
    
        for snr_idx = 1:N_SNR
            for amp_idx = 1:N_AMP
                current_amp_type = amplifiers_type{amp_idx};
                y(:,:,snr_idx, amp_idx, mc_idx1, mc_idx2) = H_current.' * amplifier(sqrt(snr(snr_idx)) * x_normalized, current_amp_type, A0) + v_normalized;
                bit_received = zeros(B * N_BLK, K);

                for users_idx = 1:K
                    s_received = y(users_idx, :, snr_idx, amp_idx, mc_idx1, mc_idx2).';
                    Ps_received = norm(s_received)^2 / N_BLK;

                    bit_received(:, users_idx) = qamdemod(sqrt(Ps(users_idx) / Ps_received) * s_received, M_QAM, 'OutputType', 'bit');
                    [~, bit_error] = biterr(bit_received(:, users_idx), bit_array(:, users_idx));
                    BER(users_idx, snr_idx, amp_idx, mc_idx1, mc_idx2) = bit_error;
                end
            end
        end
    end
end

save('ber_mc_zf.mat', 'M', 'K', 'y', 'SNR', 'BER', 'N_AMP', 'N_A0', 'A0', 'precoder_type', 'amplifiers_type');