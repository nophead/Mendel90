//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// PSU assembly view
//
use <../scad/main.scad>

view([ 117.04, -11.09, 68.2 ],[ 71.1, 0.00, 152.4 ], 1770.35)
group() {

    psu_assembly();
    %frame_stay(false);
    %frame_gantry();
}
