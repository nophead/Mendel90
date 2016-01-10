//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Bracket to mount an LED light strip behind the gantry
//
include <conf/config.scad>
use <spool_holder.scad>
use <fixing-block.scad>
use <light_strip_clip.scad>
include <positions.scad>

wall = 2;

light = light_strip ? light_strip : RIGID5050_290;

use_screws = light_strip_has_holes(light);
use_clips = !use_screws;
z_offset = use_clips ? wall : 0;
y_offset = use_clips ? light_strip_clip_length(light) / 2 : light_strip_width(light) / 2;

x = (left_stay_x + right_stay_x) / 2;
y = gantry_Y + sheet_thickness(frame) + spool_holder_gap();
z = height - gantry_thickness + light_strip_set_back(light);

bracket_z = z + light_strip_thickness(light) + z_offset;

hypot = sqrt(sqr(bracket_z - bed_height) + sqr(Y0 - y));
angle = atan2(Y0 - y, bracket_z - bed_height) + asin(y_offset / hypot);

clearance = 0.5;
boss_r = nut_radius(M3_nut) + 2;
nut_trap_meat = 2;

bracket_thickness = use_screws ? nut_trap_meat + nut_thickness(M3_nut, true) : 3;
bracket_width = min(spool_holder_gap() - clearance, light_strip_clip_length(light) * cos(angle));
bracket_length = use_screws ? (right_stay_x - left_stay_x - sheet_thickness(frame) - light_strip_hole_pitch(light)) / 2 + boss_r
                            : (right_stay_x - left_stay_x - sheet_thickness(frame) - light_strip_length(light)) / 2 + light_strip_clip_depth(light);
bracket_height = height - z - light_strip_thickness(light) - (use_clips ? wall : 0);
bracket_stem = bracket_width - fixing_block_height();

stem_thickness = 3;

hook = 8;
hook_overlap = 3;
hook_r = 3;

wire_hole_r = 3.5 / 2;

module light_strip_bracket() {
    hook_w = stem_thickness + sheet_thickness(frame) + hook;
    hook_h = hook + hook_overlap;
    slot = sheet_thickness(frame) + 0.2;

    difference() {
        union() {
            multmatrix([[1,0,0,0],
                        [0,1,-tan(angle),0],
                        [0,0,1,0],
                        [0,0,0,1]])
               union() {
                    cube([bracket_length, bracket_thickness, bracket_width]);

                    translate([0, bracket_thickness, bracket_stem])
                        rotate([90, 0, 90])
                            right_triangle(width = bracket_width, height = bracket_width - bracket_stem, h = stem_thickness, center = false);
               }

            cube([stem_thickness, bracket_height, bracket_stem]);

            translate([stem_thickness, bracket_thickness, 0])
                right_triangle(width = bracket_length - stem_thickness, height = bracket_width, h = stem_thickness, center = false);

            translate([-sheet_thickness(frame) - hook + hook_w / 2, bracket_height - hook_overlap + hook_h / 2, 0])
                rounded_rectangle([hook_w, hook_h, bracket_stem], center = false, r = hook_r);
        }
        translate([-slot, bracket_height - bracket_thickness - hook_overlap, -1])
            cube([slot, bracket_thickness + hook_overlap, bracket_stem + 2]);

        rotate([angle, 0, 0]) {
            translate([0, -5, 0])
                cube([100, 10, 100], center = true);

            if(use_screws)
                translate([bracket_length - boss_r, nut_trap_meat + M3_nut_trap_depth,
                           light_strip_width(light) / 2 + light_strip_hole_pitch2(light) / 2])
                    rotate([90, 0, 0])
                        nut_trap(M3_clearance_radius, M3_nut_radius, M3_nut_trap_depth, horizontal = true);

            translate([stem_thickness + wire_hole_r + layer_height, bracket_thickness + 1, light_strip_width(light) / 2])
                rotate([90, 0, 0])
                    teardrop_plus(r = wire_hole_r, h = 100);
        }
    }
}

module light_strip_bracket_left_stl() {
    stl("light_strip_bracket_left");
    light_strip_bracket();
}

module light_strip_bracket_right_stl() {
    stl("light_strip_bracket_right");
    mirror([1,0,0]) light_strip_bracket();
}

module light_strip_brackets_stl() {
    light_strip_bracket_left_stl();
    translate([-2 - 2 * (hook + sheet_thickness(frame)), 0, 0])
        light_strip_bracket_right_stl();

    if(use_clips)
        for(i = [0,1])
            translate([-2, (i + 0.5) * (light_strip_clip_length(light) + 2), 0])
                rotate([0, 0, 90])
                    light_strip_clip(light);
}

module light_strip_assembly() {
    assembly("light_strip_assembly");
    translate([x, y, bracket_z])
        rotate([angle, 0, 0]) {
            translate([0, -y_offset, -z_offset])
                rotate([180, 0, 0])
                    light_strip(light);

            if(use_clips)
                for(side = [-1, 1])
                    translate([side * (light_strip_length(light) / 2), -y_offset, 0])
                        rotate([-90, 0, side * 90])
                            color(side < 0 ? "red": "lime") render() light_strip_clip(light);
        }

    translate([left_stay_x + sheet_thickness(frame) / 2, y, bracket_z])
        rotate([90, 0, 0])
            color("lime") render() light_strip_bracket_left_stl();

    translate([right_stay_x - sheet_thickness(frame) / 2, y, bracket_z])
        rotate([90, 0, 0])
            color("red") render() light_strip_bracket_right_stl();

    if(use_screws)
        translate([x, y, bracket_z])
            rotate([angle - 180, 0, 0])
                translate([0, light_strip_width(light) / 2, light_strip_thickness(light)])
                    light_strip_hole_positions(light) group() {
                        screw_and_washer(M3_cap_screw, 10);

                        translate([0, 0, -light_strip_thickness(light) - nut_trap_meat])
                            rotate([180, 0, 0])
                                nut(M3_nut, true);
                    }

    if(show_rays)
        %hull() {                           // light ray, should point at center of Y axis.
            translate([x, y, bracket_z])
                rotate([angle, 0, 0])
                    translate([0, -y_offset, z - bracket_z])
                        sphere();

            translate([x, Y0, bed_height])
                sphere();
        }
    end("light_strip_assembly");
}


if(1)
    light_strip_assembly();
else
    if(0)
        light_strip_bracket();
    else
        light_strip_brackets_stl();
