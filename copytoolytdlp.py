import tkinter as tk
import pyperclip

def generate_command():
    url = url_entry.get().strip()
    time_range = time_entry.get().strip()
    if url and time_range:
        result = f'yt-dlp {url} -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" --download-sections "*{time_range}"'
        result_var.set(result)

def copy_to_clipboard():
    result = result_var.get()
    if result:
        pyperclip.copy(result)

# ウィンドウ設定
root = tk.Tk()
root.title("URL + 時間範囲 生成ツール")
root.geometry("500x200")

# 入力フォーム
tk.Label(root, text="URL:").pack()
url_entry = tk.Entry(root, width=60)
url_entry.pack()

tk.Label(root, text="時間範囲（例: 12:00-13:00）:").pack()
time_entry = tk.Entry(root, width=60)
time_entry.pack()

# 出力結果表示
result_var = tk.StringVar()
tk.Label(root, text="生成されたコマンド:").pack()
result_label = tk.Entry(root, textvariable=result_var, width=60)
result_label.pack()

# ボタン
tk.Button(root, text="生成", command=generate_command).pack(pady=5)
tk.Button(root, text="コピー", command=copy_to_clipboard).pack()

root.mainloop()
