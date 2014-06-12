#!/usr/bin/env python

from __future__ import print_function

import os
import sys
import shutil
import openscad

source_dir = "scad"

def find_scad_file(assembly):
    for filename in os.listdir(source_dir):
        if filename[-5:] == ".scad":
            #
            # look for module which makes the assembly
            #
            for line in open(source_dir + "/" + filename, "r").readlines():
                words = line.split()
                if len(words) and words[0] == "module":
                    module = words[1].split('(')[0]
                    if module == assembly:
                        return filename


    return None

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
                line = ""
                for ass in sorted(self.assemblies):
                    name = ass.replace("_assembly","").replace("_"," ").capitalize()
                    index = i - (longest - len(name))
                    if index < 0:
                        line += "   "
                    else:
                        line += (" %s " % name[index])
                print(line[:-1], file=file)

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

def boms(machine, assembly = None):

    bom_dir = machine + "/bom"
    if assembly:
        bom_dir += "/accessories"
        if not os.path.isdir(bom_dir):
            os.makedirs(bom_dir)
    else:
        assembly = "machine_assembly"
        if os.path.isdir(bom_dir):
            shutil.rmtree(bom_dir)
        os.makedirs(bom_dir)

    f = open("scad/conf/machine.scad","wt")
    f. write("include <%s_config.scad>\n" % machine);
    f.close()
    #
    # Find the scad file that makes the module
    #
    scad_file = find_scad_file(assembly)
    if not scad_file:
        raise Exception("can't find source for " + assembly)
    #
    # make a file to use the module
    #
    bom_maker_name = source_dir + "/bom.scad"
    f = open(bom_maker_name, "w")
    f.write("use <%s>\n" % scad_file)
    f.write("%s();\n" % assembly);
    f.close()
    #
    # Run openscad
    #
    openscad.run("-D","$bom=2","-o", "dummy.csg", bom_maker_name)
    print("Generating bom ...", end=" ")

    main = BOM()
    stack = []

    for line in open("openscad.log"):
        pos = line.find('ECHO: "')
        if pos > -1:
            s = line[pos + 7 : line.rfind('"')]
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

    if assembly == "machine_assembly":
        main.print_bom(True, open(bom_dir + "/bom.txt","wt"))

    for ass in sorted(main.assemblies):
        f = open(bom_dir + "/" + ass + ".txt", "wt");
        bom = main.assemblies[ass]
        print(bom.make_name(ass) + ":", file=f)
        bom.print_bom(False, f)
        f.close()

    print(" done")

if __name__ == '__main__':
    args = len(sys.argv)
    if args > 1:
        if args > 2:
            boms(sys.argv[1], sys.argv[2])
        else:
            boms(sys.argv[1])
    else:
        print("usage: bom mendel|sturdy|your_machine [assembly_name]")
        sys.exit(1)
