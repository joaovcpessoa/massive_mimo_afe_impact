%% LIMPEZA
% ####################################################################### %

clear;
close all;
clc;

% ####################################################################### %
%% PARÂMETROS PRINCIPAIS
% ####################################################################### %

root_save = ['C:\Users\joaov_zm1q2wh\OneDrive\Code\github\Impact-Analysis-of-Analog-Front-end-in-Massive-MIMO-Systems\images\'];
savefig = 1;

params = {
    struct('chi_A', 1.6397, 'kappa_A', 0.0618, 'chi_phi', 0.2038, 'kappa_phi', 0.1332),
    struct('chi_A', 1.9638, 'kappa_A', 0.9945, 'chi_phi', 2.5293, 'kappa_phi', 2.8168)
};

A0 = [1.0];

N_params = length(params);
N_A0 = length(A0);

N_amp_in = 100;
amplitude_in = linspace(0, 10, N_amp_in);

%% CÁLCULO DA TRANSFERÊNCIA DE AMPLITUDE E FASE
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

%% PLOT
% ####################################################################### %

figure;
hold on;

yyaxis left;
for a0_idx = 1:N_A0
    for param_idx = 1:N_params       
        plot(amplitude_in, squeeze(amplitude_out(:, param_idx, a0_idx)), '--', ...
            'DisplayName', sprintf('Amplitude Param Set %d, A0 = %.1f', param_idx, A0(a0_idx)));
    end
end
ylabel('Amplitude Out (V)');

yyaxis right;
for a0_idx = 1:N_A0
    for param_idx = 1:N_params       
        plot(amplitude_in, squeeze(phase_out(:, param_idx, a0_idx)), '--', ...
            'DisplayName', sprintf('Phase Param Set %d, A0 = %.1f', param_idx, A0(a0_idx)));
    end
end
ylabel('Phase Out (degrees)');

xlabel('Amplitude In (V)');
%legend('Location', 'southeast');
%legend box off;
%title('Amplitude and Phase vs. Input Amplitude');
grid off;
hold off;

graph_name = sprintf('am_am_am_pm_amp_twt');

if savefig == 1
    saveas(gcf,[root_save graph_name],'fig');
    saveas(gcf,[root_save graph_name],'png');
    saveas(gcf,[root_save graph_name],'epsc2');
end