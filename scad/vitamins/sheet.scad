//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Flat sheets
//

// If you'd like to add a new material type, or a different color of an existing material type
// simply add a new line here (or in your machine config file).
//
// The "Soft" parameter determines if the sheet material needs machine screws or wood screws
// if "soft", wood screws will be used, with a pilot hole.
// If "not soft", either tapped holes or a clearance hole and nuts will be used to retain screws.
//
// The "Color" parameter is a quad-array: [R, G, B, Alpha], or can be a named color
// see http://en.wikibooks.org/wiki/OpenSCAD_User_Manual/The_OpenSCAD_Language#color
//
//         [ Code, Description, Thickness, Color, Soft]
//
MDF6     = [ "MD", "MDF sheet",            6, [0.4, 0.4, 0.2, 1    ], true];    // ~1/4"
MDF10    = [ "MD", "MDF sheet",           10, [0.4, 0.4, 0.2, 1    ], true];    // ~3/8"
MDF12    = [ "MD", "MDF sheet",           12, [0.4, 0.4, 0.2, 1    ], true];    // ~1/2"
PMMA6    = [ "AC", "Acrylic sheet",        6, [1,   1,   1,   0.5  ], false];   // ~1/4"
PMMA8    = [ "AC", "Acrylic sheet",        8, [1,   1,   1,   0.5  ], false];   // ~5/16"
PMMA10   = [ "AC", "Acrylic sheet",       10, [1,   1,   1,   0.5  ], false];   // ~3/8"
glass2   = [ "GL", "Glass sheet",          2, [1,   1,   1,   0.25 ], false];
DiBond   = [ "DB", "Dibond sheet",         3, "RoyalBlue",            false];
Cardboard= [ "CB", "Corrugated cardboard", 5, [0.8, 0.6, 0.3, 1    ], false];
FoilTape = [ "AF", "Aluminium foil tape",0.05,[0.9, 0.9, 0.9, 1    ], false];
Foam20   = [ "FM", "Foam sponge",          20,[0.3, 0.3, 0.3, 1    ], true];

function sheet_thickness(type) = type[2];
function sheet_colour(type) = type[3];
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
    vitamin(str(type[0], ceil(t), round(w), round(d),": ",type[1]," ",  round(w), "mm x ", round(d), "mm x ", t, "mm"));
    color(sheet_colour(type))
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

module taped_area(type, tape_width, w, d, overlap) {
    total_width = w + 2 * overlap;
    strips = ceil(total_width / tape_width);
    pitch = total_width / strips;
    intersection() {
        group() {
            for(i = [0 : strips - 1])
                assign(k = ((i % 2) ? 0.9 : 1), c = sheet_colour(type))
                    translate([-w / 2 - overlap + tape_width / 2 + i * pitch, 0, sheet_thickness(type) / 2 + i * eta])
                        explode([0, 0, d / 2 + i * 10])
                            color([c[0] * k, c[1] * k, c[2] * k, c[3]])
                                sheet(type, tape_width, d + 2 * overlap);
        }
        if(!exploded)
            cube([w + 2 * eta, d + 2 * eta, 100], center = true);
    }
}
