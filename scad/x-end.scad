//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Ends of the X axis
//
include <conf/config.scad>

use <x-carriage.scad>
use <pulley.scad>
use <ribbon_clamp.scad>
use <wade.scad>

bwall = 2.3;

bearing_dia = Z_bearings[1];
bearing_width = bearing_dia + 2 * bwall;
bearing_depth = bearing_width / 2 + 1;
bearing_length = Z_bearings[0];

shelf_thickness = 2;
shelf_clearance = 0.5;

bearing_height = max( min(65, 2.8 * bearing_length), 2 * (bearing_length + shelf_clearance) + 3 * shelf_thickness);


shelves = [ shelf_thickness / 2,
            shelf_thickness + bearing_length + shelf_clearance + shelf_thickness / 2,
            bearing_height - shelf_thickness / 2,
            bearing_height - (shelf_thickness + bearing_length + shelf_clearance + shelf_thickness / 2) ];

module z_linear_bearings(motor_end) {
    rod_dia = Z_bearings[2];
    opening = bearing_dia / 7;
    shelf_depth = bearing_depth - (rod_dia / 2 + 1);

    union() {
        difference(){
            union(){
                //main vertical block
                translate([-bearing_depth / 2, 0, bearing_height / 2])
                    cube([bearing_depth, bearing_width, bearing_height], center = true);

                cylinder(h = bearing_height, r = bearing_width / 2);

            }
            //hole for bearings
            translate([0, 0, -1])
                cylinder(h = bearing_height + 2, r = bearing_dia / 2);


            //entry cut out
            translate([10 * sqrt(2) - opening, 0, bearing_height / 2])
                rotate([0, 0, 45])
                    cube([20, 20, bearing_height + 1], center = true);

        }
        //
        // shelves
        //
        for(y = shelves)
            translate([-bearing_depth + shelf_depth / 2 + eta, 0, y])
                cube([shelf_depth, bearing_width, shelf_thickness], center = true);
    }
}

//z_linear_bearings();

wall = thick_wall;                          // 4mm on Mendel and Sturdy, 3mm on Huxley
web = 3;
corner_rad = 3;

clamp_wall = 0.5 + washer_diameter(M3_washer) / 2 + M3_clearance_radius;

width = x_bar_spacing() + X_bar_dia + 2 * clamp_wall;
back = -ceil(z_bar_offset() + Z_nut_radius + wall);
front = -(Z_bar_dia / 2 + 1);
length = front - back;
thickness = X_bar_dia + 2 * wall;

clamp_hole_inset = clamp_wall;
clamp_height = thickness / 2 - 0.4;
clamp_width = X_bar_dia + 2 * clamp_wall;

nut_flat_radius = nut_radius * cos(30);
bar_y = x_bar_spacing() / 2;

belt_edge = -x_carriage_width() / 2 - X_carriage_clearance;
function x_belt_offset() = belt_edge - belt_width(X_belt) / 2;

idler_stack = 2 * ball_bearing_width(BB624) + 2 * (washer_thickness(M4_washer) + washer_thickness(M5_penny_washer));
idler_front = min(belt_edge - belt_width(X_belt) / 2 + idler_stack / 2, -bar_y - X_bar_dia / 2 - clamp_wall);
idler_screw_length = 45;
idler_depth = idler_screw_length - idler_stack - 1;
idler_back = idler_front + idler_depth;
idler_width = ceil(2 * (M4_nut_radius + wall));

mbracket_thickness = 4;
mbracket_corner = 7;
motor_angle = 45;
motor_w = ceil(min(max(sin(motor_angle) + cos(motor_angle)) * NEMA_width(X_motor), NEMA_radius(X_motor) * 2) + 1);
mbracket_width = motor_w + 2 * mbracket_thickness;
mbracket_height = thickness / 2 + NEMA_radius(X_motor) + mbracket_thickness + 0.5;
mbracket_front = belt_edge + 14;
mbracket_depth = NEMA_length(X_motor) + 3 * washer_thickness(M3_washer) + 2 * mbracket_thickness;
mbracket_centre = mbracket_front + mbracket_depth / 2 - mbracket_thickness;
nut_shelf = bearing_height -thickness / 2 - wall - nut_trap_depth(Z_nut);

