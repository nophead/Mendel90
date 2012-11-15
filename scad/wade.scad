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

feed_tube_wall = 2;


module b608(h=7){
    difference(){
        union(){
            translate([0,0,3.5])
                cylinder(r=11.01,h=h,center=true);
            *translate([0,0,3.5])
                cylinder(r=6,h=7,center=true);
        }
        //translate([0,0,3.5]) cylinder(r=4,h=8,center=true);
    }
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
width = 28;
height = 52;
mount_pitch = 25;

filament_x = 75;
filament_z = 15;


pscrew_x = 60;
pscrew_y = [17.5, 45.5];
pscrew_z = [8.5,  21.5];

driven_x = 70;
driven_y = 31.5;

bearing_housing_depth = 24 + 2 * filament_width;
bearing_housing_x = 57;

clamp_depth = hot_end_inset(hot_end) - 1;
clamp_width = 2 * (hot_end_screw_pitch(hot_end) + max(screw_clearance_radius(M3_cap_screw) + min_wall, clamp_depth / 2));
clamp_height = width - filament_z - 0.5;

function extruder_connector_offset() = [-filament_x + motor_x, filament_z - thickness, motor_y] + d_motor_connector_offset(NEMA17);

module feed_tube_connector_stl() {
    stl("feed_tube_connector");

    w = 2 * (bearing_housing_x + bearing_housing_depth - filament_x);

    difference() {
        union() {
            translate([0, 0, feed_tube_wall / 2])
                rounded_rectangle([w, w, feed_tube_wall], r = 3);
            translate([0, 0, eta])
                cylinder(r = feed_tube_tape_rad + feed_tube_wall, h = feed_tube_tape + feed_tube_wall);
        }
        translate([0, 0, -eta]) {
            poly_cylinder(r = feed_tube_tape_rad, h = feed_tube_tape);
            translate([0, 0, feed_tube_tape + layer_height + eta])
                poly_cylinder(r = feed_tube_rad, h = 100);
        }
    }
}

module keyhole(r, h, l) {
    R = r + layer_height / 4;
    waist = 2 * R - 1;
    entrance = 2 * R + 0.5;
    y = sqrt(R * R - waist * waist / 4);
    teardrop(h = h, r = R, center = true);
    hull() {
        translate([0, l, 0])
            cube([entrance, 2 * eta, h ], center = true);
        translate([0, y, 0])
            cube([waist, 2 * eta, h ], center = true);
    }
}

module wades_block_stl() {
    stl("wades_block");

    insulator = hot_end_insulator_diameter(hot_end);
    screw_pitch = hot_end_screw_pitch(hot_end);
    insulator_depth = hot_end_inset(hot_end);

