//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Originally based on Josef Prusa's version but much hacked
//
include <conf/config.scad>
use <d-motor_bracket.scad>
use <vitamins/m90_hot_end.scad>
use <vitamins/stoffel_hot_end.scad>
use <vitamins/jhead_hot_end.scad>

spring = false;             // use two nuts or one nut and a spring

module b608(h = 7) {
    cylinder(r = 11.01, h = h);
}


screw_depth = 5;

motor_y = 28;
driven_y = 31.5;
motor_min = 26 + 5;
motor_max = 36;
motor_x = (motor_min + motor_max) / 2;
motor_leeway = motor_max - motor_min;

thickness = 5;
base_thickness = 6;
width = 26;
height = 52;
mount_pitch = 25;

filament_x = 75;
filament_z = 13;

extension = max(0, nozzle_length - hot_end_length(hot_end));
extension_width = 30;

jhead_screw = M3_cap_screw;
jhead_screw_length = 16;
jhead_washer = M4_washer;
jhead_screw_pitch = max(hot_end_insulator_diameter(hot_end) / 2 + screw_head_radius(jhead_screw),
                          jhead_groove_dia() / 2 + washer_diameter(jhead_washer) / 2);

extension_rad = jhead_screw_pitch + 5;
extension_clearance = 1;

pscrew_y = [17.5, 45.5];
pscrew_z = [filament_z - 6.5, filament_z + 6.5];

driven_x = 70;
driven_y = 31.5;

bearing_housing_depth = 24 + 2 * filament_width;
bearing_housing_x = 57;
pscrew_length = 50;
pscrew_x = bearing_housing_x + pscrew_length;

clamp_depth = hot_end_inset(hot_end) - 1;
clamp_width = 2 * (hot_end_screw_pitch(hot_end) + max(screw_clearance_radius(M3_cap_screw) + min_wall, clamp_depth / 2));
clamp_height = width - filament_z - 0.5;

function extruder_connector_offset() = [-filament_x + motor_x, filament_z - thickness, motor_y] + d_motor_connector_offset(NEMA17);

module keyhole(r, h, l) {
    R = r + layer_height / 4;
    waist = 2 * R - 1;
    entrance = 2 * R + 0.5;
    y = sqrt(R * R - waist * waist / 4);
    teardrop(h = h, r = R, center = true);
    *hull() {
        translate([0, l, 0])
            cube([entrance, 2 * eta, h ], center = true);
        translate([0, y, 0])
            cube([waist, 2 * eta, h ], center = true);
    }
}

nut_inset = min_wall;

jhead_screw_angle = 5;
jhead_nut_slot = nut_thickness(screw_nut(jhead_screw)) + 0.3;

module wades_block_stl() {
    stl("wades_block");

    insulator = hot_end_insulator_diameter(hot_end);
    screw_pitch = hot_end_screw_pitch(hot_end);
    insulator_depth = hot_end_inset(hot_end);
    nut_clearance = 2 * nut_thickness(M4_nut);

    nut_slot = nut_thickness(M4_nut) + 0.3;


