//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Clamps for ribbon cable plus cable_strip
//
include <conf/config.scad>

thickness = 5;
slot_depth = 1.3;
min_gap = 1.5;

function ribbon_clamp_slot(ways) = ways * 0.05 * 25.4 + 2;
function ribbon_clamp_pitch(ways, screw_type) = ribbon_clamp_slot(ways) + 2 * (screw_clearance_radius(screw_type) + min_gap);
function ribbon_clamp_width(screw_type) = washer_diameter(screw_washer(screw_type)) + 2;
function ribbon_clamp_length(ways, screw_type) =  ribbon_clamp_pitch(ways, screw_type) + ribbon_clamp_width(screw_type);
function ribbon_clamp_thickness() = thickness;

module ribbon_clamp_holes(ways, screw_type) {
    pitch = ribbon_clamp_pitch(ways, screw_type);
    for(end = [-1, 1])
        translate([end * pitch / 2, 0, 0])
            child();
}

module ribbon_clamp(ways, screw_type) {
    hole_rad = screw_clearance_radius(screw_type);
    stl(str("ribbon_clamp_",ways,"_", 20 * hole_rad));
    rad = ribbon_clamp_width(screw_type) / 2;
    slot = ribbon_clamp_slot(ways);
    pitch = ribbon_clamp_pitch(ways, screw_type);
    translate([0,0, -thickness / 2]) difference() {
        //
        // body
        //
        slot(r = rad, l = pitch, h = thickness, center = true);
        //
        // screw holes
        //
        ribbon_clamp_holes(ways, screw_type)
            poly_cylinder(r = hole_rad, h = thickness + 1, center = true);
        //
        // Slot
        //
        translate([0, 0,thickness - slot_depth])
            cube([slot, 2 * rad + 1,thickness], center = true);
    }
}

module ribbon_clamp_assembly(ways, screw_type, screw_length, panel_thickness = 0, vertical = false, washer = false) {
    color(ribbon_clamp_color)
        render() rotate([180, 0, 0])
            ribbon_clamp(ways, screw_type);

    translate([0,0, thickness])
        ribbon_clamp_holes(ways, screw_type)
            screw_and_washer(screw_type, screw_length, panel_thickness == 0);

    if(panel_thickness != 0)
        translate([0,0, - panel_thickness])
            ribbon_clamp_holes(ways, screw_type)
                rotate([180, 0, vertical ? 90 : 0])
                    if(washer)
                        nut_and_washer(screw_nut(screw_type), true);
                    else
                        nut(screw_nut(screw_type), true);
}

module ribbon_clamp_12_33_stl() translate([0,0,thickness]) ribbon_clamp(12, M3_cap_screw);
module ribbon_clamp_20_33_stl() translate([0,0,thickness]) ribbon_clamp(20, M3_cap_screw);
module ribbon_clamp_20_40_stl() translate([0,0,thickness]) ribbon_clamp(20, No6_screw);
module ribbon_clamp_20_44_stl() translate([0,0,thickness]) ribbon_clamp(20, M4_cap_screw);
module ribbon_clamp_22_33_stl() translate([0,0,thickness]) ribbon_clamp(22, M3_cap_screw);
module ribbon_clamp_22_40_stl() translate([0,0,thickness]) ribbon_clamp(22, No6_screw);
module ribbon_clamp_22_44_stl() translate([0,0,thickness]) ribbon_clamp(22, M4_cap_screw);

module ribbon_clamps_stl() {
    translate([0,-12,0]) ribbon_clamp(bed_ways, cap_screw);
    translate([0,0,0])   ribbon_clamp(bed_ways, cap_screw);
    translate([0,12,0])  ribbon_clamp(bed_ways, base_screw);
    translate([0,25,0])  ribbon_clamp(x_end_ways, frame_screw);
    translate([0,37,0])  ribbon_clamp(x_end_ways, M3_cap_screw);
    translate([0,48,0])  ribbon_clamp(extruder_ways, M3_cap_screw);
}

if(1)
    ribbon_clamp_assembly(20, M4_cap_screw, 20, 4);

else
    ribbon_clamps_stl();
