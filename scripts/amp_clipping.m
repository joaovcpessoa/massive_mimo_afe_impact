% Dados de exemplo
input_voltage = linspace(0, 1, 100);
output_voltage = 1.9638 * input_voltage.^0.9945; % Coeficientes de A(r)
output_phase = 2.5293 * input_voltage.^2.8168; % Coeficientes de Φ(r)

% Criar o gráfico
figure;
yyaxis left
plot(input_voltage, output_voltage, '*-');
xlabel('Tensão de Entrada (normalizada)');
ylabel('Tensão de Saída (normalizada)');
title('Relação entre Tensão de Entrada e Saída de um TWT Amplifier');

yyaxis right
plot(input_voltage, output_phase, 'o-');
ylabel('Fase de Saída (graus)');

legend('Tensão de Saída', 'Fase de Saída');
grid on;
