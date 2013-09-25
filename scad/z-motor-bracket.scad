//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Fastens the Z motor to the gantry
//
include <conf/config.scad>
include <positions.scad>
use <z-coupling.scad>

corner_rad = 5;
length = ceil(NEMA_width(Z_motor));
thickness = 4;
back_thickness = part_base_thickness + (frame_nut_traps ? nut_trap_depth(frame_nut) : 0);
back_height = 24;
big_hole = NEMA_big_hole(Z_motor);
clamp_height = washer_diameter(washer) + 3;
clamp_thickness = bar_clamp_band;
clamp_screw_clearance = 2;
clamp_length = Z_bar_dia / 2 + bar_clamp_tab - 2;
gap = 1.5;

clamp_width = Z_bar_dia + 2 * clamp_thickness;

clamp_x = z_bar_offset() + clamp_length - bar_clamp_tab / 2;

function z_motor_bracket_height() = back_height;

module z_motor_bracket(y_offset, rhs) {
    width = y_offset + length / 2;
    cutout = y_offset - length / 2 - part_base_thickness;

    stl(rhs? "z_motor_bracket_rhs" : "z_motor_bracket_lhs");
        color(z_motor_bracket_color) {
            difference() {
                union() {
                    //
                    // main body
                    //
                    translate([0, width / 2 - length / 2, back_height / 2])
                        difference() {
                            cube([length, width, back_height], center = true);
                            translate([0, -back_thickness, thickness])
                                cube([length + 1, width, back_height], center = true);
                        }
                    //
                    // Bracing webs
                    //
                    for(x = [length / 2 - 2 * z_slot_inset - thickness / 2, -(length / 2 - 2 * z_slot_inset - thickness / 2)])
                        translate([x, y_offset - back_thickness + eta, thickness - eta])
                            rotate([90, 0, -90])
                                right_triangle(width = y_offset - back_thickness - big_hole, height = back_height - thickness, h = thickness);
                    //
                    // bar clamp
                    //
                    translate([z_bar_offset() + clamp_length / 2 - eta, 0, clamp_height / 2 + eta])
                        cube([clamp_length, clamp_width, clamp_height], center = true);
                    translate([z_bar_offset(), 0, clamp_height / 2 + eta])
                        cylinder(h = clamp_height, r = Z_bar_dia/2 + clamp_thickness, center = true);
                }
                //
                // front corners rounded
                //
                translate([-length / 2, - length / 2, thickness / 2])
                    fillet(r = corner_rad, h = thickness + 1);
                translate([ length / 2, - length / 2, thickness / 2])
                    rotate([0,0, 90])
                        fillet(r = corner_rad, h = thickness + 1);
                //
                // Cut out between webs
                //
                translate([0, length / 2 + cutout / 2 - eta, 0])
                    rounded_rectangle([length - 4 * z_slot_inset - 2 * thickness, cutout, back_height * 2 + 1], r = corner_rad / 2, center = true);
                //
                // motor holes
                //
                poly_cylinder(r = big_hole, h = thickness * 2 + 1, center = true);                   // hole for stepper locating boss

                for(x = NEMA_holes(Z_motor))                                                         // motor screw holes
                    for(y = NEMA_holes(Z_motor))
                        translate([x,y,0])
                            poly_cylinder(r = M3_clearance_radius, h = 2 * thickness + 1, center = true);
                //
                // bar clamp
                //
                translate([z_bar_offset() + clamp_length / 2, 0, 0])                            // clamp slot
                    cube([clamp_length, gap,  clamp_height * 2 + 1], center = true);

                translate([clamp_x, Z_bar_dia / 2 + clamp_thickness, clamp_height / 2])
                    rotate([90, 0, 0])
                        nut_trap(screw_clearance_radius, nut_radius, nut_trap_depth, horizontal = true);  // clamp screw

                translate([z_bar_offset(), 0,  0])
                    poly_cylinder(r = Z_bar_dia / 2, h = clamp_height * 2 + 1, center = true);       // hole for z rod

                //
                // screw slots in the back
                //
                for(side = [-1, 1])
                    translate([side * (length / 2 - z_slot_inset + z_nut_offset), width - length / 2 - back_thickness,  back_height / 2 + thickness / 2])
                        rotate([90, 0, 0])
                            if(frame_nut_traps)
                                nut_trap(screw_clearance_radius(frame_screw), nut_radius(frame_nut), back_thickness - part_base_thickness, true);
                            else
                                vertical_tearslot(h = back_thickness * 2 + 1, l = back_height - thickness - 2 * z_slot_inset,
                                    r = screw_clearance_radius(frame_screw), center = true);
                //
                // rounded corners on the back
                //
                translate([-length / 2, width - length / 2 - back_thickness / 2, back_height])
                    rotate([-90, 0, 0])
                        fillet(r = corner_rad, h = back_thickness + 1);

                translate([length / 2, width - length / 2 - back_thickness / 2, back_height])
                    rotate([-90, 90, 0])
                        fillet(r = corner_rad, h = back_thickness + 1);
            }
        }
}

