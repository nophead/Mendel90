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
use <z-coupling.scad>
use <x-end.scad>
use <ribbon_clamp.scad>


module small_bits_stl() {
    pcb_spacer_pitch = 9;

    rotate([0, 0, 90]) {
        if(extruder == Wades) {
            translate([-washer_diameter(M8_washer) / 2, washer_diameter(M8_washer) / 2, 0])
                wades_gear_spacer_stl();

            translate([-y_belt_anchor_width() / 2, -2 * pcb_spacer_pitch - y_belt_anchor_depth() / 2 - 1, 0])
                y_belt_clip_toothed_stl();

            translate([-y_belt_anchor_width() / 2, y_belt_anchor_depth() / 2 + washer_diameter(M8_washer) + 2, 0])
                y_belt_clip_stl();
        }
        else {
            translate([-y_belt_anchor_width() / 2 - 1, 3 + 1.5 * y_belt_anchor_depth(), 0])
                y_belt_clip_toothed_stl();

            translate([-y_belt_anchor_width() / 2 - 1, 1 + y_belt_anchor_depth() / 2, 0])
                y_belt_clip_stl();
        }


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


        translate([1, x_carriage_lug_depth() + 1, 0]) x_belt_clamp_stl();
        translate([1, -x_carriage_dowel() - 1, 0])    x_belt_grip_stl();

        translate([x_belt_tensioner_radius() + 3, x_belt_tensioner_radius() + x_carriage_lug_depth() + 3.5 , 0]) rotate([0, 0, -90]) x_belt_tensioner_stl();
    }

    translate([0, -y_belt_anchor_width() - 3 - (ribbon_clamp_width(M3_cap_screw) + 1) / 2, 0])
        x_motor_ribbon_bracket_stl();
}


module medium_bits_stl() {

    spacing = 23;
    z_coupling_x = x_carriage_lug_depth() + x_carriage_dowel() + 2;

    small_bits_stl();
    for(i = [-1.5: 1.5])
        translate([z_coupling_length() / 2 + z_coupling_x, i * 23, 0])
            z_coupling_stl();

    for(x = [0.5, 1.5])
        for(y = [-1, 1])
            translate([z_coupling_x - 1 - (x_end_length() + 2) * x, 1.5 * spacing * y, 0])
                x_end_clamp_stl();

}

if(1)
    small_bits_stl();
else
    medium_bits_stl();
