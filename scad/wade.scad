//
// Mendel90
//
// Originally based on Josef Prusa's version but much hacked
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
include <conf/config.scad>
use <d-motor_bracket.scad>

Stoffle15_10mm = [10,   13, 5, false];
Stoffle15_16mm = [16.5, 10, 6, false];
Mendel90_12mm  = [12,   10, 6 + 3/2 - 1, false];

function insulator_diameter(type)    = type[0];
function insulator_depth(type)       = type[1];
function insulator_screw_pitch(type) = type[2];
function insulator_clamped(type)     = type[3];

hot_end = Stoffle15_16mm;

clamp_width = 2 * (insulator_screw_pitch(hot_end) + screw_clearance_radius(M3_cap_screw) + min_wall);

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

motor_y = 31.5;
motor_min = 26 + 5;
motor_max = 36;
motor_x = (motor_min + motor_max) / 2;
motor_leeway = motor_max - motor_min;
thickness = 5;
base_thickness = 6;

filament_x = 75;
filament_z = 15;

width = 28;
mount_pitch = 25;

pscrew_x = 60;
pscrew_y = [17.5, 45.5];
pscrew_z = [8.5,  21.5];

driven_x = 70;
driven_y = 31.5;

function extruder_connector_offset() = [-filament_x + motor_x, filament_z - thickness, motor_y] + d_motor_connector_offset(NEMA17);

module wades_block_stl() {
    stl("wades_block");

    insulator = insulator_diameter(hot_end);
    screw_pitch = insulator_screw_pitch(hot_end);
    insulator_depth = insulator_depth(hot_end);


    difference(){
        union(){
            cube([81, 52, thickness]);                            // motor plate
            cube([filament_x + 25 - 3.5, base_thickness, 28]);    // base
            translate([filament_x + 25 - 3.5, base_thickness / 2, filament_z])
                for(a = [-90, 90])
                    rotate([a, 0, 0])
                        teardrop(r = 10.6, h = base_thickness, truncate = false, center = true);

            translate([57, 0, 0])
                cube([26, 52, width]);                      // bearing housing

            translate([80,1,0])                             // fillet
                cube([11,11, width]);
        }
        translate([91,base_thickness,-1])
            rotate([0,0,45])
                cube([9,9,30]);                           // chamfer on fillet

        translate([-11,-1,30]) rotate([0,60,0]) cube([30, base_thickness + 2, 60]);            // base chamfers
        translate([80, -1, width + eta]) cube([40, base_thickness + 2, 10]);

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

        translate([driven_x, driven_y, 7.5]) poly_cylinder(r = M8_clearance_radius + 0.25,h=30); // hole for hobbed bolt

        translate([driven_x, driven_y, 21.01]) b608();                                  // top bearing socket
        translate([83,       driven_y, 11.5])  b608(8);                                 // clearance for idler
        translate([driven_x, driven_y, -0.01]) b608();                                  // bottom bearing socket

        //
        // Hole for hot end
        //
        translate([filament_x, -15 + insulator_depth, filament_z])
            rotate([90,0,0]) {
                teardrop(h = 30, r = insulator / 2, center=true);               // insulator
                translate([0,0, -14.5])
                    teardrop(h = 1 , r = insulator / 2 + 1, center=true);       // relief to avoid radius so end is flat
            }

        if(insulator_clamped(hot_end))
            translate([filament_x - clamp_width / 2, -eta, filament_z])
                cube([clamp_width, insulator_depth, 100]);

        for(side = [-1, 1])
            translate([filament_x + screw_pitch * side, screw_depth, -1])
                cylinder(h = 30, r = (3.3 / 2), $fn = 9);                       // retaining screws

    }
}

module wades_gear_spacer_stl() {
    stl("wades_gear_spacer");
    washer = M8_washer;

    h = 5 * washer_thickness(washer);
    difference() {
        cylinder(r = washer_diameter(washer) / 2, h = h,  center = false);
        translate([0,0, -0.5])
            poly_cylinder(r = M8_clearance_radius, h = h + 1, center = false);
    }
}



