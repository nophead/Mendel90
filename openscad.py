from __future__ import print_function

import subprocess


def run(*args):
    print("openscad", end=" ")
    for arg in args:
        print(arg, end=" ")
    print()
    log = open("openscad.log", "w")
    subprocess.call(["openscad"] + list(args), stdout = log, stderr = log)
    log.close()
