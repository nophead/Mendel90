#!/usr/bin/env python

import sys
import os
import shutil
from stls import stls, bom_to_stls

plate_list = [
    "cal.stl",
    "atx_brackets.stl",
    "bar_clamps.stl",
    "cable_clips.stl",
    "d_motor_brackets.stl",
    "fixing_blocks.stl",
    "ribbon_clamps.stl",
    "small_bits.stl",
    "spool_holder_brackets.stl",
    "wades_extruder.stl",
    "x_carriage_parts.stl",
    "y_bearing_mounts.stl",
    "y_belt_anchors.stl",
    "z_motor_brackets.stl"
]

def plates(machine):
    #
    # Make the target directory
    #
    target_dir = machine + "/stls/printed"
    if os.path.isdir(target_dir):
        shutil.rmtree(target_dir)
    os.makedirs(target_dir)
    #
    # Make the stls in the list
    #
    if machine == "dibond" or machine == "huxley":
        plate_list.remove("cable_clips.stl");
    used = stls(machine, plate_list)
    #
    # Move them to the plates directory
    #
    for file in plate_list:
        shutil.move(machine + "/stls/"+ file, target_dir + "/" + file)
    #
    # Copy all the stls that are not in the plates to the plates directory
    #
    for file in bom_to_stls(machine):
        path = machine + "/stls/"+ file
        if not file in used:
            if os.path.isfile(path):
                shutil.copy(path, target_dir + "/" + file)
            else:
                print "can't find %s to copy" % path

if __name__ == '__main__':
    if len(sys.argv) > 1:
        plates(sys.argv[1])
    else:
        print "usage: plates [mendel|sturdy|your_machine]"
        sys.exit(1)
