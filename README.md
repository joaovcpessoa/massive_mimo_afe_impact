# Análise do Front-End analógico de sistemas Massive MIMO

Este repositório apresenta exemplos em MATLAB que modelam os impactos de não linearidades de hardware em sistemas de comunicação Massive MIMO.

## Scripts:

Cada script aborda um aspecto específico da análise:

### Downlink

* [dl_precoder_mf_zf.m](scripts) - Análise da BER vs. SNR utilizando modulação 16-QAM, utilizando modelagem de não linearidade baseada em 3 tipos amplificadores operacionais para os pré-codificadores Matched Filter e Zero Forcing. 
* [dl_precoder_mmse.m](scripts) -  Análise da BER vs. SNR utilizando modulação 16-QAM, utilizando modelagem de não linearidade baseada em 3 tipos amplificadores operacionais para o pré-codificadores MMSE.
* [dl_mc_precoder_mf_zf.m](scripts) - Análise da BER vs. SNR utilizando modulação 16-QAM, utilizando modelagem de não linearidade baseada em 3 tipos amplificadores operacionais para os pré-codificadores Matched Filter e Zero Forcing, além de utilizar Monte Carlo. 
* [dl_mc_precoder_mmse.m](scripts) -  Análise da BER vs. SNR utilizando modulação 16-QAM, utilizando modelagem de não linearidade baseada em 3 tipos amplificadores operacionais para o pré-codificadores MMSE, além de utilizar Monte Carlo.
* [plot_ber.m](scripts) - Exibir os gráficos para as análises de BER.
* [plot_mc_ber.m](scripts) - Exibir os gráficos para as análises de BER que utilizam Monte Carlo.

### Uplink

[🚧EM CONSTRUÇÃO🚧]

### Funções

* [compute_precoder.m](scripts) - Função criada para pré-codificar do sinal.
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

[🚧EM CONSTRUÇÃO🚧]

### Referências

[✍🏻 Artigo](https://)

## Apoiadores do Projeto

[@rafaelschaves](https://github.com/rafaelschaves)

## Autor

[@joaovcpessoa](https://github.com/joaovcpessoa)