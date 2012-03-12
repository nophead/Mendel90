//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Configuration file
//
bom = 2;                        // 0 no bom, 1 assemblies and stls, 2 vitamins as well
exploded = false;               // true for exploded view
eta = 0.01;                     // small fudge factor to stop CSG barfing on coincident faces.
$fa = 5;
$fs = 0.5;
//
// Hole sizes
//
No2_pilot_radius = 1.7 / 2;       // self tapper into ABS
No4_pilot_radius = 2.0 / 2;       // wood screw into soft wood
No6_pilot_radius = 2.0 / 2;       // wood screw into soft wood

No2_clearance_radius = 2.5 / 2;
No4_clearance_radius = 3.5 / 2;
No6_clearance_radius = 4.0 / 2;

M2p5_tap_radius = 2.05 / 2;
M2p5_clearance_radius= 2.8 / 2;   // M2.5

M3_tap_radius = 2.5 / 2;
M3_clearance_radius = 3.3 / 2;
M3_nut_radius = 6.5 / 2;
M3_nut_trap_depth = 3;

M4_tap_radius = 3.3 / 2;
M4_clearance_radius = 2.2;
M4_nut_radius = 8.2 / 2;
M4_nut_trap_depth = 4.5;

M6_tap_radius = 5 / 2;
M6_clearance_radius = 6.4 / 2;
M6_nut_radius = 11.6 / 2;
M6_nut_depth = 5;

M8_tap_radius = 6.75 / 2;
M8_clearance_radius = 8.4 / 2;
M8_nut_radius = 15.4 / 2;
M8_nut_depth = 6.5;

layer_height = 0.4;
filament_width = layer_height * 1.5;
min_wall = 2 * filament_width + eta;

pcb_thickness = 1.6;

include <utils.scad>
include <vitamins.scad>

endstop_wires    = [2, 1.4, "A"];   // 7 strands of 0.2
motor_wires      = [4, 1.4, "B"];
bed_wires        = [2, 2.8, "C"];   // 13A mains cable
fan_motor_wires  = [6, 1.4, "D"];   // fan and motor wires along top of gantry
thermistor_wires = endstop_wires;

endstop_wires_hole_radius = wire_hole_radius(endstop_wires);
motor_wires_hole_radius = wire_hole_radius(motor_wires);
fan_motor_wires_hole_radius = wire_hole_radius(fan_motor_wires);
bed_wires_hole_radius = wire_hole_radius(bed_wires);
thermistor_wires_hole_radius = wire_hole_radius(thermistor_wires);

include <machine.scad>              // this file is generated from the command line parameter to include one of the machine configs

screw_clearance_radius = screw_clearance_radius(cap_screw);
nut = screw_nut(cap_screw);
nut_radius = nut_radius(nut);
nut_trap_depth = nut_trap_depth(nut);
washer = screw_washer(cap_screw);

bearing_clamp_tab = washer_diameter(washer) + 2;   // how much the lugs stick out and their width
bearing_clamp_tab_height = 4;   // thickness of the lugs

hole_edge_clearance = 5;        // how close a hole can be to the edge of a sheet
base_clearance = 2;             // how close we get to the edge of the base
axis_endstop_clearance = 2;     // how close we get to the end of an axis
X_carriage_clearance = 2;       // how close the X carriage is to the XZ plane
                                // how close the Y carriage is to the window in the XZ plane
Y_carriage_clearance = 2 + bulldog_handle_length(small_bulldog) - (Y_carriage_width - bed_width) / 2;
Z_clearance = 10;               // How close the top of the object gets to the gantry
belt_clearance = 0.2;           // clearance of belt clamp slots

pulley_inner_radius = (14.4 / 2) - belt_thickness(T5x6); // measured from outer diameter


X_bar_dia = X_bearings[2];      // rod sizes to match the bearings
Y_bar_dia = Y_bearings[2];
Z_bar_dia = Z_bearings[2];

Y_idler_bearing = BB624;
X_idler_bearing = BB624;

extruder_ways = 4 + 4 + 2 + 1 + 1;      // motor + heater(x2) + thermistor + probe + fan = 12
x_end_ways = extruder_ways + 4 + 2 + 2; // motor plus limit switch and two guards = 20
bed_ways = 20 + 2;                      // ten each way for the current plus a thermistor

function z_bar_offset() = round(NEMA_width(Z_motor)) / 2;

base_screw = sheet_is_soft(base) ? frame_soft_screw : frame_thick_screw;
base_screw_length = screw_shorter_than(sheet_thickness(base) + 5 + 2 * washer_thickness(screw_washer(base_screw)));

base_clip_screw = base_screw;
base_clip_screw_length = base_screw_length;

frame_screw = sheet_is_soft(frame) ? frame_soft_screw : frame_nuts ? frame_thin_screw : frame_thick_screw;
frame_clip_screw = frame_screw;

frame_screw_length = frame_nuts ? screw_longer_than(sheet_thickness(frame) + 5 + 2 * washer_thickness(screw_washer(frame_screw)) +
                                      nut_thickness(screw_nut(frame_screw), true))
                                : screw_shorter_than(sheet_thickness(frame) + 5 + 2 * washer_thickness(screw_washer(frame_screw)));
frame_clip_screw_length = frame_screw_length;

echo("base screw length", base_screw_length);
echo("frame screw length",frame_screw_length);


module frame_screw(thickness) {
    screw_and_washer(frame_screw, frame_screw_length, !frame_nuts);
    if(frame_nuts)
        translate([0, 0, -sheet_thickness(frame) - thickness])
            rotate([180, 0, 0])
                nut_and_washer(screw_nut(frame_screw), true);
}

module frame_screw_hole() {
    cylinder(r = frame_nuts ? screw_clearance_radius(frame_screw) :
                              screw_pilot_hole(frame_screw), h = 100, center = true);

}

module base_screw() {
    screw_and_washer(base_screw, base_screw_length, true);
}

module base_screw_hole() {
    cylinder(r = screw_pilot_hole(base_screw), h = 100, center = true);
}

bar_clamp_depth = 4 + washer_diameter(screw_washer(base_screw));           // how thick the bar clamps are
bar_clamp_tab = 3 + washer_diameter(screw_washer(base_screw));             // how much the lugs stick out
bar_clamp_band = 3;                                                        // the thickness of the strap that clamps the bar.
