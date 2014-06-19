#!/usr/bin/env python

from __future__ import print_function

import sys
import bom
import stls
import shutil
import os

def accessories(machine, assembly = None):
    assemblies = [
        "raspberry_pi_assembly",
        "raspberry_pi_camera_assembly",
        "light_strip_assembly",
        "z_limit_switch_assembly"
    ]
    #
    # Make the target directory
    #
    target_dir = machine + "/stls/accessories"
    if os.path.isdir(target_dir):
        if not assembly:
            shutil.rmtree(target_dir)   #if making all of them clear the directory first
            os.makedirs(target_dir)
    else:
        os.makedirs(target_dir)


    if assembly:
        assemblies = [ assembly ]

    for assembly in assemblies:
        print(assembly)
        bom.boms(machine, assembly)
        stl_list = stls.bom_to_stls(machine, assembly)
        stls.stls(machine, stl_list)
        #
        # Move all the stls that are not in the plates to the plates directory
        #
        for file in stl_list:
            src = machine + "/stls/"+ file
            if os.path.isfile(src):
                shutil.move(src, target_dir + "/" + file)
            else:
                print("can't find %s to move" % src)

if __name__ == '__main__':
    args = len(sys.argv)
    if args > 1:
        if args > 2:
            accessories(sys.argv[1], sys.argv[2])
        else:
            accessories(sys.argv[1])
    else:
        print("usage: accessories mendel|sturdy|your_machine [assembly_name]")
        sys.exit(1)
