//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Nylon pillars
//
M3x13_pillar = [3, 13, 6.5, 6];
M3x20_pillar = [3, 20, 5.5, 7];

function pillar_height(type) = type[1];

module pillar(type) {
    height = pillar_height(type);

    vitamin(str("pillar M", type[0], "x", height));
    color(pillar_color) render() difference() {
        cylinder(h = height, r = type[2] / 2);
        translate([0,0, height])
            cylinder(h = type[3] * 2, r = type[0] / 2, center = true);
    }
    color(pillar_liner_color) render() cylinder(h = type[3] * 2, r = type[0] / 2, center = true);

}

module hex_pillar(type) {
    height = pillar_height(type);

    vitamin(str("HP0", type[0], height, ": Hex male / female pillar M", type[0], " x ", height, "mm"));
    color(pillar_color) render() difference() {
        union() {
            cylinder(h = height, r = type[2] / 2, $fn = 6);
            cylinder(h = type[3] * 2, r = type[0] / 2, center = true);
        }
        translate([0,0, height])
            cylinder(h = type[3] * 2, r = type[0] / 2, center = true);
    }
}
