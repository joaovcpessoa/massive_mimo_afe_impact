clear; clc; close all;

%% PATHS
% ####################################################################### %

current_dir = fileparts(mfilename('fullpath'));

env_file = fullfile(current_dir, '..', '..', '.env');
env_vars = load_env(env_file);

simulation = env_vars.CPU_SIMULATION_SAVE_PATH;
output_dir = env_vars.CPU_PLOT_BER_PATH;
functions = env_vars.CPU_FUNCTIONS_PATH;

addpath(simulation);
addpath(functions);

load('amplitude_io_ss.mat');

savefig = 1;

%% PLOTTING PARAMETERS
% ####################################################################### %

graph_name = 'amplitude_io_ss';

linewidth  = 2;
fontname   = 'Times New Roman';
fontsize   = 20;
markersize = 10;

colors = [0.0000 0.4470 0.7410;
          0.8500 0.3250 0.0980;
          0.9290 0.6940 0.1250];

%% PLOT - SSA AMPLIFIER
% ####################################################################### %

figure;
set (gcf, "Position", [0, 0, 800, 600]);

linestyles = {'-', '--'};

for a0_idx = 1:N_A0
    for p_idx = 1:length(p_values)
        plot(amplitude_in, squeeze(amplitude_out_ss(:, p_idx, a0_idx)), ...
             linestyles{a0_idx}, 'LineWidth', linewidth, ...
             'Color', colors(p_idx, :));
        hold on;
    end
    
end

xlabel('Input Amplitude', 'FontName', fontname, 'FontSize', fontsize);
ylabel('Output Amplitude', 'FontName', fontname, 'FontSize', fontsize);

h_legend_p = zeros(1, 3);
for p_idx = 1:3
    h_legend_p(p_idx) = plot(nan, nan, '-', 'Color', colors(p_idx, :), ...
                             'LineWidth', linewidth);
end

h_a0_1 = plot(nan, nan, '-',  'Color', 'k', 'LineWidth', linewidth);
h_a0_2 = plot(nan, nan, '--', 'Color', 'k', 'LineWidth', linewidth);

legend([h_legend_p, h_a0_1, h_a0_2], ...
       {'$p = 1$', '$p = 2$', '$p = 3$', '$A_0 = 1$', '$A_0 = 2$'}, ...
       'Location', 'southeast', ...
       'FontSize', fontsize, 'FontName', fontname, ...
       'Interpreter', 'latex', 'NumColumns', 2);
legend box off;

set(gca, 'FontName', fontname, 'FontSize', fontsize);

if savefig == 1
    %saveas(gcf, fullfile(output_dir, graph_name), 'png');
    %saveas(gcf, fullfile(output_dir, graph_name), 'fig');
    saveas(gcf, fullfile(output_dir, graph_name), 'epsc2');
end
