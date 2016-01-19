//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Washers
//
M2_nut    =   [2, 4.9, 1.6, 2.4,  M2_washer,     M2_nut_trap_depth, 5/2];
M2p5_nut  = [2.5, 5.8, 2.2, 3.8,  M2p5_washer, M2p5_nut_trap_depth, 5.9 / 2];
M3_nut      = [3, 6.4, 2.4, 4,    M3_washer,     M3_nut_trap_depth, M3_nut_radius];
M4_nut      = [4, 8.1, 3.2, 5,    M4_washer,     M4_nut_trap_depth, M4_nut_radius];
M5_nut      = [5, 9.2,   4, 6.25, M5_washer,     M5_nut_depth,      M5_nut_radius];
M6_nut      = [6, 11.5,  5, 8,    M6_washer,     M6_nut_depth,      M6_nut_radius];
M6_half_nut = [6, 11.5,  3, 8,    M6_washer,     3,                 M6_nut_radius];
M8_nut      = [8, 15,  6.5, 8,    M8_washer,     M8_nut_depth,      M8_nut_radius];

function nut_radius(type) = type[1] / 2;
function nut_flat_radius(type) = nut_radius(type) * cos(30);
function nut_thickness(type, nyloc = false) = nyloc ? type[3] : type[2];
function nut_washer(type) = type[4];
function nut_trap_depth(type) = type[5];

module nut(type, nyloc = false, brass = false) {
    hole_rad  = type[0] / 2;
    outer_rad = nut_radius(type);
    thickness = nut_thickness(type);
    nyloc_thickness = type[3];

    if(nyloc)
        vitamin(str("NYLOCM", type[0], ": Nyloc nut M", type[0]));
    else
        if(brass)
            vitamin(str("NUTBM", type[0], ": Brass nut M", type[0]));
        else
            vitamin(str("NUTM", type[0], ": Nut M", type[0]));

    if(exploded && nyloc)
        cylinder(r = 0.2, h = 10);

    color(brass? brass_nut_color : nut_color) render() translate([0, 0, (exploded && nyloc) ? 10 : 0]) difference() {
        union() {
            cylinder(r = outer_rad, h = thickness, $fn = 6);
            if(nyloc)
                translate([0,0, eta])
                    rounded_cylinder(r = outer_rad * cos(30) , h = nyloc_thickness, r2 = (nyloc_thickness - thickness) / 2);
        }
        translate([0, 0, -1])
            cylinder(r = hole_rad, h = nyloc_thickness + 2);
    }
    if($children)
        translate([0, 0, thickness])
            children();
}

module nut_and_washer(type, nyloc) {
    washer = nut_washer(type);
    translate([0, 0, exploded ? 7 : 0])
        washer(washer);
    translate([0,0, washer_thickness(washer)])
        nut(type, nyloc);
}

M4_wingnut = [4, 10, 3.75, 8, M4_washer, 0, 22, 10, 6, 3];

module wingnut(type) {
    hole_rad  = type[0] / 2;
    bottom_rad = nut_radius(type);
    top_rad = type[3] / 2;
    thickness = nut_thickness(type);
    wing_span = type[6];
    wing_height = type[7];
    wing_width = type[8];
    wing_thickness = type[9];

    top_angle = asin((wing_thickness / 2) / top_rad);
    bottom_angle = asin((wing_thickness / 2) / bottom_rad);

    vitamin(str("WING0", type[0], ": Wingnut M",type[0]));
    if(exploded)
        cylinder(r = 0.2, h = 10);

    color(nut_color) render() translate([0, 0, exploded ? 10 : 0]) difference() {
        union() {
            cylinder(r1 = bottom_rad, r2 = top_rad, h = thickness);
            for(rot = [0, 180])
                rotate([90, 0, rot]) linear_extrude(height = wing_thickness, center = true)
                    hull() {
                        translate([wing_span / 2  - wing_width / 2, wing_height - wing_width / 2])
                            circle(r = wing_width / 2, center = true);
                        polygon([
                            [bottom_rad * cos(top_angle) - eta, 0],
                            [wing_span / 2  - wing_width / 2, wing_height - wing_width / 2],
                            [top_rad * cos(top_angle) - eta, thickness],
                        ]);
                    }
        }
        translate([0,0,-1])
            cylinder(r = hole_rad, h = thickness + 2);
    }
}
function nut_trap_radius(nut, horizontal = true, snug = true) = (snug ? nut_radius(nut) : nut[6]) + (horizontal ? layer_height / 4 : 0);
function nut_trap_flat_radius(nut, horizontal = true, snug = true) = nut_trap_radius(nut, horizontal, snug) * cos(30);

module nut_trap(screw_r, nut_r, depth, horizontal = false, supported = false) {
    render(convexity = 5) union() {
        if(horizontal) {
            if(screw_r)
                teardrop_plus(r = screw_r, h = 200, center = true);
            cylinder(r = nut_r + layer_height / 4, h = depth * 2, center = true, $fn = 6);
        }
        else {
            difference() {
                union() {
                    if(screw_r)
                        poly_cylinder(r = screw_r, h = 200, center = true);
                    cylinder(r = nut_r, h = depth * 2, center = true, $fn = 6);
                }
                if(supported)
                    translate([0, 0, depth - eta])
                        cylinder(r = nut_r, h = layer_height, center = false);
            }
        }
    }
}
