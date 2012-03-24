import subprocess
import os

version = "unknown"

if not os.name == "nt":
    try:
        log = open("openscad.log", "w")
        subprocess.call(["openscad","--version"],stdout = log)
        log.close()
        version = open("openscad.log", "r").read().split()[2]
    except OSError, e:
        print "OpenSCAD could not be executed"

def run(*args):
    args = list(args)
    if os.name == "nt":
        subprocess.call(["openscad_cl"] + args)
    else:
        if version == "2011.06":
            #-o attempts to output a OFF in this version, so we have to change the switches
            if "-o" in args:
                idx = args.index("-o")
                ext = args[idx+1].split('.')[-1]
                if  ext == "dxf":
                    args[idx] = "-x"
                elif ext == "stl":
                    args[idx] = "-s"

        log = open("openscad.log", "w")
        subprocess.call(["openscad"] + args, stdout = log, stderr = log)
        log.close()

