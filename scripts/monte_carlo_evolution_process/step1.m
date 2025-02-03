% ####################################################################### %
%% LIMPEZA
% ####################################################################### %

clear;
close all;
clc;

% ####################################################################### %
%% PARÂMETROS PRINCIPAIS
% ####################################################################### %

addpath('./functions/');

precoder_type = 'ZF'; % Tipo de precodificador

N_BLK = 10000;  % Número de blocos
M = 64;         % Número de antenas
K = 16;         % Número de usuários

B = 4;          % Número de bits por símbolo (modulação)
M_QAM = 2^B;    % Número de pontos da constelação QAM

SNR = -10:1:30;              % Faixa de SNR em dB
N_SNR = length(SNR);         % Número de valores de SNR
snr_linear = 10.^(SNR/10);   % Conversão SNR para valor linear

A0 = [0.5, 1.0, 1.5, 2.0, 2.5];                   % Parâmetros dos amplificadores
amplifiers_type = {'IDEAL', 'CLIP', 'TWT', 'SS'}; % Tipos de amplificadores
N_A0 = 5;                                         % Número de parâmetros A0
N_AMP = 4;                                        % Número de amplificadores                 

BER = zeros(K, N_SNR, N_AMP, N_A0); % Inicialização da matriz de BER

% Parâmetros físicos
c = 3e8;               % Velocidade da luz (m/s)
f = 1e9;               % Frequência de operação (Hz)
K_f_dB = 10;           % Fator de Rician em dB
K_f = 10^(K_f_dB/10);  % Fator de Rician em valor linear

% Comprimento de onda e espaçamento entre antenas
lambda = c / f;
d = lambda / 2;

% ângulo de chegada da LOS
theta_LOS = -pi/2 + pi*rand(K, 1);

% Componentes LOS e NLOS
A_LOS = exp(1i * 2 * pi * (0:M-1)' * 0.5 .* repmat(sin(theta_LOS'), M, 1));
H_LOS = sqrt(K_f / (1 + K_f)) * A_LOS;

W = (randn(M, K) + 1i * randn(M, K)) / sqrt(2);
R = eye(M);
H_NLOS = sqrtm(R) * W;

% Canal completo
H = H_LOS + sqrt(1 / (1 + K_f)) * H_NLOS;

% ####################################################################### %
%% PARAMETROS DO SINAL E DO RUÍDO 
% ####################################################################### %

bit_array = randi([0, 1], B * N_BLK, K);           % Gerar bits aleatórios
s = qammod(bit_array, M_QAM, 'InputType', 'bit');  % Modulação QAM
Ps = vecnorm(s).^2 / N_BLK;                        % Potência do sinal

% Computar e normalizar o sinal pré-codificado
precoder = compute_precoder(precoder_type, H, N_SNR, snr_linear);
x_normalized = normalize_precoded_signal(precoder, precoder_type, M, s, N_SNR);

% Gerar ruído
v = sqrt(0.5) * (randn(K, N_BLK) + 1i*randn(K, N_BLK));
Pv = vecnorm(v,2,2).^2/N_BLK;
v_normalized = v./sqrt(Pv);

% ####################################################################### %
%% CALCULO DA BER
% ####################################################################### %

for snr_idx = 1:N_SNR
    for a_idx = 1:N_A0
        for amp_idx = 1:N_AMP
            a0 = A0(a_idx);
            current_amp_type = amplifiers_type{amp_idx};

            y = H.' * amplifier(sqrt(snr_linear(snr_idx)) * x_normalized, current_amp_type, a0) + v_normalized;
            bit_received = zeros(B * N_BLK, K);

            for users_idx = 1:K
                s_received = y(users_idx, :).';
                Ps_received = norm(s_received)^2 / N_BLK;

                % Sinal decodificado (com normalização)
                s_received_normalized = sqrt(Ps(users_idx) / Ps_received) * s_received; 
                bit_received(:, users_idx) = qamdemod(s_received_normalized, M_QAM, 'OutputType', 'bit');
                
                % Cálculo da BER
                [~, BER(users_idx, snr_idx, amp_idx, a_idx)] = biterr(bit_received(:, users_idx), bit_array(:, users_idx));
            end
        end
    end
end

% Salvar resultados
save('ber_zf.mat', 'M', 'K', 'y', 'SNR', 'A0', 'N_AMP', 'N_A0', 'BER', 'precoder_type', 'amplifiers_type', 's_received_normalized');