    difference(){
        union(){
            cube([81, height, thickness]);                                  // motor plate
            cube([filament_x + 25 - 3.5, base_thickness, width]);           // base
            translate([filament_x + 25 - 3.5, base_thickness / 2, filament_z])
                for(a = [-90, 90])
                    rotate([a, 0, 0])
                        teardrop(r = 10.6, h = base_thickness, truncate = false, center = true);

            translate([bearing_housing_x, 0, 0])
                cube([bearing_housing_depth, height, width]);               // bearing housing

            translate([80,1.5,0])                                           // fillet
                cube([11,11, width]);
        }
        translate([92,base_thickness + 1,-1])
            rotate([0,0,45])
                cube([10,9,30]);                                            // chamfer on fillet

        translate([-11,-1,30]) rotate([0,60,0]) cube([30, base_thickness + 2, 60]);             // slope on base
        translate([80, -1, width + eta]) cube([40, base_thickness + 2, 10]);                    // remove top of teardrop

        translate([filament_x, 20, filament_z])
            rotate([90,0,0])
                teardrop(h = 70, r=4/2, center=true);                       // filament

        // mounting holes
        for(side = [-1, 1])
            translate([filament_x + mount_pitch * side, base_thickness, filament_z])
                rotate([90,0,0])
                    nut_trap(M4_clearance_radius, M4_nut_radius, 3, true);

        for(y = pscrew_y)
            for(z = pscrew_z) {
                translate([70, y, z]) rotate([90,0,90])teardrop(h=40,r=4.5/2, center=true);   // pressure screws
                translate([pscrew_x - 5, y, z]) rotate([90,0,90])cylinder(h=10,r=M4_nut_radius, $fn=6, center=true);  // nut traps
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
            cube([40,32,7]);
        translate([motor_x - 40 + motor_leeway / 2 + 6, motor_y, -1])
            cube([40,32,7]);

        translate([-5,-1,-1]) cube([16,60,30]);              // truncates tail

        difference() {
            translate([driven_x, driven_y, 6.99 + layer_height]) poly_cylinder(r = M8_clearance_radius + 0.25,h=30); // hole for hobbed bolt
            translate([driven_x + 2, driven_y - 5, 11 + 8 - eta]) cube([10, 10, layer_height + eta]); // support bridge
        }

        translate([driven_x, driven_y, 21.01]) b608();                                  // top bearing socket
        translate([filament_x + 8, driven_y, 11.5])  b608(8);                           // clearance for idler
        translate([driven_x, driven_y, -0.01]) b608();                                  // bottom bearing socket

        //
        // Hole for hot end
        //
        translate([filament_x, 0, filament_z])
            rotate([90,0,0]) {
                if(hot_end_groove_mount(hot_end)) assign(relief = 0.5) {

                    translate([0, 0, -insulator_depth + jhead_groove_offset() / 2])         // slot for the flange
                        keyhole(insulator / 2, jhead_groove_offset(), width - filament_z);

                    keyhole(12 / 2, insulator_depth * 2 - 1, width - filament_z);           // slot fot the groove

                    translate([0, 0, -insulator_depth + jhead_groove_offset() - relief / 2])
                        keyhole(insulator / 2 + 0.5, relief, width - filament_z);           // relief to avoid corner radius

                    translate([0, 0, -insulator_depth + relief / 2])
                        keyhole(insulator / 2 + 0.5, relief, width - filament_z);           // relief to avoid corner radius
                }
                else {
                    teardrop_plus(h = insulator_depth * 2, r = insulator / 2, center = true);      // insulator socket
                    translate([0, 0, -insulator_depth + 0.5])
                        teardrop_plus(h = 1 , r = insulator / 2 + 1, center=true);       // relief to avoid radius so end is flat
                }
            }

        if(!hot_end_groove_mount(hot_end))
            for(side = [-1, 1])
                translate([filament_x + screw_pitch * side, screw_depth, -1])
                    rotate([0, 0, -90 + 90 * side])
                        poly_cylinder(h = 30, r = M3_clearance_radius);                  // retaining screws
    }
}


module jhead_insertion_jig_stl() {
    stl("jhead_insertion_jig");
    h1 = jhead_groove() - 1;
    h2 = jhead_groove_offset() - 1;
    l = width + 2 - filament_z;
    w1 = hot_end_insulator_diameter(hot_end) - 2;
    w2 = jhead_groove_dia() - 2;

     color("blue")
        union() {
            difference() {
                translate([-w1 / 2, 0, 0])
                    cube([w1, l, h1]);
                poly_cylinder(r = hot_end_insulator_diameter(hot_end) / 2, h = 100, center = true);
            }
            difference() {
                translate([- w2 / 2, 0, h1 - eta])
                    cube([w2, l, h2]);
                poly_cylinder(r = jhead_groove_dia() / 2, h = 100, center = true);
            }
        }
}

module wades_gear_spacer_stl() {
    stl("wades_gear_spacer");
    washer = M8_washer;

