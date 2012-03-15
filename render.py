import os
import sys
import shutil
import openscad

class RENDER:
    def __init__(self):
        self.count = 1
        self.vitamins = {}
        self.printed = {}
        self.assemblies = {}

    def add_part(self, s):
        if s[-4:] == ".stl":
            parts = self.printed
        else:
            parts = self.vitamins
        if s in parts:
            parts[s] += 1
        else:
            parts[s] = 1

    def add_assembly(self, ass):
        if ass in self.assemblies:
            self.assemblies[ass].count += 1
        else:
            self.assemblies[ass] = RENDER()

def render(machine):
    bom_dir = machine + "/render"

if __name__ == '__main__':
    if len(sys.argv) > 1:
        render(sys.argv[1])
    else:
        print "usage: bom [mendel|sturdy|your_machine]"
        sys.exit(1)
