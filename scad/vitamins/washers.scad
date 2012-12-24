//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Washers
//
M2p5_washer=      [2.5, 5.9, 0.5, false,  5.4];
M3_washer  =      [3,   7, 0.5, false,  5.8];
M3_penny_washer  =[3,  12, 0.8, false,  5.8];
M3p5_washer  =    [3.5, 8, 0.5, false,  6.9];
M4_washer  =      [4,   9, 0.8, false,  7.9];
M5_washer  =      [5,  10, 1.0, false,    9];
M5_penny_washer = [5,  20, 1.4, false,  8.8];
M6_washer  =      [6,  12, 1.5, false, 10.6];
M8_washer =       [8,  17, 1.6, false, 13.8];
M8_penny_washer = [8,  30, 1.5, false, 13.8];

M3_rubber_washer= [3,  10, 1.5, true];

function washer_diameter(type)  = type[1];
function washer_thickness(type) = type[2];
function washer_soft(type)      = type[3];
function washer_color(type) = washer_soft(type) ? soft_washer_color : hard_washer_color;
function star_washer_diameter(type) = type[4];

module washer(type) {
    hole = type[0];
    thickness = washer_thickness(type);
    diameter  = washer_diameter(type);
    if(washer_soft(type))
        vitamin(str("WR", hole * 10, diameter, thickness * 10, ": Rubber washer M", hole, " x ", diameter, "mm x ", thickness, "mm"));
    else
        vitamin(str("WA", hole * 10, diameter, thickness * 10, ": Washer M",        hole, " x ", diameter, "mm x ", thickness, "mm"));
    color(washer_color(type)) render() difference() {
        cylinder(r = diameter / 2, h = thickness);
        cylinder(r = hole / 2, h = 2 * thickness + 1, center = true);
    }
    translate([0, 0, thickness])
        child();
}

module star_washer(type) {
    hole = type[0];
    thickness = washer_thickness(type);
    diameter  = star_washer_diameter(type);
    rad = diameter / 2;
    inner = (hole / 2 + rad) / 2;
    spoke  = rad - hole / 2;
    vitamin(str("WS", hole * 10, washer_diameter(type), thickness * 10,
                ": Star washer M", hole, " x ", thickness, "mm"));
    color(star_washer_color) render() difference() {
        cylinder(r = rad, h = thickness);
        cylinder(r = hole / 2, h = 2 * thickness + 1, center = true);
        for(a = [0:30:360])
            rotate([0, 0, a])
                translate([inner + spoke / 2, 0, 0.5])
                    cube([spoke, 2 * 3.142 * inner / 36,  thickness + 1], center = true);
    }
    translate([0, 0, thickness])
        child();
}
