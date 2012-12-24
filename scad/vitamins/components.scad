//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Resistor model for hot end
//
RWM04106R80J   = [ "RES6R8: RWM04106R80J 6R8 3W vitreous enamel resistor",    12,     5, 0.8,  30,  5.5, "green",               false, false];
RIE1212UB5C5R6 = [ "RES5R6: UB5C 5R6F 5R6 3W vitreous enamel resistor",       13,   5.9, 0.96, 35,  6.0, "gray",                false, false];

Honewell       = [ "THRMH104: Honewell 135-104LAC-J01 100K 1% thermistor",    4.75, 1.8, 0.5,  28.6,  2, "red",                        false];
Epcos          = [ "THRME104: Epcos B57560G104F 100K 1% thermistor",          4.6,  2.5, 0.3,  67,  2.5, [0.8, 0.8, 0.8, 0.25], true,  false];
EpcosBlue      = [ "THRMB104: Epcos B57861S104F40 100K 1% thermistor",        6.5,  2.41,0.25, 43.5,2.5, [0.8, 0.8, 0.8, 0.25], true,  true];

function resistor_length(type)        = type[1];
function resistor_diameter(type)      = type[2];
function resistor_wire_diameter(type) = type[3];
function resistor_wire_length(type)   = type[4];
function resistor_hole(type)          = type[5];
function resistor_colour(type)        = type[6];
function resistor_radial(type)        = type[7];
function resistor_sleeved(type)       = type[8];

splay_angle = 5; // radial lead splay angle

module resistor(type, on_bom = true) {
    length = resistor_length(type);

    if(on_bom)
        vitamin(type[0]);
    //
    // wires
    //
    color([0.7, 0.7, 0.7])
        render()
            if(resistor_radial(type))
                for(side= [-1,1])
                    translate([side *  resistor_diameter(type) / 6, 0, length / 2])
                        rotate([0, splay_angle * side, 0])
                            cylinder(r = resistor_wire_diameter(type) / 2, h = resistor_wire_length(type), center = false);
            else
                cylinder(r = resistor_wire_diameter(type) / 2, h = length + 2 * resistor_wire_length(type), center = true);
    //
    // Sleeving
    //
    if(resistor_sleeved(type))
        color([0.5, 0.5, 1])
            render()
                if(resistor_radial(type))
                    for(side= [-1,1])
                        translate([side *  resistor_diameter(type) / 6, 0, length / 2]) {
                            rotate([0, splay_angle * side, 0])
                                cylinder(r = resistor_wire_diameter(type) / 2 + 0.1, h = resistor_wire_length(type) - 5, center = false);                   }
    //
    // Body
    //
    color(resistor_colour(type))
        render()
            cylinder(r = resistor_diameter(type) / 2, h = length, center = true);

}

module sleeved_resistor(type, sleeving, bare = 5, on_bom = true, heatshrink = false, exploded = exploded) {
    resistor(type, on_bom);
    sleeving_length = resistor_wire_length(type) - bare;

    for(side= [-1,1])
        if(resistor_radial(type)) {
            translate([side *  resistor_diameter(type) / 6, 0, 0])
                rotate([0, splay_angle * side, 0]) {
                    if(!resistor_sleeved(type))
                        translate([0, 0,  sleeving_length / 2 + resistor_length(type) / 2 + 20 * exploded])
                            tubing(sleeving, sleeving_length);

                    if(heatshrink)
                        translate([0, 0, sleeving_length + resistor_length(type) / 2 + bare / 2 + 30 * exploded])
                            tubing(heatshrink);
                }
        }
        else {
            translate([0, 0, side * (resistor_length(type) + sleeving_length + 40 * exploded) / 2])
                tubing(sleeving, sleeving_length);

            if(heatshrink)
                translate([0, 0, side * (resistor_length(type) /2  + sleeving_length + 30 * exploded)])
                    tubing(heatshrink);
        }
}

