//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Wade's motor assembly view
//
// assembly  1141 965 51.27 13.11 -39.31 57.80 2.10 5.40 700
// assembled 1141 965 51.27 13.11 -39.31 57.80 2.10 5.40 500
//
$exploded = 1;

use <../scad/wade.scad>

//view([ 51.27, 13.11, -39.31 ],[ 57.80, 2.10, 5.40 ], 762.08)
rotate([0, 90, -30])
    extruder_motor_assembly();
