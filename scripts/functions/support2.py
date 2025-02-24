import os

pasta = r"C:\Users\joaov_zm1q2wh\OneDrive\Code\github\massive_mimo_afe_impact\scripts\amplifiers\traveling_wave_tube\data"

for arquivo in os.listdir(pasta):
    if arquivo.startswith("ber_mc_mmse_") and arquivo.endswith(".mat"):
        partes = arquivo.split("_")
        if "clip" not in partes:
            novo_nome = f"{partes[0]}_{partes[1]}_{partes[2]}_twt_{partes[3]}_{partes[4]}"
            antigo_caminho = os.path.join(pasta, arquivo)
            novo_caminho = os.path.join(pasta, novo_nome)

            os.rename(antigo_caminho, novo_caminho)
            print(f"Renomeado: {arquivo} -> {novo_nome}")
