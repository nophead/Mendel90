//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
include <conf/config.scad>

use <pcb_spacer.scad>
use <wade.scad>
use <z-screw_pointer.scad>
use <y-belt-anchor.scad>
use <x-carriage.scad>

module small_bits_stl() {
    pcb_spacer_pitch = 9;

    rotate([0, 0, 90]) {
        translate([-washer_diameter(M8_washer) / 2, washer_diameter(M8_washer) / 2, 0])
            wades_gear_spacer_stl();

        translate([z_screw_pointer_radius() + x_carriage_lug_width() + 3, z_screw_pointer_radius() + 1, 0])
            rotate([0, 0, 90])
                z_screw_pointer_stl();

        translate([z_screw_pointer_radius() + x_carriage_lug_width() + 3, -z_screw_pointer_radius() - 1, 0])
            rotate([0, 0, -90])
                z_screw_pointer_stl();

        for(x = [0 : 1])
            for(y = [0 : 1]) {
                translate([-(x + 0.5) * pcb_spacer_pitch, -(y + 0.5) * pcb_spacer_pitch, 0])
                    pcb_spacer_stl();
            }

        translate([-y_belt_anchor_width() / 2, -2 * pcb_spacer_pitch - y_belt_anchor_depth() / 2 - 1, 0])
            y_belt_clip_toothed_stl();

        translate([-y_belt_anchor_width() / 2, y_belt_anchor_depth() / 2 + washer_diameter(M8_washer) + 2, 0])
            y_belt_clip_stl();


        translate([1, x_carriage_lug_depth() + 1, 0]) x_belt_clamp_stl();
        translate([1, -x_carriage_dowel() - 1, 0])    x_belt_grip_stl();

        translate([x_belt_tensioner_radius() + 3, x_belt_tensioner_radius() + x_carriage_lug_depth() + 3.5 , 0]) rotate([0, 0, -90]) x_belt_tensioner_stl();
    }
}

small_bits_stl();
