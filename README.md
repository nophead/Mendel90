Standard variants
-----------------
dibond is the version that was sold as a kit with 3mm sheets, 8mm rods and uses nuts and machine screws through the frame.

sturdy is 12mm MDF sheets, 10mm rods and uses wood screws into pilot holes in the frame. It can be built without CNC.

mendel is 6mm acrylic sheets with a 10mm acrylic base, 8mm rods and uses machine screws into tapped holes in the frame.

huxley is a scaled down version of dibond using 6mm rods and NEMA14 motors.

Limitations
-----------
The dibond and sturdy versions are well tested and popular. The acrylic version, called mendel, hasn't been built for a long time and is not recommened.
The Huxley version hasn't been tested in its final form although one prototype has been made of an earlier version and a few snags fixed since.

Use
---
Add the directory of the OpenScad executable to your search path. OpenSCAD-2015.05 or later is required.
To get PDF versions of the sheet drawings add InkScape to your search path.

To make all the files for a machine run
```python
make_machine.py machine_name
```

To make just the bom, sheets or stls run bom.py, sheets.py or stls.py machine\_name.

machine\_name can be dibond, mendel, sturdy or huxley. To make your own variant copy scad\conf\mendel\_config.scad or scad\conf\sturdy\_config.scad to yourname\_config.scad.  Then run `make_machine.py yourname`.

To view the model of the whole machine, open scad\main.scad. It will take several minutes to render (about about 5 minutes on my computer) but after that you can pan and zoom it at reasonable speed and changes takes less time to render.  (Note: main.scad will only render correctly if conf\machine.scad exists, which is created by the make_machine.py script.)

To view a sub-assembly, open the individual scad files. Set the exploded flag in config.scad to make exploded views.

To get blender renders of all the parts put blender in your search path and run `render.py machine_name`.

Credits
-------
Fan model based on [this model](http://www.thingiverse.com/thing:8063) by MiseryBot, CC license.

[Sanguinololu model](http://www.thingiverse.com/thing:18606) by ax\_the\_b, CC license.

Spring taken from openscad example 20

x-end.scad and wade.scad use some elements of the Prusa ones by Josef Prusa, GPL license.

z_couplings originally based on [this model](http://www.thingiverse.com/thing:7153) by Griffin_Nicoll, GPL license.

Bearing holders originally based on [this model](http://www.thingiverse.com/thing:7755) by Jolijar, CC license.

InkCL.py based on [this code](http://kaioa.com/node/42)
