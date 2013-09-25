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

slot_depth = 1.2;
thickness = 5.2;
base_thickness = slot_depth + 2;
min_gap = 1.5;
nut_trap_meat = 4;
rib = 3;

function ribbon_clamp_slot(ways) = ways * 0.05 * 25.4 + 2;
function ribbon_clamp_pitch(ways, screw_type) = ribbon_clamp_slot(ways) + 2 * (screw_clearance_radius(screw_type) + min_gap);
//function ribbon_clamp_width(screw_type) = washer_diameter(screw_washer(screw_type)) + 2;
function ribbon_clamp_width(screw_type) = screw_boss_diameter(screw_type);
function ribbon_clamp_length(ways, screw_type) =  ribbon_clamp_pitch(ways, screw_type) + ribbon_clamp_width(screw_type);
function ribbon_clamp_thickness(nut = false) = nut ? nut_trap_meat : thickness;
function ribbon_clamp_slot_depth() = slot_depth;

module ribbon_clamp_holes(ways, screw_type) {
    pitch = ribbon_clamp_pitch(ways, screw_type);
    for(end = [-1, 1])
        translate([end * pitch / 2, 0, 0])
            child();
}

module ribbon_clamp(ways, screw_type, nutty = false, slotted = true) {
    hole_rad = screw_clearance_radius(screw_type);
    stl(str("ribbon_clamp_",ways,"_", 20 * hole_rad, nutty ? "N" : "", slotted ? "": "B"));
    rad = ribbon_clamp_width(screw_type) / 2;
    slot = ribbon_clamp_slot(ways);
    pitch = ribbon_clamp_pitch(ways, screw_type);
    nut = screw_nut(screw_type);
    nut_depth = nut_trap_depth(nut);
    nut_trap_height = nut_trap_meat + nut_depth;
    difference() {
        //
        // body
        //
        union() {
            if(nutty) {
                translate([0, 0, thickness - nut_trap_height - eta]) {
                    ribbon_clamp_holes(ways, screw_type)
                        cylinder(r = rad - eta, h = nut_trap_height);

                    translate([0, 0, nut_trap_height / 2])
                        cube([pitch, rib, nut_trap_height - eta], center = true);
                }
                translate([0, 0, thickness - base_thickness])
                    slot(r = rad, l = pitch, h = base_thickness, center = false);
            }
            else
                slot(r = rad, l = pitch, h = thickness, center = false);
        }
        //
        // Nut trap
        //
        //
        // screw holes
        //
        ribbon_clamp_holes(ways, screw_type)
            if(nutty)
                translate([0, 0, thickness - nut_trap_height])
                    nut_trap(hole_rad, nut_radius(nut), nut_depth, false, supported = false);
            else
                poly_cylinder(r = hole_rad, h = 2 * thickness + 1, center = true);
        //
        // Slot
        //
        if(slotted)
            translate([0, 0, thickness / 2 + thickness - slot_depth])
                cube([slot, 2 * rad + 1,thickness], center = true);

    }
}

module ribbon_clamp_stl(ways, screw_type, nutty = false, slotted = true) {
    if(nutty)
        translate([0, 0, thickness])
            rotate([180, 0, 0])
                ribbon_clamp(ways, screw_type, nutty, slotted);
    else
        ribbon_clamp(ways, screw_type, nutty, slotted);
}

module ribbon_clamp_support(ways, screw_type) {
    hole_rad = screw_clearance_radius(screw_type);
    stl(str("ribbon_clamp_support",ways,"_", 20 * hole_rad));
    rad = ribbon_clamp_width(screw_type) / 2;

    slot = ribbon_clamp_slot(ways);

    //
    // Slot
    //
    translate([0, 0, slot_depth / 2])
        cube([slot, 2 * rad + 8, slot_depth], center = true);

}

module ribbon_clamp_assembly(ways, screw_type, screw_length, panel_thickness = 0, vertical = false, washer = false, nutty = false, slotted = true) {
    color(ribbon_clamp_color) render()
        translate([0, 0, thickness])
            rotate([180, 0, 0])
                ribbon_clamp(ways, screw_type, nutty = nutty, slotted = slotted);

