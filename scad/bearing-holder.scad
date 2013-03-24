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

wall = 2.5;                            // wall thickness
end_wall = 2.8;
clearance = 0.2;                       // end clearance
relief = 0.5;                          // clearance in the middle to stop the bearing rocking
ziptie_clearance = 1;

ziptie = small_ziptie;

zipslot_width    = ziptie_width(ziptie) + ziptie_clearance;
zipslot_tickness = ziptie_thickness(ziptie) + ziptie_clearance;

function bearing_holder_length(bearing) = bearing[0] + 2 * (end_wall + clearance);
function bearing_holder_width(bearing) = bearing[1] + wall * 2;

function bearing_ziptie_radius(bearing) = bearing[1] / 2 + wall + eta;

module bearing_holder(bearing, bar_height, populate = false, rad = 0) {
    bearing_length = bearing[0];
    bearing_dia = bearing[1];
    below = 5 * bearing_dia / 15;
    height = bar_height + bearing_dia/2 - below;
    offset = below + height / 2 - bearing_dia / 2;
    fence = 2.5;
    fence_width = sqrt(bearing_dia * bearing_dia - 4 * below * below) + eta;
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