    difference(){
        union(){
            cube([81, height, thickness]);                                  // motor plate
            cube([filament_x + 25 - 3.5, base_thickness, width]);           // base
            translate([filament_x + 25 - 3.5, base_thickness / 2, filament_z])
                intersection() {
                    union() {
                        for(a = [-90, 90])
                            rotate([a, 0, 0])
                                teardrop(r = 10.6, h = base_thickness, truncate = false, center = true);
                    }
                    cube([22, base_thickness + 1, width], center = true);
                }
            translate([bearing_housing_x, 0, 0])
                cube([bearing_housing_depth, height, width]);               // bearing housing

            translate([80,1.5,0])                                           // fillet
                cube([11,11, width]);

            if(extension)
                translate([filament_x - extension_width / 2, -extension + extension_clearance + eta, 0])
                    intersection() {
                        cube([extension_width, extension - extension_clearance, width]);
                        translate([extension_width / 2, extension / 2, filament_z])
                            rotate([-90, 0, 0])
                                teardrop(r = extension_rad, h = extension + 1, center = true);
                    }
        }

        translate([-11,-1,30]) rotate([0,60,0]) cube([30, base_thickness + 2, 60]);             // slope on base


        translate([filament_x, 20, filament_z])
            rotate([90,0,0])
                teardrop(h = 70, r=4/2, center=true);                       // filament

        // mounting holes
        for(side = [-1, 1])
            translate([filament_x + mount_pitch * side, base_thickness, filament_z])
                rotate([90,0,0])
                    nut_trap(M4_clearance_radius, M4_nut_radius, 3, true);

        // pressure screws
        for(i = [0, 1]) {
            translate([bearing_housing_x + nut_inset + nut_slot / 2, pscrew_y[i], pscrew_z[i]]) {
                rotate([-90, 90, 90])
                    nut_trap(0, M4_nut_radius, nut_slot / 2, true);

                rotate([180 + 180 * i, 0, 0])
                    translate([0, 0, 5])
                        cube([nut_slot, nut_flat_radius(M4_nut) * 2, 10], center = true);

            }

            translate([bearing_housing_x - 4,   pscrew_y[i], pscrew_z[i]])
                rotate([90,0,90])
                    teardrop(h = bearing_housing_depth + 10, r = 4.4 / 2);

        }
        //
        // holes for motor
        //
        translate([motor_x, motor_y, -1]) {
            slot(r = NEMA_big_hole(NEMA17), l = motor_leeway, h = 10, center = false);      // motor hub slot

            for(x = NEMA_holes(NEMA17))                                                     // motor screw slots
                for(y = NEMA_holes(NEMA17))
                    translate([x,y,0])
                        slot(r = M3_clearance_radius, l = motor_leeway, h = 10, center = false);
        }

        //
        // remove fourth motor slot
        //
        translate([motor_x - 40 + motor_leeway / 2, motor_y - NEMA_big_hole(NEMA17), -1])
            cube([40, 32, 7]);

        translate([motor_x - 40 + motor_leeway / 2 + 6, motor_y, -1])
            cube([40, 32, 7]);

        translate([-1,-1,-1]) cube([12,60,30]);              // truncates tail

        translate([11, 0, -1])
            fillet(4, 30);

        translate([11, motor_y - NEMA_big_hole(NEMA17), -1])
            rotate([0, 0, -90])
                fillet(4, 30);

        translate([motor_x + motor_leeway / 2 + 6, height, -1])
            rotate([0, 0, -90])
                fillet(4, 30);

        //
        // hole for hobbed bolt
        //
        difference() {
            translate([driven_x,     driven_y, 7 + layer_height + eta])
                poly_cylinder(r = M8_clearance_radius + 0.25, h = 30);

            translate([driven_x + 2, driven_y - 5, filament_z + 4 - eta])
                cube([10, 10, layer_height + eta]); // support bridge
        }
        //
        // Sockets for bearings
        //
        translate([driven_x,       driven_y, width - 7])       b608(8);                // top bearing socket
        translate([filament_x + 8, driven_y, filament_z - 4])  b608(8);                // clearance for idler
        translate([driven_x,       driven_y, -1 + eta])        b608(8);                // bottom bearing socket

        //
        // Hole for hot end
        //
        translate([filament_x, -extension + eta, filament_z])
            rotate([90,0,0]) {
                if(hot_end_groove_mount(hot_end)) assign(relief = 0.5) {

                    translate([0, 0, -insulator_depth + jhead_groove_offset() / 2 + eta])         // slot for the flange
                        keyhole(insulator / 2, jhead_groove_offset(), width - filament_z);

                    translate([0, 0, -insulator_depth + relief / 2])
                        keyhole(insulator / 2 + 0.5, relief, width - filament_z);           // relief to avoid corner radius
                    //
                    // Screw holes and nut traps
                    //
                    for(i = [0:2])
                         rotate([0, 0, i * 120 + jhead_screw_angle])
                            translate([jhead_screw_pitch, 0, 0])
                                rotate([0, 0, -i * 120 - jhead_screw_angle]) {
                                    teardrop_plus(r = screw_clearance_radius(jhead_screw), h = jhead_screw_length * 2, center = true);
                                    translate([0, 0, -base_thickness - extension - jhead_nut_slot / 2]) {
                                        rotate([0, 0, [0, 30, 30][i]])
                                            nut_trap(0, nut_radius(screw_nut(jhead_screw)), jhead_nut_slot / 2, horizontal = true);

                                        assign(w = nut_flat_radius(screw_nut(jhead_screw)))
                                        rotate([0, 0, [-90 ,0, 180][i]])
                                            translate([-w, 0, -jhead_nut_slot / 2])
                                                cube([w * 2, 100, jhead_nut_slot], center = false);

                                    }

                                }
                }
                else {
                    teardrop_plus(h = insulator_depth * 2, r = insulator / 2, center = true);      // insulator socket
                    translate([0, 0, -insulator_depth + 0.5])
                        teardrop_plus(h = 1 , r = insulator / 2 + 1, center=true);       // relief to avoid radius so end is flat
                }
            }

        if(!hot_end_groove_mount(hot_end))
            for(side = [-1, 1])
                translate([filament_x + screw_pitch * side, screw_depth - extension, -1])
                    rotate([0, 0, -90 + 90 * side])
                        poly_cylinder(h = 30, r = M3_clearance_radius);                  // retaining screws
    }
}


