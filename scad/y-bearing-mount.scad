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

nutty = cnc_sheets;

slot = nutty ? 0 : 2;
tab_length = bearing_clamp_tab + slot;

function bearing_mount_width(bearing)  = bearing_holder_width(bearing) + 2 * tab_length;
function bearing_mount_length(bearing) = bearing_holder_length(bearing);

module tab() {
    linear_extrude(height = bearing_clamp_tab_height + (nutty ? nut_trap_depth(nut) : 0), center = false, convexity = 6)
        difference() {
            union() {
                translate([(bearing_clamp_tab / 2 + slot) / 2, 0])
                    square([bearing_clamp_tab / 2 + slot, bearing_clamp_tab], center = true);
                translate([bearing_clamp_tab / 2 + slot ,0])
                    circle(r = bearing_clamp_tab/ 2, center = true);
            }
            if(!nutty) {
                translate([bearing_clamp_tab / 2, 0])
                    circle(r = screw_clearance_radius, center = true);
                translate([bearing_clamp_tab / 2 + slot, 0, 0])
                    circle(r = screw_clearance_radius, center = true);
                translate([bearing_clamp_tab / 2 + slot / 2, 0])
                    square([slot, screw_clearance_radius * 2], center = true);
            }
        }
}

nut_offset = nutty ? -bearing_clamp_tab / 2 + nut_radius(nut) + 0.5 : 0;

module bearing_mount(bearing, height) {

    endstop_w = bar_clamp_switch_x_offset() + microswitch_thickness() / 2 - bearing_holder_width(bearing) / 2;
    endstop_d = 3;
    endstop_h = 3;
    endstop_inset = bearing_holder_width(bearing) / 2 - bearing_radius(bearing);
    rad = 7;
    endstop_root_inset = (1 - sqrt(0.5)) * rad;

    stl("y_bearing_mount");
    color(y_bearing_mount_color) union() {
        bearing_holder(bearing, height, rad = rad);
        for(end = [-1, 1])
            translate([end * (bearing_holder_width(bearing) / 2 - eta), -end * (bearing_holder_length(bearing) - bearing_clamp_tab)/2, -height])
                difference() {
                    rotate([0, 0, 90 - end * 90])
                        tab();

                    if(nutty)
                        translate([end * (tab_length / 2 + nut_offset), 0, bearing_clamp_tab_height + nut_trap_depth(nut)])
                            nut_trap(screw_clearance_radius, nut_radius, nut_trap_depth(nut));
                }
        hull() {
            translate([-(bearing_holder_width(bearing) / 2 + endstop_w / 2 - endstop_inset / 2 - eta),
                       -(bearing_holder_length(bearing) / 2 - endstop_d / 2),
                       -bar_clamp_switch_z_offset()])
                cube([endstop_w + endstop_inset, endstop_d, endstop_h], center = true);

            translate([-(bearing_holder_width(bearing) / 2 - endstop_root_inset - eta),
                       -(bearing_holder_length(bearing) / 2 - endstop_root_inset - eta),
                       - height + bearing_clamp_tab_height])
                cube(1);
        }
    }
}

module bearing_mount_holes()
    for(end = [-1, 1])
        translate([end * (bearing_holder_width(Y_bearings) / 2 + tab_length / 2 + nut_offset),
                  -end * (bearing_holder_length(Y_bearings) - bearing_clamp_tab ) / 2, 0])
             child();

module y_bearing_assembly(height)
{
    color(y_bearing_mount_color) render() bearing_mount(Y_bearings, height);

    rotate([0,0,90]) {
        linear_bearing(Y_bearings);
        rotate([0,90,0])
            scale([bearing_radius(X_bearings) / bearing_ziptie_radius(X_bearings), 1])
                ziptie(small_ziptie, bearing_ziptie_radius(Y_bearings));
    }

    //
    // Fasterners
    //
    bearing_mount_holes()
        translate([0, 0, -height + bearing_clamp_tab_height]) {
            if(nutty)
                nut(nut, true);
            else
                nut_and_washer(nut, true);
            translate([0,0, -bearing_clamp_tab_height - sheet_thickness(Y_carriage)])
                rotate([180, 0, 0])
                    screw_and_washer(cap_screw, 16);
        }
}

module y_bearing_mount_stl() translate([0,0, Y_bearing_holder_height]) bearing_mount(Y_bearings, Y_bearing_holder_height);

module y_bearing_mounts_stl()
{
    y_bearing_mount_stl();
    translate([  bearing_mount_width(Y_bearings) - tab_length + 2,  0, 0]) y_bearing_mount_stl();
    translate([-(bearing_mount_width(Y_bearings) - tab_length + 2), 0, 0]) y_bearing_mount_stl();
}

if(0)
    y_bearing_assembly(Y_bearing_holder_height);
else
    y_bearing_mounts_stl();
