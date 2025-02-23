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

root_save = ['C:\Users\joaov_zm1q2wh\OneDrive\Code\github\Impact-Analysis-of-Analog-Front-end-in-Massive-MIMO-Systems\images\'];
savefig = 1;

params = {
    struct('chi_A', 1.6397, 'kappa_A', 0.0618, 'chi_phi', 0.2038, 'kappa_phi', 0.1332),
    struct('chi_A', 1.9638, 'kappa_A', 0.9945, 'chi_phi', 2.5293, 'kappa_phi', 2.8168),
    struct('chi_A', 2.1587, 'kappa_A', 1.1517, 'chi_phi', 4.0033, 'kappa_phi', 9.1040)
};

A0 = [1.0];

N_params = length(params);
N_A0 = length(A0);

N_amp_in = 100;
amplitude_in = linspace(0, 10, N_amp_in);

%% CALCULATION OF AMPLITUDE AND PHASE TRANSFER
% ####################################################################### %

amplitude_out = zeros(N_amp_in, N_params, N_A0);
phase_out = zeros(N_amp_in, N_params, N_A0);

for a0_idx = 1:N_A0
    a0 = A0(a0_idx);
    
    for param_idx = 1:N_params
        chi_A = params{param_idx}.chi_A;
        kappa_A = params{param_idx}.kappa_A;
        chi_phi = params{param_idx}.chi_phi;
        kappa_phi = params{param_idx}.kappa_phi;
        
        for amp_in_idx = 1:N_amp_in
            amp_in = amplitude_in(amp_in_idx);
            
            g_A = (chi_A .* abs(amp_in)) ./ (1 + kappa_A .* abs(amp_in).^2);
            g_phi = (chi_phi .* abs(amp_in).^2) ./ (1 + kappa_phi .* abs(amp_in).^2);
            amp_out = g_A .* exp(1i * (angle(amp_in) + g_phi));
            
            amplitude_out(amp_in_idx, param_idx, a0_idx) = abs(amp_out);
            phase_out(amp_in_idx, param_idx, a0_idx) = angle(amp_out) * 180 / pi;
        end
    end
end

%% PLOT AMPLITUDE
% ####################################################################### %

figure;

for a0_idx = 1:N_A0
    for param_idx = 1:N_params       
        plot(amplitude_in, squeeze(amplitude_out(:, param_idx, a0_idx)), '-', 'LineWidth', linewidth);
        hold on;
    end
end

xlabel('Amplitude de entrada', 'FontName', fontname, 'FontSize', fontsize);
ylabel('Amplitude de saída', 'FontName', fontname, 'FontSize', fontsize);

legend_text = {'$\mathcal{C}_1$', '$\mathcal{C}_2$', '$\mathcal{C}_3$'};  
legend(legend_text, 'Location', 'northwest', 'FontSize', fontsize, 'FontName', fontname, 'Interpreter', 'latex');
legend box off;
grid off;

xlim([0 3.5]);
ylim([0 3.5]);

set(gca, 'FontName', fontname, 'FontSize', fontsize);

graph_name = 'amplitude_io_twt';

if savefig == 1
    saveas(gcf, [root_save graph_name], 'epsc2');
end

%% PLOT FASE
% ####################################################################### %

figure;

for a0_idx = 1:N_A0
    for param_idx = 1:N_params       
        plot(amplitude_in, squeeze(phase_out(:, param_idx, a0_idx)), '-', 'LineWidth', linewidth);
        hold on;
    end
end

xlabel('Amplitude de entrada', 'FontName', fontname, 'FontSize', fontsize);
ylabel('Fase de saída', 'FontName', fontname, 'FontSize', fontsize);

legend(legend_text, 'Location', 'northwest', 'FontSize', fontsize, 'FontName', fontname, 'Interpreter', 'latex');
legend box off;
grid off;

xlim([0 5]);

set(gca, 'FontName', fontname, 'FontSize', fontsize);

graph_name = 'phase_io_twt';

if savefig == 1
    saveas(gcf, [root_save graph_name], 'epsc2');
end
