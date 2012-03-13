Limitations
-----------
Currently only supports mendel and sturdy machine varients, the huxley version needs more work.

Use
---
To make all the files for a machine run
    make_machine.py machine_name

To make just the bom, sheets or stls run bom.py, sheets.py or stls.py

machine_name can be mendel or sturdy. To make your own variant copy scad\conf\mendel.scad or scad\conf\sturdy to yourname_config.scad.

To view the whole machine model open scad\main.scad. It will take about 8 miniutes to render but after that you can pan and zoom it
at reasonable speed and changes takes less time to render.

To view a sub assembly open the inididual scad files. Set the exploded flag in config.scad to make exploded views.

Credits
-------
Fan model based on http://www.thingiverse.com/thing:8063 by MiseryBot, CC license.

Sangunino model http://www.thingiverse.com/thing:18606 by ax_the_b, CC license.

Spring taken from openscad example 20

x-end.scad and wade.scad use some elements of the Prusa ones by Josef Prusa, GPL license.

z_couplings orginally based on http://www.thingiverse.com/thing:7153 by Griffin_Nicoll, GPL license.

Bearing holders originally based on http://www.thingiverse.com/thing:7755 by Jolijar, CC license.
