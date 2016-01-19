//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Direct drive extruder
//
include <conf/config.scad>
use <d-motor_bracket.scad>
use <hot_end.scad>

MiniHyena = [5, 8, 13, 4, 6.3, 5.3, 1.5, 9, M3_grub_screw, 3];

function hobbed_id(type)         = type[0];
function hobbed_od(type)         = type[1];
function hobbed_length(type)     = type[2];
function hobbed_offset(type)     = type[3];
function hobbed_hob_od(type)     = type[4];
function hobbed_hob_id(type)     = type[5];
function hobbed_hob_radius(type) = type[6];
function hobbed_screw_z(type)    = type[7];
function hobbed_screw_type(type) = type[8];
function hobbed_screw_l(type)    = type[9];


module hobbed_pulley(type) {
    od = hobbed_od(type);
    id = hobbed_id(type);
    len = hobbed_length(type);
    vitamin(str("HOB",od, id, len, ": hobbed pulley ", od, ,"x", id));

    color("DarkGoldenrod") render() difference() {
        cylinder(r = od / 2, h = len);
        cylinder(r = id / 2, h = len * 2 + 1, center = true);
        translate([0, 0, hobbed_offset(type)])
            rotate_extrude(a = 360)
                translate([hobbed_hob_od(type) / 2 + hobbed_hob_radius(type), 0])
                    circle(r = hobbed_hob_radius(type));

        translate([0, 0, hobbed_screw_z(type)])
            rotate([-90, 0, 0])
                cylinder(r = screw_radius(hobbed_screw_type(type)), h = od / 2 + 1);
    }
}

module hobbed_pulley_assembly(type) {
    hobbed_pulley(type);
    translate([0, hobbed_id(type) / 2 + hobbed_screw_l(type) - 0.5, hobbed_screw_z(type)])
        rotate([-90, 0, 0])
            screw(hobbed_screw_type(type), hobbed_screw_l(type));
}

peg_spring = [6.5, 0.96, 16, 8];

pulley = MiniHyena;
idler = BB624;

d_extruder = extruder == Direct14 || extruder == Direct17 ? extruder : Direct17;

motor = extruder_motor(d_extruder);
spring = peg_spring;

compressed_spring = 9.5;

motor_thickness = 5;
motor_screw_depth = 3;
min_base_thickness = 8;
extension_clearance = 0.5;
extension = max(extension_clearance, nozzle_length(hot_end) - hot_end_length(hot_end));

jhead_screw = M3_cap_screw;
jhead_screw_length = 16;
jhead_washer = M4_washer;
jhead_screw_pitch = max(hot_end_insulator_diameter(hot_end) / 2 + screw_head_radius(jhead_screw),
                          hot_end_groove_dia(hot_end) / 2 + washer_diameter(jhead_washer) / 2);
jhead_nut_slot = nut_thickness(screw_nut(jhead_screw)) + 0.3;

angle = 30;
jhead_screw_angles = [angle, -angle, 180 - angle, -180 + angle];

extension_width = extruder_hole(d_extruder)[0] - 1;
extension_rad = jhead_screw_pitch + 5;

width = extruder_width(d_extruder);
length = min(extruder_length(d_extruder), 64);
base_thickness = max(min_base_thickness, jhead_screw_length - extension - 2 * washer_thickness(M3_washer) - washer_thickness(M4_washer));
height = base_thickness + NEMA_width(motor) + 1;

jhead_nut_offset = -(extension + base_thickness - 2 - jhead_nut_slot); // offset of nut from screw head

filament_r = extruder_filament(d_extruder) / 2;
filament_x = 0;
filament_z = width / 2;
filament_path_r = filament_r + 0.125;

motor_y = height - NEMA_width(motor) / 2 - 1;
motor_x = filament_x + filament_r + hobbed_hob_id(pulley) / 2;
motor_z = 0;
motor_screw_length = 8;
motor_screw_z = motor_screw_length - 2 * washer_thickness(M3_washer) - motor_screw_depth;

motor_plate_width = NEMA_width(motor) + 2;
motor_plate_rad = (motor_plate_width - NEMA_hole_pitch(motor)) / 2;

