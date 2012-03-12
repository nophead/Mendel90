//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// For the y carriage
//
include <conf/config.scad>
include <positions.scad>
use <bearing-holder.scad>
use <bar-clamp.scad>

slot = 2;
tab_length = bearing_clamp_tab + slot;

function bearing_mount_width(bearing) = bearing_holder_width(bearing) + 2 * tab_length;
function bearing_mount_length(bearing) = bearing_holder_length(bearing);

module tab() {
    linear_extrude(height = bearing_clamp_tab_height, center = false, convexity = 6)
        difference() {
            union() {
                translate([(bearing_clamp_tab / 2 + slot) / 2, 0])
                    square([bearing_clamp_tab / 2 + slot, bearing_clamp_tab], center = true);
                translate([bearing_clamp_tab / 2 + slot ,0])
                    circle(r = bearing_clamp_tab/ 2, center = true);
            }
            translate([bearing_clamp_tab / 2, 0])
                circle(r = screw_clearance_radius, center = true);
            translate([bearing_clamp_tab / 2 + slot, 0, 0])
                circle(r = screw_clearance_radius, center = true);
            translate([bearing_clamp_tab / 2 + slot / 2, 0])
                square([slot, screw_clearance_radius * 2], center = true);

        }
}

module bearing_mount(bearing, height, endstop) {

    endstop_w = bar_clamp_switch_x_offset() + microswitch_thickness() / 2 - bearing_holder_width(bearing) / 2;
    endstop_d = 3;
    endstop_h = height - bar_clamp_switch_z_offset() + microswitch_thickness() / 4;

    stl(str("y_bearing_mount", endstop ? "_switch" : ""));
    color([1,0,0]) union() {
        bearing_holder(bearing, height);
        for(end = [-1, 1])
            translate([end * (bearing_holder_width(bearing) / 2 - eta), -end * (bearing_holder_length(bearing) - bearing_clamp_tab)/2, -height])
                rotate([0,0,90 - end * 90])
                    tab();
        if(endstop)
            translate([-(bearing_holder_width(bearing) / 2 + endstop_w / 2),
                       -(bearing_holder_length(bearing) / 2 - endstop_d / 2),
                       endstop_h / 2 - height])
                cube([endstop_w, endstop_d, endstop_h], center = true);
    }
 }

module bearing_mount_holes(height)
    for(end = [-1, 1])
        translate([end * (bearing_holder_width(Y_bearings) / 2 + tab_length / 2),
                  -end * (bearing_holder_length(Y_bearings) - bearing_clamp_tab) / 2, 0])
             cylinder(r = screw_clearance_radius, h = 100, center = true);;

module y_bearing_assembly(height, endstop = false)
{
    //assembly("y_bearing_assembly");

    color([1,0,0]) render() bearing_mount(Y_bearings, height, endstop);

    rotate([0,0,90]) {
        linear_bearing(Y_bearings);
        rotate([0,90,0])
            ziptie(small_ziptie, bearing_ziptie_radius(Y_bearings));
    }

    //
    // Fasterners
    //
    for(end = [-1, 1])
        translate([end * (bearing_holder_width(Y_bearings) / 2 + tab_length / 2),
                   -end * (bearing_holder_length(Y_bearings) - bearing_clamp_tab) / 2, -height + bearing_clamp_tab_height]) {
            nut_and_washer(nut, true);
            translate([0,0, -bearing_clamp_tab_height - sheet_thickness(Y_carriage)])
                rotate([180, 0, 0])
                    screw_and_washer(cap_screw, 16);
        }

    //end("y_bearing_assembly");
}

module y_bearing_mount_stl() translate([0,0, Y_bearing_holder_height]) bearing_mount(Y_bearings, Y_bearing_holder_height, false);
module y_bearing_mount_switch_stl() translate([0,0, Y_bearing_holder_height]) bearing_mount(Y_bearings, Y_bearing_holder_height, true);

if(1)
    y_bearing_assembly(Y_bearing_holder_height, false);
else {
    y_bearing_mount_stl();
    translate([  bearing_mount_width(Y_bearings) - tab_length + 2,  0, 0]) y_bearing_mount_stl();
    translate([-(bearing_mount_width(Y_bearings) - tab_length + 2), 0, 0]) y_bearing_mount_switch_stl();
};
