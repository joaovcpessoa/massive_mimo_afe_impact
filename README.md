# Análise do Front-End analógico de sistemas Massive MIMO

## Introdução

O foco deste trabalho é avaliar o impacto dos modelos de não linearidade baseados em amplificadores operacionais em sistemas de comunicação Massive MIMO.
O sistema é modelado através do <b>MATLAB</b> e o desempenho é avaliado em termos da BER média por usuário como uma função da SNR do downlink e uplink medido em terminais usando simulação de Monte Carlo e assumindo conhecimento completo de CSI pela estação base.

### Scripts de análise:

* `amplitude_analisys.m` - Análise da amplitude e fase dos modelos não lineares baseados nos amplificadores operacionais.
* `dl_ber.m` -  Análise da BER vs. SNR em Downlink utilizando modulação 16-QAM com as modelagens não lineares baseadas nos amplificadores operacionais.
* `ul_ber.m` - Análise da BER vs. SNR em Uplink utilizando modulação 16-QAM com as modelagens não lineares baseadas nos amplificadores operacionais.

### Scripts para gerar as imagens:

* `plot_amplitude_phase.m` - Exibi os gráficos para as análises de amplitude e fase dos amplificadores operacionais.
* `plot_ber_clip_ss.m` - Exibi os gráficos para as análises de BER das modelagens não lineares baseadas nos amplificadores operacionais (Tubo de onda tunelada, Corte ideal e Estado sólido).
* `plot_constellation.m` - Exibi os gráficos das constelações.

### Funções

* `precode_signal.m` - Aplica pré-codificação no sinal.
* `decode_signal.m` - Aplica decodificação no sinal.
* `amplify_signal.m` - Amplifica o sinal baseada nos modelos de não linearidade.
* `normalize_precoded_signal.m` - Normalizar a potência do sinal.
* `rician_channel_generator.m` - Gera um canal com desvanecimento de Rician.
* `user_position_generator.m` - Gera um posicionamento para os usuários dentro de uma célula.
* `load_env.m` - Ajusta as variáveis de ambiente e caminhos importantes dos scripts

---

## Detalhamento do Código

### dl_ber.m

O código simula um sistema de comunicação Massive MIMO (Multiple-Input Multiple-Output) em Downlink. O objetivo é calcular a Taxa de Erro de Bit (BER) considerando diferentes tipos de amplificadores e parâmetros do sistema. Como eu detesto comentar código, vou deixar abaixo uma explicação mais detalhada possível sobre como ele é estruturado.

<b>Limpeza e Configuração Inicial</b>

```matlab
clear;     % Remove todas as variáveis do workspace
close all; % Fecha todas as figuras abertas
clc;       % Limpa a janela de comando
```
Comandos básicos do sistema e extremamente importante se você, assim como eu, fica facilmente frustrado com o fato de ter que ficar limpando o terminal após executar o código.

<b>Configuração de Caminhos</b>

```matlab
% Obtém o diretório do script atual
current_dir = fileparts(mfilename('fullpath'));

% Define o caminho para um arquivo .env no diretório superior
env_file = fullfile(current_dir, '..', '.env');

% Carrega variáveis de ambiente (como caminhos) usando a função load_env
env_vars = load_env(env_file);

% Extrai os caminhos para salvar simulações e acessar funções
simulation_dir = env_vars.SIMULATION_SAVE_PATH;
functions_dir = env_vars.FUNCTIONS_PATH;

% Adiciona esses diretórios ao caminho de busca do MATLAB
addpath(simulation_dir);
addpath(functions_dir);
```

Eu descobri o quão necessário é isso lidando com erros de diretório. Simplesmente criei uma `.env` que utilizo em projetos de Python e JS e construi uma função para lidar com isso.

<details>
  <summary><b>Sobre a função load_env.m</b></summary>

A função load_env é o coração dessa solução. Ela lê o arquivo .env e transforma seu conteúdo em um struct que o MATLAB pode usar.

