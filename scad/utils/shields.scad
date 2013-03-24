// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// For making heat shields to prevent corner warping, see http://hydraraptor.blogspot.co.uk/2010/09/some-corners-like-it-hot.html
//
shield_thickness = 1;
shield_base_thickness = 5;
shield_base_height = 3;
shield_clearance = 1;

module shield_corner(w, h, r) {
    linear_extrude(height = h, convexity = 5)
        hull() {
            intersection() {
                translate([r, r])
                    circle(r);
                square([r + 1,r + 1]);
            }

            translate([w - 1, 0])
                square([1, w]);

            translate([0, w - 1])
                square([w, 1]);
        }
}

module L(w, h, t, r) {
    translate([-t, -t, 0])
        difference() {
            shield_corner(w, h, r + t);
            translate([t, t, -1]) shield_corner(w, h + 2, r);
        }
}



module corner_shield(w, h, r) {
    color([0,1,0])union() translate([-shield_clearance, -shield_clearance, 0]) {
        L(w, h, shield_thickness, r + shield_clearance);
        L(w + shield_base_thickness - shield_thickness, shield_base_height, shield_base_thickness, r + shield_clearance);
    }
}

module side_shield(w,h) {
    translate([-w/2, -shield_thickness, 0])
        color([0,1,0]) union() {
            cube([w, shield_thickness, h]);
            translate([0,shield_thickness - shield_base_thickness, 0])
                cube([w, shield_base_thickness, shield_base_height]);
        }
}

//corner_shield(20, 15, 7);
