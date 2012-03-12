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
    import("../imported_stls/sanguinololu.stl");
}

module sanguinololu_screw_positions() {
    inset = 1.5 * 2.54;

    for(x = [inset, sanguinololu_width() - inset])
        for(y = [inset, sanguinololu_length() - inset])
            translate([x, y, 0])
                child();
}

KY240W = ["KY240W12L", 199, 110, 50, [[ 199 / 2 - 12,  110 / 2 - 93],
                         [ 199 / 2 - 12,  110 / 2 - 9 ],
                         [ 199 / 2 - 138, 110 / 2 - 93],
                         [ 199 / 2 - 138, 110 / 2 - 9 ]]];

function psu_name(type)   = type[0];
function psu_length(type) = type[1];
function psu_width(type)  = type[2];
function psu_height(type) = type[3];
function psu_hole_list(type) = type[4];

module psu(type) {
    vitamin(str(psu_name(type),": PSU e.g. ", psu_name(type)));
    color([0.8, 0.8, 0.8])
        translate([0,0, psu_height(type) / 2])
            cube([psu_length(type), psu_width(type), psu_height(type)], center = true);

}

module psu_screw_positions(type) {
    for(point = psu_hole_list(type))
        translate(point)
            child();
}
