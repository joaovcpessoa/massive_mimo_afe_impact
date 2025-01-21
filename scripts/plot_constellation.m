% ####################################################################### %
%% LIMPEZA
% ####################################################################### %

clear;
close all;
clc;

% ####################################################################### %
%% CAMINHOS
% ####################################################################### %

addpath('./functions/');
load('C:\Users\joaov_zm1q2wh\OneDrive\Code\github\Impact-Analysis-of-Analog-Front-end-in-Massive-MIMO-Systems\ber_mc_zf.mat');
root_save = ['C:\Users\joaov_zm1q2wh\OneDrive\Code\github\Impact-Analysis-of-Analog-Front-end-in-Massive-MIMO-Systems\images\'];
savefig = 1;

% ####################################################################### %
%% PARÂMETROS DE PLOTAGEM
% ####################################################################### %

linewidth  = 2;
fontname   = 'Times New Roman';
fontsize   = 20;
markersize = 10;

colors = [0.0000 0.0000 0.0000;
          0.0000 0.4470 0.7410;
          0.8500 0.3250 0.0980;
          0.9290 0.6940 0.1250;
          0.4940 0.1840 0.5560;
          0.4660 0.6740 0.1880;
          0.3010 0.7450 0.9330;
          0.6350 0.0780 0.1840];

% ####################################################################### %
%% PLOT
% ####################################################################### %

K = 16;

figure;
hold on;

% Sinal decodificado (com normalização)
figure;
for users_idx = 1:K    
    s_received_ZF = y_ZF(users_idx, :).';
    Ps_received_ZF = norm(s_received_ZF)^2 / N_BLK;

    s_received_ZF_normalized = sqrt(Ps(users_idx) / Ps_received_ZF) * s_received_ZF;
    
    plot(real(s_received_ZF_normalized), imag(s_received_ZF_normalized),'.','MarkerSize', markersize,'Color',colors(users_idx, :));
    xlabel('Re', 'FontName', fontname, 'FontSize', fontsize);
    ylabel('Im', 'FontName', fontname, 'FontSize', fontsize);
end


for users_idx = 1:K
    s_received = y(users_idx, :, snr_idx, amp_idx, a_idx, mc_idx1, mc_idx2).';
    Ps_received = norm(s_received)^2 / N_BLK;
    bit_received(:, users_idx) = qamdemod(sqrt(Ps(users_idx) / Ps_received) * s_received, M_QAM, 'OutputType', 'bit');

    [~, bit_error] = biterr(bit_received(:, users_idx), bit_array(:, users_idx));
    BER(users_idx, snr_idx, amp_idx, a_idx, mc_idx1, mc_idx2) = bit_error;
end

for users_idx = 1:K    
    s_received = squeeze(y(users_idx, :, :, :, :, :, :));

    Ps_received = norm(s_received)^2 / N_BLK;
    s_received_normalized = sqrt(Ps(users_idx) / Ps_received) * s_received;

    plot(real(s_received_normalized), imag(s_received_normalized), '.', 'MarkerSize', markersize, 'Color', colors(users_idx, :));
end

xlabel('Re', 'FontName', fontname, 'FontSize', fontsize);
ylabel('Im', 'FontName', fontname, 'FontSize', fontsize);
title('Constelação de Sinais Recebidos', 'FontName', fontname, 'FontSize', fontsize);

legend(arrayfun(@(x) sprintf('Usuário %d', x), 1:K, 'UniformOutput', false), 'Location', 'northeast', 'FontSize', fontsize);
grid on;
axis equal;

hold off;
