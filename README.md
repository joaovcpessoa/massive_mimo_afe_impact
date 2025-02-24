# Análise do Front-End analógico de sistemas Massive MIMO

Como o foco principal é avaliar o impacto dos modelos de não linearidade baseados em amplificadores operacionais  em sistemas de comunicação Massive MIMO, iremos separar em 3 cenários, cada cenário avaliando um pré-codificador específico.
 O desempenho é avaliado em termos da BER média por usuário como uma função da SNR do downlink e uplink medido em terminais usando simulação de Monte Carlo e assumindo conhecimento completo de CSI pela estação base. 

### Scripts:

* [amplitude_clip_io.m](scripts) - Análise da Amplitude de Entrada vs. Amplitude Saída do modelo não linear baseado no amplificador operacional de corte ideal.
* [amplitude_ss_io.m](scripts) - Análise da Amplitude de Entrada vs. Amplitude Saída do modelo não linear baseado no amplificador operacional de estado sólido.
* [amplitude_twt_io.m](scripts) - Análise da Amplitude de Entrada vs. Amplitude Saída e Amplitude de Entrada vs. Fase de Saída do modelo não linear baseado no amplificador operacional de tubo de onda tunelada.
* [ul_clip_ss.m](scripts) - Análise da BER vs. SNR em Uplink utilizando modulação 16-QAM e modelagem de não linearidade baseada em 2 tipos amplificadores operacionais: Corte ideal e Estado sólido. 
* [ul_twt.m](scripts) -  Análise da BER vs. SNR em Uplink utilizando modulação 16-QAM e modelagem de não linearidade baseada no amplificador operacional de tubo de onda tunelada.
* [dl_clip_ss.m](scripts) - Análise da BER vs. SNR em Downlink utilizando modulação 16-QAM e modelagem de não linearidade baseada em 2 tipos amplificadores operacionais: Corte ideal e Estado sólido. 
* [dl_twt.m](scripts) -  Análise da BER vs. SNR em Downlink utilizando modulação 16-QAM e modelagem de não linearidade baseada no amplificador operacional de tubo de onda tunelada.
* [plot_ber_clip_ss.m](scripts) - Exibir os gráficos para as análises de BER das modelagens não lineares baseadas nos amplificadores operacionais de corte ideal e estado sólido.
* [plot_ber_twt.m](scripts) - Exibir os gráficos para as análises de BER da modelagem não linear baseada no amplificador operacional de tubo de onda tunelada.
* [plot_constellation.m](scripts) - Exibir os gráficos das constelações.

### Funções

* [compute_precoder.m](scripts) - Função criada para pré-codificar do sinal.
* [compute_decoder.m](scripts) - Função criada para decodificar do sinal.
* [amplifier.m](scripts) - Função criada para aplicar amplificação do sinal baseada nos modelos de não linearidade.
* [normalize_precoded_signal.m](scripts) - Função criada para normalizar a potência do sinal.
* [userPositionGenerator.m](scripts) - Função criada para gerar o posicionamento dos usuários dentro de uma célula.

---

### Definição de parâmetros principais

- <b>precoder_type:</b> Define o tipo de precodificador que será usado na chamada da função <i>compute_precoder</i>

- <b>N_BLK:</b> Número de blocos de dados transmitidos na simulação. Um valor maior aumenta a precisão estatística das métricas, como a BER, ao fornecer mais amostras, aproximando a simulação de cenários reais. Contudo, isso também eleva o tempo de execução, pois mais dados são processados. Valores altos permitem uma análise mais robusta sob diferentes condições de canal

- <b>N_MC1:</b> Monte Carlo para posições de usuário

- <b>N_MC2:</b> Monte Carlo para desvanecimento em pequena escala

- <b>M:</b> Número de antenas na estação base

- <b>K:</b> Número de usuários

- <b>B:</b> Número de bits transmitidos por símbolo na modulação

- <b>M_QAM:</b> Calcula o tamanho da constelação para a modulação QAM (Quadrature Amplitude Modulation), que é $2^B$

- <b>SNR:</b> Define um vetor de valores para a Relação Sinal-Ruído (SNR) em decibéis, variando de -10 a 20 dB, para simular diferentes condições de ruído no canal de comunicação.

- <b>N_SNR:</b> Calcula o comprimento do vetor SNR, que representa o número de valores de SNR que serão testados na simulação.

- <b>snr:</b> Conversão SNR para valor linear

- <b>A0:</b> Valores de amplitudo usados nos amplificadores

- <b>amplifiers_type:</b> Define o tipo de amplificador que será usado na chamada da função <i>amplifier</i>

- <b>N_A0:</b> Número de parâmetros de A0

- <b>N_AMP:</b> Número de amplificadores

- <b>radial:</b> Raio da célula em metros

- <b>c:</b> Velocidade da luz (m/s)

- <b>f:</b> Frequência de operação (Hz)

- <b>K_f_dB:</b> Fator de Rician em dB

- <b>K_f:</b> Fator de Rician em valor linear

- <b>lambda:</b> Comprimento de onda

- <b>d:</b>  Espaçamento entre antenas (em m)

- <b>R:</b> Matriz identidade de dimensão

<details>
    <summary><code>Detalhamento</code></summary>

<b>Componentes do canal</b><br>
- <b>$randn(M, K)$:</b> Gera uma matriz $𝑀×𝐾$ com valores aleatórios provenientes de uma distribuição normal (média 0 e variância 1). Esses valores representam as partes reais do canal. 

- <b>$1i×randn(M, K)$:</b> Gera a parte imaginária do canal da mesma forma, multiplicando por 1i para criar números complexos.

A matriz resultante $H$ é composta de valores complexos $H_{ij}$, que representam os coeficientes de canal entre a i-ésima antena da estação base e o j-ésimo usuário. A divisão por $\sqrt{2}$ normaliza o canal para que cada coeficiente tenha variância unificada, ou seja:

$$Var(Re(H_{ij}) = Var(Im(H_{ij}) = \frac{1}{2}$$

Isso garante que a potência total (soma das variâncias das partes real e imaginária) seja igual a 1, um requisito comum em simulações de sistemas de comunicação. Este modelo de canal é típico em sistemas Massive MIMO e modela um canal de desvanecimento Rayleigh com distribuição $\mathcal{CN}(0,1)$.
        

</details>

## Imagens:

### ber:

As imagens estão codificadas conforme explicado abaixo: 

Padrão: %s_%s_%s_%d_%d</br>
Exemplo: MC_ZF_TWT_128_32

- O primeiro grupo informa a existência de Monte Carlo
- O segundo grupo informa o precodificador
- O terceiro grupo informa o modelo de não linearidade do amplificador
- O quarto grupo é o número de antenas na BS
- O quinto grupo é o número de terminais UEs

### constellation:

As imagens estão codificadas conforme explicado abaixo: 

Padrão: %s_%s_%d_%d_%d_%d</br>
Exemplo: MF_CLIP_64_16_30_100

- O primeiro grupo informa o precodificador
- O segundo grupo informa o modelo de não linearidade do amplificador
- O terceiro grupo é o número de antenas na BS
- O quarto grupo é o número de terminais UEs
- O quinto grupo é o SNR
- O sexto grupo é a amplitude

[🚧EM CONSTRUÇÃO🚧]

### Referências

[✍🏻 Artigo](https://)

## Apoiadores do Projeto

[@rafaelschaves](https://github.com/rafaelschaves)

## Autor

[@joaovcpessoa](https://github.com/joaovcpessoa)
