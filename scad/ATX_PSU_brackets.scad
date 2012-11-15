//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// ATX PSU brackets
//
include <conf/config.scad>
include <positions.scad>
frame_nutty = cnc_sheets && frame_nuts;
base_nutty  = cnc_sheets && base_nuts;

wall = 3;

length = psu == ATX500 ? psu_length(psu) : psu_length(psu) - 138 + 114;
offset = (psu_length(psu) - length) / 2;
width = atx_bracket_width;
thickness = part_base_thickness;
psu_hole_z = 6;
psu_hole_z2 = 16;
psu_hole_x = 6;
tab_length = psu_hole_x + washer_diameter(M4_washer) / 2 + 1;
tab_height = psu_hole_z * 2;
tab_height2 = psu_hole_z * 2 + psu_hole_z2 - psu_hole_z;
tab_thickness = 5;
nut_depth = frame_nutty ? nut_trap_depth(screw_nut(frame_screw)) : 0;

module atx_long_bracket_stl() {
    stl("atx_long_bracket");

    translate([offset, width / 2, thickness / 2]) difference() {
        union() {
            hull() {
                translate([0, -width / 4, 0])
                    cube([length - 2 * tab_length, width / 2, thickness], center = true);

                for(end = [-1, 1])
                    translate([end * (length  / 2 - tab_length - width / 2), 0, 0])
                        cylinder(r = width / 2, h = thickness, center = true);
            }
            for(end = [-1, 1]) assign(height =  end == -1 ? tab_height : tab_height2)
                translate([end * (length / 2 - tab_length / 2 - eta), -(width - tab_thickness) / 2, (height - thickness) / 2])
                    cube([tab_length, tab_thickness, height], center = true);

            if(frame_nutty)
                for(end = [-1, 1])
                    translate([end * (length  / 2 - tab_length - width / 2), 0, eta])
                        linear_extrude(height = thickness / 2 + nut_depth, convexity = 5)
                            union() {
                                translate([end * width / 2, (tab_thickness - width) / 2])
                                    square([tab_length, tab_thickness], center = true);
                                circle(r = width / 2 - eta);
                            }
        }
        rotate([0, 0, 180])
            for(end = [-1, 1])
                translate([end * (length / 2 - tab_length - width / 2), 0, thickness / 2 + nut_depth + eta])
                    if(frame_nutty)
                        nut_trap(screw_clearance_radius(frame_screw), nut_radius(screw_nut(frame_screw)), nut_depth);
                    else
                        poly_cylinder(r = screw_clearance_radius(frame_screw), h = 100, center = true);

        for(end = [-1, 1])
            translate([end * (length / 2 - psu_hole_x), 0, (end == -1 ? psu_hole_z : psu_hole_z2) - thickness / 2])
                rotate([90, 0, 0])
                    teardrop_plus(r = screw_clearance_radius(No632_pan_screw), h = 100);
    }
}


module atx_tall_bracket_stl() {
    stl("atx_tall_bracket");
    length = psu_height(psu) + wall;


    translate([0, 0, 0]) difference() {
        cube([length, width * 2, width]);

        translate([-wall, -width - wall, wall])
            cube([length, width * 2, width]);

        translate([thickness + nut_depth, width, -0.5])
            cube([length, width * 2, width + 1]);

        translate([thickness + nut_depth, 3 * width / 2, width / 2])
            rotate([90, 0, 90])
                if(frame_nutty)
                    nut_trap(screw_clearance_radius(frame_screw), nut_radius(screw_nut(frame_screw)), nut_depth, true);
                else
                    teardrop_plus(r = screw_clearance_radius(frame_screw), h = 100, center = true);

   }
}

frame_washer = screw_washer(frame_screw);

sb_wall = 4;
sb_frame_offset = psu_y - psu_width(psu) / 2 - gantry_Y - sheet_thickness(frame);
sb_corner_offset = max(5, fixing_block_height() - sb_frame_offset + base_clearance);
sb_clearance = 0.5;
sb_frame_width = 1 + 2 * sb_wall + (frame_nutty ? nut_radius(screw_nut(frame_screw)) * 2 : washer_diameter(screw_washer(frame_screw)));
sb_base_width  = 1 + 2 * sb_wall + ( base_nutty ? nut_radius(screw_nut( base_screw)) * 2 : washer_diameter(screw_washer( base_screw)));
sb_height = max(sb_base_width, sb_frame_width);
sb_frame_thickness = part_base_thickness + (frame_nutty ? nut_trap_depth(screw_nut(frame_screw)) : 0);
sb_base_thickness  = part_base_thickness + ( base_nutty ? nut_trap_depth(screw_nut( base_screw)) : 0);
sb_base_offset  = psu_z - psu_length(psu) / 2;
sb_frame_screw = sb_frame_offset > (frame_nutty ? sb_frame_thickness
                                                : sb_frame_thickness + washer_thickness(frame_washer) + screw_head_height(frame_screw));

module atx_short_bracket_stl() {
    stl("atx_short_bracket");