switch_op_x = Z_bearings[1] / 2 + 3;        // switch operates 2mm before carriage hits the bearing
switch_op_z = x_carriage_offset() - 2;      // hit the edge of the carriage
sbracket_top = switch_op_z + 12;
sbracket_height = sbracket_top + thickness / 2;
sbracket_depth = switch_op_x - 3 - front;
sbracket_thickness = bar_y - (X_bar_dia / 2) * sin(45) - bearing_width / 2 - 1.5 - microswitch_thickness();
sbracket_y = -bearing_width / 2 - 1 - sbracket_thickness / 2;

function x_motor_offset() = back - mbracket_thickness - motor_w / 2;
function x_motor_overhang() = back - mbracket_width;
function x_idler_offset() = back - idler_width / 2;
function x_idler_overhang() = x_idler_offset() - washer_diameter(M5_penny_washer) / 2;
function x_end_bar_length() = -back;
function x_end_height() = bearing_height - thickness / 2;
function x_end_thickness() = thickness;
function x_motor_height() = mbracket_height - thickness / 2;
function x_end_clearance() = switch_op_x;
function x_end_z_nut_z() = nut_shelf;

ribbon_screw = M3_cap_screw;
ribbon_nut = screw_nut(ribbon_screw);
ribbon_nut_trap_depth = nut_trap_depth(ribbon_nut);
ribbon_pillar_thickness = wall + ribbon_nut_trap_depth;
ribbon_pillar_depth = ribbon_pillar_thickness;
ribbon_pillar_width = nut_radius(ribbon_nut) * 2 + 2 * web + 0.5;
ribbon_pillar_height = ribbon_clamp_length(extruder_ways, ribbon_screw);
ribbon_clamp_x = back - mbracket_thickness + eta;
ribbon_clamp_y = -bearing_width / 2 - ribbon_pillar_width / 2 + web - eta;
ribbon_clamp_z = max(mbracket_height + ribbon_pillar_height / 2 - thickness / 2,
                     bearing_height - ribbon_clamp_length(extruder_ways, ribbon_screw) / 2 - thickness / 2);
ribbon_pillar_top = ribbon_clamp_z + ribbon_pillar_height / 2;

function x_end_ribbon_clamp_y() = mbracket_front + NEMA_length(X_motor) + ribbon_bracket_thickness();
function x_end_ribbon_clamp_z() = NEMA_hole_pitch(X_motor) / sqrt(2);

function x_end_extruder_ribbon_clamp_offset() = [-ribbon_clamp_x, ribbon_clamp_y + ribbon_clamp_width(ribbon_screw) / 2, ribbon_clamp_z];

module x_end_clamp_stl() {
    stl("x_end_clamp");

    difference() {
        hull() {
            for(end = [-1, 1], side = [-1,1])
                translate([end * (length / 2 - corner_rad), side * (clamp_width / 2 - corner_rad), 0])
                    if(side < 0)
                        translate([0, 0, clamp_height / 2])
                            cube([2 * corner_rad, 2 * corner_rad, clamp_height], center = true);
                        else
                            cylinder(r = corner_rad, h = clamp_height);
        }

        translate([0, 0, thickness / 2])
            rotate([90, 0, 90])
                teardrop_plus(r = X_bar_dia / 2, h = length + 1, center = true);

        for(end = [-1, 1]) {
            for(side = [-1,1])
                translate([end * (length / 2 - clamp_hole_inset), side * (X_bar_dia / 2 + M3_clearance_radius), 0])
                    poly_cylinder(r = M3_clearance_radius, h = 100, center = true);

            translate([end * (length / 2 - clamp_hole_inset), 0, thickness / 2])
                cube([M3_clearance_radius * 2 - eta, X_bar_dia + M3_clearance_radius * 2, X_bar_dia * 0.8], center = true);
        }
    }
}

function ribbon_bracket_counterbore() = washer_thickness(M3_washer) + screw_head_height(M3_cap_screw) + 0.5;
function ribbon_bracket_thickness() = ribbon_bracket_counterbore() + 2.4;

