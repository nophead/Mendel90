//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Wade's motor assembly view
//
// assembly  1141 965 -24 26 13 226 0 108 350
// assembled 1141 965 -24 26 13 226 0 108 250
//
$exploded = 1;

use <../scad/extruder.scad>

rotate([0, 90, -30])
    extruder_motor_assembly();
