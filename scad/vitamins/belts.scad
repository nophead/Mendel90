//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Belt model
//
T5x6 =  [  5,  6, 2.25];
T5x10 = [  5, 10, 2.25];
T2p5x6 =[2.5,  6,  1.7];
GT2 =   [2.0,  6,  1.38];

function belt_pitch(type) = type[0];
function belt_width(type) = type[1];
function belt_thickness(type) = type[2];

module belt(type, x1, y1, r1, x2, y2, r2, gap = 0) {
    width = belt_width(type);
    pitch = belt_pitch(type);
    thickness = belt_thickness(type);

    pi = 3.14159265;
    dx = x2 - x1;
    dy = y2 - y1;

    length = round((pi * (r1 + r2 + thickness) + 2 * sqrt(dx * dx + dy * dy) - gap) / pitch) * pitch;
    vitamin(str("BT", belt_pitch(type) * 10,width, round(length), ": Belt T", belt_pitch(type)," x ", width, "mm x ", round(length), "mm"));

    color(belt_color)
    linear_extrude(height = width, center = true, convexity = 6) {
        difference() {
            hull() {                                                    // outside of belt
                translate([x1,y1])
                    circle(r = r1 + thickness, center = true);
                translate([x2,y2])
                    circle(r = r2 + thickness, center = true);
            }
            hull() {                                                    // inside of belt
                translate([x1,y1])
                    circle(r = r1, center = true);
                translate([x2,y2])
                    circle(r = r2, center = true);
            }
        }
    }
}

module twisted_belt(type, x1, y1, r1, x2, y2, r2, gap = 0) {
    dx = x2 - x1;
    dy = y2 - y1;

    angle = atan2(dy, dx) - atan2((r2 - r1), dx);

    color(belt_color)
    union() {
        difference() {
            belt(type, x1, y1, r1, x2, y2, r2, gap);
            translate([x1, y1 - r1 - belt_thickness(type) / 2, 0])
                rotate([0,0, angle])
                    translate([dx / 2, 0, 0])
                        cube([dx, belt_thickness(type) + 1 , belt_width(type) + 1], center = true);
        }
        translate([x1, y1 - r1 - belt_thickness(type) / 2, 0])
            rotate([0,90, angle])
                linear_extrude(height = dx, twist = 180)
                    square([belt_width(type), belt_thickness(type)], center = true);
    }
}

//twisted_belt(T5x6, 10, 11-4.87, 4.87, 200, 20, 11);
//twisted_belt(T5x6,  -374, -1.55, 6.5, 0, 0, 4.95);
