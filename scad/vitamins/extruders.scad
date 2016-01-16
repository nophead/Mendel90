//
// Mendel90
//
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Extruder descriptions
//
extruder_mount_pitch = 50;

Wades    = [96, 16, 26, [36, 36,   5], NEMA17, 45, 3];
Direct14 = [63,  0, 20, [28, 26,   3], NEMA14, 35, 1.75];
Direct17 = [96, 16, 24, [29, 34,   3], NEMA17, 35, 1.75];

function extruder_length(type)         = type[0];
function extruder_x_offset(type)       = type[1];
function extruder_width(type)          = type[2];
function extruder_hole(type)           = type[3];
function extruder_motor(type)          = type[4];
function extruder_d_screw_length(type) = type[5];
function extruder_filament(type)       = type[6];

module extruder_mounting_screws()
    for(side = [-1, 1])
        translate([extruder_mount_pitch * side / 2, 0, 0])
            if(side > 0 && hot_end_invert_screw(hot_end))
                nut_and_washer(M4_nut);
            else
                translate([0, 0, -3])
                     screw(M4_hex_screw, 20);

module extruder_mounting_holes(reversed = false)
    rotate([90, 0, 0])
        for(side = [-1, 1])
            translate([side * extruder_mount_pitch / 2, 0, 0])
                if((reversed ? side < 0 : side > 0) && hot_end_invert_screw(hot_end))
                    poly_cylinder(r = M4_clearance_radius, h = 100, center = true);
                else
                    nut_trap(M4_clearance_radius, M4_nut_radius, 3, true);
