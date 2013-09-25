//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Wade's assembly view
//
// assembly 910 904 61.89 7.66 0.30 13.70 25.90 348.60 555.56
//
use <../scad/wade.scad>
include <../scad/conf/config.scad>

//view([ 61.89, 7.66, 0.30 ], [ 13.70, 25.90, 348.60 ], 555.56)
wades_assembly(show_connector = !exploded, show_drive = false);
