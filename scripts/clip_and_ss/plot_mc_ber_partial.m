% ####################################################################### %
%% LIMPEZA
% ####################################################################### %

clear;
close all;
clc;

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
          0.6350 0.0780 0.1840;
          0.3010 0.7450 0.9330];

% ####################################################################### %
%% CAMINHOS
% ####################################################################### %

addpath('./functions/');

root_save = 'C:\Users\joaov_zm1q2wh\OneDrive\Code\github\Impact-Analysis-of-Analog-Front-end-in-Massive-MIMO-Systems\images\ber\';
savefig = 1;

files = {'ber_mc_zf_128_64_A0_05.mat', 'ber_mc_zf_128_64_A0_10.mat', 'ber_mc_zf_128_64_A0_15.mat', 'ber_mc_zf_128_64_A0_20.mat', 'ber_mc_zf_128_64_A0_25.mat'};

load(files{1}, 'BER', 'SNR', 'amplifiers_type', 'precoder_type');
[a, b, c, d, e] = size(BER);
amp_idx = 4;

BER_combined = zeros(a, b, c, d, e);

% ####################################################################### %
%% GERAÇÃO DE GRÁFICOS E PREENCHIMENTO DA MATRIZ
% ####################################################################### %

% Iterar pelos amplificadores: 2, 3 e 4
for amp_idx = 2:4
    figure;
    set(gcf, 'position', [0 0 800 600]);

    load(files{1}, 'BER', 'SNR', 'amplifiers_type', 'precoder_type');
    BER_per_user = mean(BER, 1);
    avg_H_BER = mean(BER_per_user, 4);
    avg_BER_per_user = mean(avg_H_BER, 5);

    % Plotar a linha do modelo ideal para todos
    semilogy(SNR, avg_BER_per_user(:, :, 1, 1), 'LineWidth', linewidth, 'MarkerSize', markersize, 'Color', colors(2,:));
    hold on;

    % Iterar pelos arquivos, preenchar a BER e plotar as linhas para A0 = [0.5, 1.0, 1.5, 2.0, 2.5];
    % Então teremos:
    % CLIP [0.5, 1.0, 1.5, 2.0, 2.5]
    % SS   [0.5, 1.0, 1.5, 2.0, 2.5]
    % TWT  [0.5, 1.0, 1.5, 2.0, 2.5]
    for file_idx = 1:length(files)
        load(files{file_idx}, 'BER', 'SNR', 'amplifiers_type', 'precoder_type');
        
        BER_per_user = mean(BER, 1);
        avg_H_BER = mean(BER_per_user, 4);
        avg_BER_per_user = mean(avg_H_BER, 5);
    
        disp(size(BER_per_user));
        disp(size(avg_H_BER));
        disp(size(avg_BER_per_user));
    
        semilogy(SNR, avg_BER_per_user(:, :, amp_idx, 1), 'LineWidth', linewidth, 'MarkerSize', markersize, 'Color', colors(file_idx+2,:));
        hold on;
    end
    
    xlabel('SNR (dB)', 'FontName', fontname, 'FontSize', fontsize);
    ylabel('BER', 'FontName', fontname, 'FontSize', fontsize);

    legend_text = {'Ideal', '$A = 0.5$', '$A = 1.0$', '$A = 1.5$', '$A = 2.0$', '$A = 2.5$'};
    legend(legend_text, 'Location', 'southwest', 'FontSize', fontsize, 'fontname', fontname, 'Interpreter','latex');
    legend box off;

    set(gca, 'FontName', fontname, 'FontSize', fontsize);

    graph_name = sprintf('BER_MC_%s_%s', precoder_type, amplifiers_type{amp_idx});

    if savefig == 1
        saveas(gcf,[root_save graph_name],'fig');
        saveas(gcf,[root_save graph_name],'png');
        saveas(gcf,[root_save graph_name],'epsc2');
    end
end