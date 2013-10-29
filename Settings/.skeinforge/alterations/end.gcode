M104 S0 ; turn off extruder
M140 S0 ; bed off
M107 ; carriage fan off
G1 E-1 F1200 ; extra retract
;G1 X-100 Y100 F9000 ; go to back
;M42 P28 S255 ;bed fan on
G1 Z200 X-100 F9000 ; go to top
;G4 P300000
;M42 P28 S0 ;bed fan off
G1 Y-100  ;bed to front
M84     ; disable motors
M0 ; end
