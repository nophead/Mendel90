//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// X carriage, carries the extruder
//

include <conf/config.scad>
use <bearing-holder.scad>
use <wade.scad>

hole = 36;
width = hole + 2 * bearing_holder_width(X_bearings);

length = 97;
top_thickness = 3;
rim_thickness = 8;
nut_trap_thickness = 8;
corner_radius = 5;
wall = 2.8;

base_offset = nozzle_x_offset;      // offset of base from centre
bar_offset = ceil(max(X_bearings[2] / 2 + rim_thickness + 1,                     // offset of carriage origin from bar centres
                 nut_radius(M3_nut) * 2 + belt_thickness(X_belt) + pulley_inner_radius + 6 * layer_height));

mounting_holes = [[-25, 0], [25, 0], /*[57, 7]*/];

function x_carriage_offset() = bar_offset;
function x_bar_spacing() = hole + bearing_holder_width(X_bearings);
function x_carriage_width() = width;
function x_carriage_length() = length;
function x_carriage_thickness() = rim_thickness;

bar_y = x_bar_spacing() / 2;
bar_x = (length - bearing_holder_length(X_bearings)) / 2;

tooth_height = belt_thickness(X_belt) / 2;
tooth_width = belt_pitch(X_belt) / 2;

lug_width = max(2.5 * belt_pitch(X_belt), 2 * (M3_nut_radius + 2));
lug_depth = X_carriage_clearance + belt_width(X_belt) + belt_clearance + M3_clearance_radius + lug_width / 2;
lug_screw = -(X_carriage_clearance + belt_width(X_belt) + belt_clearance + M3_clearance_radius);
slot_y =  -X_carriage_clearance - (belt_width(X_belt) + belt_clearance) / 2;

function x_carriage_belt_gap() = length - 2 * lug_width;

clamp_thickness = 3;
dowel = 5;
dowel_height = 2;


module belt_lug(motor_end) {
    height = motor_end ? x_carriage_offset() - pulley_inner_radius:
                         x_carriage_offset() - ball_bearing_diameter(X_idler_bearing) / 2;

    height2 = motor_end ? height + clamp_thickness : height;
    width = lug_width;
    depth = lug_depth;
    extra = 0.5;            // extra belt clearance

    union() {
        difference() {
            union() {
                translate([width / 2, -depth + width / 2])
                    cylinder(r = width / 2, h = height2 + (motor_end ? M3_nut_trap_depth : 0));
                translate([0, -(depth - width / 2)])
                    cube([width, depth - width / 2, height2]);
            }

            translate([width / 2, slot_y, height - belt_thickness(X_belt) / 2 + 2 * eta])                   // slot for belt
                cube([width + 1, belt_width(X_belt) + belt_clearance, belt_thickness(X_belt)], center = true);

            translate([width / 2, lug_screw, height2 + M3_nut_trap_depth + eta])
                nut_trap(M3_clearance_radius, M3_nut_radius, M3_nut_trap_depth);

            // slot to join screw hole
            translate([width / 2,  -(X_carriage_clearance + belt_width(X_belt) + belt_clearance),
                       height - belt_thickness(X_belt) / 2 + extra /2])
                cube([M3_clearance_radius * 2, M3_clearance_radius * 2, belt_thickness(X_belt) + extra], center = true);

            if(motor_end) {
                translate([width, slot_y, (height - belt_thickness(X_belt)) / 2])                       // tensioning screw
                    rotate([90, 0, 90])
                        nut_trap(M3_clearance_radius, M3_nut_radius, M3_nut_trap_depth, true);

                translate([width / 2, slot_y, height - (belt_thickness(X_belt) - extra) / 2 - eta])                 // clearance slot for belt
                    cube([width + 1, belt_width(X_belt) + extra, belt_thickness(X_belt) + extra], center = true);
            }
        }
        //
        // fillets
        //
        *translate([width, 0, height / 2])
            rotate([0, 0, -90])
                fillet(r = X_carriage_clearance, h = height);

        if(motor_end)
            //
            // support membrane
            //
            translate([width / 2, lug_screw, height + extra + layer_height / 2 - eta])
                cylinder(r = M3_clearance_radius + 1, h = layer_height, center = true);
        else
            for(i = [-1:1])                                                                                 // teeth to grip belt
                translate([width / 2 + i * belt_pitch(X_belt), slot_y, height- belt_thickness(X_belt) + tooth_height / 2 - eta ])
                    cube([tooth_width, belt_width(X_belt) + belt_clearance + eta, tooth_height], center = true);

    }
}

