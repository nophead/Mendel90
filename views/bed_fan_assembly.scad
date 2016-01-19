//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Bed fan assembly view
//
$vpt = [-99, 147, 85];
$vpr = [63, 0, 215];
$vpd = 115;
//
// assembly 958 958
//
include <../scad/conf/config.scad>
include <../scad/positions.scad>

use <../scad/main.scad>

translate([-left_stay_x, -fan_y, -fan_z])
    bed_fan_assembly(show_fan = true);

$exploded = 1;