idler_closed_x = motor_x - hobbed_od(pulley) / 2 - ball_bearing_diameter(idler) / 2;
idler_x = filament_x - filament_r - ball_bearing_diameter(idler) / 2;
idler_z = filament_z;
idler_y = motor_y;
idler_clearance = 1;

motor_screw_offset = NEMA_hole_pitch(motor) / 2;

idler_pivot_x = motor_x - motor_screw_offset;
idler_pivot_y = motor_y + motor_screw_offset;

idler_swing_r = sqrt(sqr(idler_x -idler_pivot_x) + sqr(idler_y - idler_pivot_y));
idler_max_swing = atan((idler_closed_x - idler_pivot_x) / idler_swing_r);

pivot_screw_length = 25;
pivot_screw_z = min(pivot_screw_length - washer_thickness(M3_washer) - motor_screw_depth, width + eta);

lever_bottom_y = base_thickness + 1;
lever_width = 2 * motor_plate_rad + 1;

spring_x = idler_pivot_x - lever_width / 2;
spring_z = filament_z + filament_path_r + 3 * layer_height + screw_clearance_radius(M3_cap_screw);
spring_y = lever_bottom_y + 5;


filament_top_guide_r = tubing_od(PF7) / 2 + 2;

function direct_extruder_connector_offset() = [-motor_x, -width / 2, motor_y] + d_motor_connector_offset();

idler_clearance_r = ball_bearing_diameter(idler) / 2 + idler_closed_x - idler_x;


filament_bottom_guide_w = 2 * (filament_path_r + layer_height / 4 + min_wall);
filament_lower_gap = sqrt(sqr(idler_clearance_r) - sqr(idler_x - filament_x + filament_bottom_guide_w / 2));
filament_bottom_guide_length = idler_y - filament_lower_gap;
filament_botton_guide_height = filament_z - hobbed_offset(pulley) + hobbed_screw_z(pulley) - screw_radius(hobbed_screw_type(pulley)) - 0.5;
filament_bottom_guide_x = filament_x - filament_bottom_guide_w / 2;
bulkhead_x = filament_bottom_guide_x;
bulkhead_depth = filament_x + cos(angle) * jhead_screw_pitch - nut_trap_flat_radius(screw_nut(jhead_screw)) - bulkhead_x;
spring_screw_length = screw_longer_than(compressed_spring + 2 * washer_thickness(M4_washer) - (spring_x - bulkhead_x) + bulkhead_depth);

grub_screw_clearance_r = NEMA_shaft_dia(motor) / 2 + hobbed_screw_l(pulley);

module keyhole(r, h, l) {
    R = r + layer_height / 4;
    waist = 2 * R - 1;
    entrance = 2 * R + 0.5;
    y = sqrt(R * R - waist * waist / 4);
    teardrop(h = h, r = R, center = true);
}

module direct_block_stl(include_support = true) {
    stl("direct_block");

    feed_tube_socket = 5;
    insulator = hot_end_insulator_diameter(hot_end);
    screw_pitch = hot_end_screw_pitch(hot_end);
    insulator_depth = hot_end_inset(hot_end);

    base_rad = 10.6;


    filament_top_guide_length = feed_tube_socket + 2;
    filament_top_guide_top = height + filament_top_guide_length - eta;

    nut_channel_width = 2 * nut_radius(M4_nut) + 0.2;
    nut_channel_z = idler_z - ball_bearing_width(idler) / 2 - nut_thickness(M4_nut) - layer_height;

