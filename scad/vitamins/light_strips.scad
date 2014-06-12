//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// LED light strips
//
SPS125 = ["SPS125: Sanken SPS125 light strip", 300, 20, 0, 1.6, 260, 3.5];

function light_strip_length(type)     = type[1];
function light_strip_width(type)      = type[2];
function light_strip_set_back(type)   = type[3];
function light_strip_thickness(type)  = type[4];
function light_strip_hole_pitch(type) = type[5];
function light_strip_hole_dia(type)   = type[6];

module light_strip(type) {
    vitamin(type[0]);
    color("white") render() difference() {
        translate([0, 0, light_strip_thickness(type) / 2])
            cube([light_strip_length(type), light_strip_width(type), light_strip_thickness(type)], center = true);

        for(side = [-1, 1])
            translate([side * light_strip_hole_pitch(type) / 2, 0, 0])
                cylinder(r = light_strip_hole_dia(type) / 2, h = 100, center = true);
    }
}
