//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
include <conf/config.scad>

module pulley_stl() {
    stl("pulley");
    color([1,0,0])
        translate([-10, -10, 0])
            import("../imported_stls/pulley.stl");
}

module pulley_assembly() {
    color([1,0,0]) render() pulley_stl();
    rotate([90, 0, 0]) {
        translate([0, 4, -5/2 - 6])
            screw(M3_grub_screw, 6);
        translate([0, 4, -6])
            rotate([0,0,30])
                nut(M3_nut);
    }
}

if(1)
    pulley_assembly();
else
    pulley_stl();
