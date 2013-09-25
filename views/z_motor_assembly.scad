//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// The Z motor assembly view
//
// assembly  1057 965 -2.5 10.5 15 55 0 25 556
// assembled 1057 965 10  -6.3 0   59 0 42 556
//
use <../scad/z-motor-bracket.scad>

include <../scad/conf/config.scad>
include <../scad/positions.scad>


z_motor_assembly(gantry_setback, false, false);

$exploded = 1;
