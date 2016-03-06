//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// For making horizontal holes that don't need support material
// Small holes can get away without it but they print better with truncated teardrops
//
module teardrop_2D(r) {
    hull() {
        circle(r = r, center = true);
        translate([0, r/2])
            square([2*r*(2*cos(45)-1), r], center = true);
    }
}

module teardrop(h, r, center)
    render(convexity = 5) linear_extrude(height = h, convexity = 2, center = center)
        teardrop_2D(r);

module teardrop_plus(h, r, center)
    teardrop(h, r + layer_height / 4, center);


module tearslot(h, r, w, center)
    linear_extrude(height = h, convexity = 6, center = center)
        hull() {
            translate([-w/2,0,0]) teardrop_2D(r);
            translate([ w/2,0,0]) teardrop_2D(r);
        }

module vertical_tearslot(h, r, l, center = true)
    linear_extrude(height = h, convexity = 6, center = center)
        hull() {
            translate([0, l / 2]) teardrop_2D(r);
            translate([0, -l / 2, 0])
                circle(r = r, center = true);
        }
