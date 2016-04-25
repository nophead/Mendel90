#!/usr/bin/env python

from __future__ import print_function
import sys
import os
import shutil
import filecmp


def prune_dir(dst, src):
    for file in os.listdir(dst):
        dfile = dst + '/' + file
        sfile = src + '/' + file
        if os.path.isdir(dfile):
            prune_dir(dfile, sfile)
        else:
            if not os.path.isfile(sfile) or not filecmp.cmp(dfile, sfile):
                print(dfile)
            else:
                os.remove(dfile)

def prune(variant):
    #
    # Check directories exist
    #
    target_dir = variant
    if not os.path.isdir(target_dir):
        print("directory", target_dir, "does not exist")
        return

    source_dir = variant.split('_')[0]
    if not os.path.isdir(source_dir):
        print("directory", source_dir, "does not exist")
        return

    prune_dir(target_dir, source_dir)

if __name__ == '__main__':
    if len(sys.argv) == 2:
        prune(sys.argv[1])
    else:
        print("usage: remove_identical_files machine_variant")
        sys.exit(1)
