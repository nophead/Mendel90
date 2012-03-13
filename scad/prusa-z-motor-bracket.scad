//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Not actually a part of Mendel90. This allows the Mendle90 x-axis to be used on a Prusa
//
include <conf/config.scad>
use <z-coupling.scad>

corner_rad = 5;
clamp_rad = 0;
end_wall = 2;
thickness = 4;
length = ceil(NEMA_width(Z_motor));
height = 2 * thickness +  X_bar_dia;

bar_y = 58.5 / 2;
width = 2 * bar_y;

big_hole = NEMA_big_hole(Z_motor);
clamp_height = 12;
clamp_thickness = bar_clamp_band;
clamp_screw_clearance = 2;
clamp_length = Z_bar_dia / 2 + bar_clamp_tab - 2 + clamp_rad;
gap = 1.5;

clamp_width = Z_bar_dia + 2 * clamp_thickness;

clamp_x = z_bar_offset() + clamp_length - bar_clamp_tab / 2;

function z_bar_offset() = round(NEMA_width(Z_motor)) / 2;

module z_motor_bracket_stl() {

    stl("z_motor_bracket");
    difference() {
        union() {
            //
            // main body
            //
            difference() {
                translate([0, 0, clamp_height / 2])
                    cube([length, width, clamp_height], center = true);
                translate([0, 0, clamp_height / 2 + thickness])
                    cube([length - 2 * end_wall, width, clamp_height], center = true);

            }
            //
            // Bar holders
            //
            for(side = [-1, 1])
                translate([0,  bar_y * side, height / 2]) {
                    rotate([90, 0, 90])
                        teardrop(r = height / 2, h = length, center = true);
                    rotate([-90, 0, 90])
                        teardrop(r = height / 2, h = length, center = true);
                }
            //
            // bar clamp
            //
            translate([z_bar_offset() + clamp_length / 2 - eta, 0, clamp_height / 2 + eta])
                cube([clamp_length, clamp_width, clamp_height], center = true);
            translate([z_bar_offset(), 0, clamp_height / 2 + eta])
                cylinder(h = clamp_height, r = Z_bar_dia/2 + clamp_thickness, center = true);
        }
        //
        // Holes for bars
        //
        for(side = [-1, 1])
            translate([0, bar_y * side, height  / 2])
                rotate([90, 0, 90])
                    teardrop(r = M8_clearance_radius, h = length + 1, center = true, truncate = true);

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

    }
}


module z_motor_assembly() {
    assembly("z-motor-assembly");

    color([0,1,0]) render() z_motor_bracket_stl();
    //
    // Clamp screw and washer
    //
    translate([clamp_x, -clamp_width / 2, clamp_height / 2])
        rotate([90, 0, 0])
            screw_and_washer(cap_screw, 16);
    //
    // Clamp nyloc
    //
    translate([clamp_x, clamp_width / 2 - nut_trap_depth, clamp_height / 2])
        rotate([-90, 0, 0])
            nut(nut, true);

    //
    // Motor and screws
    //
    NEMA(Z_motor);
    translate([0,0, thickness])
        NEMA_screws(Z_motor);

    //
    // The coupling assembly
    //
    translate([0, 0, NEMA_shaft_length(Z_motor) + 1])
        rotate([0,0,-45])
            z_coupler_assembly();

   end("z-motor-assembly");

}

if(1)
    z_motor_bracket_stl();
else
    z_motor_assembly();