THS15 = [ "THS15 Aluminium clad resistor", 20, 21, 6, 14.3, 15.9, 2, 2.4, 2.45, 11, 35.6];

function al_clad_length(type)      = type[1];
function al_clad_width(type)       = type[2];
function al_clad_tab(type)         = type[3];
function al_clad_hpitch(type)      = type[4];
function al_clad_vpitch(type)      = type[5];
function al_clad_thickness(type)   = type[6];
function al_clad_hole(type)        = type[7];
function al_clad_clearance(type)   = type[8];
function al_clad_height(type)      = type[9];
function al_clad_wire_length(type) = type[10];

module al_clad_resistor_hole_positions(type)
    for(end = [-1,1])
        translate([end * al_clad_hpitch(type) / 2, end * al_clad_vpitch(type) / 2, al_clad_thickness(type)])
            child();

module al_clad_resistor_holes(type) {
    al_clad_resistor_hole_positions(type)
        cylinder(r = frame_nuts ? screw_clearance_radius(M2p5_pan_screw)
                                : screw_pilot_hole(sheet_is_soft(frame) ? No2_screw : M2p5_pan_screw), h = 100, center = true);
}


module al_clad_resistor(type, value) {
    vitamin(str("ACR",value,": ",type[0], " ", value));
    length = al_clad_length(type);
    width = al_clad_width(type);
    height = al_clad_height(type);
    tab = al_clad_tab(type);
    thickness = al_clad_thickness(type);
    terminal_h = 4;
    terminal_t = 1;
    terminal_l = 5;

    body = al_clad_vpitch(type) - 2 * al_clad_clearance(type);

    color("silver") render() {
        difference() {
            union() {
                hull() {
                    translate([0, 0, al_clad_height(type) / 2])
                        intersection() {
                            cube([length, body, al_clad_height(type)], center = true);
                            translate([0, 0,  0])
                                rotate([0, 90, 0])
                                    cylinder(r = body / 2 - eta, h = length + 1, center = true);
                        }
                    translate([0, 0, thickness / 2])
                        cube([length, body, thickness], center = true);
                }
                for(end = [-1,1]) {
                    translate([end * (length - tab) / 2, end * (width - width / 2) / 2, thickness / 2])
                        cube([tab, width / 2, thickness], center = true);

                    translate([end * (al_clad_wire_length(type) - terminal_l) / 2, 0, height / 2])
                        difference() {
                            cube([terminal_l, terminal_t, terminal_h], center = true);
                            rotate([90, 0, 0])
                                cylinder(r = 1, h = 100, center = true);
                        }
                }
                translate([0, 0, height / 2])
                    rotate([0, 90, 0])
                        cylinder(r = 1, h = al_clad_wire_length(type) - 2 * terminal_l + eta, center = true);
            }
            al_clad_resistor_hole_positions(type)
                cylinder(r = al_clad_hole(type) /2, h = 100, center = true);
        }
    }
    color("black") render()
        translate([0, 0, height / 2])
            rotate([0, 90, 0])
                cylinder(r = 3, h = length + eta, center = true);
}

module al_clad_resistor_assembly(type, value) {
    sleeving_length = 15;
    sleeving = HSHRNK32;

    al_clad_resistor(type, value);

    for(end = [-1, 1])
        translate([end * (al_clad_length(type) + sleeving_length + 0) / 2, 0,  al_clad_height(type) / 2])
            rotate([0, 90, 0])
                scale([1.5, 0.66, 1])
                    %tubing(sleeving, sleeving_length);

    al_clad_resistor_hole_positions(type) group() {
        if(sheet_is_soft(frame))
            screw(No2_screw,13);
        else
            screw(M2p5_pan_screw, 12);

        if(frame_nuts)
            translate([0, 0, -sheet_thickness(frame) -  al_clad_thickness(type)])
                rotate([180, 0, 0])
                    nut_and_washer(M2p5_nut, true);
    }
}