module belt_loop() {
    d = x_carriage_offset() - pulley_inner_radius - belt_thickness(X_belt);
    height = d + 2 * belt_thickness(X_belt);
    length = lug_width + 12.5;

    color(belt_color)
    translate([d / 2, 0, 0])
        linear_extrude(height = belt_width(X_belt), convexity = 5, center = true)
            difference() {
                union() {
                    circle(r = height / 2, center = true);
                    translate([0, -height / 2])
                        square([length, height]);
                }
                union() {
                    circle(r = d / 2, center = true);
                    translate([0, -d / 2])
                        square([length, d]);
                }
                translate([length - 12.5, -height])
                    square([100, height]);
            }
}

function x_belt_loop_length() = PI * (x_carriage_offset() - pulley_inner_radius - belt_thickness(X_belt) / 2) / 2 + lug_width + 15;

module x_belt_clamp_stl()
{
    height = clamp_thickness;
    width = lug_width;
    depth = lug_depth;

    stl("x_belt_clamp");
    union() {
        difference() {
            union() {
                translate([width / 2, -depth + width / 2])
                    cylinder(r = width / 2, h = height + M3_nut_trap_depth);
                translate([0, -(depth - width / 2)])
                    cube([width, depth - width / 2, height]);
            }
            translate([width / 2, lug_screw, height + M3_nut_trap_depth])
                nut_trap(M3_clearance_radius, M3_nut_radius, M3_nut_trap_depth);
        }
   }
}

module x_belt_grip_stl()
{
    height = clamp_thickness + belt_thickness(X_belt);
    width = lug_width;
    depth = lug_depth;

    stl("x_belt_grip");
    union() {
        difference() {
            linear_extrude(height = height, convexity = 5)
                hull() {
                    translate([width / 2, -depth + width / 2])
                        circle(r = width / 2);
                    translate([0, -(depth - width / 2 - dowel)])
                        square([width, depth - width / 2]);
                }
            translate([width / 2, lug_screw, -1])
                poly_cylinder(r = M3_clearance_radius, h = height + 2);                                // clamp screw hole

            translate([width / 2,  -(X_carriage_clearance + belt_width(X_belt) + belt_clearance), height])  // slot to join screw hole
                cube([M3_clearance_radius * 2, M3_clearance_radius * 2, 2 * belt_thickness(X_belt)], center = true);

            translate([width / 2, slot_y, height - belt_thickness(X_belt) / 2 + 2 * eta])                   // slot for belt
                cube([width + 1, belt_width(X_belt) + belt_clearance, belt_thickness(X_belt)], center = true);
        }
        translate([width / 2, dowel / 2, eta])
            cylinder(r = dowel / 2 - 0.1, h = height + dowel_height);

        for(i = [-1:1])                                                                                     // teeth
            translate([width / 2 + i * belt_pitch(X_belt), slot_y, height - belt_thickness(X_belt) + tooth_height / 2 - eta ])
                cube([tooth_width, belt_width(X_belt) + belt_clearance + eta, tooth_height], center = true);
    }
}
belt_tensioner_rim = X_carriage_clearance;
belt_tensioner_height = belt_tensioner_rim + belt_width(X_belt) + belt_clearance + belt_tensioner_rim;

module x_belt_tensioner_stl()
{
    stl("x_belt_tensioner");

    flat = 1;
    d = x_carriage_offset() - pulley_inner_radius - belt_thickness(X_belt);

    module d(r, w) {
        difference() {
            union() {
                circle(r, center = true);
                translate([0, -r])
                    square([w + 1, 2 * r]);
            }
            translate([w, - 50])
                square([100, 100]);
        }
    }

    difference() {
        translate([d / 2, 0, 0]) union() {
            linear_extrude(height = belt_tensioner_height)
                d(d / 2, flat);

            linear_extrude(height = belt_tensioner_rim)
                d(d / 2 + 2, flat);
        }
        translate([wall, 0, belt_tensioner_height / 2])
            rotate([90, 0, 90])
                teardrop(r = M3_clearance_radius, h = 100);
    }
}

fan_x = 53;
fan_plug_width = 7;
fan_plug_length = 9;

part_fan = fan30x10;

fan_screw = No4_screw;
fan_screw_length = 16;
fan_screw_wall = 3 * filament_width;
fan_screw_boss_r = screw_radius(fan_screw) + fan_screw_wall;
fan_voffset = fan_hole_pitch(part_fan) + fan_screw_boss_r;

