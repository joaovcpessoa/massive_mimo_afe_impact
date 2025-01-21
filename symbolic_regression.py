import numpy as np
from scipy.io import loadmat
from gplearn.genetic import SymbolicRegressor
import matplotlib.pyplot as plt

data = loadmat(r'Impact-Analysis-of-Analog-Front-end-in-Massive-MIMO-Systems\ber_mc_mf_64_32.mat')

SNR = data['SNR'][0]
BER = data['BER']

print("Dimensões iniciais do array BER:", BER.shape)

# Passo 1: Média sobre o eixo 0 (usuários, equivalente ao axis=1 no MATLAB)
BER_per_user = np.mean(BER, axis=0, keepdims=True)
print("Dimensões após média por usuário (axis=0):", BER_per_user.shape)

# Passo 2: Média sobre o eixo 4 (axis=4 em Python, axis=5 no MATLAB)
avg_H_BER = np.mean(BER_per_user, axis=4, keepdims=True)
print("Dimensões após média sobre canal H (axis=4):", avg_H_BER.shape)

# Passo 3: Média sobre o eixo 5 (axis=5 em Python, axis=6 no MATLAB)
BER_mean = np.mean(avg_H_BER, axis=5)
print("Dimensões finais após média geral (axis=5):", BER_mean.shape)

# Curva de BER para regressão simbólica
snr = SNR
ber_curve = BER_mean[0, :, 0, 0]

model = SymbolicRegressor(population_size=1000,
                          generations=10,
                          stopping_criteria=0.01,
                          p_crossover=0.7,
                          p_subtree_mutation=0.1,
                          p_hoist_mutation=0.05,
                          p_point_mutation=0.1,
                          max_samples=0.9,
                          verbose=1,
                          parsimony_coefficient=0.01,
                          random_state=0)

# Regressão simbólica no log10(BER)
model.fit(snr.reshape(-1, 1), np.log10(ber_curve))

# Predição simbólica
predicted = model.predict(snr.reshape(-1, 1))

# Função simbólica encontrada
print("Funcao ajustada:", model._program)

# Plotando a curva original e o ajuste simbólico
plt.figure(figsize=(10, 6))
plt.semilogy(snr, ber_curve, label="Curva Original", marker='o')
plt.semilogy(snr, 10**predicted, label="Ajuste Simbólico", linestyle='--')
plt.xlabel('SNR (dB)')
plt.ylabel('BER')
plt.title('Regressão Simbólica')
plt.legend()
plt.grid()
plt.show()
