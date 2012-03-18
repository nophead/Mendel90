//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Model by Václav 'ax' Hula
//

function sanguinololu_width()  = 2 * 25.4;
function sanguinololu_length() = 4 * 25.4;

module sanguinololu() {
    vitamin("SANGUINOL: Electronics e.g. Sanguinolou");

    color(sanguinololu_color)
    import("../imported_stls/sanguinololu.stl");
}

module sanguinololu_screw_positions() {
    inset = 1.5 * 2.54;

    for(x = [inset, sanguinololu_width() - inset])
        for(y = [inset, sanguinololu_length() - inset])
            translate([x, y, 0])
                child();
}

KY240W =
    ["KY240W12L", 199, 110, 50, M3_cap_screw, M3_clearance_radius,
        [
            [ 199 / 2 - 12,  110 / 2 - 93],
            [ 199 / 2 - 12,  110 / 2 - 9 ],
            [ 199 / 2 - 138, 110 / 2 - 93],
            [ 199 / 2 - 138, 110 / 2 - 9 ]
        ]
    ];

// This PSU, and ones very like it, are sold by LulzBot, and various sellers on eBay.
// The screw layout specified here uses the inner set of screw-mounts on the PSU, which are M4.
// The outer set don't appear to be M3, even though the datasheet claims they are.
S_300_12 =
    ["S30012", 215, 115, 50, M4_cap_screw, M4_clearance_radius,
        [
            [ 215 / 2 - 32.5,  115 / 2 - 82.5],
            [ 215 / 2 - 32.5,  115 / 2 - 32.5 ],
            [ 215 / 2 - 182.5, 115 / 2 - 82.5],
            [ 215 / 2 - 182.5, 115 / 2 - 32.5 ]
        ]
    ];

function psu_name(type)              = type[0];
function psu_length(type)            = type[1];
function psu_width(type)             = type[2];
function psu_height(type)            = type[3];
function psu_screw_type(type)        = type[4];
function psu_screw_hole_radius(type) = type[5];
function psu_hole_list(type)         = type[6];

module psu(type) {
    vitamin(str(psu_name(type),": PSU e.g. ", psu_name(type)));
    color(psu_color)
        translate([0,0, psu_height(type) / 2])
            cube([psu_length(type), psu_width(type), psu_height(type)], center = true);

}

module psu_screw_positions(type) {
    for(point = psu_hole_list(type))
        translate(point)
            child();
}
