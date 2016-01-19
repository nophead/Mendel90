//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Wade's assembly view
//
// assembly 929 904 -9 39 -19 241 0 38 450
//
include <../scad/conf/config.scad>
use <../scad/extruder.scad>

rotate(extruder == Wades ? [-90, 0, 0] : [0, 180, 0])
    extruder_assembly(show_connector = false);

$exploded = 1;
