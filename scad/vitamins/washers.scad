//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Washers
//
M2p5_washer=      [2.5, 5, 0.5, false];
M3_washer  =      [3,   7, 0.5, false];
M3p5_washer  =    [3.5, 8, 0.5, false];
M4_washer  =      [4,   9, 0.9, false];
M5_penny_washer = [5,  20, 1.4, false];
M6_washer  =      [6,  12, 1.5, false];
M8_washer =       [8,  16, 1.5, false];

M3_rubber_washer= [3,  10, 1.5, true];

function washer_diameter(type) =  type[1];
function washer_thickness(type) = type[2];
function washer_soft(type) = type[3];
function washer_color(type) = washer_soft(type) ? soft_washer_color : hard_washer_color;

module washer(type) {
    if(washer_soft(type))
        vitamin(str("WR", type[0] * 10, type[1], type[2] * 10, ": Rubber washer M",type[0], " x ", type[1], " x ", type[2]));
    else
        vitamin(str("WA", type[0] * 10, type[1], type[2] * 10, ": Washer M",type[0], " x ", type[1], " x ", type[2]));
    color(washer_color(type))  render() difference() {
        cylinder(r = washer_diameter(type) / 2, h = washer_thickness(type));
        cylinder(r = type[0] / 2, h = 2 * washer_thickness(type) + 1, center = true);
    }
}

module star_washer(type) {
    hole = type[0] / 2;
    rad = washer_diameter(type) / 2;
    inner = (hole + rad) / 2;
    spoke  = rad - hole;
    vitamin(str("WS", type[0] * 10, type[1], type[2] * 10, ": Star washer M",type[0], " x ", type[1], " x ", type[2]));
    color(star_washer_color) render() difference() {
        cylinder(r = rad, h = washer_thickness(type));
        cylinder(r = hole, h = 2 * washer_thickness(type) + 1, center = true);
        for(a = [0:30:360])
            rotate([0, 0, a])
                translate([inner + spoke / 2, 0, 0.5])
                    cube([spoke, 2 * 3.142 * inner / 36,  washer_thickness(type) + 1], center = true);
    }
}
