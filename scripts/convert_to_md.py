import os

# Define the folder path
folder_path = r"C:\Users\burha\Downloads\database design\Database Design 18dead362d9380d99e2cdf933c8719d6"

# Walk through all files and subfolders
for root, dirs, files in os.walk(folder_path):
    for filename in files:
        old_file = os.path.join(root, filename)
        new_file = os.path.join(root, os.path.splitext(filename)[0] + ".md")
        
        # Rename only if the extension is not already .md
        if not filename.endswith(".md"):
            os.rename(old_file, new_file)
            print(f"Renamed: {old_file} -> {new_file}")

print("✅ All files converted to .md!")
