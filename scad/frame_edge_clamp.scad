//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// A clamp for gripping the frame edge
//
include <conf/config.scad>

wall = 2;
width  = 8;
hinge = 5;
rim = 1.2;
function frame_edge_clamp_pitch(length) = length - 2 * nut_flat_radius(M3_nut) - 2 * wall;

clamp_back_thickness = 2;
clamp_thickness = 2 + M3_nut_trap_depth;
clearance = 0.2;

screw_d = 3;

total_width = width + screw_d / 2 + corrected_radius(screw_d / 2) + hinge;
function pivot_l(length) = length - 2 * (min_wall + clearance);
pivot_w = hinge - 2 * (min_wall + clearance);
pivot_h = 1.2;

function frame_edge_clamp_width() = total_width;
function frame_edge_clamp_thickness() = clamp_thickness;


module frame_edge_clamp_front_stl(length = 20) {

    w = total_width;

    difference() {
        union() {
            translate([0, 0, clamp_thickness / 2])
                cube([length, w, clamp_thickness], center = true);

            if($children)
                child();
        }

        for(side = [-1, 1])
            translate([side * frame_edge_clamp_pitch(length) / 2, w / 2 - width - screw_d / 2, clamp_thickness])
                rotate([0, 0, 90])
                    nut_trap(M3_clearance_radius, nut_radius(M3_nut), M3_nut_trap_depth);

        translate([0, - w / 2 + hinge / 2, 0])
            cube([pivot_l(length) + 2 * clearance, pivot_w + 2 * clearance, pivot_h * 2], center = true);
    }
}

module frame_edge_clamp_back_stl(length = 20, gap = sheet_thickness(frame)) {
    l = length;
    w = total_width;

    union() {
        difference() {
            translate([-l / 2, -w / 2, 0])
                cube([l, w, clamp_back_thickness + gap - layer_height]);

            translate([-l / 2 + wall, -w / 2 + hinge, clamp_back_thickness])
                cube([l - 2 * wall, w, clamp_back_thickness + gap - layer_height]);

            translate([-l, w / 2 - width, clamp_back_thickness])
                cube([2 * l, w, clamp_back_thickness + gap - layer_height]);

            for(side = [-1, 1])
                translate([side * frame_edge_clamp_pitch(l) / 2, w / 2 - width - screw_d / 2, clamp_thickness])
                    rotate([0, 0, 90])
                        poly_cylinder(M3_clearance_radius, h = 100, center = true);
        }

        translate([0, - w / 2 + hinge / 2, clamp_back_thickness + gap])
            cube([pivot_l(l), pivot_w, pivot_h * 2], center = true);
    }
}


module frame_edge_clamp_assembly(length = 20, gap = sheet_thickness(frame), left = true) {
    kids = $children;

    screw_length = screw_longer_than(washer_thickness(M3_washer)
                                   + clamp_back_thickness
                                   + gap
                                   + clamp_thickness
                                   - M3_nut_trap_depth
                                   + nut_thickness(M3_nut, true));

    color(left ? "lime" : "red") render() {
        frame_edge_clamp_front_stl(length = length)
            if(kids)
                child();
    }

    translate([0, 0, -gap - clamp_back_thickness])
        color(left ? "red" : "lime") render() frame_edge_clamp_back_stl(length, gap);

    for(side = [-1, 1])
        translate([side * frame_edge_clamp_pitch(length) / 2, total_width / 2 - width - screw_d / 2, -gap - clamp_back_thickness])
            rotate([0, 0, 90]) {
                rotate([180, 0, 0])
                    screw_and_washer(M3_cap_screw, max(screw_length, 16));

                translate([0, 0, clamp_thickness + gap + clamp_back_thickness - M3_nut_trap_depth])
                    nut(M3_nut, true);
            }


}

module frame_edge_clamp_stl() {
    frame_edge_clamp_front_stl();

    translate([0, total_width + 2, 0])
        frame_edge_clamp_back_stl();

}

if(1)
    frame_edge_clamp_assembly();
else
    frame_edge_clamp_stl();