spacer_length = 4 * 1.5;
gear_thickness = 6;

module wades_gear_spacer_stl() {
    stl("wades_gear_spacer");
    washer = M8_washer;

    difference() {
        cylinder(r = washer_diameter(washer) / 2, h = spacer_length,  center = false);
        translate([0,0, -0.5])
            poly_cylinder(r = M8_clearance_radius, h = spacer_length + 1, center = false);
    }
}



bfbext=false;

function extruder_connector_height() = motor_y - d_motor_bracket_offset(NEMA17);

module wades_big_gear_stl() {
    stl("wades_big_gear");
    color(wades_big_gear_color) difference() {
        import("../imported_stls/39t17p.stl", convexity = 10);
        poly_cylinder(r = 4, h = 100, center = true);
    }
}

module wades_small_gear_stl() {
    stl("wades_small_gear");
    color(wades_small_gear_color) difference() {
        translate([-10, -10, 0])
            import("../imported_stls/wades_gear.stl", convexity = 10);
        translate([0, 0, 4])
            rotate([90, 0, -24 + 180])
                teardrop_plus(r = M3_clearance_radius, h = 100);

    }
}

module small_gear_assembly() {
    wades_small_gear_stl();
    rotate([90, 0, -24]) {
        translate([0, 4, -5/2 - 6])
            rotate([180, 0, 0])
                screw(M3_grub_screw, 6);

        translate([0, 4, -6])
            explode([0, -10 ,0])
                rotate([0,0,30])
                    nut(M3_nut);
    }
}

idler_height = 12;
idler_axel_length = 22;
idler_axel_slot = idler_axel_length + 2;
idler_short_side = idler_axel_slot + 2 * min_wall;

module wades_idler_block_stl() {
    stl("wades_idler_block");

    long_side = 37;
    corners_diameter = 3;
    608_dia = 12;
    608_height = 9;

    mounting_dia = 4.5;

    difference(){
        // Main block
        rounded_rectangle([long_side, idler_short_side, idler_height], corners_diameter, center = false);

        // bearing cutout
        translate([0, 0, idler_height - 2]){
            rotate([90,0,0])
                cylinder(h = 608_height, r=608_dia, center=true);

            rotate(a=[90,0,0])
                cylinder(h = idler_axel_slot, r=8.6/2, center=true);
        }

        //mounting holes
        for(i = [0,1])
            translate([pscrew_y[1-i] - driven_y, pscrew_z[i] - filament_z, 0])
                poly_cylinder(h = idler_height * 2.1, r = mounting_dia / 2, center=true);
    }
}

module wade_idler_assembly() {
    color(wades_idler_block_color) render() wades_idler_block_stl();

    translate([0, 0, idler_height - 2])
        rotate([90, 0, 0]) {
            rod(d = 8, l = idler_axel_length);
            ball_bearing(BB608);
        }
}

module extruder_motor_assembly(show_connector = true, exploded = exploded) {
    assembly("extruder_motor_assembly");
    // motor and gear
    translate([motor_x, motor_y, thickness + eta])
        rotate([0,180,0]) {
            rotate([0, 0, 180])
                NEMA(NEMA17);

            translate([0,0, 2.5 + 30 * exploded])
                rotate([0, 0, 11])
                    small_gear_assembly();

            if(show_connector)
                d_motor_bracket_assembly(NEMA17);
        }
    end("extruder_motor_assembly");
}

module wades_assembly(show_connector = true, show_drive = true) {
    spring_total = 10;
    spring_length = spring_total - 2 * washer_thickness(M4_washer);

    assembly("extruder_assembly");

    color(wades_block_color) render()
        difference() {
            wades_block_stl();
            *translate([-1,-10, filament_z])                     // cross section
                cube([200,100,100]);
        }

