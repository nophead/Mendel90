//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Wade's assembly view
//
$vpt = [-10, 6, 3];
$vpr = [107, 12, 24];
$vpd = 300;
//
// assembly 910 904
//
use <../scad/extruder.scad>
include <../scad/conf/config.scad>

extruder_assembly(show_connector = !exploded, show_drive = false);
