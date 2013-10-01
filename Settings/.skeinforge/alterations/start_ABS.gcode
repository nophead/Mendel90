M83 ; use relative distances for extrusion
G28 ; home axes
G1 X5 Y98 F9000 ; go to front of bed
G1 Z0.05 ; use the bed to block the nozzle to prevent ooze
M190 S110 ; heat the bed part way
M104 S240 ; start the nozzle heating
M190 S130 ; finish heating the bed
M109 S240 ; wait for nozzle to heat
G92 E0    ; zero the extruder
G1 E3 F50 ; make a blob
G1 E-1 F1200 ; retract
G1 X40 F4000 ; wipe along the edge of the bed
G1 Z0.3     ; lift before move to center

