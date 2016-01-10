//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// LED light strips
//
SPS125        = ["SPS125: Sanken SPS125 light strip"      , 300, 20.0, 2.8, 1.6, 260,  0, 3.5];
Rigid5050_290 = ["RDG5050: Rigid 5050 light strip x 290mm", 290, 14.4,   0,   7,   0,  0,   0];
Rigid5050_208 = ["RDG5050: Rigid 5050 light strip x 208mm", 208, 14.4,   0,   7,   0,  0,   0];
RIGID5050_290 = ["RDG5050: Rigid 5050 light strip x 290mm", 290, 14.4,   0, 8.6,   0,  0,   0];
RIGID5050_208 = ["RDG5050: Rigid 5050 light strip x 208mm", 208, 14.4,   0, 8.6,   0,  0,   0];
FSRP3W        = ["FSRP3W: F-SRP-3W-250LM-CW-ND-300MM"     , 278, 20.0, 5.4, 3.0, 295, 15, 3.0];

function light_strip_length(type)     = type[1];
function light_strip_width(type)      = type[2];
function light_strip_set_back(type)   = type[3];
function light_strip_thickness(type)  = type[4];
function light_strip_hole_pitch(type) = type[5];
function light_strip_hole_pitch2(type)= type[6];
function light_strip_hole_dia(type)   = type[7];
function light_strip_has_holes(type)  = light_strip_hole_pitch(type) > 0;

module light_strip_hole_positions(type, all = false) {
    if(light_strip_has_holes(type))
        for(end = [-1, 1])
            if(light_strip_hole_pitch2(type)) {
                for(side = [-1, 1])
                    if(all || side > 0)
                        translate([end * light_strip_hole_pitch(type) / 2, side * light_strip_hole_pitch2(type) / 2 - wall, 0])
                            children();
            }
            else
                translate([end * light_strip_hole_pitch(type) / 2, 0, 0])
                    children();
}

module light_strip(type) {
    vitamin(type[0]);
    color("white") render() difference() {
        translate([0, 0, light_strip_thickness(type) / 2])
            cube([light_strip_length(type), light_strip_width(type), light_strip_thickness(type)], center = true);

        light_strip_hole_positions(type, true)
            cylinder(r = light_strip_hole_dia(type) / 2, h = 100, center = true);

    }
    if(show_rays)
        %cylinder(r = 1, h = 150);

    translate([0, 0, light_strip_thickness(type) + light_strip_set_back(type) / 2])
        %cube([light_strip_length(type), light_strip_width(type), light_strip_set_back(type)], center = true);
}
