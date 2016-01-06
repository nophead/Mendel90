//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Fastens the bearings to the Y-carriage
//
// Based on a design by Jeffrey Olijar (Jolijar)
//
include <conf/config.scad>

relief = squeeze ? 0.25 : 0.5;                        // clearance in the middle to stop the bearing rocking
wall = squeeze ? 3 * filament_width + relief + eta : 2.5;  // wall thickness
clearance = 0.2;                       // end clearance
end_wall = min(default_wall, 3) - clearance;
ziptie_clearance = 1;

ziptie = small_ziptie;

zipslot_width    = ziptie_width(ziptie) + ziptie_clearance;
zipslot_tickness = ziptie_thickness(ziptie) + ziptie_clearance;

function bearing_holder_length(bearing) = bearing[0] + 2 * (end_wall + clearance);
function bearing_holder_width(bearing) = bearing[1] + wall * 2;
function zipslot_width() = zipslot_width;

function bearing_ziptie_radius(bearing) = bearing[1] / 2 + wall + eta;

module bearing_holder(bearing, bar_height, populate = false, rad = 0, tie_offset = 0) {
    bearing_length = bearing[0];
    bearing_dia = bearing[1];
    below = 5 * bearing_dia / 15;
    height = bar_height + bearing_dia / 2 - below;
    offset = below + height / 2 - bearing_dia / 2;
    fence = 2.5;
    fence_width = sqrt(sqr(bearing_dia) - 4 * sqr(bearing_dia / 2 - fence)) + eta;
    width = bearing_holder_width(bearing);
    length = bearing_holder_length(bearing);
    fence_offset = bearing_dia / 2 - fence + (fence + 1) /2;
    union(){
        difference() {
            translate([0, 0, -offset]) // Basic shape
                if(rad)
                    hull() {
                        rounded_rectangle([width, length, height], center = true, r = rad);

                        translate([-width / 2, length / 2 - 1, -height / 2])
                            cube(1);

                        translate([width / 2 - 1, -length / 2, -height / 2])
                            cube(1);

                        translate([0, 0, height / 2])
                            cube([width, length, eta], center = true);
                    }
                else
                    cube(size = [width, length, height], center = true);

            rotate([90,0,0]) {
                cylinder(h = length + 1, r = bearing_dia / 2, center=true);         // Bearing Cutout
                cylinder(h = length / 2, r = bearing_dia / 2 + relief, center=true);// releave the center so does not rock
                translate([0, 0, tie_offset])
                    tube(h = zipslot_width, ir = bearing_dia / 2 + wall,
                                            or = bearing_dia / 2 + wall + zipslot_tickness, fn=64); // ziptie slot

            }
        }
        translate([0,  (length - end_wall)/ 2, -fence_offset]) cube(size = [fence_width,end_wall,fence + 1], center = true); // Blocks at the end to keep the bearing from sliding out
        translate([0, -(length - end_wall)/ 2, -fence_offset]) cube(size = [fence_width,end_wall,fence + 1], center = true);
    }
    if(populate)
        rotate([0,0,90])
            linear_bearing(bearing);
}

bearing_holder(LM8UU, 20, rad = 7);