    difference() {
        linear_extrude(height = sb_height, convexity = 10) {
            translate([-sb_base_offset, sb_corner_offset])
                square([sb_base_offset - sb_clearance, sb_base_width]);

            translate([sb_corner_offset, -sb_frame_offset])
                square([sb_frame_width, sb_frame_offset - sb_clearance]);

            polygon([[sb_corner_offset, -sb_clearance],
                     [ - sb_clearance, sb_corner_offset],
                     [ - sb_clearance, sb_corner_offset + sb_base_width],
                     [sb_corner_offset + sb_frame_width,  - sb_clearance]]);

        }
        translate([-sb_clearance,  -sb_clearance, sb_wall])             // space for PSU
            cube([100, 100, sb_height]);

        translate([sb_corner_offset + sb_wall, -sb_frame_offset + sb_frame_thickness, sb_wall])        // Recess for screw
            cube([sb_frame_width - 2 * wall, sb_frame_offset, sb_height - 2 * wall]);

        if(sb_frame_screw)
            translate([sb_corner_offset + sb_frame_width / 2, -sb_frame_offset + sb_frame_thickness, sb_height / 2])
                rotate([90, 0, 0])
                    if(frame_nutty)
                        nut_trap(screw_clearance_radius(frame_screw), nut_radius(screw_nut(frame_screw)), nut_trap_depth(screw_nut(frame_screw)), true);
                    else
                        teardrop(r = screw_clearance_radius(frame_screw), h = 100, center = true);

        translate([-sb_base_offset + sb_base_thickness, sb_corner_offset + sb_wall, sb_wall])       // Recess for screw
            cube([sb_base_offset, sb_base_width - 2 * sb_wall, sb_height - 2 * sb_wall - layer_height]);

        translate([-sb_base_offset + sb_base_thickness, sb_corner_offset + sb_base_width / 2, sb_height / 2])
            rotate([90, 0, 90])
                if(frame_nutty)
                    nut_trap(screw_clearance_radius(base_screw), nut_radius(screw_nut(base_screw)), nut_trap_depth(screw_nut(base_screw)), true);
                else
                    teardrop(r = screw_clearance_radius(base_screw), h = 100, center = true);
    }
}

module atx_screw_positions(psu, base = false) {
    if(base)
        translate([-psu_length(psu) / 2 - sb_base_offset + sb_base_thickness - (base_nutty ? nut_trap_depth(screw_nut(base_screw)) : 0),
                    psu_width(psu) / 2 - sb_corner_offset - sb_base_width / 2,
                    psu_height(psu) + sb_wall - sb_height / 2 + sb_clearance])
            rotate([90, 0, 90])
                child();

    else {
        for(end = [-1, 1])
            translate([end * (length  / 2 - tab_length - width / 2) - offset, -psu_width(psu) / 2 - width / 2, thickness])
                child();

        *translate([psu_length(psu) / 2 + wall - width / 2, psu_width(psu) / 2 + width / 2 + wall, thickness])
            rotate([0, 0, 90])
                child();

        if(sb_frame_screw)
            translate([-psu_length(psu) / 2 + sb_corner_offset + sb_frame_width / 2,
                        psu_width(psu) / 2 + sb_frame_offset - sb_frame_thickness + (frame_nutty ? nut_trap_depth(screw_nut(frame_screw)) : 0),
                        psu_height(psu) + sb_wall - sb_height / 2 + sb_clearance])
                rotate([90, 0, 0])
                    child();
    }
}

res = THS15;
second_resistor_pos = controller == Melzi ?
        [psu_length(psu) / 2 + 3 * al_clad_wire_length(res) / 2 + 30, -psu_width(psu) / 2 +     al_clad_width(res) / 2, 0]
      : [psu_length(psu) / 2 +     al_clad_wire_length(res) / 2 + 15, -psu_width(psu) / 2 + 4 * al_clad_width(res) / 2, 0];

module atx_bracket_assembly(show_psu = false) {
    rotate([0, 0, 180]) {
        translate([0, psu_width(psu) / 2, 0]) {
            color(plastic_part_color("lime")) render() atx_long_bracket_stl();
            for(end = [-1, 1])
                translate([end * (length / 2 - psu_hole_x) + offset, tab_thickness, end == -1 ? psu_hole_z : psu_hole_z2])
                    rotate([-90, 0, 0])
                        screw_and_washer(No632_pan_screw, 9.5, true);
        }
    }
    *translate([psu_length(psu) / 2 + wall, psu_width(psu) / 2 - width + wall, 0])
        rotate([0, -90, 0])
            color(plastic_part_color("lime")) render() atx_tall_bracket_stl();

    translate([-psu_length(psu) / 2, psu_width(psu) / 2, psu_height(psu) + sb_wall + sb_clearance])
        rotate([180, 0, 0])
            color(plastic_part_color("lime")) render() atx_short_bracket_stl();

    atx_screw_positions(psu, false)
        frame_screw(thickness);

    atx_screw_positions(psu, true)
        frame_screw(thickness);

    if(show_psu)
        psu(psu);

    translate([psu_length(psu) / 2 + al_clad_wire_length(res) / 2 + 15, -psu_width(psu) / 2 + al_clad_width(res) / 2, 0])
        al_clad_resistor_assembly(res, "10R");

    translate(second_resistor_pos)
        al_clad_resistor_assembly(res, "4R7");
}

module atx_resistor_holes(psu) {
    translate([psu_length(psu) / 2 + al_clad_wire_length(res) / 2 + 15, -psu_width(psu) / 2 + al_clad_width(res) / 2, 0])
        al_clad_resistor_holes(res);

    translate(second_resistor_pos)
        al_clad_resistor_holes(res);
}

module atx_brackets_stl() {
    rotate([0, 0, 180])
        atx_long_bracket_stl();

    *translate([-psu_height(psu) / 2, width + 2, 0])
        atx_tall_bracket_stl();

    translate([-length / 2 - offset + sb_corner_offset - 2, sb_base_offset - width + 2, 0])
        rotate([0, 0, 90])
            atx_short_bracket_stl();
}

module pair() {
     atx_brackets_stl();
     translate([-offset * 2 + 8, 2, 0])
        rotate([0, 0, 180])
            color("blue") atx_brackets_stl();
}


if(1)
    atx_bracket_assembly(true);
else
    if(1)
        pair();
    else
        atx_brackets_stl();
