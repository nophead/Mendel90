#!/usr/bin/env python

from __future__ import print_function

import os
import sys
import shutil
import openscad


class BOM:
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
            self.assemblies[ass] = BOM()

    def make_name(self, ass):
        if self.count == 1:
            return ass
        return ass.replace("assembly", "assemblies")

    def print_bom(self, breakdown, file = None):
        print("Vitamins:", file=file)
        if breakdown:
            longest = 0
            for ass in self.assemblies:
                name = ass.replace("_assembly","")
                longest = max(longest, len(name))
            for i in range(longest):
                for ass in sorted(self.assemblies):
                    name = ass.replace("_assembly","").replace("_"," ").capitalize()
                    index = i - (longest - len(name))
                    if index < 0:
                        print("  ", end=" ", file=file)
                    else:
                        print(" %s" % name[index], end=" ", file=file)
                print(file=file)

        for part in sorted(self.vitamins):
            if ': ' in part:
                part_no, description = part.split(': ')
            else:
                part_no, description = "", part
            if breakdown:
                for ass in sorted(self.assemblies):
                    bom = self.assemblies[ass]
                    if part in bom.vitamins:
                        file.write("%2d|" % bom.vitamins[part])
                    else:
                        file.write("  |")
            print("%3d" % self.vitamins[part], description, file=file)

        print(file=file)
        print("Printed:", file=file)
        for part in sorted(self.printed):
            if breakdown:
                for ass in sorted(self.assemblies):
                    bom = self.assemblies[ass]
                    if part in bom.printed:
                        file.write("%2d|" % bom.printed[part])
                    else:
                        file.write("  |")
            print("%3d" % self.printed[part], part, file=file)

        print(file=file)
        if self.assemblies:
            print("Sub-assemblies:", file=file)
        for ass in sorted(self.assemblies):
            print("%3d %s" % (self.assemblies[ass].count, self.assemblies[ass].make_name(ass)), file=file)

def boms(machine):
    bom_dir = machine + "/bom"
    if os.path.isdir(bom_dir):
        shutil.rmtree(bom_dir)
    os.makedirs(bom_dir)

    f = open("scad/conf/machine.scad","wt")
    f. write("include <%s_config.scad>\n" % machine);
    f.close()

    openscad.run("-D","$bom=2","-o", "dummy.csg", "scad/bom.scad")
    print("Generating bom ...", end=" ")

    main = BOM()
    stack = []

    for line in open("openscad.log"):
        if line[:7] == 'ECHO: "':
            s = line[7:-2]
            if s[-1] == '/':
                ass = s[:-1]
                if stack:
                    main.assemblies[stack[-1]].add_assembly(ass)    #add to nested BOM
                stack.append(ass)
                main.add_assembly(ass)                              #add to flat BOM
            else:
                if s[0] == '/':
                    if s[1:] != stack[-1]:
                        raise Exception("Mismatched assembly " + s[1:] + str(stack))
                    stack.pop()
                else:
                    main.add_part(s)
                    if stack:
                        main.assemblies[stack[-1]].add_part(s)

    main.print_bom(True, open(bom_dir + "/bom.txt","wt"))

    for ass in sorted(main.assemblies):
        f = open(bom_dir + "/" + ass + ".txt", "wt");
        bom = main.assemblies[ass]
        print(bom.make_name(ass) + ":", file=f)
        bom.print_bom(False, f)
        f.close()

    print(" done")

if __name__ == '__main__':
    if len(sys.argv) > 1:
        boms(sys.argv[1])
    else:
        print("usage: bom [mendel|sturdy|your_machine]")
        sys.exit(1)