    h = 5 * 1.5;
    difference() {
        cylinder(r = washer_diameter(washer) / 2, h = h,  center = false);
        translate([0,0, -0.5])
            poly_cylinder(r = M8_clearance_radius, h = h + 1, center = false);
    }
}



bfbext=false;

function extruder_connector_height() = motor_y - d_motor_bracket_offset(NEMA17);

module wades_big_gear_stl() {
    stl("wades_big_gear");
    color(wades_big_gear_color) import("../imported_stls/39t17p.stl");
}

module wades_small_gear_stl() {
    stl("wades_small_gear");
    color(wades_small_gear_color)
        translate([-10, -10, 0])
            import("../imported_stls/wades_gear.stl");
}

module small_gear_assembly() {
    wades_small_gear_stl();
    rotate([90, 0, -24]) {
        translate([0, 4, -5/2 - 6])
            rotate([180, 0, 0])
                screw(M3_grub_screw, 6);
        translate([0, 4, -6])
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
        for(x = pscrew_y)
            for(y = pscrew_z)
                translate([x - driven_y, y - filament_z, 0])
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


module wades_assembly(show_connector = true) {
    assembly("wades_assembly");

    color(wades_block_color) render()
        difference() {
            wades_block_stl();
            *translate([-1,-1, filament_z])                     // cross section
                cube([200,100,100]);
        }

    color(plastic_part_color("red")) render()
        rotate([-90, 0, 0])
            translate([filament_x, -filament_z, height])
                feed_tube_connector_stl();

    // idler screws, washers and springs
    for(i = [0,1])
        translate([pscrew_x, pscrew_y[i], pscrew_z[i]])
            rotate([-90,0,90]) {
                screw(M4_hex_screw, 50);
                translate([0,0, -38]) {
                    translate([0,0, -9]) {
                        comp_spring(extruder_spring, 9);
                        //translate([0,0, -washer_thickness(M4_washer)]) {
                        //    washer(M4_washer);
                            translate([0,0, -nut_thickness(M4_nut)])
                                nut(M4_nut);
                        //}
                    }
                }
            }

    // mounting screws
    for(side = [-1, 1])
        translate([filament_x + mount_pitch * side, base_thickness - 3, filament_z])
            rotate([-90,0,0])
                screw(M4_hex_screw, 20);

    //idler
    translate([98, driven_y, filament_z])
        rotate([90, 0, -90])
            wade_idler_assembly();

    // motor and gear
    translate([motor_x, motor_y, thickness + eta])
        rotate([0,180,0]) {
            NEMA(NEMA17);

            translate([0,0, 3.5])
                rotate([0, 0, 11])
                    small_gear_assembly();

            translate([0, 0, thickness])
                rotate([0, 0, 90])
                    NEMA_screws(NEMA17, 3, 10, M3_hex_screw);

            if(show_connector) {
                assembly("D_connector_assembly");
                d_motor_bracket_assembly(NEMA17);
                d_shell_assembly(NEMA17);
                end("D_connector_assembly");
            }
        }

    // hobbed bolt and gear
    translate([driven_x, driven_y, 0]) {
        translate([0, 0, width - BB608[2] / 2])
            ball_bearing(BB608);

        translate([0, 0,         BB608[2] / 2])
            ball_bearing(BB608);

        rotate([180, 0, 0])
            color(wades_gear_spacer_color) render() wades_gear_spacer_stl();

        translate([0, 0, -7.5])
            rotate([180, 0, 0])
                wades_big_gear_stl();

        translate([0,0, -14])
            rotate([180, 0, 0])
                screw(M8_hex_screw, 60);

        translate([0,0, width])
            washer(M8_washer);

        translate([0,0, width + washer_thickness(M8_washer)]) {
            if(spring) {
                comp_spring(hob_spring, 8);
                translate([0, 0, 8])
                    nut(M8_nut);
            }
            else {
                nut(M8_nut);
                translate([0, 0, nut_thickness(M8_nut)]) {
                    star_washer(M8_washer);
                    translate([0, 0, washer_thickness(M8_washer)])
                        nut(M8_nut);
                }
            }
        }

    }


    translate([filament_x, 0, filament_z])
        rotate([-90, 0, 0]) {
            if(hot_end_style(hot_end) == m90)
                m90_hot_end(hot_end);
            if(hot_end_style(hot_end) == Stoffel)
                stoffel_hot_end(hot_end);
            if(hot_end_style(hot_end) == jhead)
                jhead_hot_end(hot_end);
       }


    if(!hot_end_groove_mount(hot_end))
        for(side = [-1, 1])
            translate([filament_x + hot_end_screw_pitch(hot_end) * side, screw_depth, width])
                screw(M3_cap_screw, 30);

    if(show_jigs)
        translate([filament_x, hot_end_inset(hot_end) - 1, filament_z])
            rotate([90, 0, 0])
                jhead_insertion_jig_stl();

    end("wades_assembly");
}

module wades_extruder_stl() {
    wades_block_stl();
    translate([96, driven_y + 1, 0]) rotate([0,0,90]) wades_idler_block_stl();
    translate([motor_max, motor_y, 0]) wades_gear_spacer_stl();
}

if(1)
    rotate([90, 0, 0])
        wades_assembly(true);
else
    wades_extruder_stl();
