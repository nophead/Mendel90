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

module slot(h, r, l, center = true)
    linear_extrude(height = h, convexity = 6, center = center)
        hull() {
            translate([l/2,0,0])
                circle(r = r, center = true);
            translate([-l/2,0,0])
                circle(r = r, center = true);
        }

module nut_trap(screw_r, nut_r, depth, horizontal = false, supported = false) {
    union() {
        if(horizontal) {
            teardrop_plus(r = screw_r, h = 200, center = true);
            cylinder(r = nut_r   + layer_height / 4, h = depth * 2, center = true, $fn = 6);
        }
        else {
            difference() {
                union() {
                    poly_cylinder(r = screw_r, h = 200, center = true);
                    cylinder(r = nut_r, h = depth * 2, center = true, $fn = 6);
                }
                if(supported)
                    translate([0, 0, depth - eta])
                        cylinder(r = nut_r, h = layer_height, center = false);
            }
        }
    }
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
                    circle(r = r);
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
        union() {
            square([r - r2, h]);
            square([r, h - r2]);
            translate([r - r2, h - r2])
                circle(r = r2);
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
    difference() {
        cylinder(r = or, h = h,    center = center);
        cylinder(r = ir, h = h + 1, center = center);
    }
}

//
// Exploded view helper
//
module explode(v, offset = [0,0,0]) {
    if(exploded) {
        translate(v)
            child();
        render() hull() {
            sphere(0.2);
            translate(v + offset)
                sphere(0.2);
        }
    }
    else
        child();
}
//
// Same again as cant appear twice in the tree
//
module explode2(v, offset = [0,0,0]) {
    if(exploded) {
        translate(v)
            child();
        render() hull() {
            sphere(0.2);
            translate(v + offset)
                sphere(0.2);
        }
    }
    else
        child();
}
