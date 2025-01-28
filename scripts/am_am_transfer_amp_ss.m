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

amplitude_out = zeros(N_amp_in, length(p_values), N_A0);

for a0_idx = 1:N_A0
    a0 = A0(a0_idx);
    
    for p_idx = 1:length(p_values)
        p = p_values(p_idx);
        
        for amp_in_idx = 1:N_amp_in
            amp_in = amplitude_in(amp_in_idx);
            
            amp_out = abs(amp_in) ./ (1 + (abs(amp_in) / a0).^(2 * p)).^(1 / (2 * p)) .* exp(1j * angle(amp_in));
            
            amplitude_out(amp_in_idx, p_idx, a0_idx) = amp_out;
        end
    end
end

% ####################################################################### %
%% PLOT
% ####################################################################### %

figure;
hold on;

for a0_idx = 1:N_A0
    for p_idx = 1:length(p_values)
        if A0(a0_idx) == 1
            style = '-o';
        elseif A0(a0_idx) == 2
            style = '-*';
        end
        
        plot(amplitude_in, squeeze(amplitude_out(:, p_idx, a0_idx)), style, ...
            'DisplayName', sprintf('p = %d, A0 = %.1f', p_values(p_idx), A0(a0_idx)));
    end
end

xlabel('Amplitude In');
ylabel('Amplitude Out');
legend('Location', 'southeast');
legend box off;