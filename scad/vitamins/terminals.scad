//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Screw terminal blocks
//

module terminal_254(ways) {
    vitamin(str("TERM", ways, ": ", ways, " way terminal block"));
    pitch = 2.54;
    width = ways * pitch;
    depth = 6.2;
    height = 8.5;
    ledge_height = 5;
    ledge_depth = 0.7;
    top = 3;
    back = 3;
    color("lime") render()
        difference() {
            rotate([90, 0, 0])
                linear_extrude(height = width, center = true, convexity = 5)
                    polygon(points = [
                        [ depth / 2,               0],
                        [ depth / 2,               ledge_height],
                        [ depth / 2 - ledge_depth, ledge_height],
                        [   top / 2,               height],
                        [  -top / 2,               height],
                        [-depth / 2,               back],
                        [-depth / 2,               0],
                    ]);
            for(i = [0: ways -1]) {
                translate([0, i * 2.54 - width / 2 + pitch / 2, 1])
                    cylinder(r = 1, h = 100);
                translate([depth / 2, i * pitch - width / 2 + 1.27, ledge_height / 2]) {
                    hull() {
                        cube([1, pitch - 0.4, ledge_height - 0.4], center = true);
                        cube([4, 2, 2], center = true);
                    }
                    cube([6, 2, 2], center = true);
                }
            }
        }

    color("silver") render()
        for(i = [0: ways -1])
            translate([0, i * pitch - width / 2 + pitch / 2, 1]) {
                difference() {
                    cylinder(r = 1, h = height - 1.5);
                    translate([0, 0, height - 1])
                        cube([4, 0.5, 2], center = true);
                }
                cube([0.44, 0.75, 6.6], center = true);
            }
}

module molex_254(ways) {
    vitamin(str("MLXHDR", ways, ": ", ways, " way Molex KK header"));
    pitch = 2.54;
    width = ways * pitch;
    depth = 6.35;
    height = 8.15;
    base = 3.18;
    back = 1;
    below = 2.3;
    above = 9;
    color("white") render()
        difference() {
            rotate([90, 0, 0])
                linear_extrude(height = width, center = true, convexity = 5)
                    union() {
                        translate([-depth / 2, 0])
                            square([depth, base]);

                        translate([- depth / 2, 0])
                            square([back, height]);
                    }
        }

    color("silver") render()
        for(i = [0: ways -1])
            translate([0, i * pitch - width / 2 + pitch / 2, (above + below) / 2 - below]) {
                cube([0.44, 0.75, above + below], center = true);
            }
}

//terminal_254(6);