```matlab
% Define a função load_env que lê variáveis de ambiente de um arquivo .env
function env_vars = load_env(env_file)
    % Inicializa um struct vazio para armazenar as variáveis de ambiente
    env_vars = struct();
    
    % Verifica se o arquivo .env existe (retorna 2 se for um arquivo regular)
    if exist(env_file, 'file') == 2
        % Abre o arquivo .env em modo leitura
        fid = fopen(env_file, 'r');
        % Lê o arquivo linha por linha até o final
        while ~feof(fid)
            % Lê uma linha, remove espaços em branco no início e fim
            line = strtrim(fgetl(fid));
            % Pula linhas vazias ou comentários (que começam com #)
            if isempty(line) || startsWith(line, '#')
                continue;
            end
            % Usa expressão regular para dividir a linha em chave e valor (formato CHAVE=VALOR)
            tokens = regexp(line, '^(.*?)=(.*)$', 'tokens');
            % Se a linha foi dividida corretamente, processa chave e valor
            if ~isempty(tokens)
                % Extrai e remove espaços da chave
                key = strtrim(tokens{1}{1});
                % Extrai e remove espaços do valor
                value = strtrim(tokens{1}{2});
                % Adiciona o par chave-valor ao struct
                env_vars.(key) = value;
            end
        end
        % Fecha o arquivo após a leitura
        fclose(fid);
    else
        % Lança erro se o arquivo .env não for encontrado
        error('Arquivo .env não encontrado.');
    end
end
```
</details>

<br>

<b>Parâmetros Principais</b>
Precoding e Amplificadores

```matlab
% Define o precodificador como 'MF' (Matched Filter)
precoder_type = 'MF';

% Lista os tipos de amplificadores ('IDEAL' e 'TWT')
amplifiers_type = {'IDEAL', 'TWT'};

% Calcula o número de amplificadores (2)
N_AMP = length(amplifiers_type);
```

<b>Parâmetros do Amplificador TWT</b>

```matlab
% Define três conjuntos de parâmetros para o amplificador TWT (chi_A, kappa_A, chi_phi, kappa_phi), que modelam suas características não lineares
params = {
    struct('chi_A', 1.6397, 'kappa_A', 0.0618, 'chi_phi', 0.2038, 'kappa_phi', 0.1332),
    struct('chi_A', 1.9638, 'kappa_A', 0.9945, 'chi_phi', 2.5293, 'kappa_phi', 2.8168),
    struct('chi_A', 2.1587, 'kappa_A', 1.1517, 'chi_phi', 4.0033, 'kappa_phi', 9.1040)
};

% Calcula o número de conjuntos (3)
N_params = length(params);
```

<b>Configurações de Simulação</b>

```matlab
% Número de blocos de símbolos por simulação (1000)
N_BLK = 1000;

% Número de realizações de Monte Carlo para posições dos usuários (10)
N_MC1 = 10;

% Número de realizações de Monte Carlo para o canal NLOS (10)
N_MC2 = 10;

% Antenas e Usuários

% Número de antenas na estação base (64)
M = 64;

% Número de usuários (16)
K = 16;

% Modulação

% Bits por símbolo (4)
B = 4;

% Ordem da modulação QAM (16-QAM)
M_QAM = 2^B;

% Vetor de SNR em dB, de -10 a 30 com passo 1
SNR = -10:1:30;

% Número de valores de SNR (41)
N_SNR = length(SNR);

% Converte SNR para escala linear
snr = 10.^(SNR/10);

% Raio máximo para posições dos usuários (1000 metros)
radial = 1000;
% Velocidade da luz
c = 3e8;
% Frequência portadora (1 GHz)
f = 1e9;
% Fator de Rice em dB (10)
K_f_dB = 10;
% Fator de Rice em escala linear
K_f = 10^(K_f_dB/10);

```

<b>Configurações do canal</b>

```matlab
% Comprimento de onda
lambda = c / f;
% Distância entre antenas
d = lambda / 2;
% Matriz de correlação espacial
R = eye(M);
```

<b>Alocação de Memória</b>

```matlab
% Matrizes para armazenar as coordenadas x e y dos usuários
x_user = zeros(K, N_MC1);
y_user = zeros(K, N_MC1);

% Matriz 6D para armazenar a BER por usuário, SNR, amplificador, conjunto de parâmetros e realizações de Monte Carlo
BER = zeros(K, N_SNR, N_AMP, N_params, N_MC1, N_MC2);
```

<b>Simulação de Monte Carlo</b>

```matlab
% Loop Externo: Posições dos Usuários
for mc_idx1 = 1:N_MC1
    mc_idx1
    [x_user(:,mc_idx1), y_user(:,mc_idx1)] = user_position_generator(K,radial);
    theta_user = atan2(y_user(:,mc_idx1), x_user(:,mc_idx1));
    A_LOS = exp(1i * 2 * pi * (0:M-1)' * 0.5 .* repmat(sin(theta_user'), M, 1));
    H_LOS = sqrt(K_f / (1 + K_f)) * A_LOS;

% Exibe o índice da realização para monitoramento
% Gera posições aleatórias para K usuários dentro do raio radial
% Calcula os ângulos dos usuários em relação à estação base
% Matriz de direção LOS (M×K) baseada nos ângulos
% Canal LOS escalado pelo fator de Rice
```