module x_motor_ribbon_bracket_stl(support = true) {
    stl("x_motor_ribbon_bracket");
    length = ribbon_clamp_length(x_end_ways, ribbon_screw) + 2;
    rad = ribbon_clamp_width(ribbon_screw) / 2 + 1;
    counterbore = ribbon_bracket_counterbore();
    height = ribbon_bracket_thickness();
    ridge_width = 5 * filament_width + eta;                 // angled same as infill so make sure whole number of filaments
    ridge_offset = (NEMA_width(X_motor) - NEMA_hole_pitch(X_motor)) / 2 + ridge_width / 2;
    ridge_height = 5;
    difference() {
        union() {
            hull() {
                for(side = [-1, 1])
                    translate([side * (length / 2 - rad), 0, 0])
                        cylinder(h = height, r = rad);

            }
            for(side = [-1,1])
                intersection() {
                    rotate([0, 0, side * 45])
                        translate([ridge_offset * side, 0, height - 1 + ridge_height / 2])
                            cube([ridge_width, 100, ridge_height + 1], center = true);
                    cube([length, rad * 2 - 1, 100], center = true);
                }
        }
        //
        // counterbored hole for motor screw
        //
        difference() {
            union() {
                poly_cylinder(r = M3_clearance_radius, h = 100, center = true);
                poly_cylinder(r = washer_diameter(M3_washer) / 2 + 0.5, h = counterbore * 2, center = true);
            }
            if(support)
                hole_support(M3_clearance_radius, counterbore);
        }
        //
        // ribbon clamp holes
        //
        translate([0, 0, height])
            ribbon_clamp_holes(x_end_ways, ribbon_screw)
                nut_trap(screw_clearance_radius(ribbon_screw), nut_radius(ribbon_nut), ribbon_nut_trap_depth);
    }
}

nut_trap_support_height = 10;

module x_idler_support_stl() {
    color("grey") {
        translate([-z_bar_offset(), 0, 0])
            hole_support(r = (Z_screw_dia + 1) / 2, h = bearing_height - wall);

        translate([-z_bar_offset(), 0,  nut_shelf  + thickness / 2 - nut_trap_support_height])
            nut_trap_support(r = Z_nut_radius, h = nut_trap_support_height + eta, r2 = (Z_screw_dia + 1) / 2);

        for(side = [-1,1])
            for(x = [front - clamp_hole_inset, back + clamp_hole_inset])
                for(i = [-1,1])
                    translate([x, side * bar_y + i * (X_bar_dia / 2 + M3_clearance_radius), 0])
                        hole_support(r = M3_clearance_radius, h = M3_nut_trap_depth, max_r = nut_flat_radius(M3_nut));
    }
}

module x_motor_support_stl() mirror([1,0,0]) x_idler_support_stl();

module x_end_bracket(motor_end, integral_support = false){

    if(motor_end)
        stl("x_motor_bracket");
    else
        stl("x_idler_bracket");
    union(){
        translate([0, 0, - thickness / 2])
            z_linear_bearings(motor_end);