fan_mount_width = (nut_radius(M3_nut) + wall) * 2;
fan_mount_depth = wall + nut_trap_depth(M3_nut);
fan_mount_screw_z = rim_thickness + screw_head_radius(M3_cap_screw);
fan_mount_height = fan_mount_screw_z + nut_radius(M3_nut) * cos(30) + wall;

fan_mount_clearance = 0.25;
fan_mount_recepticle_width = fan_mount_width + 2 * (fan_mount_clearance + wall);
fan_mount_recepticle_depth = 2 * wall;
fan_mount_recepticle_screw_z = hot_end_length(hot_end) + hot_end_duct_offset(hot_end)[2] - fan_mount_screw_z;
fan_mount_recepticle_height = fan_mount_recepticle_screw_z - 2 * fan_voffset + washer_diameter(M3_washer) / 2 + wall;
fan_mount_recepticle_stop = fan_mount_recepticle_screw_z - 2 * fan_voffset - (fan_mount_height - fan_mount_screw_z) - eta;

front_nut_width = 2 * nut_radius(M3_nut) + wall;
front_nut_height = 2 * nut_radius(M3_nut) * cos(30) + wall;
front_nut_depth = wall + nut_trap_depth(M3_nut);

gap = 4;
taper_angle = 30;
nozzle_height = 5;
duct_height = 15;
duct_wall = 2 * 0.35 * 1.5;
ir = hot_end_duct_radius(hot_end);
or = ir + duct_wall + gap + duct_wall;
skew = nozzle_height * tan(taper_angle);
throat_width = (or + skew) * 2;
top_thickness = 2;

module throat(inner) {
    x = or + skew - duct_wall;
    if(inner)
        translate([x, -throat_width / 2 + duct_wall, nozzle_height])
            cube([2 * eta, throat_width - 2 * duct_wall, (duct_height - nozzle_height) - top_thickness]);
    else
        translate([x - duct_wall, -throat_width / 2, 0])
            cube([2 * eta, throat_width, duct_height]);
}


module x_carriage_fan_duct_stl() {
    stl("x_carriage_fan_duct");

    height = fan_voffset * 2;
    width = height;
    boss_length = fan_screw_length - fan_depth(part_fan) + duct_wall;

    difference() {
        union() {
            difference() {
                union() {
                    hull() {
                        translate([fan_x - fan_depth(part_fan) / 2 - boss_length - duct_wall, -width / 2, 0])
                            cube([boss_length + duct_wall, width, height]);
                        throat(false);
                    }
                    hull() {
                        union() {
                            cylinder(r1 = or, r2 = or + skew, h = nozzle_height);
                            translate([0, 0, nozzle_height - eta])
                                cylinder(r = or + skew, h = duct_height - nozzle_height);
                        }
                        throat(false);
                    }
                }
                // hole in the middle
                translate([0, 0,  -2 * eta])
                    cylinder(r1 = ir, r2 = ir + skew, h = nozzle_height + 4 * eta);
                translate([0, 0, nozzle_height - 2 * eta])
                    cylinder(r = ir + skew, h = duct_height - nozzle_height + 4 * eta);

                // fan entrance
                translate([fan_x - fan_depth(part_fan) / 2 + 2 * eta, 0, height / 2])
                    rotate([90, 0, -90])
                        teardrop(r = fan_bore(part_fan) / 2, h = boss_length + 2 * eta);

                hull() {
                    translate([fan_x - fan_depth(part_fan) / 2 - boss_length, - fan_bore(part_fan) / 2, height / 2 - fan_bore(part_fan) / 2])
                        cube([2 * eta, fan_bore(part_fan), fan_bore(part_fan) / 2 + height / 2 - top_thickness]);

                    throat(true);
                }

                // exit slot
                translate([0, 0, -2 * eta])
                    difference() {
                        union() {
                            cylinder(r1 = or - duct_wall, r2 = or + skew - duct_wall, h = nozzle_height);
                            hull() {
                                translate([0, 0, nozzle_height - 2 * eta])
                                    cylinder(r = or + skew - duct_wall, h = duct_height - nozzle_height - 5 * layer_height);
                                throat(true);
                            }
                        }

                        translate([0, 0, -2 * eta])
                            cylinder(r1 = ir + duct_wall, r2 = ir + skew + duct_wall, h = nozzle_height + 4 * eta);

                        translate([0, 0, nozzle_height - 2 * eta])
                            cylinder(r = ir + skew + duct_wall, h = duct_height - nozzle_height + 4 * eta);

                    }

            }
            translate([fan_x - fan_depth(part_fan) / 2 - fan_mount_recepticle_depth, -fan_mount_recepticle_width / 2, height - eta])
                difference() {
                    cube([fan_mount_recepticle_depth, fan_mount_recepticle_width, fan_mount_recepticle_height]);
                    translate([-wall + eta, wall, fan_mount_recepticle_stop])
                        cube([fan_mount_recepticle_depth, fan_mount_recepticle_width - 2 * wall, fan_mount_recepticle_height]);

                    translate([0, fan_mount_recepticle_width / 2, fan_mount_recepticle_screw_z - height+ 10])
                        rotate([0, 90, 0])
                            slot(r = M3_clearance_radius, l = 20, h = 100, center = true);
                }

            *translate([fan_x - eta, 0, height / 2])
                rotate([90, 0, -90])
                    fan_hole_positions(part_fan)
                        cylinder(r =fan_screw_boss_r, h = boss_length + 1);
        }
        translate([fan_x + 2 * eta, 0, height / 2])
            rotate([90, 0, -90])
                fan_hole_positions(part_fan)
                    cylinder(r = screw_pilot_hole(fan_screw), h = boss_length - wall);
    }
}

