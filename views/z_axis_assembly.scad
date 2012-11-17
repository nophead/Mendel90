//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// The Z axis assembly view
//
use <../scad/main.scad>

view([ -43.95, 51.01, 143.73 ], [ 73.20, 0.00, 39.70 ], 2998.11) group() {
    z_axis_assembly();
    bed_fan_assembly();
    frame_assembly();
}
