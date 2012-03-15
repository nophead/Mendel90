//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Flat sheets
//

// The "Soft" parameter determines if the sheet material will hold threads.
// If not, nuts will be used to retain screws.

// The "Color" parameter is a quad-array: [R, G, B, Alpha]

//		   [ Code, Description, Thickness, Color, Soft]

MDF6     = [ "MD", "MDF sheet",     6, MDF_color, true];	// ~1/4"
MDF10    = [ "MD", "MDF sheet",    10, MDF_color, true];	// ~3/8"
MDF12    = [ "MD", "MDF sheet",    12, MDF_color, true];	// ~1/2"
PMMA6    = [ "AC", "Acrylic sheet", 6, acrylic_color, false];	// ~1/4"
PMMA8    = [ "AC", "Acrylic sheet", 8, acrylic_color, false];	// ~5/16"
PMMA10   = [ "AC", "Acrylic sheet",10, acrylic_color, false];	// ~3/8"
glass    = [ "GL", "Glass sheet",   glass_thickness, glass_color, false];
DiBond   = [ "DB", "Dibond sheet",  3, dibond_color, false];

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