bearing_gap = 5;
bearing_slit = 1;

hole_width = hole - wall - bearing_slit;
hole_offset = (hole - hole_width) / 2;


module base_shape() {
    difference() {
        hull() {
            translate([-length / 2, -width / 2])
                square();

            translate([ length / 2 - 1, -width / 2])
                square();

            translate([bearing_holder_length(X_bearings) / 2 + bearing_gap, width / 2 - corner_radius])
                circle(r = corner_radius, center = true);

            translate([-bearing_holder_length(X_bearings) / 2 - bearing_gap, width / 2 - corner_radius])
                circle(r = corner_radius, center = true);

            translate([-length / 2 + corner_radius, extruder_width / 2 ])
                circle(r = corner_radius, center = true);

            translate([ length / 2 - corner_radius , extruder_width / 2])
                circle(r = corner_radius, center = true);
        }
        translate([0, width / 2 - (bearing_holder_width(X_bearings) + bearing_slit) / 2 + eta])
            square([bearing_holder_length(X_bearings) + 2 * bearing_gap,
                     bearing_holder_width(X_bearings) + bearing_slit ], center = true);
    }
}

module inner_base_shape() {
    difference() {
        square([length - 2 * wall, width - 2 * wall], center = true);
        minkowski() {
            difference() {
                square([length + 1, width + 1], center = true);
                translate([10,0])
                    square([length + 1, 2 * wall + eta], center = true);
                base_shape();

            }
            circle(r = wall, center = true);
        }
    }
}

module x_carriage_stl(){
    stl("x_carriage");

