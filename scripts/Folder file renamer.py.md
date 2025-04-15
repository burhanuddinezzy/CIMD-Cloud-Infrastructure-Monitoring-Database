import os
import re

# Set the folder path
folder_path = r"C:\Users\burha\Downloads\database design\Database Design 18dead362d9380d99e2cdf933c8719d6"

# Define a function to rename files
def rename_files_in_directory(directory):
    # Iterate through every item in the directory
    for root, dirs, files in os.walk(directory, topdown=False):
        for filename in files:
            # Check if the filename contains a string starting with "18..." or "19..."
            print(f"Checking file: {filename}")  # Debug print to see the files
            new_filename = re.sub(r'(.*?)(18|19)[a-f0-9]+.*$', r'\1', filename)
            print(f"New filename: {new_filename}")  # Debug print to see the new filename
            if new_filename != filename:
                # Create the full path for the old and new filenames
                old_file = os.path.join(root, filename)
                new_file = os.path.join(root, new_filename)
                # Rename the file
                os.rename(old_file, new_file)
                print(f'Renamed file: {old_file} -> {new_file}')  # Debug print to show renaming
                
        for dir_name in dirs:
            # Check and rename folders if needed (if folder name contains "18..." or "19...")
            print(f"Checking folder: {dir_name}")  # Debug print to see the folders
            new_dirname = re.sub(r'(.*?)(18|19)[a-f0-9]+.*$', r'\1', dir_name)
            print(f"New folder name: {new_dirname}")  # Debug print to see the new folder name
            if new_dirname != dir_name:
                old_dir = os.path.join(root, dir_name)
                new_dir = os.path.join(root, new_dirname)
                # Rename the directory
                os.rename(old_dir, new_dir)
                print(f'Renamed folder: {old_dir} -> {new_dir}')  # Debug print to show renaming

# Call the function
rename_files_in_directory(folder_path)