```matlab
% Loop Interno: Canal NLOS
for mc_idx2 = 1:N_MC2
  mc_idx2
  H_NLOS = (randn(M, K) + 1i * randn(M, K)) / sqrt(2);
  H = H_LOS + sqrt(1 / (1 + K_f)) * sqrtm(R) * H_NLOS;

% Exibe o índice da realização NLOS
% Gera a componente NLOS como ruído gaussiano complexo normalizado
% Combina LOS e NLOS para formar o canal total
```

<b>Geração de Símbolos</b>

```matlab
bit_array = randi([0, 1], B * N_BLK, K);
s = qammod(bit_array, M_QAM, 'InputType', 'bit');
Ps = vecnorm(s).^2 / N_BLK;

% Gera bits aleatórios
% Modula os bits em símbolos 16-QAM
% Calcula a potência média dos símbolos por usuário
```

<b>Precoding</b>

```matlab
precoder = precode_signal(precoder_type, H, N_SNR, snr);
x_normalized = normalize_precoded_signal(precoder, precoder_type, M, s, N_SNR);

% Calcula o precodificador 'MF' baseado no canal H
% Normaliza o sinal precodificado para cada SNR
```

<b>Ruído</b>

```matlab
% Loops de SNR, Amplificador e Parâmetros
for snr_idx = 1:N_SNR
  for amp_idx = 1:N_AMP
    for param_idx = 1:N_params
      chi_A = params{param_idx}.chi_A;
      kappa_A = params{param_idx}.kappa_A;
      chi_phi = params{param_idx}.chi_phi;
      kappa_phi = params{param_idx}.kappa_phi;
      current_amp_type = amplifiers_type{amp_idx};
```

Itera sobre SNR, tipos de amplificador e parâmetros do TWT, extraindo os valores correspondentes.

<b>Transmissão e Recepção</b>

```matlab
if strcmp(precoder_type, 'MMSE')
  y = H.' * amplify_signal(sqrt(snr(snr_idx)) * x_normalized(:, :, snr_idx), current_amp_type, chi_A, kappa_A, chi_phi, kappa_phi) + v_normalized;    
else
  y = H.' * amplify_signal(sqrt(snr(snr_idx)) * x_normalized, current_amp_type, chi_A, kappa_A, chi_phi, kappa_phi) + v_normalized;
end

% Escala o sinal precodificado pela SNR.
% Aplica amplificação ('IDEAL' ou 'TWT') usando amplify_signal.
% Multiplica pelo canal conjugado transposto (H.') e adiciona ruído.
```

<b>Demodulação e BER</b>

```matlab
bit_received = zeros(B * N_BLK, K);              
for users_idx = 1:K
  s_received = y(users_idx, :).';
  Ps_received = norm(s_received)^2 / N_BLK;
  bit_received(:, users_idx) = qamdemod(sqrt(Ps(users_idx) / Ps_received) * s_received, M_QAM, 'OutputType', 'bit');
  [~, bit_error] = biterr(bit_received(:, users_idx), bit_array(:, users_idx));
  BER(users_idx, snr_idx, amp_idx, param_idx, mc_idx1, mc_idx2) = bit_error;
end

% Para cada usuário
%   Extrai o sinal recebido
%   Calcula sua potência
%   Demodula os símbolos, ajustando pela potência original
%   Calcula a BER comparando bits transmitidos e recebidos
```

<b>Salvamento dos Resultados</b>

```matlab
file_name = sprintf('dl_ber_%s_%s_%d_%d.mat', lower(precoder_type), lower(amplifiers_type{2}), M, K);
save(fullfile(simulation_dir, file_name), 'M', 'K', 'SNR', 'BER', 'N_AMP', 'N_A0', 'A0', 'precoder_type', 'amplifiers_type', 'N_params');

% Cria um nome como dl_ber_mf_twt_64_16.mat.
% Salva variáveis relevantes no diretório simulation_dir.
```

### Referências

[✍🏻 Artigo](https://)

## Apoiadores do Projeto

[@rafaelschaves](https://github.com/rafaelschaves)

## Autor

[@joaovcpessoa](https://github.com/joaovcpessoa)
