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

simulation_dir = env_vars.GPU_SIMULATION_SAVE_PATH;
plot_dir = env_vars.GPU_PLOT_BER_PATH;
functions_dir = env_vars.GPU_FUNCTIONS_PATH;

addpath(simulation_dir);
addpath(functions_dir);
addpath(plot_dir);

savefig = 1;

%% PLOTTING PARAMETERS
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


%% PLOT COMPARATIVO
% ####################################################################### %

file_list={'ul_ber_zf_ss_256_64_256QAM.mat', 'ul_ber_zf_ss_256_128_256QAM.mat', 'ul_ber_zf_ss_256_256_256QAM.mat'}';
qam_labels = {'K64', 'K128', 'K256'};

figure;

for file_idx = 1:length(file_list)

    load(file_list{file_idx});

    BER_per_user = mean(BER, 1);
    avg_H_BER = mean(BER_per_user, 5);
    avg_BER_per_user = mean(avg_H_BER, 6);

    for amp_idx = 2
        figure;
        set(gcf, 'position', [0 0 800 600]);
    
        semilogy(SNR, avg_BER_per_user(:, :, 1, 1), 'LineWidth', linewidth, 'MarkerSize', markersize, 'Color', colors(2,:));
        hold on;
    
        for a_idx = 1:N_A0
            semilogy(SNR, avg_BER_per_user(:, :, amp_idx, a_idx), 'LineWidth', linewidth, 'MarkerSize', markersize, 'Color', colors(a_idx+2,:));
        end
    
        xlabel('SNR (dB)', 'FontName', fontname, 'FontSize', fontsize);
        ylabel('BER', 'FontName', fontname, 'FontSize', fontsize);
        %title(sprintf('Amplificador: %s', amplifiers_type{amp_idx}), 'FontName', fontname, 'FontSize', fontsize);
    
        legend_text = {'Ideal', '$A = 0.5$', '$A = 1.0$', '$A = 1.5$', '$A = 2.0$', '$A = 2.5$'};
        legend(legend_text , 'Location', 'southeast', 'FontSize', fontsize, 'fontname', fontname, 'Interpreter','latex');
    
        %legend(arrayfun(@(a) sprintf('A=%.1f', a), A0, 'UniformOutput', false), 'Location', 'northwest', 'FontSize', fontsize);
        legend box off;
    
        set(gca, 'FontName', fontname, 'FontSize', fontsize);
       
    end
end

% 
% if savefig == 1
%     saveas(gcf, fullfile(plot_dir, [graph_name '.eps']), 'epsc2');
% end


