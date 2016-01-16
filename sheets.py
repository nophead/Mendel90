#!/usr/bin/env python

import os
import openscad
import InkCL
import shutil
import sys
from dxf import *
from set_machine import *
from time import *

source_dir = "scad"

def sheets(machine):
    #
    # Make the target directory
    #
    target_dir = machine + "/sheets"
    if os.path.isdir(target_dir):
        shutil.rmtree(target_dir)
        sleep(0.1)
        os.makedirs(target_dir)
    else:
        os.makedirs(target_dir)

    #
    # Set the target machine
    #
    set_machine(machine)

    #
    # Find all the scad files
    #
    for filename in os.listdir(source_dir):
        if filename[-5:] == ".scad":
            #
            # find any modules ending in _dxf
            #
            for line in open(source_dir + "/" + filename, "r").readlines():
                words = line.split()
                if(len(words) and words[0] == "module"):
                    module = words[1].split('(')[0]
                    if module[-4:] == "_dxf":
                        #
                        # make a file to use the module
                        #
                        dxf_maker_name = target_dir + "/" + module + ".scad"
                        f = open(dxf_maker_name, "w")
                        f.write("use <../../%s/%s>\n" % (source_dir, filename))
                        f.write("%s();\n" % module);
                        f.close()
                        #
                        # Run openscad on the created file
                        #
                        base_name = target_dir + "/" + module[:-4]
                        dxf_name = base_name + ".dxf"
                        openscad.run("-o", dxf_name, dxf_maker_name)
                        #
                        # Make SVG drill template
                        #
                        dxf_to_svg(dxf_name)
                        #
                        # Make PDF for printing
                        #
                        InkCL.run("-f", base_name + ".svg", "-A", base_name + ".pdf")
                        os.remove(dxf_maker_name)

if __name__ == '__main__':
    if len(sys.argv) > 1:
        sheets(sys.argv[1])
    else:
        print("usage: sheets dibond|mendel|sturdy|huxley|your_machine")
        sys.exit(1)
