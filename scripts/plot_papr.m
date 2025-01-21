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
load('C:\Users\joaov_zm1q2wh\OneDrive\Code\github\Impact-Analysis-of-Analog-Front-end-in-Massive-MIMO-Systems\ber_mc_mmse_64_32.mat');
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

% BER = zeros(K, N_SNR, N_AMP, N_A0, N_MC1, N_MC2);
BER_per_user = mean(BER,1);
avg_H_BER = mean(BER_per_user,5);
avg_BER_per_user = mean(avg_H_BER,6);

% Gráfico para amp_idx = 2, 3, 4, incluindo também amp_idx = 1
for amp_idx = 2:4
    figure;
    set(gcf, 'position', [0 0 800 600]);
    
    % Adicionar o gráfico de amp_idx = 1
    for a_idx = 1:N_A0
        semilogy(SNR, avg_BER_per_user(:, :, 1, a_idx), 'LineWidth', linewidth, 'MarkerSize', markersize, 'Color', colors(a_idx+1,:));
        hold on;
    end

    % Adicionar o gráfico do amp_idx atual (2, 3 ou 4)
    for a_idx = 1:N_A0
        semilogy(SNR, avg_BER_per_user(:, :, amp_idx, a_idx), 'LineWidth', linewidth, 'MarkerSize', markersize, 'Color', colors(a_idx+1,:));
        hold on;
    end

    xlabel('SNR (dB)', 'FontName', fontname, 'FontSize', fontsize);
    ylabel('BER', 'FontName', fontname, 'FontSize', fontsize);
    %title(sprintf('Amplificador: %s', amplifiers_type{amp_idx}), 'FontName', fontname, 'FontSize', fontsize);
    
    legend(arrayfun(@(a) sprintf('A=%.1f', a), A0, 'UniformOutput', false), 'Location', 'southwest', 'FontSize', fontsize);
    legend box off;
    
    set(gca, 'FontName', fontname, 'FontSize', fontsize);

    graph_name = sprintf('BER_MC_%s_%s', precoder_type, amplifiers_type{amp_idx});
    
    if savefig == 1
        saveas(gcf,[root_save graph_name],'fig');
        saveas(gcf,[root_save graph_name],'png');
        saveas(gcf,[root_save graph_name],'epsc2');
    end
end