    difference(){
        union(){
            //
            // motor plate
            //
            translate([motor_x - motor_plate_width / 2, 0, 0]){
                hull() {
                    cube([motor_plate_width, 1, motor_thickness]);

                    for(x = [motor_plate_rad, motor_plate_width - motor_plate_rad])
                        translate([x, height - motor_plate_rad, 0])
                            cylinder(r = motor_plate_rad, h = motor_thickness);
                }
            }
            //
            // Filament guide
            //
            translate([bulkhead_x, 0, 0])
                cube([bulkhead_depth, motor_y - grub_screw_clearance_r, width]);

            translate([filament_bottom_guide_x, 0, 0])
                cube([filament_bottom_guide_w, filament_bottom_guide_length, filament_botton_guide_height]);

            hull() {
                translate([filament_x, filament_top_guide_top - filament_top_guide_length, filament_z])
                    rotate([-90, 0, 0])
                        cylinder(r = filament_top_guide_r, h = filament_top_guide_length);

                translate([filament_x - filament_top_guide_r, filament_top_guide_top - filament_top_guide_length, 0])
                    cube([filament_top_guide_r * 2, filament_top_guide_length, 1]);
            }
            // base
            hull()
                for(end = [-1 , 1])
                    translate([end * (length / 2 - base_rad), min_base_thickness / 2, filament_z])
                        intersection() {
                            union()
                                for(a = [-90, 90])
                                    rotate([a, 0, 0])
                                        teardrop(r = base_rad, h = min_base_thickness, truncate = false, center = true);

                            cube([width * 2, base_thickness + 1, width], center = true);
                        }

            if(base_thickness > min_base_thickness)                 // nut housing
                translate([motor_x - motor_plate_width / 2, 1, 0])
                    cube([2 * (filament_x - (motor_x - motor_plate_width / 2)), base_thickness - 1, width]);

            if(extension)
                translate([filament_x - extension_width / 2, -extension + extension_clearance + eta, 0])
                    intersection() {
                        cube([extension_width, extension - extension_clearance, width]);
                        translate([extension_width / 2, extension / 2, filament_z])
                            rotate([-90, 0, 0])
                                teardrop(r = extension_rad, h = extension + 1, center = true);
                    }
        }

        // filament path
        translate([filament_x, 0, filament_z])
            rotate([90,0,0]) {
                teardrop_plus(h = 2 * filament_top_guide_top + 1, r = filament_path_r, center=true);   // filament

                translate([0, 0, -filament_top_guide_top])
                    teardrop_plus(h = feed_tube_socket * 2, r = tubing_od(PF7) / 2, center = true);   // feed tube
            }
        //
        // idler tension screw
        //
        translate([bulkhead_x + bulkhead_depth, spring_y, spring_z])
            rotate([90, 0, 90])
                nut_trap(screw_clearance_radius(M4_cap_screw), nut_radius(M4_nut), nut_thickness(M4_nut), horizontal = true);
        //
        // Bearing nut channel
        //
        translate([idler_pivot_x, idler_pivot_y, nut_channel_z])
            linear_extrude(height = 100)
                hull() {
                    translate([0, -idler_swing_r])
                        circle(nut_channel_width / 2);

                    rotate([0, 0, idler_max_swing])
                        translate([0, -idler_swing_r])
                            circle(nut_channel_width / 2);
                }

        // mounting holes
        translate([filament_x, min_base_thickness, filament_z])
             extruder_mounting_holes(true);
        //
        // holes for motor
        //
        translate([motor_x, motor_y, 0]) {
            hub_recess = round_to_layer(NEMA_boss_height(motor)) + layer_height;
            poly_cylinder(r = NEMA_big_hole(motor), h = hub_recess * 2, center = true);     // motor hub slot

            translate([0, 0, hub_recess + (include_support ? layer_height : -1)])
                poly_cylinder(r = hobbed_od(pulley) / 2 + 0.5, h = width, center = false);  // hole for shaft and pulley

            for(x = NEMA_holes(motor), y = NEMA_holes(motor))                               // motor screw holes
                translate([x, y, motor_screw_z]) {
                    poly_cylinder(r = M3_clearance_radius, h = 100, center = true);

                    if(x > 0 || y < 0)
                        poly_cylinder(r = washer_diameter(M3_washer) / 2 + 0.5, h = 100, center = false);
                }
        }
        //
        // Hole for hot end
        //
        translate([filament_x, -extension + eta, filament_z])
            rotate([90,0,0]) {
                relief = 0.5;

                translate([0, 0, -insulator_depth + hot_end_inset(hot_end) / 2])        // slot for the flange
                    keyhole(insulator / 2, hot_end_inset(hot_end), width - filament_z);

                *translate([0, 0, -insulator_depth + relief / 2])
                    keyhole(insulator / 2 + 0.5, relief, width - filament_z);           // relief to avoid corner radius
                //
                // Screw holes and nut traps
                //
                for(i = [0 : len(jhead_screw_angles) - 1])
                    rotate([0, 0, jhead_screw_angles[i]])
                        translate([jhead_screw_pitch, 0, 0])
                            rotate([0, 0, -jhead_screw_angles[i]]) {
                                translate([0, 0, washer_thickness(M4_washer) + washer_thickness(M3_washer) - extension_clearance])
                                    teardrop_plus(r = screw_clearance_radius(jhead_screw), h = jhead_screw_length * 2, center = true);

                                translate([0, 0, jhead_nut_offset - jhead_nut_slot / 2]) {
                                    w = nut_flat_radius(screw_nut(jhead_screw));
                                    rotate([0, 0, 90])
                                        nut_trap(0, nut_radius(screw_nut(jhead_screw)), jhead_nut_slot / 2, horizontal = true);

                                    rotate([0, 0, jhead_screw_angles[i] < 0 ? 180 : 0])
                                        translate([-w, -1, -jhead_nut_slot / 2])
                                            cube([w * 2, 100, jhead_nut_slot], center = false);
                                }
                            }
            }
    }
}

