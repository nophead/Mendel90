import subprocess

def run(*args):
    print "openscad",
    for arg in args:
        print arg,
    print
    log = open("openscad.log", "w")
    subprocess.call(["openscad"] + list(args), stdout = log, stderr = log)
    log.close()