    if(nutty) {
        if(panel_thickness > 0)
            ribbon_clamp_holes(ways, screw_type) group() {
                translate([0, 0, -panel_thickness])
                    rotate([180, 0, 0])
                        screw_and_washer(screw_type, screw_length);
                translate([0, 0, nut_trap_meat])
                    nut(screw_nut(screw_type), true);
            }
    }
    else {

        translate([0,0, thickness])
            ribbon_clamp_holes(ways, screw_type)
                screw_and_washer(screw_type, screw_length, panel_thickness == 0);  // spring washer if no nut

        if(panel_thickness != 0)
            translate([0,0, - panel_thickness])
                ribbon_clamp_holes(ways, screw_type)
                    rotate([180, 0, vertical ? 90 : 0])
                        if(washer)
                            nut_and_washer(screw_nut(screw_type), true);
                        else
                            nut(screw_nut(screw_type), true);
    }
}

module ribbon_clamp_14_33_stl()    ribbon_clamp_stl(14, M3_cap_screw);
module ribbon_clamp_14_33NB_stl()  ribbon_clamp_stl(14, M3_cap_screw, nutty = true, slotted = false);

module ribbon_clamp_20_33_stl()    ribbon_clamp_stl(20, M3_cap_screw);
module ribbon_clamp_20_33N_stl()   ribbon_clamp_stl(20, M3_cap_screw, nutty = true);
module ribbon_clamp_20_40_stl()    ribbon_clamp_stl(20, No6_screw);
module ribbon_clamp_20_44_stl()    ribbon_clamp_stl(20, M4_cap_screw);
module ribbon_clamp_20_44N_stl()   ribbon_clamp_stl(20, M4_cap_screw, nutty = true);

module ribbon_clamp_26_33_stl()    ribbon_clamp_stl(26, M3_cap_screw);
module ribbon_clamp_26_33N_stl()   ribbon_clamp_stl(26, M3_cap_screw, nutty = true);
module ribbon_clamp_26_40_stl()    ribbon_clamp_stl(26, No6_screw);
module ribbon_clamp_26_44_stl()    ribbon_clamp_stl(26, M4_cap_screw);
module ribbon_clamp_26_44N_stl()   ribbon_clamp_stl(26, M4_cap_screw, nutty = true);

module ribbon_clamps_stl() {
    gap = 2;
    y1 = ribbon_clamp_width(cap_screw) / 2 + ribbon_clamp_width(base_screw) / 2 + gap;
    y2 = y1 + ribbon_clamp_width(base_screw) / 2 + ribbon_clamp_width(frame_screw) / 2 + gap;
    y3 = y2 + ribbon_clamp_width(frame_screw) / 2 + ribbon_clamp_width(cap_screw) / 2 + gap;
    y4 = y3 + ribbon_clamp_width(cap_screw) / 2 + ribbon_clamp_width(M3_cap_screw) / 2 + gap;
    y5 = y4 + ribbon_clamp_width(M3_cap_screw) / 2 + ribbon_clamp_width(M3_cap_screw) / 2 + gap;
    rotate([0, 0, 90]) {
        translate([0,0, 0])  ribbon_clamp_stl(bed_ways, cap_screw, nutty = true);
        translate([0,y1,0])  ribbon_clamp_stl(bed_ways, base_screw, nutty = (cnc_sheets && base_nuts));
        translate([0,y2,0])  ribbon_clamp_stl(x_end_ways, frame_screw, nutty = (cnc_sheets && frame_nuts));
        translate([0,y3,0])  ribbon_clamp_stl(bed_ways, cap_screw);
        translate([0,y4,0])  ribbon_clamp_stl(x_end_ways, M3_cap_screw);
        translate([0,y5,0])  ribbon_clamp_stl(extruder_ways, M3_cap_screw);
    }
}
if(0) {
    ribbon_clamp_assembly(20, M4_cap_screw, 16, 4, nutty = true);

    translate([0, -15, 0]) ribbon_clamp_assembly(20, frame_screw, frame_screw_length, sheet_thickness(frame), nutty = false);
}
else
    ribbon_clamps_stl();