module direct_motor_assembly(show_connector = true, exploded = exploded) {
    assembly("extruder_motor_assembly");
    // motor and gear
    rotate([0, 0, 180]) {
        NEMA(motor);

        translate([0, 0, filament_z - hobbed_offset(pulley) + exploded * 20])
            rotate([0, 0, -90])
                hobbed_pulley_assembly(pulley);
    }
    if(show_connector)
        d_motor_bracket_assembly();

    end("extruder_motor_assembly");
}

module direct_idler_lever_stl() {
    stl("direct_idler_lever");
    w = lever_width;
    h = width - motor_thickness - nut_thickness(M3_nut) - 3 * washer_thickness(M3_washer);
    h2 = width - idler_z -  ball_bearing_width(idler) / 2 - washer_thickness(M4_washer);
    //h3 = width - motor_thickness - screw_head_height(M3_cap_screw) - 3 * washer_thickness(M3_washer);
    h4 = width / 2 - filament_path_r - 0.5;
    difference() {
        union() {
            linear_extrude(height = h, convexity = 10) {
                union() {
                    hull() {
                        circle(ball_bearing_diameter(idler) / 2 - 0.5);                 // idler boss

                        translate([idler_x - idler_pivot_x, idler_pivot_y - idler_y])   // pivot boss
                            circle(w / 2);
                    }
                    hull() {
                        translate([idler_x - idler_pivot_x, idler_pivot_y - idler_y])   // idler boss
                            circle(w / 2);

                        translate([idler_x - idler_pivot_x - w / 2, lever_bottom_y - idler_y])    // bottom of lever
                            square([w, 1]);
                    }
                }
            }
            linear_extrude(height = h4)                                                 // release handle
                hull() {
                    translate([idler_x - idler_pivot_x, idler_pivot_y - idler_y])
                        circle(w / 2 - 2);

                    translate([idler_x - idler_pivot_x - 2 * motor_screw_offset, idler_pivot_y - idler_y])
                        circle(w / 2 - 2);
                }
        }
        translate([0, 0, h2])
            poly_cylinder(r = ball_bearing_diameter(idler) / 2 + 0.5, h = 10);          // bearing socket

        rotate([0, 0, 90])
            nut_trap(2, nut_trap_radius(M4_nut, horizontal = false, snug = false), nut_trap_depth(M4_nut), supported = true); // nut trap for axle

        translate([idler_x - idler_pivot_x, idler_pivot_y - idler_y, width - pivot_screw_z]) {
            translate([0, 0, width > pivot_screw_z ? layer_height : -1])                // support membrane if needed
                poly_cylinder(r = 3/2, h = 100, center = false);                        // pivot hole

            rotate([180, 0, 0])
                poly_cylinder(r = washer_diameter(M3_washer) / 2 + 0.5, h = 10);          // counterbore
        }

        translate([idler_closed_x - spring_x, spring_y - idler_y, width - spring_z])
            rotate([90, 0, 90])
                tearslot(100, M4_clearance_radius, 1, true);                            // Tension screw slot

        translate([idler_x - motor_x,
                    motor_y - idler_y,
                    width - (filament_z - hobbed_offset(pulley) + hobbed_screw_z(pulley))])     // clearance for grub screw
            cylinder(r =grub_screw_clearance_r,
                     h = 2 * screw_radius(hobbed_screw_type(pulley)) + 1, center = true);
    }
}

