import os
import openscad
import shutil
import sys

source_dir = "scad"

def stls(machine, parts = None):
    #
    # Set target directory name
    #
    target_dir = machine + "/stls"

    #
    # Set the target machine
    #
    f = open("scad/conf/machine.scad","wt")
    f. write("include <%s_config.scad>\n" % machine);
    f.close()

    #
    # Make a list of all the stls in the BOM
    #
    targets = []
    if not parts:
        #
        # clean target directory for full rebuild
        #
        if os.path.isdir(target_dir):
            shutil.rmtree(target_dir)

        for line in open(machine + "/bom/bom.txt", "rt").readlines():
            words = line.split()
            if words:
                last_word = words[-1]
                if len(last_word) > 4 and last_word[-4:] == ".stl":
                    targets.append(last_word.replace(".stl", "_stl"))
    else:
        for part in parts:
            targets.append(part.replace(".stl", "_stl"))

    #
    # make target directory if need
    #

    if not os.path.isdir(target_dir):
        os.makedirs(target_dir)

    #
    # Find all the scad files
    #
    for filename in os.listdir(source_dir):
        if filename[-5:] == ".scad":
            #
            # find any modules ending in _stl
            #
            for line in open(source_dir + "/" + filename, "r").readlines():
                words = line.split()
                if(len(words) and words[0] == "module"):
                    module = words[1].split('(')[0]
                    if module in targets:
                        #
                        # make a file to use the module
                        #
                        stl_maker_name = source_dir + "/stl.scad"
                        f = open(stl_maker_name, "w")
                        f.write("use <%s/%s>\n" % (source_dir, filename))
                        f.write("%s();\n" % module);
                        f.close()
                        #
                        # Run openscad on the created file
                        #
                        stl_name = target_dir + "/" + module[:-4] + ".stl"
                        openscad.run("-o", stl_name, stl_maker_name)
                        targets.remove(module)

    #
    # List the ones we didn't find
    #
    for module in targets:
        print "Could not find", module

if __name__ == '__main__':
    if len(sys.argv) > 1:
        stls(sys.argv[1], sys.argv[2:])
    else:
        print "usage: stls [mendel|sturdy|your_machine] [part.stl ...]"
    sys.exit(1)
