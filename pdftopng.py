import os
from pathlib import Path
from PIL import Image
import fitz  # PyMuPDF
import tkinter as tk
from tkinter import filedialog
import io

def compress_image_to_target_size(img, out_path, target_size=1_000_000, min_quality=10):
    """Compress and save image as JPEG, reducing quality until under target_size bytes."""
    quality = 95
    step = 5
    img = img.convert("RGB")
    while quality >= min_quality:
        buffer = io.BytesIO()
        img.save(buffer, format="JPEG", quality=quality, optimize=True)
        size = buffer.tell()
        if size <= target_size:
            with open(out_path, "wb") as f:
                f.write(buffer.getvalue())
            return
        quality -= step
    # If can't reach target size, save with lowest quality
    img.save(out_path, format="JPEG", quality=min_quality, optimize=True)

def pdfs_to_jpgs(folder):
    folder = Path(folder)
    pdf_files = list(folder.glob("*.pdf"))
    if not pdf_files:
        print("No PDF files found.")
        return

    for pdf_path in pdf_files:
        print(f"Converting: {pdf_path.name}")
        doc = fitz.open(str(pdf_path))
        for page_num in range(len(doc)):
            page = doc.load_page(page_num)
            pix = page.get_pixmap()
            out_name = pdf_path.with_suffix('').name + f"_page_{page_num+1}.jpg"
            out_path = folder / out_name
            img = Image.frombytes("RGB", [pix.width, pix.height], pix.samples)
            compress_image_to_target_size(img, out_path)
            print(f"Saved: {out_path} (<=1MB)")
        doc.close()

if __name__ == "__main__":
    root = tk.Tk()
    root.withdraw()
    selected_folder = filedialog.askdirectory(title="Select folder with PDFs")
    if selected_folder:
        pdfs_to_jpgs(selected_folder)
    else:
        print("No folder selected.")