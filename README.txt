Limitations
-----------
Currently only supports mendel and sturdy machine variants, the huxley version needs more work.

Use
---
Add the directory of the OpenScad executable to your search path. OpenSCAD-2013.06 or later is required.
To get PDF versions of the sheet drawings add InkScape to your search path.

To make all the files for a machine run
    make_machine.py machine_name

To make just the bom, sheets or stls run bom.py, sheets.py or stls.py machine_name.

machine_name can be mendel or sturdy. To make your own variant copy scad\conf\mendel_config.scad or scad\conf\sturdy_config.scad to yourname_config.scad.  Then run make_machine yourname.

To view the model of the whole machine, open scad\main.scad. It will take several minutes to render (about about 8 minutes on my computer) but after that you can pan and zoom it at reasonable speed and changes takes less time to render.  (Note: main.scad will only render correctly if conf\machine.scad exists, which is created by the make_machine.py script.)

To view a sub-assembly, open the individual scad files. Set the exploded flag in config.scad to make exploded views.

To get blender renders of all the parts put blender in your search path and run render.py machine_name.

Credits
-------
Fan model based on http://www.thingiverse.com/thing:8063 by MiseryBot, CC license.

Sanguinololu model http://www.thingiverse.com/thing:18606 by ax_the_b, CC license.

Spring taken from openscad example 20

x-end.scad and wade.scad use some elements of the Prusa ones by Josef Prusa, GPL license.

z_couplings originally based on http://www.thingiverse.com/thing:7153 by Griffin_Nicoll, GPL license.

Bearing holders originally based on http://www.thingiverse.com/thing:7755 by Jolijar, CC license.

InkCL.py based on code from http://kaioa.com/node/42
