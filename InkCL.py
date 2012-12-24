#!/usr/bin/env python
#from http://kaioa.com/node/42

import os, subprocess, sys

def run(*args):
    print "inkscape",
    for arg in args:
        print arg,
    print
    run = subprocess.Popen(["inkscape"] + list(args) + [" -z"], shell = False, stdout = subprocess.PIPE, stderr = subprocess.PIPE)
    out,err=[e.splitlines() for e in run.communicate()]
    return run.returncode, out, err

if __name__=='__main__':
    r = run(sys.argv[1:])
    if not r[0]==0:
        print 'return code:',r[0]
    for l in r[1]:
        print l
    for l in r[2]:
        print l
