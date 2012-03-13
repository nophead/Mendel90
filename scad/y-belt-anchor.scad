//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Anchors the belt to the bottom of the y carriage
//
include <conf/config.scad>
include <positions.scad>

wall = 2;

clearance = 2;
thickness = M3_nut_trap_depth + wall;
rad = 3;

clamp_thickness = 3;

width = belt_width(Y_belt) + 3 + washer_diameter(M3_washer) + clearance;
inner_width = (M3_nut_radius + wall) * 2;
depth =  washer_diameter(M3_washer) + clearance;
length = depth + 2 * (2 * M3_nut_radius * cos(30) + wall);

tooth_height = belt_thickness(Y_belt) / 2;
tooth_width = belt_pitch(Y_belt) / 2;

function y_belt_anchor_width() = width;

module y_belt_anchor_holes() {
    for(side = [-1, 1])
        translate([0, side * (depth / 2 + M3_nut_radius * cos(30) + eta) + depth / 2, 0])
            cylinder(r = M3_clearance_radius, h = 100, center = true);

}

module y_belt_anchor(height, toothed) {
    h = height + belt_thickness(Y_belt) - belt_clearance;
    recess = length - depth;

    stl(str("y_belt_anchor", toothed ? "_toothed" : ""));
    color(y_belt_anchor_color)  union() {
        difference() {
            union() {
                translate([0, depth / 2, h / 2])                                                        // tall bit
                    rounded_rectangle([width, depth, h], r = rad);

                translate([0, depth / 2, thickness / 2])
                    rounded_rectangle([inner_width, length, thickness], r = rad);                       // wide bit

                for(side = [-1, 1])                                                                     // webs
                    for(end = [-1, 1])
                        translate([side * (M3_nut_radius + wall / 2), eta + (end + 1) * (depth / 2 - 2 * eta), thickness - eta])
                            rotate([90,0,90 * end])
                                right_triangle(width = (length - depth) / 2 - rad, height = h - thickness, h = wall);
            }


            translate([0, depth / 2, height + (h - height) / 2 + 2 * eta])                              // slot for belt
                cube([belt_width(Y_belt) + belt_clearance, depth + 1, h - height], center = true);

            for(side = [-1, 1]) {                                                                        // clamp screw nut traps
                translate([side * (belt_width(Y_belt) / 2 + M3_clearance_radius), depth / 2, 0 ])
                    rotate([0,0,90/7 * (side + 1)])
                        nut_trap(M3_clearance_radius, M3_nut_radius, height - clamp_thickness);

                translate([0, side * (depth / 2 + M3_nut_radius * cos(30) + eta) + depth / 2, thickness])  // mounting screw nut traps
                    nut_trap(M3_clearance_radius, M3_nut_radius, M3_nut_trap_depth);

            }
            translate([0, depth / 2, height + (h - height) / 2 + 2 * eta])                                  // slot to join screw holes
                cube([belt_width(Y_belt) + M3_clearance_radius * 2, corrected_diameter(M3_clearance_radius * 2), h - height], center = true);
        }

        for(side = [-1, 1])                                                                                 // blind the nut traps
            translate([side * (belt_width(Y_belt) / 2 + M3_clearance_radius), depth / 2, height - clamp_thickness])
                cylinder(r =  M3_clearance_radius + 0.5, h = layer_height + eta);

        if(toothed)
            translate([0,depth / 2, height - eta + tooth_height / 2])
                cube([belt_width(Y_belt), tooth_width, tooth_height], center = true);
    }
}

module y_belt_clip(toothed) {
    stl(str("y_belt_clip",  toothed ? "_toothed" : ""));

    color(y_belt_clip_color) union() {
        translate([0, 0, clamp_thickness / 2]) difference() {
            rounded_rectangle([width, depth, clamp_thickness], r = rad);

            for(side = [-1, 1])                                                                        // screw holes
                translate([side * (belt_width(Y_belt) / 2 + M3_clearance_radius), 0, 0 ])
                    poly_cylinder(r = M3_clearance_radius, h = clamp_thickness + 1, center = true);
        }
        if(toothed)
            translate([0,0, clamp_thickness - eta + tooth_height / 2])
                cube([belt_width(Y_belt), tooth_width, tooth_height], center = true);
    }

}

module y_belt_anchor_assembly(height, toothed) {
    //assembly("y_belt_anchor_assembly");

    color(y_belt_anchor_color) render() y_belt_anchor(height, toothed);

    translate([0, depth / 2, height + belt_thickness(Y_belt) + clamp_thickness]) {
        rotate([180, 0, 0])
            color(y_belt_clip_color) render() y_belt_clip(!toothed);
        //
        // Clamp screws
        //
        for(side = [-1, 1])
            translate([side * (belt_width(Y_belt) / 2 + M3_clearance_radius), 0, 0]) {
                screw_and_washer(M3_cap_screw, 16);
                translate([0, 0, -2 * clamp_thickness - belt_thickness(Y_belt)])
                    rotate([180, 0, 0])
                        nut(M3_nut, true);
            }
    }
    for(side = [-1, 1])
        translate([0, side * (depth / 2 + M3_nut_radius * cos(30) + eta) + depth / 2, 0]) {
            translate([0, 0, thickness - M3_nut_trap_depth])
                nut(M3_nut, true);
            translate([0, 0, - sheet_thickness(Y_carriage)])
                rotate([180, 0, 0])
                    screw_and_washer(M3_cap_screw, 16);
        }

    //end("y_belt_anchor_assembly");
}

module y_belt_anchor_stl()         y_belt_anchor(Y_belt_clamp_height, false);
module y_belt_anchor_toothed_stl() y_belt_anchor(Y_belt_clamp_height, true);
module y_belt_clip_stl()           y_belt_clip(false);
module y_belt_clip_toothed_stl()   y_belt_clip(true);

if(1)
    y_belt_anchor_assembly(Y_belt_clamp_height, true);
else {
    translate([0,  0, 0]) y_belt_anchor_toothed_stl();
    translate([0, 25, 0]) y_belt_anchor_stl();
    translate([15, 5, 0]) rotate([0,0,90])y_belt_clip_toothed_stl();
    translate([15,30, 0]) rotate([0,0,90]) y_belt_clip_stl();
}
