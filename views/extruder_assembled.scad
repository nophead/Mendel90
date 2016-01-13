//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Wade's assembly view
//
$vpt = [-21, 23, 11];
$vpr = [55, 0, 26];
$vpd = 380;
//
// view 929 904
//
include <../scad/conf/config.scad>
use <../scad/extruder.scad>

rotate(extruder == Wades ? [-90, 0, 0] : [0, 0, 180])
    extruder_assembly(show_connector = true);
