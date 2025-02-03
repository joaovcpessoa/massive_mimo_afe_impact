import os
import shutil

images_directory = r'C:\Users\joaov_zm1q2wh\OneDrive\Code\github\Impact-Analysis-of-Analog-Front-end-in-Massive-MIMO-Systems\images\ber'

fig_folder = os.path.join(images_directory, 'fig')
eps_folder = os.path.join(images_directory, 'eps')
png_folder = os.path.join(images_directory, 'png')

os.makedirs(fig_folder, exist_ok=True)
os.makedirs(eps_folder, exist_ok=True)
os.makedirs(png_folder, exist_ok=True)

for file in os.listdir(images_directory):
    file_path = os.path.join(images_directory, file)

    if os.path.isfile(file_path):
        extension = file.lower().split('.')[-1]

        if extension == 'fig':
            shutil.move(file_path, fig_folder)
        elif extension == 'eps':
            shutil.move(file_path, eps_folder)
        elif extension == 'png':
            shutil.move(file_path, png_folder)

print("Images organized into their respective folders!")