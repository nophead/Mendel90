//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Cable clips to order
//
include <conf/config.scad>

wall = 2;
thickness = 5;

function cable_clip_width(screw) = wall + 2 * screw_clearance_radius(screw) + wall;
function cable_clip_height(cable) = max(cable_height(cable) + wall, thickness);
function cable_clip_extent(screw, cable) = screw_clearance_radius(screw) + wall + cable_width(cable) + wall;
function cable_clip_offset(screw, cable) = screw_clearance_radius(screw) + wall + cable_width(cable) / 2;

module single_cable_clip(cable, screw, h = 0) {
    screw_dia = 2 * screw_clearance_radius(screw);
    height = cable_clip_width(screw);
    depth = h ? h : cable_height(cable) + wall;
    width = wall + cable_width(cable) + wall + screw_dia + wall;
    hole_x = wall + cable_width(cable) + wall + screw_dia / 2;
    rad = min(wall + cable_wire_size(cable) / 2, depth / 2);
    translate([-hole_x, 0, 0]) difference() {
        linear_extrude(height = height)
             hull() {
                square([width, 1]);

                translate([width - 1, 0])
                    square([1, depth]);

                translate([rad, depth - rad])
                    circle(r = rad);
            }
        translate([wall + cable_width(cable) / 2, 0, 0])
            rounded_rectangle([cable_width(cable), cable_height(cable) * 2], cable_wire_size(cable) / 2, center = true);

        translate([hole_x, depth / 2, height / 2])
            rotate([90,0,0])
                teardrop_plus(h = depth + 1, r = screw_dia / 2, center = true);
    }
}


module double_cable_clip(cable1, cable2, screw_dia) {
    h = max(cable_clip_height(cable1), cable_clip_height(cable2));
    union() {
        single_cable_clip(cable1, screw_dia, h);
        mirror([1,0,0]) single_cable_clip(cable2, screw_dia, h);
    }
}

module cable_clip(screw, cable1, cable2 = 0) {
    if(cable2) {
        stl(str("cable_clip_", cable1[2], cable2[2]));
        double_cable_clip(cable1, cable2, screw);
    }
    else {
        stl(str("cable_clip_",2 * screw_radius(screw), cable1[2]));
        single_cable_clip(cable1, screw);
    }
}

module cable_clip_assembly(screw, screw_length, cable1, cable2 = 0) {
    color(clip_color) render() translate([0, cable_clip_width(screw) / 2, 0]) rotate([90, 0, 0])
        cable_clip(screw, cable1, cable2);

    translate([0, 0, max(cable_clip_height(cable1), cable_clip_height(cable2))])
        screw_and_washer(screw, screw_length);
}

module cable_clip_AB_stl() cable_clip(base_clip_screw, endstop_wires, motor_wires);
module cable_clip_AD_stl() cable_clip(frame_clip_screw, endstop_wires, fan_motor_wires);
module cable_clip_CA_stl() cable_clip(base_clip_screw, thermistor_wires, bed_wires);

spacing = cable_clip_height(motor_wires) + 1;

if(1)
    cable_clip_assembly(base_clip_screw, base_screw_length, endstop_wires, motor_wires);
else {
    translate([0, -cable_clip_height(bed_wires) - 1, 0])
        cable_clip(base_clip_screw, thermistor_wires, bed_wires);

    for(i=[0:1])
        translate([0, spacing * i, 0])
            cable_clip(base_clip_screw, endstop_wires, motor_wires);

    for(i=[2:3])
        translate([0, spacing * i, 0])
            cable_clip(frame_clip_screw, endstop_wires, fan_motor_wires);

}
