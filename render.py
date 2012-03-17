#!/usr/bin/env python

import os
import sys
import shutil
import subprocess

def render(machine):
    stl_dir = machine + os.sep + "stls"
    render_dir = machine + os.sep + "render"

    if os.path.isdir(render_dir):
        shutil.rmtree(render_dir)   #clear out any dross
    os.makedirs(render_dir)
    #
    # List of individual part files
    #
    stls = [i[:-4] for i in os.listdir(stl_dir) if i[-4:] == ".stl"]
    #
    # Add the multipart files
    #
    for i in  os.listdir(stl_dir + os.sep + "printed"):
        if not i[:-4] in stls:
            stls.append("printed" + os.sep + i[:-4])

    for i in stls:
        command = 'blender -b  utils' + os.sep + 'render.blend -P utils' + os.sep + 'viz.py -- ' + \
            stl_dir + os.sep + i + '.stl ' + render_dir + os.sep + i + '.png'
        print(command)
        subprocess.check_output(command.split())

if __name__ == '__main__':
    if len(sys.argv) > 1:
        render(sys.argv[1])
    else:
        print "usage: render [mendel|sturdy|your_machine]"
        sys.exit(1)
