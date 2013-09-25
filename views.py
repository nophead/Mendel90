#!/usr/bin/env python

import os
import sys
import shutil
import openscad



def views(machine):
    scad_dir = "views"
    render_dir = machine + os.sep + "views"

    if not os.path.isdir(render_dir):
        os.makedirs(render_dir)
    #
    # Set the target machine
    #
    f = open("scad/conf/machine.scad","wt")
    f.write("include <%s_config.scad>\n" % machine);
    f.close()
    #
    # List of individual part files
    #
    scads = [i for i in os.listdir(scad_dir) if i[-5:] == ".scad"]

    for scad in scads:
        scad_name = scad_dir + os.sep + scad
        png_name = render_dir + os.sep + scad[:-4] + "png"

        for line in open(scad_name, "r").readlines():
            words = line.split()
            if len(words) > 10 and words[0] == "//":
                cmd = words[1]
                if cmd == "view" or cmd == "assembled" or cmd == "assembly":
                    w = int(words[2]) * 2
                    h = int(words[3]) * 2

                    dx = -float(words[4])
                    dy = -float(words[5])
                    dz = -float(words[6])

                    rx = 360.0 - float(words[7]) + 90
                    ry = 360.0 - float(words[8])
                    rz = 360.0 - float(words[9])

                    d = float(words[10])
                    camera = "%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f" % (dx, dy, dz, rx, ry, rz, d)

                    exploded = "0"
                    if cmd == "assembly":
                        exploded = "1"

                    if cmd == "assembled":
                        png_name = png_name.replace("assembly","assembled")

                    if not os.path.isfile(png_name) or os.path.getmtime(png_name) < os.path.getmtime(scad_name):
                        openscad.run("--projection=p",
                                    ("--imgsize=%d,%d" % (w, h)),
                                     "--camera=" + camera,
                                      "-D$exploded=" + exploded,
                                      "-o", png_name, scad_name)
                        print

if __name__ == '__main__':
    if len(sys.argv) > 1:
        views(sys.argv[1])
    else:
        print "usage: views [mendel|sturdy|your_machine]"
        sys.exit(1)
