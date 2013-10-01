M83 ; use relative distances for extrusion
G28  ; home
G1 X0 Y98 F9000 ; Go to the middle of the front
G1Z0.05 ; close to the bed
M104 S185 ; set extruder temp 
M190 S70 ; set bed temp & wait
M109 S185 ; wait for extruder temp
G92 E0
G1 X50 E5 F200 ; make a thick line to prime extruder
G1 E-1 F1200
G1Z0.3 ;lift Z 
