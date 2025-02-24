%% CLEAR
% ####################################################################### %

clear;
close all;
clc;

%% PLOTTING PARAMETERS
% ####################################################################### %

linewidth  = 2;
fontname   = 'Times New Roman';
fontsize   = 18;
markersize = 10;

colors = [0.0000 0.0000 0.0000;
          0.0000 0.4470 0.7410;
          0.8500 0.3250 0.0980;
          0.9290 0.6940 0.1250;
          0.4940 0.1840 0.5560;
          0.4660 0.6740 0.1880;
          0.6350 0.0780 0.1840;
          0.3010 0.7450 0.9330];

%% MAIN PARAMETERS
% ####################################################################### %

root_save = ['C:\Users\joaov_zm1q2wh\OneDrive\Code\github\massive_mimo_afe_impact\images\'];
savefig = 1;

A0 = [1.0, 2.0];
p_values = [1, 2, 3];

N_A0 = length(A0);

N_amp_in = 100;
amplitude_in = linspace(0, 10, N_amp_in);

%% CALCULATION OF AMPLITUDE AND PHASE TRANSFER
% ####################################################################### %

amplitude_out_clipping = zeros(N_amp_in, 1, N_A0);

for a0_idx = 1:N_A0
    a0 = A0(a0_idx);
    
    for amp_in_idx = 1:N_amp_in
        amp_in = amplitude_in(amp_in_idx);
        
        amp_out = min(abs(amp_in), a0) .* exp(1j * angle(amp_in));
        amplitude_out_clipping(amp_in_idx, 1, a0_idx) = amp_out;
    end
end

%% PLOT
% ####################################################################### %

figure;

for a0_idx = 1:N_A0  
    plot(amplitude_in, abs(squeeze(amplitude_out_clipping(:, 1, a0_idx))), '-', 'LineWidth', linewidth);
    hold on;
end

xlabel('Amplitude de entrada', 'FontName', fontname, 'FontSize', fontsize);
ylabel('Amplitude de saída', 'FontName', fontname, 'FontSize', fontsize);

xlim([0 2.5]);
ylim([0 2.5]);

legend_text = {'$A_0 = 1$','$A_0 = 2$'};  
legend(legend_text, 'Location', 'southeast', 'FontSize', fontsize, 'FontName', fontname, 'Interpreter', 'latex');
legend box off;

set(gca, 'FontName', fontname, 'FontSize', fontsize);

%% SAVE IMAGE
% ####################################################################### %

graph_name = 'amplitude_io_clip';

if savefig == 1
   % saveas(gcf,[root_save graph_name],'fig');
   % saveas(gcf,[root_save graph_name],'png');
   saveas(gcf,[root_save graph_name],'epsc2');
end