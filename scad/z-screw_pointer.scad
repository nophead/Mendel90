//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Pointers on the Z screws
//
include <conf/config.scad>

wall = 2.4;
tap_rad = (Z_screw_dia == 6) ? M6_tap_radius : ((Z_screw_dia == 5) ? M5_tap_radius : M8_tap_radius);
inner_rad = (tap_rad + Z_screw_dia / 2) / 2; // half depth thread
outer_rad = inner_rad + wall;

function z_screw_pointer_height() = 5;
function z_screw_pointer_radius() = outer_rad;
function z_screw_pointer_length() = z_bar_offset() - Z_bar_dia / 2 - 1;

module z_screw_pointer_stl() {
    height = z_screw_pointer_height();

    pointer =z_screw_pointer_length();

    stl("z_screw_pointer");
    difference() {
        union() {
            linear_extrude(height = wall)
                hull() {
                    circle(r = outer_rad, center = true);
                    translate([pointer - filament_width, 0, 0])
                        square(filament_width * 2, center = true);
                }
            translate([0,0, eta])
                cylinder(r = outer_rad, h = height);
        }
        poly_cylinder(r = inner_rad, h = 2 * height + 1, center = true);
    }
}

z_screw_pointer_stl();
