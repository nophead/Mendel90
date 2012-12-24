//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Zipties
//

// [width, thickness, [latch_x, latch_y, latch_z], color, length]
small_ziptie = [2.5, 1, [4.7, 4.25, 3], small_ziptie_color, 25];

function ziptie_width(type) = type[0];
function ziptie_thickness(type) = type[1];

module ziptie(type, r)
{
    latch = type[2];
    length = ceil(2 * PI * r + type[4] + latch[2] + 1);
    len = length <= 100 ? 100 : length;
    vitamin(str("ZT00", len, ": Ziptie ", len, "mm min length"));

    angle = (r > latch[0] / 2) ? asin((latch[0] / 2) / r) - asin(ziptie_thickness(type) / latch[0]) : 0;
    color(type[3]) render(convexity = 5) union() {
        tube(ir = r, or = r + ziptie_thickness(type), h = ziptie_width(type));
        translate([0, -r, - latch[1] / 2])
            rotate([90, 0, angle]) {
                union() {
                    cube(latch);
                    translate([latch[0] / 2, latch[1] / 2, (latch[2] + 1) / 2])
                        cube([ziptie_thickness(type), ziptie_width(type), latch[2] + 1], center = true);
                }
            }
    }
}


//ziptie(small_ziptie, 10);
