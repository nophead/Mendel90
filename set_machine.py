#!/usr/bin/env python

from __future__ import print_function

import sys

def set_machine(machine):
    text = "include <%s_config.scad>\n" % machine;
    f = open("scad/conf/machine.scad","rt")
    line = f.read()
    f.close()
    if line != text:
        f = open("scad/conf/machine.scad","wt")
        f. write(text);
        f.close()

if __name__ == '__main__':
    args = len(sys.argv)
    if args == 2:
       set_machine(sys.argv[1])
    else:
        print("usage: set_machine dibond|mendel|sturdy|huxley|huxley|your_machine")
        sys.exit(1)
