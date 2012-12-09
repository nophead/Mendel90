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
exploded = 0;                   // 1 for exploded view

show_jigs = true;               // show printed jigs required to build the machine
show_support = true;            // show support structures, must be set when generating STLs

// Real-world colors for various parts & vitamins
use_realistic_colors = false;    // true for "real" colors, false for "distinct" colors (useful during design and for build instructions)
printed_plastic_color = "blue";
cable_strip_real_color = "fuchsia";
belt_real_color = "yellow";
bulldog_real_color ="black";

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
M2p5_nut_trap_depth = 2.5;

M3_tap_radius = 2.5 / 2;
M3_clearance_radius = 3.3 / 2;
M3_nut_radius = 6.5 / 2;
M3_nut_trap_depth = 3;

M4_tap_radius = 3.3 / 2;
M4_clearance_radius = 2.2;
M4_nut_radius = 8.2 / 2;
M4_nut_trap_depth = 4;

M5_tap_radius = 4.2 / 2;
M5_clearance_radius = 5.3 / 2;
M5_nut_radius = 9.2 / 2;
M5_nut_depth = 4;

M6_tap_radius = 5 / 2;
M6_clearance_radius = 6.4 / 2;
M6_nut_radius = 11.6 / 2;
M6_nut_depth = 5;

M8_tap_radius = 6.75 / 2;
M8_clearance_radius = 8.4 / 2;
M8_nut_radius = 15.4 / 2;
M8_nut_depth = 6.5;

cnc_tool_dia = 2.4;
layer_height = 0.4;
filament_width = layer_height * 1.5;
min_wall = 2 * filament_width + eta;
part_base_thickness = 5;;           // The thickness of things screwed to the frame

pcb_thickness = 1.6;
feed_tube_rad = 5 / 2;              // Filament feed tube
feed_tube_tape_rad = 6.2 / 2;
feed_tube_tape = 12;
nozzle_length = 54;                 // how far nozzle is below top of carriage


include <colors.scad>
include <utils.scad>
include <vitamins.scad>

endstop_wires    = [2, 1.4, "A"];   // 7 strands of 0.2
motor_wires      = [4, 1.4, "B"];
bed_wires        = [2, 2.8, "C"];   // 13A mains cable
fan_motor_wires  = [6, 1.4, "D"];   // fan and motor wires along top of gantry
two_motor_wires  = [8, 1.4,,"E"];   // Y and Z motors
thermistor_wires = endstop_wires;

endstop_wires_hole_radius = wire_hole_radius(endstop_wires);
motor_wires_hole_radius = wire_hole_radius(motor_wires);
two_motor_wires_hole_radius = wire_hole_radius(two_motor_wires);
fan_motor_wires_hole_radius = wire_hole_radius(fan_motor_wires);
bed_wires_hole_radius = wire_hole_radius(bed_wires);
thermistor_wires_hole_radius = wire_hole_radius(thermistor_wires);

cnc_sheets = false;                 // If sheets are cut by CNC we can use slots, etc instead of just round holes
base_nuts = false;                  // Need something under the base if using nuts
pulley_type = T5x8_plastic_pulley;
include <machine.scad>              // this file is generated from the command line parameter to include one of the machine configs

screw_clearance_radius = screw_clearance_radius(cap_screw);
nut = screw_nut(cap_screw);
nut_radius = nut_radius(nut);
nut_trap_depth = nut_trap_depth(nut);
washer = screw_washer(cap_screw);

bearing_clamp_tab = cnc_sheets ? (nut_radius(nut) + 3 * filament_width) * 2 : washer_diameter(washer) + 2;   // how much the lugs stick out and their width
bearing_clamp_tab_height = 4;           // thickness of the lugs

hole_edge_clearance = 5;                // how close a hole can be to the edge of a sheet
base_clearance = cnc_sheets ? 1 : 2;    // how close we get to the edge of the base
axis_end_clearance = cnc_sheets ? 1 : 2;// how close we get to the end of an axis
limit_switch_offset = 1;                // the over travel to reach the limit switch
X_carriage_clearance = 2;               // how close the X carriage is to the XZ plane
                                        // how close the Y carriage is to the window in the XZ plane
Y_carriage_clearance = 2 + bulldog_handle_length(small_bulldog) - (Y_carriage_width - bed_width) / 2;
Z_clearance = 10;                       // How close the top of the object gets to the gantry
belt_clearance = 0.2;                   // clearance of belt clamp slots

