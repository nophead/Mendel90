//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Ball bearings
//
BB624 = [4, 13, 5, "624"];            // 624 ball bearing for idlers
BB608 = [8, 22, 7, "608"];            // 608 bearings for wades

function ball_bearing_diameter(type) = type[1];
function ball_bearing_width(type) = type[2];

module ball_bearing(type) {
    vitamin(str("BB",type[3],": Ball bearing ",type[3]," ",type[0], "mm x ", type[1], "mm x ", type[2], "mm"));
    rim = type[1] / 10;

    color(bearing_color) render() difference() {
        cylinder(r = type[1] / 2, h = type[2], center = true);
        cylinder(r = type[0] / 2, h = type[2] + 1, center = true);
        for(z = [-type[2] / 2, type[2] / 2])
            translate([0,0,z]) difference() {
                cylinder(r = (type[1] - rim) / 2, h = 2, center = true);
                cylinder(r = (type[0] + rim) / 2, 2, center = true);
            }
    }
}
