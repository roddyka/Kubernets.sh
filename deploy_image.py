import os
import subprocess
import tkinter as tk
from tkinter import filedialog, messagebox, simpledialog

def save_docker_image():
    # Get list of Docker images
    images = subprocess.getoutput("docker images --format '{{.Repository}}:{{.Tag}}'").splitlines()
    if not images:
        messagebox.showinfo("Save Docker Image", "No Docker images found.")
        return

    # Image selection window
    def confirm_selection():
        selected_image = var.get()
        if not selected_image:
            messagebox.showerror("Error", "No image selected.")
            return
        select_window.destroy()
        save_path = filedialog.askdirectory(title="Select the directory to save the image")
        if not save_path:
            messagebox.showerror("Error", "No directory selected.")
            return

        tar_path = os.path.join(save_path, f"{selected_image.replace(':', '_')}.tar")
        subprocess.run(f"docker save {selected_image} -o {tar_path}", shell=True)
        messagebox.showinfo("Success", f"Image saved at: {tar_path}")

    # Create selection window
    select_window = tk.Toplevel(root)
    select_window.title("Select Docker Image")
    select_window.geometry("500x400")

    # Add title
    title_label = tk.Label(select_window, text="Select a Docker image to save:", font=("Arial", 14, "bold"))
    title_label.pack(pady=10)

    # Variable to store selection
    var = tk.StringVar()

    # List images with radio buttons
    frame = tk.Frame(select_window)
    frame.pack(fill="both", expand=True, padx=10, pady=10)
    for image in images:
        tk.Radiobutton(frame, text=image, variable=var, value=image, font=("Arial", 12)).pack(anchor="w", pady=2)

    # Action buttons
    button_frame = tk.Frame(select_window)
    button_frame.pack(pady=10)
    tk.Button(button_frame, text="Confirm Selection", command=confirm_selection, width=20, bg="lightblue").pack(side="left", padx=10)
    tk.Button(button_frame, text="Cancel", command=select_window.destroy, width=20, bg="lightcoral").pack(side="right", padx=10)

def send_docker_image():
    tar_file = filedialog.askopenfilename(title="Select the tar file", filetypes=[("Tar Files", "*.tar")])
    if not tar_file:
        messagebox.showerror("Error", "No tar file selected.")
        return

    servers = []
    while True:
        server = simpledialog.askstring("Send Image", "Enter the server name or IP (leave empty to finish):")
        if not server:
            break
        servers.append(server)

    if not servers:
        messagebox.showerror("Error", "No servers added.")
        return

    for server in servers:
        try:
            subprocess.run(f"scp {tar_file} {server}:~/", shell=True, check=True)
            messagebox.showinfo("Success", f"Image sent to {server}.")
        except subprocess.CalledProcessError:
            messagebox.showerror("Error", f"Failed to send the image to {server}.")

# def import_docker_image():
#     tar_file = filedialog.askopenfilename(title="Select the tar file", filetypes=[("Tar Files", "*.tar")])
#     if not tar_file:
#         messagebox.showerror("Error", "No tar file selected.")
#         return

#     try:
#         subprocess.run(f"docker load -i {tar_file}", shell=True, check=True)
#         messagebox.showinfo("Success", "Image imported successfully.")
#     except subprocess.CalledProcessError:
#         messagebox.showerror("Error", "Failed to import the image.")
def import_docker_image():
    # Solicitar os endereços IP dos servidores
    servers = []
    while True:
        server = simpledialog.askstring("Import Docker Image", "Enter the server IP address (leave empty to finish):")
        if not server:
            break
        servers.append(server)

    if not servers:
        messagebox.showerror("Error", "No servers added.")
        return

    # Função para procurar arquivos .tar em cada servidor
    def search_tar_files(server):
        try:
            result = subprocess.check_output(f"ssh {server} 'find ~ -name \"*.tar\"'", shell=True)
            tar_files = result.decode('utf-8').splitlines()
            return tar_files
        except subprocess.CalledProcessError:
            messagebox.showerror("Error", f"Failed to search for tar files on {server}.")
            return []

    # Função de confirmação de seleção do arquivo
    def confirm_selection(selected_file, server):
        if not selected_file:
            messagebox.showerror("Error", "No tar file selected.")
            return

        # Importar o arquivo Docker
        try:
            subprocess.run(f"sudo ctr -n=k8s.io images import {selected_file}", shell=True, check=True)
            messagebox.showinfo("Success", f"Image imported successfully from {server}.")
        except subprocess.CalledProcessError:
            messagebox.showerror("Error", f"Failed to import the image from {server}.")

    # Iterar sobre os servidores
    for server in servers:
        tar_files = search_tar_files(server)
        
        if tar_files:
            # Janela para seleção do arquivo
            select_window = tk.Toplevel(root)
            select_window.title(f"Select Docker Image from {server}")
            select_window.geometry("500x400")

            title_label = tk.Label(select_window, text=f"Select a tar file from {server}:", font=("Arial", 14, "bold"))
            title_label.pack(pady=10)

            var = tk.StringVar()

            # Adicionar arquivos .tar com radio buttons
            frame = tk.Frame(select_window)
            frame.pack(fill="both", expand=True, padx=10, pady=10)
            for file in tar_files:
                tk.Radiobutton(frame, text=file, variable=var, value=file, font=("Arial", 12)).pack(anchor="w", pady=2)

            # Botões de ação
            button_frame = tk.Frame(select_window)
            button_frame.pack(pady=10)
            tk.Button(button_frame, text="Confirm Selection", command=lambda: confirm_selection(var.get(), server), width=20, bg="lightblue").pack(side="left", padx=10)
            tk.Button(button_frame, text="Cancel", command=select_window.destroy, width=20, bg="lightcoral").pack(side="right", padx=10)

        else:
            messagebox.showinfo("No Files Found", f"No tar files found on {server}.")


def show_how_to_use():
    instructions = (
        "HOW TO USE:\n\n"
        "1. Save Docker Image:\n"
        "   - Select a Docker image from the list.\n"
        "   - Choose a directory to save the image as a tar file.\n\n"
        "2. Send Docker Image:\n"
        "   - Choose a tar file to send.\n"
        "   - Add server names or IP addresses to send the file to.\n\n"
        "3. Import Docker Image:\n"
        "   - Choose a tar file to import into Docker.\n\n"
        "Use the buttons on the main menu to perform the desired actions."
    )
    messagebox.showinfo("How to Use", instructions)

# Main interface
def main():
    global root
    root = tk.Tk()
    root.title("Docker Image Manager")
    root.geometry("400x350")

    tk.Label(root, text="Docker Image Manager", font=("Arial", 16, "bold")).pack(pady=10)
    tk.Button(root, text="Save Docker Image", command=save_docker_image, width=30, bg="lightgreen").pack(pady=5)
    tk.Button(root, text="Send Docker Image", command=send_docker_image, width=30, bg="lightblue").pack(pady=5)
    # tk.Button(root, text="Import Docker Image", command=import_docker_image, width=30, bg="lightyellow").pack(pady=5)
    tk.Button(root, text="How to Use", command=show_how_to_use, width=30, bg="lightgrey").pack(pady=5)
    tk.Button(root, text="Exit", command=root.quit, width=30, bg="lightcoral").pack(pady=5)

    root.mainloop()

if __name__ == "__main__":
    main()
