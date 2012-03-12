import os
import subprocess
import shutil
import sys

source_dir = "scad"

def stls(machine):
    #
    # Make the target directory
    #
    target_dir = machine + "/stls"
    if os.path.isdir(target_dir):
        shutil.rmtree(target_dir)
    os.makedirs(target_dir)

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
    for line in open(machine + "/bom/bom.txt", "rt").readlines():
        words = line.split()
        if words:
            last_word = words[-1]
            if len(last_word) > 4 and last_word[-4:] == ".stl":
                targets.append(last_word.replace(".stl", "_stl"))


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
                        subprocess.call(["openscad", "-o", stl_name, stl_maker_name])
                        targets.remove(module)

    #
    # List the ones we didn't find
    #
    for module in targets:
        print "Could not find", module

if __name__ == '__main__':
    if len(sys.argv) > 1:
        stls(sys.argv[1])
    else:
        print "usage: stls [mendel|sturdy|your_machine]"
    sys.exit(1)
