import os
import re

diretorio = r"C:\Users\joaov_zm1q2wh\OneDrive\Code\github\Impact-Analysis-of-Analog-Front-end-in-Massive-MIMO-Systems\images\ber"

for nome_arquivo in os.listdir(diretorio):
    nome_base, extensao = os.path.splitext(nome_arquivo)
    match = re.match(r"BER_(.*?)_M(\d+)_K(\d+)", nome_base)

    if match:
        novo_nome = f"{match.group(1)}_{match.group(2)}_{match.group(3)}{extensao}"
        caminho_antigo = os.path.join(diretorio, nome_arquivo)
        caminho_novo = os.path.join(diretorio, novo_nome)
        
        os.rename(caminho_antigo, caminho_novo)
        print(f"Renomeado: {nome_arquivo} -> {novo_nome}")
