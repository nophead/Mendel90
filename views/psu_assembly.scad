//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// PSU assembly view
//
// assembly 978 793 117 31 34 53 0 137 850
//
use <../scad/main.scad>

include <../scad/conf/config.scad>

psu_assembly();
%color([0.5,0.5,0.5,0.25]) {
    frame_stay(false);
    frame_gantry();
}

$exploded = 1;
