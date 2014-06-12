//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Linear bearings
//
LM10UU = [29, 19, 10];
LM8UU  = [24, 15,  8];
LM6UU  = [19, 12,  6];
LM4UU  = [12,  8,  4];

function bearing_length(type)  = type[0];
function bearing_radius(type)  = type[1] / 2;
function bearing_rod_dia(type) = type[2];

module linear_bearing(type) {
    vitamin(str("LM",type[2],"UU: ","LM",type[2],"UU linear bearing"));
    color(bearing_color) render() rotate([0,90,0]) difference() {
        cylinder(r = bearing_radius(type), h = type[0], center = true);
        cylinder(r = type[2] / 2, h = type[0] + 1, center = true);
    }
}
