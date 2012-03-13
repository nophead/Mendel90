//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Holds the idler pulley
//
include <conf/config.scad>
use <y-motor-bracket.scad>

slot = 10;
axel_height = y_motor_height() + pulley_inner_radius - ball_bearing_diameter(Y_idler_bearing) / 2;
base_thickness = 5;
wall = default_wall;

clearance = 1;
dia  = washer_diameter(M5_penny_washer) + 2 * clearance;
tab_length = washer_diameter(screw_washer(base_screw)) + 2 * clearance + slot;
length = dia + wall + tab_length;

function y_idler_clearance() = dia / 2 + slot;
function y_idler_offset() = dia / 2 + wall + tab_length;

width = (wall + washer_thickness(M5_penny_washer) + washer_thickness(M4_washer) + ball_bearing_width(Y_idler_bearing)) * 2;
back_width = washer_diameter(screw_washer(base_screw)) + 2 * clearance + 2 * wall;

height = axel_height + dia / 2;

module y_idler_bracket_stl() {
    stl("y_idler_bracket");

    color(y_idler_bracket_color) intersection() {
        difference() {
            rotate([90, 0, 90])
                linear_extrude(height = width, center = true)                                               //side profile
                    hull() {
                        translate([0, axel_height])
                            circle(dia / 2);

                        translate([-dia / 2 , 0])
                            square([length, base_thickness]);                                               // base

                        square([dia / 2 + wall, height]);                                                   // upright
                    }

            translate([0, - dia / 2, height + base_thickness])                                              // cavity for bearing
                rotate([0, 90, 0])
                    rounded_rectangle(size = [height * 2, dia * 2,  width - 2 * wall], r = dia / 2);

            translate([0, dia / 2 + wall + tab_length / 2 + eta, height / 2 + base_thickness + eta])        // cavity for screw slot
                cube([back_width - 2 * wall, tab_length, height], center = true);

            translate([0,  dia / 2 + wall + slot / 2 + washer_diameter(screw_washer(base_screw)) / 2 + clearance , 0])     // screw slot
                rotate([0,0,90])
                    slot(r = screw_clearance_radius(base_screw), l = slot, h = 2 * base_thickness + 1, center = true);

            translate([0, 0, axel_height])                                                                  // hole for axel
                rotate([90, 0, 90])
                    teardrop_plus(r = M4_clearance_radius, h = width + 1, center = true);
        }
        union() { // plan profile
            translate([0, (length - tab_length) / 2 - dia / 2, -1])
                rounded_rectangle([width - eta, length - tab_length - eta, height + 2], r = 2, center = false);

            translate([0, length - (tab_length + 5) / 2 - dia / 2 - eta, -1])
                rounded_rectangle([back_width, tab_length + 5, height + 2], r = 2, center = false);
        }
    }
}


module y_idler_screw_hole()
    translate([0, dia / 2 + wall + tab_length / 2 - slot / 2,0])
        child();


module y_idler_assembly() {
    assembly("y_idler_assembly");

    color(y_idler_bracket_color) render() y_idler_bracket_stl();

    translate([0, 0, axel_height]) rotate([0, -90, 0]) {

        for(side = [-1, 1]) {
            translate([0, 0, (ball_bearing_width(Y_idler_bearing) / 2) * side])
                ball_bearing(BB624);
            translate([0, 0, ball_bearing_width(Y_idler_bearing) * side])
                rotate([0, side * 90 - 90, 0])
                    washer(M4_washer);
            translate([0, 0, (ball_bearing_width(Y_idler_bearing) + washer_thickness(M4_washer)) * side])
                rotate([0, side * 90 - 90, 0])
                    washer(M5_penny_washer);
        }
        translate([0, 0, width / 2])
            screw_and_washer(M4_cap_screw, 40);     // could be 30mm but would be the only one, 40 is used on the idler

        translate([0, 0, -width / 2])
            rotate([180, 0, 0])
                nut_and_washer(M4_nut, true);
    }

    y_idler_screw_hole()
        translate([0, 0, base_thickness])
            base_screw();

    end("y_idler_assembly");
}


if(1)
    y_idler_assembly();
else
    y_idler_bracket_stl();
