%% CLEAR
% ####################################################################### %

% clear;
% close all;
% clc;

%% PATHS
% ####################################################################### %

current_dir = fileparts(mfilename('fullpath'));

env_file = fullfile(current_dir, '..', '..', '.env');
env_vars = load_env(env_file);

simulation_dir = env_vars.CPU_SIMULATION_SAVE_PATH;
functions_dir = env_vars.CPU_FUNCTIONS_PATH;

addpath(simulation_dir);
addpath(functions_dir);

%% MAIN PARAMETERS
% ####################################################################### %

precoder_type = 'MMSE';

amplifiers_type = {'IDEAL', 'SS'};
N_AMP = length(amplifiers_type);

A0 = [0.5, 1.0, 2.0];
N_A0 = length(A0);

M = 256;
% K = 256;

N_BLK = 500;
N_MC1 = 10;
N_MC2 = 10;

B = 7;
M_QAM = 2^B;

SNR = -10:5:30;
N_SNR = length(SNR);
snr = 10.^(SNR/10);

radial = 1000;
c = 3e8;
f = 1e9;
K_f_dB = 10;
K_f = 10^(K_f_dB/10);
lambda = c / f;
d = lambda / 2;
R = eye(M);                                    

x_user = zeros(K, N_MC1);
y_user = zeros(K, N_MC1);
BER = zeros(K, N_SNR, N_AMP, N_A0, N_MC1, N_MC2);

for mc_idx1 = 1:N_MC1
  
  mc_idx1

  [x_user(:,mc_idx1), y_user(:,mc_idx1)] = user_position_generator(K,radial);
  theta_user = atan2(y_user(:,mc_idx1), x_user(:,mc_idx1));

  A_LOS = exp(1i * 2 * pi * (0:M-1)' * 0.5 .* repmat(sin(theta_user'), M, 1));
  H_LOS = sqrt(K_f / (1 + K_f)) * A_LOS;

  for mc_idx2 = 1:N_MC2

    mc_idx2

    H_NLOS = (randn(M, K) + 1i * randn(M, K)) / sqrt(2);
    H = H_LOS + sqrt(1 / (1 + K_f)) * sqrtm(R) * H_NLOS;

    b = randi([0 1], N_BLK*B,K);
    s  = (qammod(b, M_QAM,'InputType','bit')).';
    Ps = vecnorm(s,2,2).^2/N_BLK;
    s_norm = s./sqrt(Ps);
    eta = 1/K;
    
    precoder = precode_signal(precoder_type, H, N_SNR, snr);
    %x = precoder*sqrt(eta)*s_norm;

    v = sqrt(0.5)*(randn(K,N_BLK) + 1i*randn(K,N_BLK));
    Pv = vecnorm(v,2,2).^2/N_BLK;
    v_norm = v./sqrt(Pv);

    for snr_idx = 1:N_SNR
      x = precoder(:,:,snr_idx)*sqrt(eta)*s_norm;
      for a_idx = 1:N_A0
        for amp_idx = 1:N_AMP
          
          a0 = A0(a_idx);
          current_amp_type = amplifiers_type{amp_idx};
           
          y = H.' * sqrt(snr(snr_idx)) * amplify_signal(x, current_amp_type, a0) + v_norm;
          
          s_hat = y;
          Ps_hat = vecnorm(s_hat,2,2).^2/N_BLK;
          s_hat_norm = s_hat.*sqrt(Ps./Ps_hat);
          b_hat = qamdemod(s_hat_norm.', M_QAM, 'OutputType', 'bit');
          [~, BER(:, snr_idx, amp_idx, a_idx, mc_idx1, mc_idx2)] = biterr(b_hat', b');
        end
      end
    end
  end
end

file_name = ['dl_ber_' lower(precoder_type) '_' lower(amplifiers_type{2}) '_' num2str(M) '_' num2str(K) '.mat'];
save(fullfile(simulation_dir, file_name), 'M', 'K', 'SNR', 'BER', 'N_AMP', 'N_A0', 'A0', 'precoder_type', 'amplifiers_type');