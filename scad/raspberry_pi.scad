//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Bracket to mount RPI
//
include <conf/config.scad>
use <pcb_spacer.scad>
include <positions.scad>

overlap = 1.5;

pi_base_width  = pi_width + 2 * pi_clearance + 2 * min_wall;
pi_base_length = pi_length+ 2 * pi_clearance + 2 * min_wall;
rim_width = overlap + pi_clearance + min_wall;

pi_lift = 10;      // space underneath for 12mm screw

standoffs = 4;
pi_base = 2;
nut_depth = nut_thickness(M2p5_nut, true) + 0.5;
rim_height = pi_lift + pi_thickness;
margin = 2;


x_offset = psu_height(psu) - raspberry_pi_width() / 2 - margin;

back_height = controller_z - (psu_z + psu_length(psu) / 2);
screw_z = back_height + controller_hole_inset(controller);
screw_pitch = controller_width(controller) - 2 * controller_hole_inset(controller);
slot_length = 2;

wall = 2.5;

back_width = screw_pitch + 2 * (M3_clearance_radius + wall);

module rpi_position() {
    rpi_x = pi_on_psu() ? psu_x + x_offset           : right_stay_x + sheet_thickness(frame) / 2;
    rpi_y = pi_on_psu() ? psu_y                      : gantry_Y + sheet_thickness(frame) + pi_card_clearance + pi_length / 2;
    rpi_z = pi_on_psu() ? psu_z + psu_length(psu) /2 : fixing_block_height() + pi_base_width / 2;

    translate([rpi_x, rpi_y, rpi_z]) rotate([0, pi_on_psu() ? 0 : 90, 0])
        children();
}

module rpi_bracket_holes() {
    inset = overlap + (washer_diameter(M3_washer) + 1) / 2;

    for(side = [-1,1], end = [-1, 1]) {
        nudge = end > 0 && side < 0;
        translate([side * (pi_width / 2 - inset),
                   end * (pi_length / 2 - inset) - (nudge ? 5 : 0), pi_base])
            children();
    }
}

module rpi_bracket_stl() {
    stl("rpi_bracket");

    difference() {
        union() {
            difference() {
                hull() {
                    translate([0, 0, rim_height / 2])
                        rounded_rectangle([pi_base_width, pi_base_length, rim_height], center = true, r = 2);

                    translate([0, 0, pi_lift + pi_thickness / 2])
                        cube([pi_base_width, pi_base_length, pi_thickness], center = true);
                }

                translate([0, 0, rim_height / 2 + pi_base])
                    cube([pi_base_width - 2 * rim_width, pi_base_length - 2 * rim_width, rim_height], center = true);

                translate([0, 0, rim_height])
                    cube([pi_width + 2 * pi_clearance, pi_length + 2 * pi_clearance, pi_thickness * 2], center = true);

                translate([-pi_width / 2 + card_offset + card_width / 2, -pi_length / 2, pi_lift])
                    cube([card_width + 2, rim_width * 2 + 1, card_thickness * 2], center = true);
            }

            if(pi_on_psu())
                translate([-x_offset, controller_y - psu_y + controller_width(controller) / 2 - back_width / 2, 0]) {
                    cube([x_offset - pi_width / 2 + eta, back_width, 4]);
                    cube([pcb_spacer_height(), back_width, back_height]);

                    for(side = [-1, 1])
                        translate([0, side * screw_pitch / 2 + back_width / 2, screw_z + slot_length / 2])
                            hull() {
                                rotate([0, 90, 0])
                                    cylinder(r = M3_clearance_radius + wall, h = 2 * pcb_spacer_height());

                                translate([0, -(M3_clearance_radius + wall), -screw_z])
                                    cube([2 * pcb_spacer_height(), 2 * (M3_clearance_radius + wall), 1]);
                            }
                }

            pi_holes() union() {
                cylinder(r = corrected_radius(M2p5_clearance_radius) + 2, h = pi_lift);
                cylinder(r = nut_radius(M2p5_nut) + 2, h = nut_depth + layer_height);
            }
        }
        pi_holes()
            nut_trap(M2p5_clearance_radius, nut_radius(M2p5_nut), nut_depth, supported = true);

        if(pi_on_psu())
            for(side = [-1, 1])
                translate([-x_offset, controller_y - psu_y + controller_width(controller) / 2 + side * screw_pitch / 2, screw_z])
                    rotate([90, 0, 90])
                        vertical_tearslot(h = 4 * pcb_spacer_height() + 1, r = M3_clearance_radius, l = slot_length);
        else
            rpi_bracket_holes()
                poly_cylinder(r = M3_clearance_radius, h = 100, center = true);

    }
}

module raspberry_pi_assembly() {
    assembly("raspberry_pi_assembly");

    rpi_position() group() {
        color("lime") render() rpi_bracket_stl();

        explode([80, 0, 0])
            translate([0, 0, pi_lift])
                raspberry_pi();

        pi_holes()
            explode([0, 0, -20])
                translate([0, 0, nut_depth])
                    rotate([180, 0, 0])
                        nut(M2p5_nut, true);
        pi_holes()
            explode([0, 0, 30])
                translate([0, 0, pi_lift + pi_thickness])
                    screw_and_washer(M2p5_pan_screw, 12);

        if(!pi_on_psu())
            rpi_bracket_holes() group() {
                screw_and_washer(M3_cap_screw,
                    screw_longer_than(2 * washer_thickness(M3_washer) + pi_base + sheet_thickness(frame) + nut_thickness(M3_nut,true)));

                translate([0, 0, -pi_base - sheet_thickness(frame)])
                    rotate([180, 0, 0])
                        nut_and_washer(M3_nut, true);
            }

    }

    end("raspberry_pi_assembly");
}

if(1)
    raspberry_pi_assembly();
else
    rpi_bracket_stl();
