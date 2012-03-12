//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
//
//
include <conf/config.scad>

thickness = 2;
wall = 2 * filament_width + eta;
finger_width = 7;
spokes = 4;

function fan_guard_thickness() = thickness;

module fan_guard(type) {
    stl("fan_guard");
    hole_pitch = fan_hole_pitch(type);
    screw = fan_screw(type);
    corner_radius = washer_diameter(screw_washer(screw)) / 2 + 1;
    width = max(2 * (hole_pitch + corner_radius), fan_bore(type) + 2 * wall);

    hole = fan_bore(type) / 2;
    rings = ceil(hole / (wall + finger_width)) - 1;
    inner_ring = hole - rings * (wall + finger_width);

    union() {
        difference() {
            rounded_rectangle([width, width, thickness], r = width / 2 - hole_pitch, center = false);
            fan_holes(type, true);
        }
        for(i = [1 : rings])
            difference() {
                cylinder(r = hole - i * (wall + finger_width) + wall / 2, h = thickness);
                cylinder(r = hole - i * (wall + finger_width) - wall / 2, h = 2 * thickness + 1, center = true);
            }
        for(i = [0 : spokes - 1])
            rotate([0, 0, i * 360 / spokes + 180 / spokes - 90])
                translate([inner_ring, -wall / 2, 0])
                    cube([hole - inner_ring + eta, wall, thickness]);

    }
}

module fan_guard_stl() fan_guard(case_fan);

fan_guard(fan80x38);
//fan_guard(fan60x25);
