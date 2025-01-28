import os
import shutil

def rename_file(file_path, suffix):
    name, extension = os.path.splitext(file_path)
    new_name = f"{name}_{suffix}{extension}"
    new_path = os.path.join(os.path.dirname(file_path), new_name)
    os.rename(file_path, new_path)
    return new_path

def move_file(file_path, base_directory, categories):
    for keyword, folder in categories.items():
        if keyword in os.path.basename(file_path):
            destination = os.path.join(base_directory, folder)
            os.makedirs(destination, exist_ok=True)
            shutil.move(file_path, os.path.join(destination, os.path.basename(file_path)))
            return True
    return False

def process_files(directory, suffix):
    categories = {"CLIP": "CLIP", "SS": "SS", "TWT": "TWT"}
    script_name = os.path.basename(__file__)

    for file_name in os.listdir(directory):
        if file_name == script_name or not os.path.isfile(os.path.join(directory, file_name)):
            continue

        file_path = os.path.join(directory, file_name)
        new_path = rename_file(file_path, suffix)

        if not move_file(new_path, directory, categories):
            print(f"File '{os.path.basename(new_path)}' does not fit any category.")

if __name__ == "__main__":
    target_directory = r"C:\Users\joaov_zm1q2wh\OneDrive\Code\github\Impact-Analysis-of-Analog-Front-end-in-Massive-MIMO-Systems\images"
    suffix = "M64_K32"

    if os.path.isdir(target_directory):
        process_files(target_directory, suffix)
    else:
        print("The specified directory is not valid. Please check the path.")
