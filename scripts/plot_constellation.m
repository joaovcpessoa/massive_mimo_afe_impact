% ####################################################################### %
%% LIMPEZA
% ####################################################################### %

clear;
close all;
clc;

% ####################################################################### %
%% CAMINHOS
% ####################################################################### %

root_save = ['C:\Users\joaov_zm1q2wh\OneDrive\Code\github\Impact-Analysis-of-Analog-Front-end-in-Massive-MIMO-Systems\'];
savefig = 1;

% ####################################################################### %
%% PARÂMETROS DE PLOTAGEM
% ####################################################################### %

linewidth  = 2;
fontname   = 'Times New Roman';
fontsize   = 20;
markersize = 10;

colors = [0.0000 0.0000 0.0000;  % Preto
          0.0000 0.4470 0.7410;  % Azul
          0.8500 0.3250 0.0980;  % Vermelho
          0.9290 0.6940 0.1250;  % Amarelo
          0.4940 0.1840 0.5560;  % Roxo
          0.4660 0.6740 0.1880;  % Verde
          0.3010 0.7450 0.9330;  % Azul claro
          0.6350 0.0780 0.1840;  % Marrom
          0.0000 0.7500 0.7500;  % Ciano
          0.7500 0.0000 0.7500;  % Magenta
          0.7500 0.7500 0.0000;  % Ouro
          0.2500 0.2500 0.2500;  % Cinza escuro
          0.8700 0.4900 0.0000;  % Laranja queimado
          0.5000 0.5000 0.5000;  % Cinza médio
          0.0000 0.5000 1.0000;  % Azul royal
          0.5000 0.0000 0.5000]; % Roxo escuro

% ####################################################################### %
%% PLOTAGEM
% ####################################################################### %

precoder_type = 'MF';
amplifiers_type = {'SS'};
A0 = [1.0];

N_BLK = 1000;
M = 64;
K = 16;
B = 4;
M_QAM = 2^B;
SNR = -10:30;
N_SNR = length(SNR);
snr = 10.^(SNR/10);
N_A0 = 1;
N_AMP = 1;

K_f = 10;
H_LOS = ones(M, K);
H_NLOS = (randn(M, K) + 1i * randn(M, K)) / sqrt(2);
H = sqrt(K_f / (1 + K_f)) * H_LOS + sqrt(1 / (1 + K_f)) * H_NLOS;

BER = zeros(K, N_SNR, N_AMP, N_A0);

% ####################################################################### %
%% PARAMETROS DO SINAL E DO RUÍDO 
% ####################################################################### %

bit_array = randi([0, 1], B * N_BLK, K);
s = qammod(bit_array, M_QAM, 'InputType', 'bit');
Ps = vecnorm(s).^2 / N_BLK;

precoder = compute_precoder(precoder_type, H, N_SNR, snr);
x_normalized = normalize_precoded_signal(precoder, precoder_type, M, s, N_SNR);

v = sqrt(0.5) * (randn(K, N_BLK) + 1i * randn(K, N_BLK));
Pv = vecnorm(v, 2, 2).^2 / N_BLK;
v_normalized = v ./ sqrt(Pv);

% ####################################################################### %
%% TRANSMISSÃO E RECEPÇÃO
% ####################################################################### %

for snr_idx = 1:N_SNR
    for a_idx = 1:N_A0
        for amp_idx = 1:N_AMP
            a0 = A0(a_idx);
            current_amp_type = amplifiers_type{amp_idx};

            y = H.' * amplifier(sqrt(snr(snr_idx)) * x_normalized, current_amp_type, a0) + v_normalized;
            bit_received = zeros(B * N_BLK, K);

            for users_idx = 1:K
                s_received = y(users_idx, :).';
                Ps_received = norm(s_received)^2 / N_BLK;

                s_received_normalized = sqrt(Ps(users_idx) / Ps_received) * s_received;

                bit_received(:, users_idx) = qamdemod(sqrt(Ps(users_idx) / Ps_received) * s_received, M_QAM, 'OutputType', 'bit');
                [~, BER(users_idx, snr_idx, amp_idx, a_idx)] = biterr(bit_received(:, users_idx), bit_array(:, users_idx));
            end
        end
    end
end

% ####################################################################### %
%% PLOTAGEM DA CONSTELAÇÃO
% ####################################################################### %

figure;
for users_idx = 1:K
    scatter(real(s_received_normalized), imag(s_received_normalized), markersize, 'MarkerEdgeColor', colors(users_idx, :));
    hold on;
end
xlabel('Parte Real', 'FontName', fontname, 'FontSize', fontsize);
ylabel('Parte Imaginária', 'FontName', fontname, 'FontSize', fontsize);
%title('Constelação dos Símbolos Recebidos', 'FontName', fontname, 'FontSize', fontsize);
grid on;
hold off;

graph_name = sprintf('constellation_plot_%s_%s_%d_%d', precoder_type, amplifiers_type{amp_idx}, M, K);

if savefig == 1
    saveas(gcf,[root_save graph_name],'fig');
    saveas(gcf,[root_save graph_name],'png');
    saveas(gcf,[root_save graph_name],'epsc2');
end