    translate([base_offset, 0, top_thickness])
        difference(){
            union(){
                translate([0, 0, rim_thickness / 2 - top_thickness]) {
                    difference() {
                        union() {
                            // base plate
                            difference() {
                                linear_extrude(height = rim_thickness, center = true, convexity = 5)
                                    base_shape();

                                translate([0, 0, top_thickness])
                                    linear_extrude(height = rim_thickness, center = true, convexity = 5)
                                        difference() {
                                            inner_base_shape();
                                            translate([-base_offset, -hole_offset])
                                                rounded_square(hole + 2 * wall, hole_width + 2 * wall, corner_radius + wall);

                                        }
                            }
                            // ribs between bearing holders
                            for(side = [-1,1])
                                assign(rib_height = bar_offset - X_bar_dia / 2 - 2)
                                translate([0, - bar_y + side * (bearing_holder_width(X_bearings) / 2 - (wall + eta) / 2), rib_height / 2 - top_thickness + eta])
                                    cube([2 * bar_x - bearing_holder_length(X_bearings) + eta, wall + eta, rib_height], center = true);

                            // Front nut traps for large fan mount
                            for(end = [-1, 1])
                                translate([end * (bar_x - bearing_holder_length(X_bearings) / 2 - front_nut_width / 2 + eta) - front_nut_width / 2,
                                            -width / 2 + wall, -top_thickness - eta])
                                     cube([front_nut_width, front_nut_depth, front_nut_height]);

                            // Fan mount post
                            translate([fan_x - base_offset - fan_depth(part_fan) / 2 - wall - fan_mount_depth,
                                      -fan_mount_width / 2 + hot_end_duct_offset(hot_end)[1],
                                       -rim_thickness / 2 + eta])
                                difference() {
                                    cube([fan_mount_depth, fan_mount_width, fan_mount_height]);
                                    translate([0, fan_mount_width / 2, fan_mount_screw_z])
                                        rotate([90, 0, 90])
                                            nut_trap(M3_clearance_radius, M3_nut_radius, M3_nut_trap_depth, true);
                                }
                         }
                        //Holes for bearing holders
                        translate([0,        bar_y, rim_thickness - top_thickness - eta])
                            cube([bearing_holder_length(X_bearings) - 2 * eta, bearing_holder_width(X_bearings) - 2 * eta, rim_thickness * 2], center = true);

                        translate([- bar_x, -bar_y, rim_thickness - top_thickness - eta])
                            cube([bearing_holder_length(X_bearings) - 2 * eta, bearing_holder_width(X_bearings) - 2 * eta, rim_thickness * 2], center = true);

                        translate([+ bar_x, -bar_y, rim_thickness - top_thickness - eta])
                            cube([bearing_holder_length(X_bearings) - 2 * eta, bearing_holder_width(X_bearings) - 2 * eta, rim_thickness * 2], center = true);
                    }
                }
                //
                // Floating bearing springs
                //
                for(side = [-1, 1])
                    translate([0, bar_y + side * (bearing_holder_width(X_bearings) - min_wall - eta) / 2, rim_thickness / 2 - top_thickness])
                        cube([bearing_holder_length(X_bearings) + 2 * bearing_gap + 1, min_wall, rim_thickness], center = true);

                // raised section for nut traps
                for(xy = mounting_holes)
                    translate([xy[0] - base_offset, xy[1], (nut_trap_thickness - top_thickness) / 2])
                        cylinder(r = 7, h = nut_trap_thickness - top_thickness, center = true);

                // belt lugs
                translate([-length / 2, -width / 2 + eta, -top_thickness])
                    belt_lug(true);

                translate([ length / 2, -width / 2 + eta, -top_thickness])
                    mirror([1,0,0])
                        belt_lug(false);

                //Bearing holders
                translate([0,        bar_y, bar_offset - top_thickness]) rotate([0,0,90]) bearing_holder(X_bearings, bar_offset - eta);
                translate([- bar_x, -bar_y, bar_offset - top_thickness]) rotate([0,0,90]) bearing_holder(X_bearings, bar_offset - eta);
                translate([+ bar_x, -bar_y, bar_offset - top_thickness]) rotate([0,0,90]) bearing_holder(X_bearings, bar_offset - eta);

            }
            translate([-base_offset, 0, 0]) {
                // hole to clear the hot end
                translate([0, - hole_offset])
                    rounded_rectangle([hole, hole_width, 2 * rim_thickness], corner_radius);

                // holes for connecting extruder
                for(xy = mounting_holes)
                    translate([xy[0], xy[1], nut_trap_thickness - top_thickness])
                        nut_trap(M4_clearance_radius, M4_nut_radius, M4_nut_trap_depth);

            }
            //
            // hole for fan plug
            //
            translate([fan_x - base_offset - fan_plug_length / 2, -bar_y + bearing_holder_width(X_bearings) / 2 + eta, -top_thickness - 1])
                cube([fan_plug_length, fan_plug_width, top_thickness + 2]);
            //
            // Belt grip dowel hole
            //
            translate([-length / 2 + lug_width / 2, -width / 2 + dowel / 2, -top_thickness])
                cylinder(r = dowel / 2 + 0.1, h = dowel_height * 2, center = true);
            //
            // Front mounting nut traps for larger fan assemblies
            //
            for(end = [-1, 1])
                translate([end * (bar_x - bearing_holder_length(X_bearings) / 2 - nut_radius(M3_nut) - 0.3),
                           -width / 2 + front_nut_depth,
                           3])
                    rotate([90, 0, 0])
                        intersection() {
                            nut_trap(screw_clearance_radius(M3_cap_screw), M3_nut_radius, M3_nut_trap_depth, true);
                            cylinder(r = M3_nut_radius + 1, h = bearing_holder_width(X_bearings), center = true);
                        }
        }
}

module x_carriage_assembly(show_extruder = true) {
    assembly("x_carriage_assembly");

