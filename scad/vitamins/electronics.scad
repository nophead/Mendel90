//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Model by Václav 'ax' Hula
//

module sanguinololu() {
    color(sanguinololu_color)
    import("../imported_stls/sanguinololu.stl");
}

Sanguinololu = ["SANGUINOL: Sanguinolou electronics", 4   * 25.4,    2 * 25.4, 1.5 * 2.54, []];
Melzi =        ["MELZI: Melzi electronics",           8.2 * 25.4, 1.95 * 25.4, 1.5 * 2.54, ["USBLEAD: USB A to Mini B lead",
                                                                                                 "SDCARD: Micro SD card",
                                                                                                 "SDUSB: Micro SD to USB adapter"]];

function controller_name(type)        = type[0];
function controller_length(type)      = type[1];
function controller_width(type)       = type[2];
function controller_hole_inset(type)  = type[3];
function controller_accessories(type) = type[4];

module controller_screw_positions(type) {
    inset = controller_hole_inset(type);

    for($i = [0:3])
        assign(x = [inset, controller_width(type) - inset][$i % 2])
        assign(y = [inset, controller_length(type) - inset][$i / 2])
            translate([x, y, 0])
                child();
}

module controller(type) {
    vitamin(type[0]);
    for(part = controller_accessories(type))
        vitamin(part);
    if(type == Sanguinololu)
        sanguinololu();
    else {
        color("green")
            render()
                translate([controller_width(type) / 2, controller_length(type) / 2, pcb_thickness / 2])
                    rounded_rectangle([controller_width(type), controller_length(type), pcb_thickness], r = controller_hole_inset(type));
    }
    for(end = [-1, 1])
        translate([-10, controller_length(type) / 2 + end * 10, 5])
            rotate([0, 90, 0])
                tubing(HSHRNK24);

}

PD_150_12 =
    ["PD15012", 199, 98, 38, M3_cap_screw, M3_clearance_radius, true,
        [
            [ 199 / 2 - 17,  98 / 2 - 89],
            [ 199 / 2 - 17,  98 / 2 - 9 ],
            [ 199 / 2 - 137, 98 / 2 - 89],
            [ 199 / 2 - 137, 98 / 2 - 9 ]
        ]
    ];

KY240W =
    ["KY240W12L", 199, 110, 50, M3_cap_screw, M3_clearance_radius, true,
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
    ["S30012", 215, 115, 50, M4_cap_screw, M4_clearance_radius, true,
        [
            [ 215 / 2 - 32.5,  115 / 2 - 82.5],
            [ 215 / 2 - 32.5,  115 / 2 - 32.5],
            [ 215 / 2 - 182.5, 115 / 2 - 82.5],
            [ 215 / 2 - 182.5, 115 / 2 - 32.5]
        ],
        []
    ];

// Single fan at back, wires exit opposite side from mains in
ATX500 =
    ["ATX500", 150, 140, 86, M4_cap_screw, M4_tap_radius, false,
        [
        ],
        []
    ];

// Two fans, wires exit same side as mains so has to be mounted upside down
ALPINE500 =
    ["ALPINE500", 150, 140, 86, false, false, false,
        [
        ],
        ["IECLEAD: IEC mains lead"]
    ];

External =
    ["LAPTOPPSU", 0, 0, 0, false, false, false,
        [
        ],
        ["IECLEAD: IEC mains lead"]
    ];

function psu_name(type)              = type[0];
function psu_length(type)            = type[1];
function psu_width(type)             = type[2];
function psu_height(type)            = type[3];
function psu_screw_type(type)        = type[4];
function psu_screw_hole_radius(type) = type[5];
function psu_screw_from_back(type)   = type[6];
function psu_hole_list(type)         = type[7];
function psu_accessories(type)       = type[8];
function atx_psu(type) = type == ATX500 || type == ALPINE500;

module psu(type) {
    vitamin(str(psu_name(type),": PSU e.g. ", psu_name(type)));
    for(part = psu_accessories(type))
        vitamin(part);
    color(psu_color)
        translate([0,0, psu_height(type) / 2])
            cube([psu_length(type), psu_width(type), psu_height(type)], center = true);
}

module psu_screw_positions(type) {
    for(point = psu_hole_list(type))
        translate(point)
            child();
}
