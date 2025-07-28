import tkinter as tk
from tkinter import filedialog, messagebox
import os

def split_text_file(file_path, max_chars=30000):
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    parts = [content[i:i + max_chars] for i in range(0, len(content), max_chars)]

    base_name = os.path.splitext(file_path)[0]
    for idx, part in enumerate(parts):
        part_filename = f"{base_name}_part{idx + 1}.txt"
        with open(part_filename, "w", encoding="utf-8") as f_out:
            f_out.write(part)
        print(f"Saved: {part_filename} ({len(part)} characters)")

    messagebox.showinfo("完了", f"{len(parts)}個のファイルに分割しました。")

def select_file():
    file_path = filedialog.askopenfilename(filetypes=[("Text Files", "*.txt")])
    if file_path:
        split_text_file(file_path, max_chars=30000)

# GUI構築
root = tk.Tk()
root.title("テキスト分割アプリ")

frame = tk.Frame(root, padx=20, pady=20)
frame.pack()

label = tk.Label(frame, text="テキストファイルを選んでください（30,000文字で分割）")
label.pack(pady=10)

button = tk.Button(frame, text="ファイルを選択して分割", command=select_file)
button.pack()

root.mainloop()
