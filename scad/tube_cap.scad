//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// End caps for the aluminium box tubes used on the dibond version
//
include <conf/config.scad>
include <positions.scad>

wall = 3;

function tube_cap_base_thicnkess() = 3 * layer_height;
function tube_jig_base_thicnkess() = wall;

module tube_jig_stl() {
    stl("tube_jig");
    punch = 3;
    clearance = 0.25;
    h = tube_height(AL_square_tube);
    w = tube_width(AL_square_tube);
    W = w + 2 * wall + clearance;
    base_screw_offset = fixing_block_width() / 2 + base_clearance - AL_tube_inset;
    l = wall + base_screw_offset + 10;

    translate([-wall, - W / 2, 0])
        difference() {
            cube([l, W, h + tube_jig_base_thicnkess()]);
            translate([wall, wall + clearance / 2, tube_jig_base_thicnkess()])
                cube([l, w + clearance, h + tube_jig_base_thicnkess()]);

            translate([wall + base_screw_offset, W / 2, -1])
                poly_cylinder(r = punch / 2, h = h);
        }
}

module tube_cap_stl() {
    stl("tube_cap");
    w = tube_height(AL_square_tube);
    h = tube_width(AL_square_tube);
    t = tube_thickness(AL_square_tube);
    clearance = 0.3;

    base_thickness = tube_cap_base_thicnkess();

    w_outer = w - 1;
    h_outer = h - 1;
    w_inner_base = w - 2 * t;
    w_inner_top  = w_inner_base - clearance;
    h_inner_base = h - 2 * t;
    h_inner_top  = h_inner_base - clearance;

    union() {
        translate([-w_outer / 2, - h_outer / 2, 0])
            cube([w_outer, h_outer, base_thickness]);

        hull() {
            translate([-w_inner_top / 2, - h_inner_top / 2, 0])
                cube([w_inner_top, h_inner_top, 5]);

            translate([-w_inner_base / 2, - h_inner_base / 2, 0])
                cube([w_inner_base, h_inner_base, base_thickness + 1]);
        }
    }
}

tube_cap_stl();
translate([20, 0, 0])
    tube_jig_stl();
