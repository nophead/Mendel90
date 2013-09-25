//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// The x axis assembly view
//
// view 929 904 50.47 49.13 146.29 47.30 0.00 312.90 1900
//
use <../scad/main.scad>

//view([ 50.47, 49.13, 146.29 ], [ 47.30, 0.00, 312.90 ], 1770.35)
group(){
    x_axis_assembly(true);

    z_axis_assembly();
}
