//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Fastens the Y motor to the base
//
include <conf/config.scad>
use <pulley.scad>

thickness = 4;
tab = 2 + washer_diameter(screw_washer(base_screw));
foot = 5;
holes = tab / 2 + 1;

function y_motor_bracket_height() = round(NEMA_width(Y_motor)) + 2;
function y_motor_height() = y_motor_bracket_height() / 2;
function y_motor_bracket_width() = y_motor_bracket_height() + 2 * (tab + thickness);
function y_motor_bracket_top_width() = y_motor_bracket_width() - 2 * tab;

depth = y_motor_bracket_height() + thickness - foot;

module y_motor_bracket() {
    height = y_motor_bracket_height();
    width = y_motor_bracket_width();

    stl("y_motor_bracket");
        color([0,1,0]) {
            difference() {
                translate([0, 0, thickness - depth / 2])                    // main body
                    cube([width, height, depth], center = true);

                cylinder(r = NEMA_big_hole(Y_motor), h = thickness * 2 + 1, center = true);   // hole for stepper locating boss

                translate([0, 0, - depth / 2])
                    cube([depth, height + 1, depth], center = true);        // space for motor

                translate([-width / 2, foot, 0])
                    cube([tab * 2,  height, depth * 2], center = true);     // cut outs for lugs

                translate([width / 2, foot, 0])
                    cube([tab * 2,  height, depth * 2], center = true);

                translate([0, - height / 2 + foot, - depth + thickness])    // sloping sides
                    rotate([45,0,0])
                        translate([0,0, - depth / 2])
                            cube([width, 3 * height, depth], center = true);

                for(x = NEMA_holes(Y_motor))                                     // motor screw holes
                    for(y = NEMA_holes(Y_motor))
                        translate([x,y,0])
                            poly_cylinder(r = M3_clearance_radius, h = 2 * thickness + 1, center = true);
                //
                // mounting screw holes
                //
                for(side = [-1, 1])
                    for(z = [thickness - depth + holes, thickness - holes])
                        translate([side * (width / 2 - tab / 2), - height / 2, z])
                            rotate([-90, 0, 0]) teardrop_plus(r = screw_clearance_radius(base_screw), h = foot * 2 + 1, center = true);
            }
        }
}

module y_motor_bracket_holes()
    for(side = [-1, 1])
        for(z = [thickness - depth + holes, thickness - holes])
            translate([side * (y_motor_bracket_width() / 2 - tab / 2), -y_motor_bracket_height() / 2 + foot, z])
                rotate([-90, 0, 0])
                    child();



module y_motor_assembly() {
    assembly("y_motor_assembly");

    color([0,1,0]) render() y_motor_bracket();
    //
    // Mounting screws and washers
    //
    y_motor_bracket_holes()
        base_screw();

    //
    // Motor and screws
    //
    NEMA(Y_motor);
    translate([0,0, thickness])
        NEMA_screws(Y_motor);
    //
    // Pulley
    //
    translate([0, 0, 4])
        pulley_assembly();

    end("y_motor_assembly");
}

module y_motor_bracket_stl() translate([0, 0, thickness]) rotate([0,180,0]) y_motor_bracket();

if(1)
    y_motor_assembly();
else
    y_motor_bracket_stl();