X_bar_dia = X_bearings[2];      // rod sizes to match the bearings
Y_bar_dia = Y_bearings[2];
Z_bar_dia = Z_bearings[2];

Y_idler_bearing = BB624;
X_idler_bearing = BB624;

extruder_ways = 4 + 6 + 2 + 1 + 1;      // motor + heater(x3) + thermistor + probe + fan = 14
x_end_ways = extruder_ways + 4 + 2;     // motor plus limit switch = 20
bed_ways = 24 + 2;                      // twelve each way for the current plus a thermistor

module wire_hole_or_slot(r) {
    if(cnc_sheets)
        rotate([0, 0, 90])
            slot(r = r, h = 100, l = 2 * r);
    else
        translate([0, r + hole_edge_clearance, 0])
            wire_hole(r);
}

function z_bar_offset() = round(NEMA_width(Z_motor)) / 2;

base_screw = sheet_is_soft(base) ? frame_soft_screw : (base_nuts ? frame_thin_screw : frame_thick_screw);
base_nut = base_nuts ? screw_nut(base_screw) : false;
base_nut_traps = base_nuts && cnc_sheets;
base_washer = screw_washer(base_screw);
base_screw_length = base_nuts ? screw_longer_than(
                                    sheet_thickness(base)
                                    + part_base_thickness +
                                    (cnc_sheets ? 1 : 2) * washer_thickness(base_washer)
                                    + nut_thickness(base_nut, true)
                                  )
                              : screw_shorter_than(
                                    sheet_thickness(base)
                                    + part_base_thickness
                                    + 2 * washer_thickness(base_washer)
                                 );


frame_screw = sheet_is_soft(frame) ? frame_soft_screw : (frame_nuts ? frame_thin_screw : frame_thick_screw);
frame_nut = frame_nuts ? screw_nut(frame_screw) : false;
frame_nut_traps = frame_nuts && cnc_sheets;
frame_washer = screw_washer(frame_screw);
frame_screw_length = frame_nuts ? screw_longer_than(
                                      sheet_thickness(frame)
                                      + part_base_thickness +
                                      (cnc_sheets ? 1 : 2) * washer_thickness(frame_washer)
                                      + nut_thickness(frame_nut, true)
                                  )

                                : screw_shorter_than(
                                      sheet_thickness(frame)
                                      + part_base_thickness
                                      + 2 * washer_thickness(frame_washer)
                                  );

echo("base screw length", base_screw_length);
echo("frame screw length",frame_screw_length);



module frame_screw(thickness) {
    if(frame_nuts && cnc_sheets) {
        nut(frame_nut, true);
        translate([0, 0, -sheet_thickness(frame) - thickness])
            rotate([180, 0, 0])
                screw_and_washer(frame_screw, frame_screw_length);
    }
    else {
        screw_and_washer(frame_screw, frame_screw_length, !frame_nuts);
        if(frame_nuts)
            translate([0, 0, -sheet_thickness(frame) - thickness])
                rotate([180, 0, 0])
                    nut_and_washer(frame_nut, true);
    }
}

module frame_screw_hole() {
    cylinder(r = frame_nuts ? screw_clearance_radius(frame_screw) : screw_pilot_hole(frame_screw), h = 100, center = true);
}



module base_screw(thickness) {
    if(base_nuts && cnc_sheets) {
        nut(base_nut, true);
        translate([0, 0, -sheet_thickness(base) - thickness])
            rotate([180, 0, 0])
                screw_and_washer(base_screw, base_screw_length);
    }
    else {
        screw_and_washer(base_screw, base_screw_length, !base_nuts);
        if(base_nuts)
            translate([0, 0, -sheet_thickness(base) - thickness])
                rotate([180, 0, 0])
                    nut_and_washer(base_nut, true);
    }
}

module base_screw_hole() {
    cylinder(r = base_nuts ? screw_clearance_radius(base_screw) : screw_pilot_hole(base_screw), h = 100, center = true);
}

bar_clamp_depth = 4 + washer_diameter(base_washer);           // how thick the bar clamps are
bar_clamp_tab = 3 + washer_diameter(base_washer);             // how much the lugs stick out
bar_clamp_band = 3;                                           // the thickness of the strap that clamps the bar.
