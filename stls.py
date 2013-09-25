#!/usr/bin/env python

import os
import openscad
import shutil
import sys
import c14n_stl

source_dir = "scad"

def bom_to_stls(machine):
    #
    # Make a list of all the stls in the BOM
    #
    stl_files = []
    for line in open(machine + "/bom/bom.txt", "rt").readlines():
        words = line.split()
        if words:
            last_word = words[-1]
            if len(last_word) > 4 and last_word[-4:] == ".stl":
                stl_files.append(last_word)
    return stl_files

def stls(machine, parts = None):
    #
    # Make the target directory
    #
    target_dir = machine + "/stls"
    if os.path.isdir(target_dir):
        if not parts:
            shutil.rmtree(target_dir)   #if making the BOM clear the directory first
            os.makedirs(target_dir)
    else:
        os.makedirs(target_dir)

    #
    # Set the target machine
    #
    f = open("scad/conf/machine.scad","wt")
    f. write("include <%s_config.scad>\n" % machine);
    f.close()

    #
    # Decide which files to make
    #
    if parts:
        targets = list(parts)           #copy the list so we dont modify the list passed in
    else:
        targets = bom_to_stls(machine)
    #
    # Find all the scad files
    #
    used = []
    for filename in os.listdir(source_dir):
        if filename[-5:] == ".scad":
            #
            # find any modules ending in _stl
            #
            for line in open(source_dir + "/" + filename, "r").readlines():
                words = line.split()
                if(len(words) and words[0] == "module"):
                    module = words[1].split('(')[0]
                    stl = module.replace("_stl", ".stl")
                    if stl in targets:
                        #
                        # make a file to use the module
                        #
                        stl_maker_name = source_dir + "/stl.scad"
                        f = open(stl_maker_name, "w")
                        f.write("use <%s>\n" % filename)
                        f.write("%s();\n" % module);
                        f.close()
                        #
                        # Run openscad on the created file
                        #
                        stl_name = target_dir + "/" + module[:-4] + ".stl"
                        openscad.run("-D$bom=1","-o", stl_name, stl_maker_name)
                        c14n_stl.canonicalise(stl_name)
                        targets.remove(stl)
                        #
                        # Add the files on the BOM to the used list for plates.py
                        #
                        for line in open("openscad.log"):
                            if line[:7] == 'ECHO: "' and line[-6:] == '.stl"\n':
                                used.append(line[7:-2])
    #
    # List the ones we didn't find
    #
    for module in targets:
        print "Could not find", module
    return used

if __name__ == '__main__':
    if len(sys.argv) > 1:
        stls(sys.argv[1], sys.argv[2:])
    else:
        print "usage: stls [mendel|sturdy|your_machine] [part.stl ...]"
    sys.exit(1)
