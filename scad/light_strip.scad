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
use <spool_holder.scad>
use <fixing-block.scad>
include <positions.scad>

light = light_strip ? light_strip : SPS125;

x = (left_stay_x + right_stay_x) / 2;
y = gantry_Y + sheet_thickness(frame) + spool_holder_gap();
z = height - gantry_thickness + light_strip_set_back(light);

angle = atan2(Y0 - y, z - bed_height);

clearance = 0.5;
boss_r = nut_radius(M3_nut) + 2;
nut_trap_meat = 2;

bracket_thickness = 3;
bracket_width = spool_holder_gap() - clearance;
bracket_length = (right_stay_x - left_stay_x - sheet_thickness(frame) - light_strip_hole_pitch(light)) / 2 + boss_r;
bracket_height = height - z - light_strip_thickness(light);
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
                right_triangle(width = bracket_length - bracket_thickness, height = bracket_width, h = bracket_thickness, center = false);

            translate([-sheet_thickness(frame) - hook + hook_w / 2, bracket_height - hook_overlap + hook_h / 2, 0])
                rounded_rectangle([hook_w, hook_h, bracket_stem], center = false, r = hook_r);

            hull() {
                rotate([angle, 0, 0])
                    translate([bracket_length - boss_r, 0, light_strip_width(light) / 2])
                        rotate([-90, 0, 0])
                            cylinder(r = boss_r - eta, h = nut_trap_meat + nut_thickness(M3_nut, true));
                    translate([bracket_length - 2 * boss_r, bracket_thickness, 0])
                        cube([2 * (boss_r - eta), nut_trap_meat + nut_thickness(M3_nut, true) - bracket_thickness, 1]);
            }
        }
        translate([-slot, bracket_height - bracket_thickness - hook_overlap, -1])
            cube([slot, bracket_thickness + hook_overlap, bracket_stem + 2]);

        rotate([angle, 0, 0]) {
            translate([0, -5, 0])
                cube([100, 10, 100], center = true);

            translate([bracket_length - boss_r, nut_trap_meat + M3_nut_trap_depth, light_strip_width(light) / 2])
                rotate([90, 0, 0])
                    nut_trap(M3_clearance_radius, M3_nut_radius, M3_nut_trap_depth, horizontal = true);

            translate([stem_thickness + wire_hole_r + layer_height, nut_trap_meat + M3_nut_trap_depth, light_strip_width(light) / 2])
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
}

module light_strip_assembly() {
    assembly("light_strip_assembly");
    translate([x, y, z + light_strip_thickness(light)])
        rotate([angle, 0, 0])
            translate([0, -light_strip_width(light) / 2, - light_strip_thickness(light)])
                light_strip(light);

    translate([left_stay_x + sheet_thickness(frame) / 2, y, z + light_strip_thickness(light)])
        rotate([90, 0, 0])
            color("lime") render() light_strip_bracket_left_stl();

    translate([right_stay_x - sheet_thickness(frame) / 2, y, z + light_strip_thickness(light)])
        rotate([90, 0, 0])
            color("red") render() light_strip_bracket_right_stl();

    for(side = [-1,1])
        translate([x + side * light_strip_hole_pitch(light) / 2, y, z + light_strip_thickness(light)])
            rotate([angle - 180, 0, 0])
                translate([0,  light_strip_width(light) / 2, light_strip_thickness(light)]) {
                    screw_and_washer(M3_cap_screw, 10);
                    translate([0, 0, -nut_trap_meat - light_strip_thickness(light)])
                        rotate([180, 0, 0])
                            nut(M3_nut, true);
                }

    *hull() {                           // light ray, should point at center of Y axis.
        translate([x, y -light_strip_width(light) / 2, z])
            sphere();
        translate([x, Y0, bed_height])
            sphere();
    }
    end("light_strip_assembly");
}


if(1)
    light_strip_assembly();
else
    if(1)
        light_strip_bracket();
    else
        light_strip_brackets_stl();
