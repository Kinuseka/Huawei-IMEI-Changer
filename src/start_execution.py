import os
import sys
import subprocess
def resource_path(relative_path):
    """ Get absolute path to resource, works for dev and for PyInstaller """
    try:
        # PyInstaller creates a temp folder and stores path in _MEIPASS
        base_path = sys._MEIPASS
    except Exception:
        base_path = os.path.abspath(".")

    return os.path.join(base_path, relative_path)
if __name__ == "__main__":
    path_file = resource_path("setimei.vbs")
    # path_file = "hide.vbs"
    current_path = resource_path("")
    os.system(f"cd {current_path}")
    print("Do not close this window")
    subprocess.run(f"Wscript {path_file} {current_path}")