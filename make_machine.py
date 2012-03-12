import sys

from bom import boms
from sheets import sheets
from stls import stls

def make_machine(machine):
    boms(machine)
    sheets(machine)
    stls(machine)

if __name__ == '__main__':
    if len(sys.argv) > 1:
        make_machine(sys.argv[1])
    else:
        print "usage: make_machine [mendel|sturdy|your_machine]"
        sys.exit(1)
