//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Flat sheets
//
MDF6    = [ "MD", "MDF sheet",     6, [0.4, 0.4, 0.2, 1    ], true];
MDF10   = [ "MD", "MDF sheet",    10, [0.4, 0.4, 0.2, 1    ], true];
MDF12   = [ "MD", "MDF sheet",    12, [0.4, 0.4, 0.2, 1    ], true];
PMMA6   = [ "AC", "Acrylic sheet", 6, [1,   1,   1,   0.5  ], false];
PMMA8   = [ "AC", "Acrylic sheet", 8, [1,   1,   1,   0.2  ], false];
PMMA10  = [ "AC", "Acrylic sheet",10, [1,   1,   1,   0.2  ], false];
glass   = [ "GL", "Glass sheet",   2, [1,   1,   1,   0.25 ], false];
DiBond  = [ "DB", "Dibond sheet",  3, [0.5, 0.5, 0.5, 1    ], false];

function sheet_thickness(type) = type[2];
function sheet_is_soft(type) = type[4];

module corner(r) {
    if(r > 0)
        translate([r, - r])
            circle(r, center = true);
    else
        if(r < 0)
            translate([-r, r])
                rotate([0,0,45])
                    square(-r * sqrt(2), -r * sqrt(2), center = true);
        else
            translate([0.5, -0.5])
                square(1, center = true);
}

module sheet(type, w, d, corners = [0, 0, 0, 0]) {
    t = sheet_thickness(type);
    vitamin(str(type[0], t, round(w), round(d),": ",type[1]," ",  round(w), " x ", round(d), " x ", t));
    color(type[3])
        linear_extrude(height = t, center = true)
            hull() {
                translate([-w/2,  d/2])
                    corner(corners[0]);

                translate([ w/2,  d/2])
                    rotate([0, 0, -90])
                        corner(corners[1]);

                translate([ w/2, -d/2])
                    rotate([0, 0, -180])
                        corner(corners[2]);

                translate([-w/2, -d/2])
                    rotate([0, 0, -270])
                        corner(corners[3]);
            }
}
