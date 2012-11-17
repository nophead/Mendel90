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

bearing_dia = Z_bearings[1] + 0.2;
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

actuator_width = 4;
actuator_depth = 3;
actuator_height = 10;

module z_linear_bearings(motor_end) {
    rod_dia = Z_bearings[2];
    opening = 2 * bearing_dia / 15.4;
    shelf_depth = bearing_depth - (rod_dia / 2 + 1);

    union() {
        difference(){
            union(){
                //main vertical block
                translate([-bearing_depth / 2, 0, bearing_height / 2])
                    cube([bearing_depth, bearing_width, bearing_height], center = true);

                cylinder(h = bearing_height, r = bearing_width / 2);

                if(!motor_end)
                    *translate([-bearing_depth + eta, 0, bearing_height - eta])
                        rotate([-90, 0, 0])
                            right_triangle(width = -actuator_depth, height = actuator_height, h = actuator_width, center = true);

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
width = x_bar_spacing();
back = -ceil(z_bar_offset() + Z_nut_radius + wall);
front = -(Z_bar_dia / 2 + 1);
length = front - back;
thickness = X_bar_dia + 2 * wall;

clamp_wall = default_wall;                  // 4mm on Sturdy, 3mm on Mendel and Huxley
nut_flat_radius = nut_radius * cos(30);
clamp_width = 2 * (nut_radius + clamp_wall);
clamp_height = washer_diameter(washer) / 2 + nut_flat_radius + clamp_wall;
clamp_depth = wall + nut_trap_depth;
clamp_thickness = 5;
slit = 1;
bar_y = x_bar_spacing() / 2;

belt_edge = -x_carriage_width() / 2 - X_carriage_clearance;
function x_belt_offset() = belt_edge - belt_width(X_belt) / 2;

idler_stack = 2 * ball_bearing_width(BB624) + 2 * (washer_thickness(M4_washer) + washer_thickness(M5_penny_washer));
idler_front = min(belt_edge - belt_width(X_belt) / 2 + idler_stack / 2, -bar_y - thickness / 2 - 0.25);
idler_screw_length = 45;
idler_depth = idler_screw_length - idler_stack - 1;
idler_back = idler_front + idler_depth;
idler_width = ceil(2 * (M4_nut_radius + wall));

mbracket_thickness = 4;
motor_angle = 45;
motor_w = ceil(min(max(sin(motor_angle) + cos(motor_angle)) * NEMA_width(X_motor), NEMA_radius(X_motor) * 2) + 1);
mbracket_width = motor_w + 2 * mbracket_thickness;
mbracket_height = thickness / 2 + NEMA_radius(X_motor) + mbracket_thickness;
mbracket_front = belt_edge + 14;
mbracket_depth = NEMA_length(X_motor) + 2 * mbracket_thickness + 1;
mbracket_centre = mbracket_front + mbracket_depth / 2 - mbracket_thickness;

switch_op_x = Z_bearings[1] / 2 + 3;                            // switch operates 2mm before carriage hits the bearing
switch_op_z = x_carriage_offset() - x_carriage_thickness() / 2; // hit the edge of the carriage
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

ribbon_screw = M3_cap_screw;
ribbon_nut = screw_nut(ribbon_screw);
ribbon_nut_trap_depth = nut_trap_depth(ribbon_nut);
ribbon_pillar_depth = 12;
ribbon_pillar_thickness = wall + ribbon_nut_trap_depth;
ribbon_clamp_x = back - ribbon_pillar_depth;
ribbon_clamp_y = mbracket_front + washer_diameter(screw_washer(ribbon_screw)) / 2 + 2;
//ribbon_clamp_z = x_carriage_offset() + extruder_connector_height();
ribbon_clamp_z = mbracket_height + ribbon_clamp_length(extruder_ways, ribbon_screw) / 2 - thickness / 2 + 0.5;
ribbon_pillar_width = nut_radius(ribbon_nut) * 2 + 2 * wall + 0.5;
ribbon_pillar_top = ribbon_clamp_z + ribbon_clamp_length(extruder_ways, ribbon_screw) / 2;

function anti_backlash_height() = 24 + thickness / 2;
anti_backlash_radius = Z_nut_radius + 0.2;
anti_backlash_wall = max(3, bearing_width / 2 - wall - cos(30) * anti_backlash_radius + 0.5);

function x_end_ribbon_clamp_y() = mbracket_front + mbracket_depth - mbracket_thickness;
function x_end_ribbon_clamp_z() = mbracket_height - thickness / 2 - mbracket_thickness - nut_radius(ribbon_nut);

function x_end_extruder_ribbon_clamp_offset() = [-ribbon_clamp_x, ribbon_clamp_y + ribbon_clamp_width(ribbon_screw) / 2, ribbon_clamp_z];

module x_end_bracket(motor_end, assembly = false){

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
                    cube([length, width, thickness], center = true);

                //
                // Anti-backlash nut holder
                //
                translate([-z_bar_offset(), 0, thickness / 2 - eta])
                    cylinder(r = anti_backlash_radius + anti_backlash_wall, h = anti_backlash_height() - thickness / 2, $fn = 6);

                //
                // Webs from bearing holder
                //
                for(side = [-1, 1])
                    if(motor_end)
                        translate([back - eta, (bearing_width - wall - eta) / 2 * side, thickness / 2 - eta])
                            rotate([90, 0, 0])
                                linear_extrude(height = wall, center = true)
                                    polygon(points = [
                                            [0, 0],
                                            [-back - bearing_depth + 2 * eta, 0],
                                            [-back - bearing_depth + 2 * eta, bearing_height - thickness],
                                            [0, mbracket_height - thickness]
                                        ],
                                        sides = [0, 1, 2, 3]
                                );
                    else
                        translate([-bearing_depth + eta, (bearing_width - wall - eta) / 2 * side, thickness / 2 - eta])
                            rotate([90, 0, 0])
                                right_triangle(width = back + bearing_depth, height = bearing_height - thickness, h = wall);

                for(side = [-1, 1]) {
                    //
                    // Bar holders
                    //
                    union() {
                        translate([front - length / 2,  bar_y * side, 0]) {
                            rotate([90, 0, 90])
                                teardrop(r = thickness / 2, h = length, center = true);
                            rotate([-90, 0, 90])
                                teardrop(r = thickness / 2, h = length, center = true);

                            rotate([90, 0, 90 * side])
                                linear_extrude(height = length - 4 * eta, center = true)
                                    hull() {
                                        translate([slit / 2 + eta, thickness / 2 - 1])
                                            square([clamp_thickness - 2 * eta, 0.5]);
                                        circle(r = thickness / 2 - eta);
                                    }
                        }
                    }
                    //
                    // Bar clamps
                    //
                    difference() {
                        group() {
                            translate([front - length / 2, side * (bar_y - clamp_depth / 2 - slit / 2), thickness / 2 + clamp_height / 2 -eta])
                                cube([clamp_width, clamp_depth, clamp_height], center = true);

                            translate([front - length / 2, side * (bar_y + clamp_thickness / 2 + slit / 2)   -eta, thickness / 2])
                                rotate([90, 0, 0])
                                    linear_extrude(height = clamp_thickness, center = true)
                                        polygon(points = [
                                            [-length / 2 + eta, 0],
                                            [-length / 2 + eta, -thickness / 2],
                                            [ length / 2 - eta, -thickness / 2],
                                            [ length / 2 - eta, 0],
                                            [ clamp_width / 2, clamp_height],
                                            [-clamp_width / 2, clamp_height],
                                        ]);
                        }
                        //
                        // Bar clamp nut traps
                        //
                        translate([front - length / 2, side * (bar_y - clamp_depth - slit / 2), thickness / 2 + washer_diameter(washer) / 2])
                            rotate([90,0,0])
                                nut_trap(screw_clearance_radius, nut_radius, nut_trap_depth, true);
                    }
                }
            }
            //
            // Cut out for bearing holder
            //
            cube([bearing_depth * 2 -eta, bearing_width - eta, thickness + 10], center = true);
            //
            // Hole for z leadscrew
            //
            translate([-z_bar_offset(), 0, -thickness / 2])
                nut_trap((Z_screw_dia + 1) / 2, Z_nut_radius, Z_nut_depth);

            translate([-z_bar_offset(), 0, thickness / 2 + eta])
                cylinder(r = anti_backlash_radius, h = bearing_height, $fn = 6);

            for(side = [-1, 1]) {
                //
                // Holes for x_bars
                //
                translate([front - length / 2, bar_y * side, 0]) {
                    translate([0, 0, thickness / 2])
                        cube([length + 1, slit, thickness + 1], center = true);
                    rotate([90, 0, 90])
                        teardrop_plus(r = X_bar_dia / 2, h = length + 1, center = true, truncate = false);
                }
            }
            //
            // cut out for bottom microswitch contact
            //
            if(motor_end)
                translate([switch_op_x,
                           sbracket_y - sbracket_thickness / 2 - microswitch_thickness() / 2,
                           switch_op_z])
                    rotate([0, -90, -90])
                        microswitch_contact_space();

        }
        //
        // support membrane
        //
        translate([-z_bar_offset(), 0, Z_nut_depth + layer_height / 2 - thickness / 2 + eta])
            cylinder(r = (Z_screw_dia + 2) /2, h = layer_height, center = true);

        if(motor_end) {
             difference() {
                //
                // Bracket
                //
                union() {
                    translate([back - mbracket_width / 2 + eta, mbracket_centre, mbracket_height / 2 - thickness / 2]) {
                        difference() {
                            cube([mbracket_width, mbracket_depth, mbracket_height], center = true);                     // outside
                            translate([0, 0, -mbracket_thickness])
                                difference() {
                                    cube([mbracket_width - 2 * mbracket_thickness,                                          // inside
                                        mbracket_depth - 2 * mbracket_thickness, mbracket_height], center = true);
                                    if(!assembly)
                                        cube([mbracket_width - 30 + 4 * filament_width,                                         // support tube
                                            mbracket_depth - 30 + 4 * filament_width, mbracket_height + 1], center = true);
                                }
                            translate([0, 0, (mbracket_height - mbracket_thickness) / 2 + layer_height])
                                cube([mbracket_width - 30, mbracket_depth - 30, true ? 100: mbracket_thickness], center = true);    // open top

                        }
                        //
                        // Fillet to anchor the end wall to the bed while being printed
                        //
                        translate([-mbracket_width / 2 + mbracket_thickness - eta, 0, -mbracket_height / 2])
                            rotate([90, 0, 0])
                                right_triangle(width = 4, height = 4, h = mbracket_depth - eta, center = true);
                    }
                    //
                    // ribbon clamp pillar
                    //
                    translate([ribbon_clamp_x,
                               ribbon_clamp_y,
                               mbracket_height + (ribbon_pillar_top - mbracket_height - thickness / 2) / 2 - eta])
                    {
                        translate([ribbon_pillar_thickness / 2, 0, 0])
                            cube([ribbon_pillar_thickness,
                                  ribbon_pillar_width,
                                  ribbon_pillar_top - mbracket_height + thickness / 2], center = true);
                        for(side = [-1, 1])
                            translate([ribbon_pillar_thickness - eta, side * (ribbon_pillar_width - wall) / 2,
                                        -(ribbon_pillar_top - mbracket_height + thickness / 2) / 2 - eta])
                                rotate([90,0,0])
                                    right_triangle(width = ribbon_pillar_depth - ribbon_pillar_thickness,
                                                   height = ribbon_pillar_top - mbracket_height + thickness / 2,
                                                   h = wall);
                    }
                    //
                    // Ribbon clamp nut traps
                    //
                    translate([x_motor_offset(), mbracket_front + mbracket_depth - 2 * mbracket_thickness + eta, x_end_ribbon_clamp_z()])
                        rotate([90, 180, 0])
                            ribbon_clamp_holes(x_end_ways, ribbon_screw)
                                difference() {
                                    teardrop(r = nut_radius(ribbon_nut) + 2, h = ribbon_nut_trap_depth, truncate = false);
                                    translate([0, (nut_radius(ribbon_nut) + 2) * sqrt(2), ribbon_nut_trap_depth + eta])
                                        rotate([0, 90, 180])
                                            right_triangle(width = ribbon_nut_trap_depth, height = ribbon_nut_trap_depth, h = 20);
                                }


                }
                //
                // Slits to leave clamp free
                //
                for(side = [-1,1])                  // both sides in case motor longer than bracket
                    translate([back - slit / 2 + eta * 2, side * (-bar_y - thickness / 2 + slit / 2), 0])
                        difference() {
                            cube([slit, thickness, thickness + 2], center = true);
                            translate([-1, 0, thickness / 2 + 1])
                                rotate([0, 45, 0])
                                    cube([2, thickness + 1, 2], center = true);
                        }
                //
                // Holes
                //
                translate([x_motor_offset(), mbracket_front, 0]) {
                    //
                    // big hole for motor boss
                    //
                    translate([0, 0, -50/2])
                        rotate([90,0,0])
                            vertical_tearslot(r = NEMA_big_hole(X_motor), h = 2 * mbracket_thickness + 1, l = 50, center = true);
                    //
                    // small hole for second shaft
                    //
                    translate([0, mbracket_depth - mbracket_thickness, -50/2])
                        rotate([90,0,0])
                            vertical_tearslot(r = 4, h = 2 * mbracket_thickness + 1, l = 50, center = true);
                    //
                    // Mounting holes
                    //
                    for(x = NEMA_holes(X_motor))                                                         // motor screw holes
                        for(z = NEMA_holes(X_motor))
                            rotate([0, motor_angle, 0])
                            translate([x,0,z])
                                rotate([90,  -motor_angle, 0]) {
                                    teardrop_plus(r = M3_clearance_radius, h = 2 * mbracket_thickness + 1, center = true);
                                    translate([0, 0, mbracket_thickness])
                                         teardrop_plus(r = (washer_diameter(M3_washer) + 1) / 2, h = 2 * (mbracket_thickness - 3.999), center = true);
                                }
                }
                //
                // ribbon clamp holes
                //
                translate([x_motor_offset(),
                           mbracket_front + mbracket_depth - 2 * mbracket_thickness - ribbon_nut_trap_depth,
                           mbracket_height - thickness / 2  - mbracket_thickness - nut_radius(ribbon_nut)])
                    rotate([90, 0, 0])
                        ribbon_clamp_holes(x_end_ways, ribbon_screw)
                            difference() {
                                nut_trap(screw_clearance_radius(ribbon_screw), nut_radius(ribbon_nut), ribbon_nut_trap_depth, true);
                                translate([0,0, 5])
                                    cylinder(r = 10, h =100);
                            }

                translate([ribbon_clamp_x + ribbon_pillar_thickness, ribbon_clamp_y, ribbon_clamp_z])
                    rotate([-90,90,90])
                        ribbon_clamp_holes(extruder_ways, ribbon_screw)
                            rotate([0, 0, 90])
                                nut_trap(screw_clearance_radius(ribbon_screw), nut_radius(ribbon_nut), ribbon_nut_trap_depth, true);
                //
                // Hole for switch wires
                //
                translate([back, -bearing_width / 2 - 3, thickness / 2 + 10])
                    rotate([90, 0, 90])
                        teardrop(r = 3, h = 2 * mbracket_thickness + 1, center = true);

            }
            //
            // limit switch bracket
            //
            difference() {
                translate([front - eta, sbracket_y, - thickness / 2])
                    rotate([90, 0, 0])
                        linear_extrude(height = sbracket_thickness, center = true)
                            polygon([
                                        [0, 0],
                                        [sbracket_depth, sbracket_height - microswitch_length() + 2],
                                        [sbracket_depth, sbracket_height],
                                        [sbracket_depth - 10, sbracket_height],
                                        //[-length / 2 + clamp_width / 2 - eta, thickness + clamp_height],
                                        [-length / 2 + clamp_width / 2 - eta, thickness - eta]
                                    ]);
                translate([switch_op_x, sbracket_y + sbracket_thickness / 2 + microswitch_thickness() / 2, switch_op_z])
                    rotate([0, -90, -90])
                        microswitch_holes(h = sbracket_thickness);
            }
        }
        else {
            //
            // idler end
            //
            difference() {
                union() {
                    translate([back - idler_width / 2 + eta - slit / 2, idler_back - idler_depth / 2, 0])
                        rounded_rectangle([idler_width - slit, idler_depth, thickness], r = 2, center = true);

                    translate([back - 5, idler_back - (idler_back + bar_y - slit / 2) / 2, 0])
                        cube([10, idler_back + bar_y - slit / 2, thickness], center = true);

                    translate([back, idler_back, 0])
                        rotate([0, 0, 90])
                            fillet(h = thickness, r = idler_width / 2);
                }

                translate([back - idler_width / 2, -bar_y, 0])
                    rotate([90, 0, 90])
                        teardrop(r = X_bar_dia / 2 + 0.5, h = idler_width + 1, center = true);

                translate([x_idler_offset(), idler_back, 0])
                    rotate([90, 0, 0])
                        nut_trap(M4_clearance_radius, M4_nut_radius, M4_nut_trap_depth);

            }
        }
    }
}

module x_end_assembly(motor_end) {
    shift = exploded ? 2 : 0;
    if(!motor_end)
        assembly("x_idler_assembly");
    //
    // RP bit
    //
    color(x_end_bracket_color) render() x_end_bracket(motor_end, true);
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
    for(side = [-1, 1]) {
        translate([front - length / 2, side * (bar_y + clamp_thickness + slit / 2), thickness / 2 + washer_diameter(washer) / 2])
            rotate([-90 * side,0,0])
                screw_and_washer(hex_screw, 16);

       translate([front - length / 2, side * (bar_y - clamp_depth - slit / 2 + nut_trap_depth), thickness / 2 + washer_diameter(washer) / 2])
            rotate([90 * side,0,0])
                nut(nut, true);
    }
    if(motor_end) {
        translate([x_motor_offset(), mbracket_front + eta, 0]) {
            rotate([90, motor_angle, 0]) {
                NEMA(X_motor);
                translate([0,0, mbracket_thickness])
                    NEMA_screws(X_motor, 3);
                translate([0, 0, 4])
                    pulley_assembly();
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
        translate([x_motor_offset(), x_end_ribbon_clamp_y(), x_end_ribbon_clamp_z()])
            rotate([-90, 0, 0])
                ribbon_clamp_assembly(x_end_ways, M3_hex_screw, 16, mbracket_thickness);

        translate([ribbon_clamp_x, ribbon_clamp_y, ribbon_clamp_z])
            rotate([-90, 90, 90])
                ribbon_clamp_assembly(extruder_ways, ribbon_screw, 16, wall, true);
        //
        // Heatshrink for motor connections
        //
        for(i = [-1.5 : 1.5])
            translate([i * 5 + back - mbracket_width / 2, 0, mbracket_height - thickness / 2])
                rotate([90, 0, 0])
                    tubing(HSHRNK24);
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

module x_motor_bracket_stl() {
    translate([0, 0, thickness / 2]) mirror ([1,0,0]) x_end_bracket(true);
    for(side = [-1, 1])
        translate([-back + mbracket_width, mbracket_centre + side * mbracket_depth / 2, 0])
            rotate([0, 0, 135 + side * 45]) corner_shield(20, 20);
}

module x_idler_bracket_stl()
    translate([0, 0, thickness / 2])
        x_end_bracket(false);

module x_ends_stl() {
    x_motor_bracket_stl();
    translate([-4, bearing_width / 2, 0])
        x_idler_bracket_stl();
}

if(0)
    x_ends_stl();
else
    if(0)
        x_end_assembly(false);
    else
        mirror ([1,0,0]) x_end_assembly(true);

//x_motor_bracket_stl();
