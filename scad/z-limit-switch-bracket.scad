//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Adjustable bottom limit switch
//
include <conf/config.scad>
include <positions.scad>

wall = 2;
thickness = 5;
adjustment = 20;
down_adjustment = 10;
hinge_length = 2;
hinge_post = 4;
switch_boss = 7;
washers = 2;

switch_y = max(14 - microswitch_thickness() / 2, gantry_setback - x_bar_spacing() / 2);

switch_mount_height = switch_y - microswitch_thickness() / 2;

hinge_height = thickness + washer_diameter(M3_washer) + 2;

centre = max(washer_diameter(M3_washer), 2 * (nut_radius(M3_nut) + wall));
screw_spacing = adjustment + centre + washer_diameter(frame_washer) + 2;
hinge_thickness = 2 * filament_width + eta;

leg_width = 1 + washer_diameter(frame_washer);
leg_length = adjustment + screw_spacing + leg_width + hinge_post;

lever_width = 4;
lever_length = leg_length / 2 + centre / 2 + hinge_post / 2;


bottom_z = microswitch_hole_y_offset() - switch_boss / 2;

slot_x = -x_end_bar_length() + z_bar_offset() -lever_width - hinge_length - leg_width / 2 -base_clearance;
screw_x = slot_x + leg_width / 2 + hinge_length + lever_width;
screw_y = hinge_height - washer_diameter(M3_washer) / 2 - 2;
screw_z = bottom_z + leg_length / 2 + hinge_post / 2;
center_thickness = leg_width - washer_thickness(M3_washer) - nut_thickness(M3_nut, true);

module z_limit_screw_positions() {
    for(z = [0, screw_spacing])
        translate([slot_x, -thickness, bottom_z  + hinge_post + leg_width / 2 + adjustment - down_adjustment + z])
            rotate([90, 0, 0])
                child();
}


module z_limit_switch_bracket_stl() {
    stl("z_limit_switch_bracket");
    difference() {
        union() {
            //
            // Boss for switch screws
            //
            translate([0, 0, -microswitch_thickness() / 2])
                hull() {
                    microswitch_hole_positions()
                        cylinder(h = switch_mount_height, r = switch_boss / 2);
                    translate([slot_x + leg_width / 2 + hinge_length, microswitch_hole_y_offset() - switch_boss / 2, microswitch_thickness() / 2])
                        cube([1, switch_boss, switch_mount_height]);
                 }
            //
            // Screw slot
            //
            linear_extrude(height = thickness, convexity = 5) {
                difference() {
                    hull() {
                        translate([slot_x, bottom_z + leg_length - leg_width / 2])
                            circle(r = leg_width / 2, center = true);

                        translate([slot_x - leg_width / 2, bottom_z])
                            square([leg_width, hinge_post]);
                    }
                    hull()
                        for(z = [bottom_z + screw_spacing, bottom_z + screw_spacing + adjustment])
                            translate([slot_x, z + hinge_post + leg_width / 2])
                                circle(r = screw_radius(frame_screw), center = true);
                    hull()
                        for(z = [bottom_z, bottom_z + adjustment])
                            translate([slot_x, z + hinge_post + leg_width / 2])
                                circle(r = screw_radius(frame_screw), center = true);
                }
            }
            //
            // Hinge
            //
            translate([slot_x, bottom_z + hinge_post / 2,  hinge_height / 2])
                cube([leg_width, hinge_post, hinge_height], center = true);

            translate([slot_x + hinge_length / 2, bottom_z + hinge_thickness / 2,  hinge_height / 2])
                cube([leg_width + hinge_length + eta, hinge_thickness, hinge_height], center = true);
            //
            // Lever
            //
            translate([slot_x + leg_width / 2 + hinge_length, bottom_z, 0])
                cube([lever_width, lever_length, hinge_height]);
            //
            // Adjuster screw bracket
            //
            translate([slot_x + leg_width / 2 -center_thickness / 2, screw_z,  hinge_height / 2])
                cube([center_thickness, centre, hinge_height], center = true);

        }
        translate([slot_x - leg_width / 2 - eta, screw_z, screw_y])
            rotate([0, 90, 0])
                cylinder(r = screw_y - 3, h = leg_width - center_thickness);

        translate([screw_x, screw_z, screw_y])
            rotate([90, 0, 90])
                nut_trap(M3_clearance_radius, M3_nut_radius, screw_head_height(M3_hex_screw), true);

        microswitch_hole_positions()
            poly_cylinder(h = 100, r = No2_pilot_radius, center = true);
    }
}

module z_limit_switch_assembly() {
    assembly("z_limit_switch_assembly");
    pos = 0;
    screw_length = 16;
    washer_thickness = hinge_length / washers;

    translate([0, 0, pos]) {
        rotate([90, 0, 0])
            color(z_limit_switch_bracket_color) render()
                z_limit_switch_bracket_stl();

        translate([screw_x - screw_head_height(M3_hex_screw), -screw_y, screw_z])
            rotate([0, 90, 0])
                screw(M3_hex_screw, 16);

        for(i = [0 : washers - 1])
            translate([slot_x + leg_width / 2 + i * washer_thickness, -screw_y, screw_z])
                explode([i * 1, 0, 15], [washer_thickness / 2, 0, - washer_diameter(M3_rubber_washer) / 2])
                    rotate([0, 90, 0])
                        scale([1, 1, washer_thickness / washer_thickness(M3_rubber_washer)])    // squash it
                            washer(M3_rubber_washer);

        translate([slot_x + leg_width / 2 - center_thickness, -screw_y, screw_z])
            rotate([0, -90, 0])
                nut_and_washer(M3_nut, true);

        translate([0, -switch_y, 0])
            rotate([90, 0, 0]) {
                microswitch();
                microswitch_hole_positions()
                    screw_and_washer(No2_screw, 13);

            }
    }

    z_limit_screw_positions()
        frame_screw(thickness);
    end("z_limit_switch_assembly");
}

if(1)
    z_limit_switch_assembly();
else
    z_limit_switch_bracket_stl();