module z_motor_bracket_hole_positions(gantry_setback)
    for(side = [-1, 1])
        translate([side * z_motor_bracket_hole_offset(), gantry_setback - part_base_thickness,  back_height / 2 + thickness / 2])
            rotate([90, 0, 0])
                child();

module z_motor_bracket_holes(gantry_setback)
    z_motor_bracket_hole_positions(gantry_setback)
        if(frame_nut_traps)
            rotate([0, 0, 90])
                slot(h = 100, l = back_height - thickness - 2 * z_slot_inset, r = screw_clearance_radius(frame_screw), center = true);
        else
            frame_screw_hole();


module z_motor_assembly(gantry_setback, rhs, rotated = true) {
    assembly("z_motor_assembly");

    color(z_motor_bracket_color) render() z_motor_bracket(gantry_setback, rhs);
    //
    // Clamp screw and washer
    //
    translate([clamp_x, -clamp_width / 2, clamp_height / 2])
        rotate([90, 0, 0])
            screw_and_washer(cap_screw, screw_longer_than(clamp_width + washer_thickness(screw_washer(cap_screw))));
    //
    // Clamp nyloc
    //
    translate([clamp_x, clamp_width / 2 - nut_trap_depth, clamp_height / 2])
        rotate([-90, 0, 0])
            nut(nut, true);

    //
    // Mounting screws
    //
    z_motor_bracket_hole_positions(gantry_setback)
        frame_screw(part_base_thickness);
    //
    // Motor and screws
    //
    NEMA(Z_motor);
    translate([0,0, thickness])
        NEMA_screws(Z_motor);

    //
    // The coupling assembly
    //
    explode([0, 0, 30])
        translate([0, 0, NEMA_shaft_length(Z_motor)])
            rotate([0, 0, rotated ? 45 : 0])
                z_coupler_assembly();

   end("z_motor_assembly");

}

module z_motor_bracket_lhs_stl()                 z_motor_bracket(gantry_setback, false);
module z_motor_bracket_rhs_stl() mirror([1,0,0]) z_motor_bracket(gantry_setback, true);

module z_motor_brackets_stl() {
    translate([ length / 2 + 1, 0, 0]) z_motor_bracket_lhs_stl();
    translate([-length / 2 - 1, 0, 0]) z_motor_bracket_rhs_stl();
}

module z_motor_bracketsX2_stl() {
    translate([0, -gantry_setback - 1, 0])
        z_motor_brackets_stl();
    rotate([0, 0, 180])
        translate([0, -gantry_setback - 1, 0])
            z_motor_brackets_stl();

}

if(0)
    if(1)
        z_motor_brackets_stl();
    else
        z_motor_bracketsX2_stl();
else
    z_motor_assembly(gantry_setback, false);
