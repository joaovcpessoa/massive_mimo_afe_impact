clear;
clc;
close all;

%% PATHS
% ####################################################################### %

current_dir = fileparts(mfilename('fullpath'));

env_file = fullfile(current_dir, '..', '..', '.env');
env_vars = load_env(env_file);

output_dir = env_vars.CPU_SIMULATION_SAVE_PATH;

%% PLOTTING PARAMETERS
% ####################################################################### %

file_name = 'amplitude_io_ss.mat';

linewidth  = 3;
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

A0 = [1.0, 2.0];
N_A0 = length(A0);

p_values = [1, 2, 3];

N_amp_in = 100;
amplitude_in = linspace(0, 10, N_amp_in);

%% SS AMPLIFIER
% ####################################################################### %

amplitude_out_ss = zeros(N_amp_in, length(p_values), N_A0);

for a0_idx = 1:N_A0
    a0 = A0(a0_idx);

    for p_idx = 1:length(p_values)
        p = p_values(p_idx);

        for amp_in_idx = 1:N_amp_in
            amp_in = amplitude_in(amp_in_idx);

            amp_out = abs(amp_in) ./ (1 + (abs(amp_in) / a0).^(2 * p)).^(1 / (2 * p)) .* exp(1j * angle(amp_in));

            amplitude_out_ss(amp_in_idx, p_idx, a0_idx) = amp_out;
        end
    end
end


disp(['Saving file to: ', fullfile(output_dir, file_name)]);
save(fullfile(output_dir, file_name));