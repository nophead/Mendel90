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

slot_length  = 10;

slot = base_nut_traps ? 0 : slot_length;
axel_height = y_motor_height() + pulley_inner_radius - ball_bearing_diameter(Y_idler_bearing) / 2;
base_thickness = part_base_thickness + (base_nut_traps ? nut_trap_depth(base_nut) : 0);
wall = default_wall;

clearance = 1;
dia  = washer_diameter(M5_penny_washer) + 2 * clearance;
tab_length = washer_diameter(base_washer) + 2 * clearance + slot;
length = dia + wall + tab_length;

function y_idler_travel() = slot_length;
function y_idler_clearance() = dia / 2 + slot_length / 2;
function y_idler_offset() = dia / 2 + wall + tab_length;

width = (wall + washer_thickness(M5_penny_washer) + washer_thickness(M4_washer) + ball_bearing_width(Y_idler_bearing)) * 2;
back_width = washer_diameter(base_washer) + 2 * clearance + 2 * wall;

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

            translate([0, - dia / 2, height + part_base_thickness])                                        // cavity for bearing
                rotate([0, 90, 0])
                    rounded_rectangle(size = [height * 2, dia * 2,  width - 2 * wall], r = dia / 2);

            translate([0, dia / 2 + wall + tab_length / 2 + eta, height / 2 + base_thickness + eta])        // cavity for screw slot
                cube([back_width - 2 * wall, tab_length, height], center = true);

            if(base_nut_traps)
                y_idler_screw_hole_position()
                    translate([0, 0, base_thickness])
                        nut_trap(screw_clearance_radius(base_screw), nut_radius(base_nut), base_thickness - part_base_thickness);

            else
                translate([0,  dia / 2 + wall + slot / 2 + washer_diameter(base_washer) / 2 + clearance , 0])     // screw slot
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

nut_offset = base_nut_traps ? -tab_length / 2 + nut_radius(base_nut) + 0.5 : 0;

module y_idler_screw_hole_position()
    translate([0, dia / 2 + wall + tab_length / 2 + nut_offset,0])
        child();

module y_idler_screw_hole()
    y_idler_screw_hole_position()
        if(base_nut_traps)
            //translate([0, -slot_length / 2, 0])
                rotate([0, 0, 90])
                    slot(h = 100, l = slot_length, r = screw_clearance_radius(base_screw), center = true);
        else
            base_screw_hole();

module y_idler_assembly() {
    assembly("y_idler_assembly");

    color(y_idler_bracket_color) render() y_idler_bracket_stl();

    translate([0, 0, axel_height]) rotate([0, -90, 0]) {

        explode([20, -20, 0])
            for(side = [-1, 1]) {
                translate([0, 0, (ball_bearing_width(Y_idler_bearing) / 2 + exploded) * side])
                    ball_bearing(BB624);
                translate([0, 0, (ball_bearing_width(Y_idler_bearing) + exploded * 4) * side])
                    rotate([0, side * 90 - 90, 0])
                        washer(M4_washer);
                translate([0, 0, (ball_bearing_width(Y_idler_bearing) + washer_thickness(M4_washer) + exploded * 6) * side])
                    rotate([0, side * 90 - 90, 0])
                        washer(M5_penny_washer);
            }
        translate([0, 0, width / 2])
            screw_and_washer(M4_cap_screw, 30);

        translate([0, 0, -width / 2])
            rotate([180, 0, 0])
                nut_and_washer(M4_nut, true);
    }

    y_idler_screw_hole_position()
        translate([0, 0, part_base_thickness])
            base_screw(part_base_thickness);

    end("y_idler_assembly");
}


if(1)
    y_idler_assembly();
else
    y_idler_bracket_stl();