        difference(){
            union(){
                // base
                translate([front - length / 2, 0, 0])
                    rounded_rectangle([length, width, thickness], corner_rad);

                // nut holder tower
                difference() {
                    translate([front - length / 2, 0, bearing_height / 2 - thickness / 2])
                        cube([length, bearing_width, bearing_height], true);

                    translate([-bearing_depth - length / 2 - eta, 0, nut_shelf - bearing_height / 2])
                        rounded_rectangle([length, bearing_width - 2 * web, bearing_height], 2);
                }
                if(motor_end)
                    //
                    // limit switch bracket
                    //
                    difference() {
                        union() {
                            translate([front - eta, sbracket_y, - thickness / 2])
                                rotate([90, 0, 0])
                                    linear_extrude(height = sbracket_thickness, center = true)
                                        polygon([
                                                    [0, 0],
                                                    [sbracket_depth, sbracket_height - microswitch_length() + 2],
                                                    [sbracket_depth, sbracket_height],
                                                    [-web, sbracket_height],
                                                    [-web, thickness - eta]
                                                ]);
                            translate([front - web, sbracket_y, thickness / 2 - 1])
                                cube([web, -bearing_width / 2 - sbracket_y + 1, sbracket_height - thickness + 1]);
                        }
                        translate([switch_op_x, sbracket_y + sbracket_thickness / 2 + microswitch_thickness() / 2, switch_op_z])
                            rotate([0, -90, -90])
                                microswitch_holes(h = sbracket_thickness);
                    }
                else {
                    //
                    // idler end
                    //
                    difference() {
                        union() {
                            translate([back - idler_width / 2 + eta + corner_rad, idler_back - idler_depth / 2, 0])
                                rounded_rectangle([idler_width + 2 * corner_rad, idler_depth, thickness], r = corner_rad, center = true);

                            translate([back, idler_back, 0])
                                rotate([0, 0, 90])
                                    fillet(h = thickness, r = idler_width / 2);
                        }

                        translate([back - idler_width / 2, -bar_y, 0])
                            rotate([90, 0, 90])
                                teardrop(r = X_bar_dia / 2 + 0.5, h = 100, center = true);

                        assign(screw_angle = atan2(M4_clearance_radius - 3.9 / 2, idler_depth))
                            translate([x_idler_offset(), idler_back, 0])
                                rotate([90, 0, -screw_angle])
                                    nut_trap(M4_clearance_radius, M4_nut_radius, M4_nut_trap_depth);

                    }
                }
            }
            //
            // Cut out for bearing holder
            //
            translate([0, 0, bearing_height / 2 - thickness / 2])
                cube([bearing_depth * 2 -eta, bearing_width - 1, bearing_height + 2], center = true);
            //
            // Hole for z leadscrew
            //
            difference() {
                translate([-z_bar_offset(), 0, - thickness / 2])
                    nut_trap((Z_screw_dia + 1) / 2, Z_nut_radius, nut_shelf + thickness / 2 + nut_trap_depth(Z_nut), supported = integral_support);

                if(integral_support)
                    translate([-z_bar_offset(), 0, nut_shelf])
                        cylinder(r = Z_nut_radius + 1, h = 2 * layer_height, center = true);
            }

            translate([-z_bar_offset(), 0, -thickness / 2 - 1])
                cylinder(r = Z_nut_radius + 1, h = thickness + 2, $fn = 6);

            for(side = [-1, 1]) {
                //
                // Holes for x_bars
                //
                translate([front - length / 2, bar_y * side, 0]) {
                    rotate([90, 0, 90])
                        teardrop_plus(r = X_bar_dia / 2, h = length + 1, center = true);
                }
                //
                // Remove clamp tops
                //
                translate([back + (length + 1) / 2 - 0.5, side * (bar_y - X_bar_dia / 2 - clamp_wall - 0.5 + 50), bearing_height / 2])
                    cube([length + 1, 100, bearing_height], center = true);
                //
                // Clamp nut traps
                //
                for(x = [front - clamp_hole_inset, back + clamp_hole_inset]) {
                    for(i = [-1,1])
                        translate([x, side * bar_y + i * (X_bar_dia / 2 + M3_clearance_radius), -thickness / 2])
                            nut_trap(M3_clearance_radius, M3_nut_radius, M3_nut_trap_depth, supported = integral_support);

                    translate([x, side * bar_y, 0])
                        cube([M3_clearance_radius * 2 - eta, X_bar_dia + M3_clearance_radius * 2, X_bar_dia * 0.8], center = true);
                }
            }
        }

