Limitations
-----------
Currently only supports mendel and sturdy machine variants, the huxley version needs more work.

Use
---
To make all the files for a machine run
    make_machine.py machine_name

machine_name can be mendel or sturdy.

To make just the bom, sheets or stls run bom.py, sheets.py or stls.py

To make your own variant copy scad\conf\mendel_config.scad or scad\conf\sturdy_config.scad to yourname_config.scad.

To view the whole machine model open scad\main.scad. It will take several minutes render (about 8 minutes on my machine) but after that you can pan and zoom it at reasonable speed and changes takes less time to render.

To view a sub assembly open the individual scad files. Set the exploded flag in config.scad to make exploded views.
