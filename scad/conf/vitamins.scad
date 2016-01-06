//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Off the shelf parts
//
//
// Hole sizes
//
No2_pilot_radius = 1.7 / 2;       // self tapper into ABS
No4_pilot_radius = 2.0 / 2;       // wood screw into soft wood
No6_pilot_radius = 2.0 / 2;       // wood screw into soft wood

No2_clearance_radius = 2.5 / 2;
No4_clearance_radius = 3.5 / 2;
No6_clearance_radius = 4.0 / 2;

M2_tap_radius = 1.6 / 2;
M2_clearance_radius = 2.4 / 2;
M2_nut_trap_depth = 2.5;

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

include <../vitamins/washers.scad>
include <../vitamins/nuts.scad>
include <../vitamins/screws.scad>
include <../vitamins/microswitch.scad>
include <../vitamins/stepper-motors.scad>
include <../vitamins/ball-bearings.scad>
include <../vitamins/linear-bearings.scad>
include <../vitamins/pillars.scad>
include <../vitamins/belts.scad>
include <../vitamins/sheet.scad>
include <../vitamins/springs.scad>
include <../vitamins/d-connectors.scad>
include <../vitamins/ziptie.scad>
include <../vitamins/bulldog.scad>
include <../vitamins/cable_strip.scad>
include <../vitamins/fans.scad>
include <../vitamins/electronics.scad>
include <../vitamins/spools.scad>
include <../vitamins/terminals.scad>
include <../vitamins/o_rings.scad>
include <../vitamins/tubing.scad>
include <../vitamins/components.scad>
include <../vitamins/hot_ends.scad>
include <../vitamins/bars.scad>
include <../vitamins/pullies.scad>
include <../vitamins/extruders.scad>
include <../vitamins/light_strips.scad>

module rod(d , l) {
    vitamin(str("RD", d, round(l), ": Smooth rod ", d, "mm x ", round(l), "mm"));
    color(rod_color)
        cylinder(r = d / 2, h = l, center = true);
}

module studding(d , l) {
    vitamin(str("ST", d, round(l),": Threaded rod M", d, " x ", round(l), "mm"));
    color(studding_color)
        cylinder(r = d / 2, h = l, center = true);
}

module wire(color, strands, length)
    vitamin(str("WR", strands, color[0], length, ": ",color, " wire ", strands, "/0.2 length ",length, "mm"));

module ribbon_cable(ways, length)
    vitamin(str("RC", ways, length, ": Ribbon cable ", ways, " way ", length, "mm"));
