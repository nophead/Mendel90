//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Brackets to fasten the frame together
//
include <conf/config.scad>


slot = cnc_sheets ? 0 : 2;

thickness = part_base_thickness;
thin_wall = filament_width * 2 + eta;
wall = 3;

counter_bore_rad = washer_diameter(base_washer) / 2 + 0.2;
width = 2 * wall + 2 * thin_wall + 6 * counter_bore_rad;
shear = min(counter_bore_rad - screw_clearance_radius(frame_screw), 2.5);


hole_pitch = 2 * (2 * counter_bore_rad + thin_wall);
depth = 2 * (thickness + counter_bore_rad) + slot - 2 * shear;
height = depth;

hole_offset = depth / 2;
corner_rad = 3;

counter_bore_depth = depth - thickness;

function fixing_block_width() = width;
function fixing_block_height() = height;

module fixing_block_v_hole(h)
    translate([0, hole_offset, h])
        child();

module fixing_block_h_holes(h)
    for(end = [-1, 1])
        translate([end * hole_pitch / 2, h, hole_offset])
            rotate([90, 0, 180])
                child();


module fixing_block(upper, rear) {
    same = screw_clearance_radius(base_screw) == screw_clearance_radius(frame_screw) && (!cnc_sheets || (base_nuts == frame_nuts));
    stl((upper && !same) ? "upper_fixing_block" : (base_nuts && rear) ? "rear_fixing_block" : "fixing_block");
    v_screw = upper ? frame_screw : base_screw;

    difference() {
        translate([-(width - 2 * corner_rad) / 2, 0, 0])
            minkowski() {
                cube([width - 2 * corner_rad, depth- corner_rad, height -corner_rad]);
                intersection() {
                    sphere(r = corner_rad);
                    translate([0, 5, 5])
                        cube([10, 10, 10], center = true);
                }
            }

        translate([-width / 2 - 1, thickness, height + eta])                // diagonal slice of the front
            rotate([-45, 0, 0])
                cube([width + 2, depth * 2, height]);


        fixing_block_v_hole(height - counter_bore_depth)
            if((cnc_sheets && (upper? frame_nuts  : base_nuts)) && !rear)
                translate([0, 0, counter_bore_depth])
                    nut_trap(screw_clearance_radius(v_screw), nut_radius(screw_nut(v_screw)), height - thickness);
            else
                rotate([0,0,90])
                    union() {
                        slot(h = 100, r = screw_clearance_radius(base_screw), l = slot, center = true);
                        multmatrix(m = [ [1, 0, (cnc_sheets ? 0 : shear) / counter_bore_depth, 0],
                                         [0, 1, 0, 0],
                                         [0, 0, 1, 0],
                                         [0, 0, 0, 1] ])
                            slot(h = 100, r = counter_bore_rad, l = slot, center = false);
                    }


        fixing_block_h_holes(depth - counter_bore_depth)
            if(cnc_sheets && frame_nuts)
                 translate([0, 0, counter_bore_depth])
                     nut_trap(screw_clearance_radius(frame_screw), nut_radius(frame_nut), depth - thickness, true);
            else
               union() {
                    vertical_tearslot(h = 100, r = screw_clearance_radius(frame_screw), l = slot, center = true);
                    multmatrix(m = [ [1, 0, 0, 0],
                                     [0, 1, shear / counter_bore_depth, 0],
                                     [0, 0, 1, 0],
                                     [0, 0, 0, 1] ])
                    vertical_tearslot(h = 100, r = counter_bore_rad, l = slot, center = false);
                }
    }
}

module fixing_block_stl() fixing_block(false, false);

module upper_fixing_block_stl() fixing_block(true, false);

module rear_fixing_block_stl() fixing_block(false, true);

module fixing_block_assembly(upper = false, rear = false) {
    t = tube_thickness(AL_square_tube);

    color(fixing_block_color) render() fixing_block(upper, rear);

    fixing_block_v_hole(height - counter_bore_depth)
        if(upper)
                frame_screw(thickness);
        else
            if(base_nuts && rear)
                translate([0, 0, -sheet_thickness(base) - thickness - t])
                    rotate([180, 0, 0])
                        base_screw(thickness + t);
            else
                base_screw(thickness);

    fixing_block_h_holes(depth - counter_bore_depth)
        frame_screw(thickness);
}

module fixing_blocks_stl()
    for(row = [0:1])
        for(col = [0:4])
            translate([(width + 2) * row, (depth + 2) * col, 0])
                rotate([0, 0, col ? col * 180 : 180])
                    translate([0, -depth / 2, 0])
                        fixing_block(col > 2, col == 0);

if(0)
    fixing_blocks_stl();
else
    fixing_block_assembly();
