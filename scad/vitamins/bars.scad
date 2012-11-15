//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Bar stock
//
AL_square_tube = [25.4 / 2, 25.4 / 2, 1.63];

function tube_width(type)     = type[0];
function tube_height(type)    = type[1];
function tube_thickness(type) = type[2];

module square_tube(type, length, center = true) {
    vitamin(str("SQT",length,": AL square tube ",tube_width(type)," x ",tube_height(type), " x ", tube_thickness(type), " x ", length, "mm"));

    color("silver")
        linear_extrude(height = length, convexity = 10, center = center)
            difference() {
                square([tube_width(type), tube_height(type)], center = true);
                square([tube_width(type) - 2 * tube_thickness(type), tube_height(type) - 2 * tube_thickness(type)], center = true);
            }
}