module direct_idler_assembly() {
    translate([-idler_x, idler_z - width / 2 + exploded * 50, idler_y]) {
        rotate([90, 0, 0]) {
            translate([0, 0, idler_z - width])
                color("lime") render() direct_idler_lever_stl();

            explode([0, 0, 20])
                ball_bearing(idler)
                    screw(M4_hex_screw, 16);

            translate([0, 0, -ball_bearing_width(idler) / 2 + exploded * 10])
                rotate([180, 0, 0])
                    washer(M4_washer);

            translate([0, 0, idler_z - width + nut_trap_depth(M4_nut)])
                rotate([180, 0, 90])
                    nut(M4_nut, true);
        }
    }
    translate([-spring_x, spring_z - width / 2, spring_y])
        rotate([0, 90, 0])
            washer(M4_washer)
                comp_spring(spring, compressed_spring)
                    washer(M4_washer)
                        screw(M4_cap_screw, spring_screw_length);
}

module direct_assembly(show_connector = true, show_drive = true) {

    assembly("extruder_assembly");

    color(wades_block_color) render()
        difference() {
            translate([0, -filament_z, 0])
                rotate([90, 0, 180])
                    direct_block_stl(false);

            *translate([-1,-10, filament_z])                     // cross section
                cube([200,100,100]);
        }

    if(show_drive) {
        // mounting screws
        translate([filament_x, 0, min_base_thickness])
            extruder_mounting_screws();

        // motor
        translate([0, -40 * exploded, 0])
            translate([-motor_x, motor_z - width / 2, motor_y])
                rotate([90,0,180])
                    direct_motor_assembly(show_connector, 0);

        // motor screws
        translate([-motor_x, -width / 2 + motor_screw_z, motor_y])
            rotate([-90, 0, 0])
                NEMA_screws(motor, 3, motor_screw_length, M3_pan_screw);

        // idler axle
        translate([-idler_pivot_x,  -width / 2, idler_pivot_y])
            rotate([-90, 0, 0]) {
                translate([0, 0, pivot_screw_z])
                    explode([0, 0, 50])
                        screw_and_washer(M3_cap_screw, pivot_screw_length);

                translate([0, 0, motor_thickness])
                    explode([0, 0, 5])
                        washer(M3_washer)
                            explode([0, 0, 2])
                                star_washer(M3_washer)
                                    explode([0, 0, 2])
                                        nut(M3_nut)
                                            explode([0, 0, 2])
                                                washer(M3_washer);
            }
        //
        // Filament
        //
        color("lime") render() cylinder(r = filament_r, h = 100);
        //
        // Idler
        //
        direct_idler_assembly();

        translate([-bulkhead_x - bulkhead_depth, spring_z - width / 2, spring_y])
            rotate([0, 90, 0])
                explode([0, 0, -5])
                    nut(M4_nut);
    }
    //
    // Hot end
    //
    translate([filament_x, 0, -extension])
        hot_end_assembly();

    //
    // Hot end screws
    //
    translate([filament_x, 0, -extension])
        for(i = [0 : len(jhead_screw_angles) - 1]) {
            a = jhead_screw_angles[i];
            rotate([180, 0, a]) {
                translate([jhead_screw_pitch, 0, 0])
                    washer(jhead_washer)
                        screw_and_washer(jhead_screw, jhead_screw_length, true);

                translate([jhead_screw_pitch, 0, jhead_nut_offset - jhead_nut_slot / 2 + nut_thickness(screw_nut(jhead_screw)) / 2])
                     explode( [ 15 * sin(-a),  15 * cos(-a), 0] * [-1,1,-1,1][i])
                        rotate([180, 0, -a + 90])
                             nut(screw_nut(jhead_screw));
            }
        }

    end("extruder_assembly");
}

module direct_extruder_stl() {
    direct_block_stl();

    translate([filament_x + filament_bottom_guide_w + (idler_pivot_x - idler_x) + 2 * motor_screw_offset + lever_width / 2,
               height - (idler_pivot_y - idler_y) + lever_width / 2, 0])
        direct_idler_lever_stl();
}



if(1)
    direct_assembly(true, true);
else
    direct_extruder_stl();
