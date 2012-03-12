//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// A strip of polypropylene used with ribbon cable to make a cable flexible in one direction only.
//
module cable_strip(width, depth, travel, x, extra = 15) {

    thickness = 0.5;

    radius = depth / 2;

    top = travel / 4 + extra + x / 2;
    bottom = travel / 4 + extra - x /2;

    length = max(top, bottom);

    total = ceil(top + bottom + PI * depth);
    w = ceil(width);

    vitamin(str("PP", thickness * 10, w, total,": Polypropylene strip ", total, "mm x ", w, "mm x ", thickness, "mm"));

    color([1,0,1]) render() linear_extrude(height = w, center = true, convexity = 4)
        difference() {
            union() {
                translate([-bottom, radius])
                    circle(r = radius, center = true);

                translate([-bottom, 0])
                    square([length, depth]);
            }
            union() {
                translate([-bottom, radius])
                    circle(r = radius - thickness, center = true);

                translate([-bottom, thickness])
                    square([length + 1, depth - thickness * 2]);
            }
            translate([0, -thickness / 2])
                square([travel, thickness * 2]);

            translate([x, depth - thickness - thickness / 2])
                square([travel, thickness * 2]);
        }
}

//cable_strip(20, 50, 200, -100);

module ellipse(xr, yr, center = true)
{
    scale([1, yr / xr])
        circle(r = xr, center = center);
}

module elliptical_cable_strip(width, p1, p2, pmax, extra = 15) {
    thickness = 0.5;
    w = ceil(width);

    max_delta = pmax - p1;
    delta = p2 - p1;

    A = abs(max_delta[0] / 2);
    B = 50;

    length = ceil(PI * pow((pow(A,1.5) + pow(B,1.5))/2, 1/1.5));
    total = length + 2 * extra;

    vitamin(str("PP", thickness * 10, w, total,": Polypropylene strip ", total, "mm x ", w, "mm x ", thickness, "mm"));

    a = abs(delta[0] / 2);
    b = pow(2 * pow(length / PI, 1.5) - pow(a, 1.5), 1/1.5);

    translate(p1 - [a, 0, 0])
        multmatrix(m = [ [1, 0, 0, 0],
                         [delta[1] / delta[0], 1, 0, delta[1] / 2],
                         [delta[2] / delta[0], 0, 1, delta[2] / 2],
                         [0, 0, 0, 1] ])

        color([1,0,1]) render() linear_extrude(height = w, center = true, convexity = 4)
            difference() {
                union()  {
                    square([(a + thickness) * 2, extra * 2], center = true);
                    translate([0, -extra])
                        ellipse((a + thickness), b + thickness);
                }
                translate([0, (b + 1) / 2])
                    square([a * 2 + 1, b + 1], center = true);

                square([a * 2, extra * 2], center = true);
                translate([0, -extra])
                    ellipse(a, b);
            }
}
