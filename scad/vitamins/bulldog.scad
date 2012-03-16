//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Crude representation of a bulldog clip
//
small_bulldog = [19, 12, 8, 0.25, 2.67, 1, 16];

function bulldog_length(type)    = type[0];
function bulldog_depth(type)     = type[1];
function bulldog_height(type)    = type[2];
function bulldog_thickness(type) = type[3];
function bulldog_tube(type)      = type[4] / 2;
function bulldog_radius(type)    = type[5];
function bulldog_handle_length(type) = type[6];

module bulldog_shape(depth, height, radius, open) {
    hull() {
        translate([-depth / 2 + radius,  height / 2 - radius]) circle(radius);
        translate([-depth / 2 + radius, -height / 2 + radius]) circle(radius);
        translate([ depth / 2, 0]) square([0.1, open], center = true);
    }
}

module shell(length, width, height, wall) {
    difference() {
        linear_extrude(height = height, center = true, convexity = 5)
            child();
        linear_extrude(height = height + 1, center = true, convexity = 5)
            difference() {
                square([length - 2 * wall, width - 2 * wall], center = true);
                minkowski() {
                    difference() {
                        square([length + 1, width + 1], center = true);
                        translate([10,0])
                            square([length + 1, 2 * wall + eta], center = true);
                        child();
                     }
                     circle(r = wall, center = true);
                }
            }
    }
}


module bulldog(type, open = 4) {
    tube = bulldog_tube(type);
    thickness = bulldog_thickness(type);
    depth = bulldog_depth(type);
    gap = open + thickness * 2;

    vitamin(str("BD00", bulldog_length(type), ": ", bulldog_length(type), "mm bulldog clip"));

    color(bulldog_color)
    render() translate([depth / 2 - thickness - eta, 0, 0])
        union() {
            difference() {
                rotate([90, 0, 0])
                    shell(depth, bulldog_height(type), bulldog_length(type), thickness)
                        bulldog_shape(depth, bulldog_height(type), bulldog_radius(type), gap);
                translate([depth - tube - eta, 0, 0])
                    cube([depth, bulldog_length(type) + 1, 100], center = true);
            }
            for(side = [-1,1])
                translate([bulldog_depth(type) / 2 - tube, 0, side * (gap / 2 + tube)])
                    rotate([90,0,0])
                        tube(or = tube, ir = tube - thickness, h = bulldog_length(type));
        }
}