        if(motor_end) {
             difference() {
                union() {
                    //
                    // Motor bracket
                    //
                    translate([back - mbracket_width / 2 + eta, mbracket_centre, mbracket_height / 2 - thickness / 2]) {
                        difference() {
                            cube([mbracket_width, mbracket_depth, mbracket_height], center = true);  // outside
                            translate([0, 0, -mbracket_thickness])
                                 cube([mbracket_width - 2 * mbracket_thickness,                      // inside
                                       mbracket_depth - 2 * mbracket_thickness, mbracket_height], center = true);

                            translate([-M3_clearance_radius - wall - 100, -50, - 50])               // truncate front
                                cube(100);

                            translate([NEMA_big_hole(X_motor) * sqrt(2), 0, -mbracket_height / 2 + thickness / 2])
                                rotate([0, 45, 180])                                                 // slope front tangential to motor boss
                                    translate([0, 0, -50])
                                        cube(100);

                            translate([-100 - NEMA_holes(X_motor)[0] * sqrt(2) - screw_head_radius(M3_cap_screw) - wall, 0, - 50])
                                cube(100);                                                           // truncate back

                            translate([-100 + mbracket_width / 2 + 1, -mbracket_centre - bearing_width / 2 + web,
                                       -mbracket_height / 2 + thickness - eta])
                                cube(100);                                                           // truncate back

                            translate([-M3_clearance_radius - wall - eta, -mbracket_centre - bearing_width / 2 + web + eta, mbracket_height / 2])
                                rotate([0, 0,-90])
                                    right_triangle(width = -mbracket_front - bearing_width / 2 + web,
                                           height = mbracket_width / 2 -mbracket_thickness + M3_clearance_radius + wall,
                                           h = 2 * mbracket_thickness + 1);
                        }
                    }
                    //
                    // Ribbon clamp pillar
                    //
                    translate([ribbon_clamp_x + ribbon_pillar_thickness / 2,
                               ribbon_clamp_y,
                               ribbon_clamp_z - eta])
                        hull() {
                            cube([ribbon_pillar_thickness,
                                  ribbon_pillar_width,
                                  ribbon_pillar_height], center = true);

                            translate([+ribbon_pillar_thickness / 2 + 0.5 - mbracket_thickness + eta, 0,
                                       -(ribbon_pillar_thickness - mbracket_thickness) * 2])
                                cube([1, ribbon_pillar_width / 2, ribbon_pillar_height], center = true);
                        }
                }
                //
                // Holes
                //
                translate([x_motor_offset(), 0, 0]) {
                    //
                    // Mounting holes
                    //
                    assign(screw_offset = M3_clearance_radius - 2.9 / 2)
                    for(x = NEMA_holes(X_motor))                                                        // motor screw holes
                        for(z = NEMA_holes(X_motor))
                            rotate([0, motor_angle, 0])
                                translate([x, 0, z])
                                    rotate([90,  -motor_angle, 0]) {
                                        translate([-screw_offset, 0, 0])
                                            teardrop_plus(r = M3_clearance_radius, h = 100);            // front holes

                                        translate([0, 0, -100])
                                            teardrop_plus(r = screw_head_radius(M3_cap_screw), h = 100);// back hole
                                    }
                }

                translate([ribbon_clamp_x + ribbon_pillar_thickness, ribbon_clamp_y, ribbon_clamp_z])
                    rotate([-90,90,90])
                        ribbon_clamp_holes(extruder_ways, ribbon_screw)
                            rotate([0, 0, 90])
                                nut_trap(screw_clearance_radius(ribbon_screw), nut_radius(ribbon_nut), ribbon_nut_trap_depth, true);
                //
                // Hole for switch wires
                //
                translate([back, -bearing_width / 2 - 4, thickness / 2 + 4])
                    rotate([90, 0, 90])
                        teardrop(r = 3, h = 2 * mbracket_thickness + 1, center = true);

            }
        }
    }
}

module x_end_assembly(motor_end) {
    shift = exploded ? 2 : 0;
    if(!motor_end)
        assembly("x_idler_assembly");
    //
    // RP bits
    //
    color(x_end_bracket_color) render() x_end_bracket(motor_end);

    for(side = [-1, 1])
        translate([(front + back) / 2, side * bar_y, thickness / 2])
            rotate([180, 0, 90 + 90 * side])
                color("red") render() x_end_clamp_stl();
    //
    // bearings
    //
    for(i = [0,2])
        translate([0, 0, (shelves[i] + shelves[i+1])/2 - thickness / 2])
            rotate([0,90,0])
                linear_bearing(Z_bearings);
    //
    // bearing clamp fasteners
    //
    for(side = [-1, 1])
        for(x = [front - clamp_hole_inset, back + clamp_hole_inset])
            for(i = [-1,1])
                translate([x, side * bar_y + i * (X_bar_dia / 2 + M3_clearance_radius), 0]) {
                    translate([0, 0, - thickness / 2 + M3_nut_trap_depth])
                        rotate([180, 0, 0])
                            nut(M3_nut, true);

                    translate([0, 0, thickness / 2])
                        washer(M3_washer)
                            screw(M3_cap_screw,
                                screw_longer_than(thickness + washer_thickness(M3_washer) + nut_thickness(M3_nut, true) - nut_trap_depth(M3_nut)));
                }

