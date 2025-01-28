%% LIMPEZA
% ####################################################################### %

clear;
close all;
clc;

% ####################################################################### %
%% PARÂMETROS PRINCIPAIS
% ####################################################################### %

A0 = [1.0, 2.0];      % Parâmetros de amplificação
p_values = [1, 2, 3]; % Valores do parâmetro de não linearidade (saturação)

N_A0 = length(A0);    % Número de valores de A0

N_amp_in = 100;                           % Número de pontos para a amplitude de entrada
amplitude_in = linspace(0, 10, N_amp_in); % Variação da amplitude de entrada

% ####################################################################### %
%% CÁLCULO DA TRANSFERÊNCIA DE AMPLITUDE
% ####################################################################### %

amplitude_out_clipping = zeros(N_amp_in, 1, N_A0);  % Inicializa a matriz de saída para clipping ideal

for a0_idx = 1:N_A0
    a0 = A0(a0_idx);
    
    for amp_in_idx = 1:N_amp_in
        amp_in = amplitude_in(amp_in_idx);
        
        % Implementação direta do modelo de clipping ideal
        amp_out = min(abs(amp_in), a0) .* exp(1j * angle(amp_in));
        
        % Armazena o resultado
        amplitude_out_clipping(amp_in_idx, 1, a0_idx) = amp_out;
    end
end

%% GERANDO O GRÁFICO DE AMPLITUDE-AMPLITUDE PARA CLIPPING IDEAL
% ####################################################################### %

figure;
hold on;

for a0_idx = 1:N_A0
    if A0(a0_idx) == 1
        style = '-';
    elseif A0(a0_idx) == 2
        style = '-';
    end
    
    plot(amplitude_in, abs(squeeze(amplitude_out_clipping(:, 1, a0_idx))), style, ...
        'DisplayName', sprintf('A0 = %.1f', A0(a0_idx)));
end

xlabel('Amplitude In');
ylabel('Amplitude Out');
legend('Location', 'southeast');
legend box off;