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

module linear_bearing(type) {
    vitamin(str("LM",type[2],"UU: ","LM",type[2],"UU linear bearing"));
    color(bearing_color) rotate([0,90,0]) difference() {
        cylinder(r = type[1] / 2, h = type[0], center = true);
        cylinder(r = type[2] / 2, h = type[0] + 1, center = true);
    }
}