    if(motor_end) {
        translate([x_motor_offset(), mbracket_front + eta, 0]) {
            rotate([90, motor_angle - 90, 0]) {
                NEMA(X_motor);
                translate([0,0, mbracket_thickness])
                    rotate([0, 0, -90])
                        NEMA_screws(X_motor, 2);

                rotate([0, 0, -180]) translate(NEMA_holes(X_motor)) translate([0, 0, -NEMA_length(X_motor)])
                    rotate([180, 0, 0])
                        washer(M3_washer) washer(M3_washer) washer(M3_washer) screw(M3_cap_screw, 45);

                translate([0, 0, 4])
                    pulley_assembly();
                //
                // Heatshrink for motor connections
                //
                for(i = [-1.5 : 1.5])
                    translate([i * 5, NEMA_width(X_motor) / 2 + 2, -NEMA_length(X_motor) / 2])
                        tubing(HSHRNK24);
            }
        }
        translate([switch_op_x, sbracket_y - sbracket_thickness / 2 - microswitch_thickness() / 2, switch_op_z])
            rotate([0, -90, -90]) {
                microswitch();
                microswitch_hole_positions()
                    translate([0,0, -(microswitch_thickness())])
                        rotate([180,0,0])
                            screw_and_washer(No2_screw, 13);
            }
        //
        // ribbon clamps
        //
        translate([x_motor_offset(), x_end_ribbon_clamp_y(), x_end_ribbon_clamp_z()]) {
            rotate([90, 0, 0]) {
                color(x_end_bracket_color) render() x_motor_ribbon_bracket_stl(false);

                translate([0, 0, ribbon_bracket_counterbore() - exploded * 7])
                    rotate([180, 0, 0])
                        washer(M3_washer)
                            screw(M3_cap_screw, 45);
            }
            explode([0, 8, 0])
                rotate([-90, 0, 0])
                    ribbon_clamp_assembly(x_end_ways, M3_cap_screw, 16, ribbon_bracket_thickness() - M3_nut_trap_depth);
        }


        translate([ribbon_clamp_x, ribbon_clamp_y, ribbon_clamp_z])
            rotate([-90, 90, 90])
                ribbon_clamp_assembly(extruder_ways, ribbon_screw, 16, wall, true);
    }
    else {
        translate([x_idler_offset(), idler_front - idler_stack / 2 - shift * 4, 0]) {
            for(i = [-1, 1]) {
                translate([0, (ball_bearing_width(X_idler_bearing) / 2 + shift) * i, 0])
                    rotate([90, 0, 0])
                        ball_bearing(BB624);

                translate([0, (ball_bearing_width(X_idler_bearing) + shift * 2) * i, 0])
                    rotate([-i * 90, 0, 0])
                        washer(M4_washer);

                translate([0, ((ball_bearing_width(X_idler_bearing) + washer_thickness(M4_washer)) + shift * 3) * i, 0])
                    rotate([-i * 90, 0, 0])
                        washer(M5_penny_washer);
            }
            translate([0,-ball_bearing_width(X_idler_bearing) - washer_thickness(M4_washer) - washer_thickness(M5_penny_washer),0])
                rotate([90,0,0])
                    screw(M4_cap_screw, idler_screw_length);
        }
        translate([x_idler_offset(), idler_back - M4_nut_trap_depth, 0])
            rotate([-90, 0, 0])
                nut(M4_nut, true);
    }
    if(!motor_end)
        end("x_idler_assembly");
}

module x_motor_bracket_stl(integral_support = true)
    translate([0, 0, thickness / 2]) mirror ([1,0,0]) x_end_bracket(true, integral_support);

module x_idler_bracket_stl(integral_support = true)
    translate([0, 0, thickness / 2])
        x_end_bracket(false, integral_support);

module x_ends_stl() {
    x_motor_bracket_stl();
    translate([-bearing_width / 4, bearing_width / 2, 0])
        x_idler_bracket_stl();
}

module facing_pair(dir = 1) {
    child();
    translate([-dir * bearing_width / 4, dir * bearing_width / 2, 0])
        rotate([0, 0, 180])
            child();
}


module x_motor_bracket_x2_stl() facing_pair() x_motor_bracket_stl(false);

module x_motor_support_x2_stl() facing_pair() x_motor_support_stl();

module x_idler_bracket_x2_stl() facing_pair(-1) x_idler_bracket_stl(false);

module x_idler_support_x2_stl() facing_pair(-1) x_idler_support_stl();


if(0)
    x_ends_stl();
else
    if(0)
        x_end_assembly(false);
    else
        mirror ([1,0,0]) x_end_assembly(true);

//x_motor_bracket_stl();
//x_motor_ribbon_bracket_stl();
