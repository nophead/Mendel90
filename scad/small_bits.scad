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
use <tube_cap.scad>

tube_cap_pitch = (tube_height(AL_square_tube) + 1);

module small_bits_stl() {
    translate([-Z_screw_dia/2 - 6, Z_screw_dia/ 2 + 12, 0])
        wades_gear_spacer_stl();

    translate([z_screw_pointer_radius() + 1, -z_screw_pointer_radius(), 0])
        rotate([0, 0, 12])
            z_screw_pointer_stl();

    translate([-z_screw_pointer_radius() + tube_cap_pitch * 2 - 1, -z_screw_pointer_radius() * 2, 0])
        rotate([0, 0, 180 + 12])
            z_screw_pointer_stl();

    for(x = [0 : 1])
        for(y = [0 : 1]) {
            translate([(x + 0.5) * tube_cap_pitch, (y + 0.5) * tube_cap_pitch, 0])
                tube_cap_stl();

            translate([-(x + 0.5) * 9, -y * 9, 0])
                pcb_spacer_stl();
        }
}

small_bits_stl();
