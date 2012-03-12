import subprocess
import os

def run(*args):
    if os.name == "nt":
        subprocess.call(["openscad_cl"] + list(args))
    else:
        log = open("openscad.log", "w")
        subprocess.call(["openscad"] + list(args), stdout = log, stderr = log)
        log.close()