    if(show_drive) {
    // idler screws, washers and springs
        for(i = [0,1])
            translate([pscrew_x, pscrew_y[i], pscrew_z[i]])
                rotate([90, 90, 90]) {
                    screw(M4_hex_screw, pscrew_length);

                    translate([0,0, -pscrew_length + nut_inset])
                        explode([12 - 24 * i, 0, 0])
                            nut(M4_nut);

                    translate([0, 0, -spring_total + 53 * exploded]) {
                        washer(M4_washer)
                            comp_spring(extruder_spring, spring_length)
                                washer(M4_washer);
                    }
                }

        // mounting screws
        for(side = [-1, 1])
            translate([filament_x + mount_pitch * side, base_thickness - 3, filament_z])
                rotate([-90,0,0])
                    screw(M4_hex_screw, 20);

        //idler
        translate([filament_x + 22 + 39 * exploded, driven_y, filament_z])
            rotate([90, 0, -90])
                wade_idler_assembly();

        // motor
        translate([0, 0, 50 * exploded])
            extruder_motor_assembly(show_connector, 0);

        translate([motor_x, motor_y, 0])
            rotate([0, 180, -90])
                NEMA_screws(NEMA17, 3, 10, M3_hex_screw);
    }

    // hobbed bolt and gear
    translate([driven_x, driven_y, 0]) {
        translate([0, 0, width - BB608[2] / 2 + (!show_drive ? exploded * 20 : 0)])
            ball_bearing(BB608);

        translate([0, 0,         BB608[2] / 2 - (!show_drive ? exploded * 20 : 0)])
            ball_bearing(BB608);


        if(show_drive) {

            translate([0, 0,  - 30 * exploded])
                rotate([180, 0, 0])
                    color(wades_gear_spacer_color) render() wades_gear_spacer_stl();

            translate([0, 0, -spacer_length - 50 * exploded])
                rotate([180, 0, 0])
                    wades_big_gear_stl();

            translate([0,0, -spacer_length - gear_thickness])
                rotate([180, 0, 0])
                    screw(M8_hex_screw, 60, spacer_length + gear_thickness + filament_z);

            translate([0,0, width]) {
                if(spring) {
                    comp_spring(hob_spring, 8);
                    translate([0, 0, 8])
                        nut(M8_nut);
                }
                else explode([0, 0, 35]) group() {
                    translate([0, 0, -15 * exploded])
                        nut(M8_nut);

                    translate([0, 0, nut_thickness(M8_nut) - 10 * exploded]) {
                        star_washer(M8_washer);

                        translate([0, 0, washer_thickness(M8_washer) + 5 * exploded])
                            nut(M8_nut);
                    }
                }
            }
        }
    }

    //
    // Hot end
    //
    assembly("hot_end_assembly");
    translate([filament_x, -extension, filament_z])
        rotate([-90, 0, 0]) {
            if(hot_end_style(hot_end) == m90)
                m90_hot_end(hot_end);
            if(hot_end_style(hot_end) == Stoffel)
                stoffel_hot_end(hot_end);
            if(hot_end_style(hot_end) == jhead)
                jhead_hot_end(hot_end, exploded = 0);
       }
    end("hot_end_assembly");

    if(!hot_end_groove_mount(hot_end))
        for(side = [-1, 1])
            translate([filament_x + hot_end_screw_pitch(hot_end) * side, screw_depth - extension, width])
                screw(M3_cap_screw, 30);
    else
        translate([filament_x, -extension, filament_z])
            for(i = [0:2]) assign(a = i * 120 - jhead_screw_angle)
                rotate([90, a, 0]) {
                    translate([jhead_screw_pitch, 0, 0])
                        washer(jhead_washer)
                            star_washer(screw_washer(jhead_screw))
                                screw(jhead_screw, jhead_screw_length);

                    translate([jhead_screw_pitch, 0, -extension - base_thickness - jhead_nut_slot / 2 - nut_thickness(screw_nut(jhead_screw)) / 2])
                        explode([ [ 10 * cos(a),  10 * sin(a), 0],
                                  [ 10 * sin(a), -10 * cos(a), 0],
                                  [-10 * sin(a),  10 * cos(a), 0] ][i])
                             rotate([0, 0, [0, 30, 30][i]])
                                 nut(screw_nut(jhead_screw));
                }

    end("extruder_assembly");
}

module wades_extruder_stl() {
    difference() {
        wades_block_stl();
        *translate([0, driven_y, -1])
            cube(100);
    }
    translate([96, driven_y + 1, 0]) rotate([0,0,90]) wades_idler_block_stl();
    translate([motor_max, motor_y, 0]) wades_gear_spacer_stl();
}

module wades_big_gear_x5_stl(){

    pitch = 44;
    wades_big_gear_stl();
    for(x = [-1,1])
        for(y = [-1,1])
            translate([x * pitch, y * pitch, 0])
                wades_big_gear_stl();
}


if(1)
    rotate([90, 0, 0])
        wades_assembly(true);
else
    if(1)
        wades_extruder_stl();
    else
        wades_big_gear_x5_stl();
