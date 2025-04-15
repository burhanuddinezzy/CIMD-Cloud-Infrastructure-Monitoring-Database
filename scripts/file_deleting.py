import os
import glob

def delete_pdf_files_with_phrase(folder_path):
    # Ensure the folder path exists
    if not os.path.exists(folder_path):
        print(f"The folder path '{folder_path}' does not exist.")
        return
    
    count = 0

    image_extensions = ["*.png", "*.jpg", "*.jpeg", "*.gif", "*.bmp", "*.tiff", "*.webp"]

    # Search for all PDF files in the folder
    for ext in image_extensions:
        image_file_type = glob.glob(os.path.join(folder_path, ext))
        for file in image_file_type:
            os.remove(file)
            print(f"Deleted: {file}")
            count += 1
    
    print (f"Deleted {count} files")

# Example usage
folder_path = r"C:\Users\burha\Downloads"  # Replace with your folder path
phrase = "Mockup"  # The phrase to look for in the filenames
delete_pdf_files_with_phrase(folder_path)