    color(x_carriage_color) render() x_carriage_stl();

    if(show_extruder)
        translate([75, 15, eta])
            rotate([-90,0,180])
                wades_assembly();


    translate([0, 0, hot_end_length(hot_end)] + hot_end_duct_offset(hot_end))
        rotate([180, 0, 0])
            color(plastic_part_color("lime")) render() x_carriage_fan_duct_stl();

    translate([fan_x - fan_depth(part_fan) / 2, hot_end_duct_offset(hot_end)[1], fan_mount_screw_z])
        rotate([0, 90, 0]) {
            screw_and_washer(M3_cap_screw, 10);
            translate([0, 0, -(wall + fan_mount_depth - nut_trap_depth(M3_nut))])
                rotate([180, 0, 0])
                    nut(M3_nut, true);
        }

    translate([fan_x, hot_end_duct_offset(hot_end)[1], hot_end_length(hot_end) + hot_end_duct_offset(hot_end)[2] - fan_voffset])
        rotate([0, 90, 0]) {
            color(fan_color) render() fan(part_fan);
            fan_hole_positions(part_fan)
                screw(fan_screw, fan_screw_length);
        }

    for(end = [-1, 1])
        translate([25 * end, 0, nut_trap_thickness])
            rotate([0, 0, 45])
                wingnut(M4_wingnut);

    translate([base_offset, bar_y, bar_offset]) {
        linear_bearing(X_bearings);
        rotate([0,-90,0])
            ziptie(small_ziptie, bearing_ziptie_radius(X_bearings));
    }
    for(end = [-1,1])
        translate([base_offset + bar_x * end, -bar_y, bar_offset]) {
            linear_bearing(X_bearings);
            rotate([90,-90,90])
                ziptie(small_ziptie, bearing_ziptie_radius(X_bearings));
        }
    //
    // Idler end belt clamp
    //
    translate([length / 2 + base_offset, -width / 2, x_carriage_offset() - ball_bearing_diameter(X_idler_bearing) / 2]) {
        mirror([1,0,0])
            color(x_belt_clamp_color) render() x_belt_clamp_stl();
        translate([-lug_width / 2, lug_screw, clamp_thickness])
            nut(M3_nut, true);
    }

    translate([length / 2 + base_offset - lug_width / 2, -width / 2 + lug_screw, 0])
        rotate([180, 0, 0])
            screw_and_washer(M3_cap_screw, 20);
    //
    // Motor end belt clamp
    //
    translate([-length / 2 + base_offset, -width / 2, x_carriage_offset() - pulley_inner_radius])
        translate([lug_width / 2, lug_screw, clamp_thickness])
            nut(M3_nut, true);

    translate([-length / 2 + base_offset, -width / 2, -(clamp_thickness + belt_thickness(X_belt))]) {
        color(x_belt_clamp_color) render() x_belt_grip_stl();
        translate([lug_width / 2, lug_screw, 0])
            rotate([180, 0, 0])
                screw_and_washer(M3_cap_screw, 25);
    }

    translate([-length / 2 + base_offset - 7, -width / 2 + slot_y, (x_carriage_offset() - pulley_inner_radius - belt_thickness(X_belt)) /2]) {
        rotate([0, -90, 0])
            screw(M3_cap_screw, 25);    // tensioning screw

        translate([25 + wall, belt_tensioner_height / 2, 0])
            rotate([90, 180, 0])
                color(x_belt_clamp_color) render() x_belt_tensioner_stl();

        translate([25 + wall, 0, 0])
            rotate([90, 180, 0])
                belt_loop();
    }

    translate([-length / 2 + base_offset + lug_width - M3_nut_trap_depth, -width / 2 + slot_y, (x_carriage_offset() - pulley_inner_radius - belt_thickness(X_belt)) /2])
        rotate([90, 0, 90])
            nut(M3_nut, false);   // tensioning nut

    end("x_carriage_assembly");
}

module x_carriage_parts_stl() {
    x_belt_clamp_stl();
    translate([-(lug_width + 2),0,0]) x_belt_grip_stl();
    x_carriage_stl();
    translate([6, 8, 0]) rotate([0, 0, -90]) x_belt_tensioner_stl();
}

if(0)
    if(1)
        intersection() {
            x_carriage_fan_duct_stl();
            *translate([-50, 0, -10])
                cube(100);
        }
    else
        x_carriage_parts_stl();
else
    x_carriage_assembly(false);
