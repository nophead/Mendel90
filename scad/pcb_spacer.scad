//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
include <conf/config.scad>

pcb_screw_length = frame_nuts ?
    screw_longer_than(2 * washer_thickness(M3_washer) + pcb_thickness + sheet_thickness(frame) + nut_thickness(M3_nut, true)) : 16;

function pcb_spacer_height() = frame_nuts ? 3 : max(3, 16 - 2 * washer_thickness(M3_washer) - pcb_thickness - sheet_thickness(frame));

module pcb_spacer_stl(screw = M3_cap_screw, h = pcb_spacer_height()) {
    stl("pcb_spacer");

    r = screw_clearance_radius(screw);

    difference() {
        cylinder(r = corrected_diameter(r * 2) / 2 + 2, h = h,  center = false);
        translate([0, 0, -0.5])
            poly_cylinder(r = r, h = h + 1, center = false);
    }
}

module pcb_spacer_assembly() {
    color(pcb_spacer_color) render() pcb_spacer_stl();
    translate([0,0, pcb_spacer_height() + pcb_thickness])
        screw_and_washer(M3_cap_screw, pcb_screw_length, !frame_nuts);

    if(frame_nuts)
        translate([0, 0, -sheet_thickness(frame)])
            rotate([180, 0, 0])
                nut_and_washer(screw_nut(M3_cap_screw), true);
}

if(0)
    pcb_spacer_stl();
else
    pcb_spacer_assembly();
