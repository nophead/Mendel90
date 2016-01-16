#!/usr/bin/env python

import sys
from bom import boms
from sheets import sheets
from stls import stls
from plates import plates
from accessories import accessories

def make_machine(machine):
    boms(machine)
    sheets(machine)
    stls(machine)
    accessories(machine)
    plates(machine)

if __name__ == '__main__':
    if len(sys.argv) > 1:
        make_machine(sys.argv[1])
    else:
        print("usage: make_machine dibond|mendel|sturdy|huxley|your_machine")
        sys.exit(1)
