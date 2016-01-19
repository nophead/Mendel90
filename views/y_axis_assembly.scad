//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// The Y carriage assembly view
//
// view 1057 846 -28.79 -4.25 11.88 57.10 0.00 14.50 800
//
use <../scad/main.scad>

y_axis_assembly(show_bed = false, show_heatshield = false);
z_axis_assembly();
bed_fan_assembly();
frame_assembly();
