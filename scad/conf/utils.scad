//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Utilities
//
include <../utils/bom.scad>
include <../utils/polyholes.scad>
include <../utils/teardrops.scad>
include <../utils/cables.scad>
include <../utils/shields.scad>

function round_to_layer(z) = ceil(z / layer_height) * layer_height;

module slot(h, r, l, center = true)
    linear_extrude(height = h, convexity = 6, center = center)
        hull() {
            translate([l/2,0,0])
                circle(r);
            translate([-l/2,0,0])
                circle(r);
        }

module hole_support(r, h, max_r = 999, closed = false, capped = false) {
    n = sides(r);
    cr = corrected_radius(r, n);
    ir = min(cr, max_r - 2.25 * filament_width);
    or = ir + 2 * filament_width;
    difference() {
        cylinder(r = or, h = h, $fn = n);
        difference() {
            translate([0, 0, closed ? layer_height : -1])
                cylinder(r = ir, h = h + 2, $fn = n);

            if(capped)
                translate([0, 0, h - 4 * layer_height])
                    cylinder(r = or, h = 3 * layer_height + eta);
        }
    }
}

module nut_trap_support(h, r, r2 = 0) {
    ir = r;
    ir2 = r2 ? r2 : r;
    or = ir + 2 * filament_width;
    or2 = ir2 + 2 * filament_width;
    difference() {
        cylinder(r2 = or, r1 = or2, h = h, $fn = 6);
        translate([0, 0, -1])
            cylinder(r2 = ir, r1 = or2, h = h + 2, $fn = 6);
    }
}

module part_screw_hole(screw, nut, horizontal = false, supported = false) {
    screw_r = screw_clearance_radius(screw);
    if(nut)
        translate([0, 0, nut_trap_depth(nut)])
            nut_trap(screw_r, nut_radius(nut), nut_trap_depth(nut), horizontal, supported);
    else
        if(horizontal)
            teardrop_plus(r = screw_r, h = 200, center = true);
        else
            poly_cylinder(r = screw_r, h = 200, center = true);
}

module fillet(r, h) {
    translate([r / 2, r / 2, 0])
        difference() {
            cube([r + eta, r + eta, h], center = true);
            translate([r/2, r/2, 0])
                cylinder(r = r, h = h + 1, center = true);
        }
}

module right_triangle(width, height, h, center = true) {
    linear_extrude(height = h, center = center)
        polygon(points = [[0,0], [width, 0], [0, height]]);
}

module rounded_square(w, h, r)
{
    union() {
        square([w - 2 * r, h], center = true);
        square([w, h - 2 * r], center = true);
        for(x = [-w/2 + r, w/2 - r])
            for(y = [-h/2 + r, h/2 - r])
                translate([x, y])
                    circle(r);
    }
}

module rounded_rectangle(size, r, center = true)
{
    w = size[0];
    h = size[1];
    linear_extrude(height = size[2], center = center)
        rounded_square(size[0], size[1], r);
}

//
// Cylinder with rounded ends
//
module rounded_cylinder(r, h, r2)
{
    rotate_extrude()
        hull() {
            square([1, h]);
            square([r, 1]);
            translate([r - r2, h - r2])
                intersection() {
                    circle(r2);
                    square(r2);
                }
        }
}

module sector(r, a, h, , center = true) {
    linear_extrude(height = h, center = center)
        intersection() {
            circle(r = r, center = true);
                polygon(points = [
                    [0, 0],
                    [2 * r * cos(a / 2),  2 * r * sin(a / 2)],
                    [2 * r * cos(a / 2), -2 * r * sin(a / 2)],
                ]);
        }
}

module tube(or, ir, h, center = true) {
    linear_extrude(height = h, center = center, convexity = 5)
        difference() {
            circle(or);
            circle(ir);
        }
}

//
// Exploded view helper
//
module explode(v, offset = [0,0,0]) {
    if(exploded) {
        translate(v * exploded)
            children();
        render() hull() {
            sphere(0.2);
            translate(v * exploded + offset)
                sphere(0.2);
        }
    }
    else
        children();
}
