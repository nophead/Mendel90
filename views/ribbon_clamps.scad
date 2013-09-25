//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Wade's assembly view
//
// view 1280 922 0.22 34.92 5.12 34.70 0.00 243.60 405
//
use <../scad/ribbon_clamp.scad>
include <../scad/conf/config.scad>

//view([ 0.22, 34.92, 5.12 ], [ 34.70, 0.00, 243.60 ], 405)
group() {
        translate([0,0 ,0])  ribbon_clamp_stl(bed_ways, base_screw, nutty = (cnc_sheets && base_nuts));
        translate([0,13,0])  ribbon_clamp_stl(bed_ways, cap_screw, nutty = true);
        translate([0,25,0])  ribbon_clamp_stl(bed_ways, cap_screw);
        translate([0,38,0])  ribbon_clamp_stl(x_end_ways, frame_screw, nutty = (cnc_sheets && frame_nuts));
        translate([0,51,0])  ribbon_clamp_stl(x_end_ways, M3_cap_screw);

        translate([0,63,0])  ribbon_clamp_stl(extruder_ways, M3_cap_screw, nutty = true, slotted = false);
        translate([0,75,0])  ribbon_clamp_stl(extruder_ways, M3_cap_screw);
}
