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
tab = 2 + washer_diameter(base_washer);
foot = part_base_thickness + (base_nut_traps ? nut_trap_depth(base_nut) : 0);
holes = tab / 2 + 1;

function y_motor_bracket_height() = round(NEMA_width(Y_motor)) + 2;
function y_motor_height() = y_motor_bracket_height() / 2;
function y_motor_bracket_width() = y_motor_bracket_height() + 2 * (tab + thickness);
function y_motor_bracket_top_width() = y_motor_bracket_width() - 2 * tab;

depth = y_motor_bracket_height() + thickness - part_base_thickness;

nut_offset = base_nut_traps ? -tab / 2 + nut_radius(base_nut) + 0.5 : 0;

module y_motor_bracket_holes()
    for(side = [-1, 1])
        for(z = [thickness - depth + holes, thickness - holes])
            translate([side * (y_motor_bracket_width() / 2 - tab / 2 + nut_offset), -y_motor_bracket_height() / 2 + part_base_thickness, z])
                rotate([-90, 0, 0])
                    child();

module y_motor_bracket() {
    height = y_motor_bracket_height();
    width = y_motor_bracket_width();

    stl("y_motor_bracket");
        color(y_motor_bracket_color) {
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

                for(side = [-1,1])
                    translate([side * (width / 2 - tab), height / 2, 0])
                        rotate([0, 0, -135 - side *45])
                            fillet(r = 3, h = 100);
                //
                // mounting screw holes
                //
                y_motor_bracket_holes()
                    if(base_nut_traps)
                        translate([0, 0, foot - part_base_thickness])
                            nut_trap(screw_clearance_radius(base_screw), nut_radius(base_nut), foot - part_base_thickness, true);
                    else
                        teardrop_plus(r = screw_clearance_radius(base_screw), h = foot * 2 + 1, center = true);
            }
        }
}




module y_motor_assembly() {
    assembly("y_motor_assembly");

    color(y_motor_bracket_color) render() y_motor_bracket();
    //
    // Mounting screws and washers
    //
    y_motor_bracket_holes()
        base_screw(part_base_thickness);

    //
    // Motor and screws
    //
    rotate([0, 0, 180])
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

module y_motor_bracket_x2_stl()
    for(i = [0:1])
        translate([0, -(y_motor_bracket_height() + 2) * i, 0])
            rotate([0, 0, i * 180])
                y_motor_bracket_stl();

if(1)
    y_motor_assembly();
else
    y_motor_bracket_stl();