bfbext=false;

*difference() {
    wadeblock(bfbext);
    *translate([-1,-1, filament_z])
        cube([200,100,100]);
}

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
            screw(M3_grub_screw, 6);
        translate([0, 4, -6])
            rotate([0,0,30])
                nut(M3_nut);
    }
}

idler_height = 12;

module wades_idler_block_stl() {
    stl("wades_idler_block");

    long_side = 37;
    short_side = 25;
    corners_diameter = 3;
    608_dia = 12;
    608_height = 9;

    mounting_dia = 4.5;

    difference(){
        // Main block
        rounded_rectangle([long_side, short_side, idler_height], corners_diameter, center = false);

        // bearing cutout
        translate([0, 0, idler_height - 2]){
            rotate([90,0,0])
                cylinder(h = 608_height, r=608_dia, center=true);

            rotate(a=[90,0,0])
                cylinder(h = short_side-2, r=8.6/2, center=true);
        }

        //mounting holes
        for(x = pscrew_y)
            for(y = pscrew_z)
                translate([x - motor_y, y - filament_z, 0])
                    poly_cylinder(h = idler_height * 2.1, r = mounting_dia / 2, center=true);
    }
}

module wade_idler_assembly() {

    color(wades_idler_block_color) render() wades_idler_block_stl();

    translate([0, 0, idler_height - 2])
        rotate([90, 0, 0]) {
            rod(d = 8, l = 22);
            ball_bearing(BB608);
        }
}

module wades_assembly() {
    assembly("wades_assembly");

    render() wades_block_stl();

    // idler screws, washers and springs
    for(i = [0,1])
        translate([pscrew_x, pscrew_y[i], pscrew_z[i]])
            rotate([-90,0,90]) {
                screw(M4_hex_screw, 50);
                translate([0,0, -38]) {
                    translate([0,0, -6]) {
                        comp_spring(extruder_spring, 6);
                        translate([0,0, -washer_thickness(M4_washer)]) {
                            washer(M4_washer);
                            translate([0,0, -nut_thickness(M4_nut)])
                                nut(M4_nut);
                        }
                    }
                }
            }

    // mounting screws
    for(side = [-1, 1])
        translate([filament_x + mount_pitch * side, base_thickness - 3, filament_z])
            rotate([-90,0,0])
                screw(M4_hex_screw, 20);

    //idler
    translate([98, motor_y, filament_z])
        rotate([90, 0, -90])
            wade_idler_assembly();

    // motor and gear
    translate([motor_x, motor_y, thickness + eta])
        rotate([0,180,0]) {
            NEMA(NEMA17);

            translate([0,0, 3.5])
                small_gear_assembly();

            translate([0, 0, thickness])
                rotate([0, 0, 90])
                    NEMA_screws(NEMA17, 3);

            assembly("D_connector_assembly");
            d_motor_bracket_assembly(NEMA17);
            d_shell_assembly(NEMA17);
            end("D_connector_assembly");
        }

    // hobbed bolt and gear
    translate([driven_x, motor_y, 0]) {
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
            comp_spring(hob_spring, 8);
            translate([0, 0, 8])
                nut(M8_nut);
        }

    }

    translate([75, 5 - nozzle_length / 4, 15])
        rotate([-90, 0, 0]) {
            color(filament_viz_color) cylinder(h = nozzle_length / 2 + 10, r = insulator_diameter(hot_end) / 2, center = true);
            translate([0, 0, -nozzle_length /2 - 5])
                color(extruder_nozzle_color) cylinder(h = nozzle_length / 2, r = 3, center = true);
        }

    for(side = [-1, 1])
        translate([filament_x + insulator_screw_pitch(hot_end) * side, screw_depth, width])
            screw(M3_cap_screw, 30);

    end("wades_assembly");
}
if(1)
    rotate([90, 0, 0])
        wades_assembly();


else {

    wades_block_stl();
    *wades_idler_block_stl();
    *wades_gear_spacer_stl();

}
