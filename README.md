# Análise do Front-End analógico de sistemas Massive MIMO

Como o foco principal é avaliar o impacto dos modelos de não linearidade baseados em amplificadores operacionais  em sistemas de comunicação Massive MIMO, iremos separar em 3 cenários, cada cenário avaliando um pré-codificador específico.
O desempenho é avaliado em termos da BER média por usuário como uma função da SNR do downlink e uplink medido em terminais usando simulação de Monte Carlo e assumindo conhecimento completo de CSI pela estação base. 

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

### Referências

[✍🏻 Artigo](https://)

## Apoiadores do Projeto

[@rafaelschaves](https://github.com/rafaelschaves)

## Autor

[@joaovcpessoa](https://github.com/joaovcpessoa)
