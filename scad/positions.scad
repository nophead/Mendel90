//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Work out the positions and size of things
//
use <y-motor-bracket.scad>
use <x-carriage.scad>
use <x-end.scad>
use <fixing-block.scad>
use <mains_inlet.scad>
use <ribbon_clamp.scad>

base_depth = Y_travel + limit_switch_offset + Y_carriage_depth + 2 * base_clearance;
AL_tube_inset = 9.5;

Y0 = limit_switch_offset / 2;

Y_carriage_height = y_motor_bracket_height() + X_carriage_clearance + sheet_thickness(Y_carriage) / 2;

bed_height =  Y_carriage_height + sheet_thickness(Y_carriage) / 2 + pillar_height(bed_pillars) + washer_thickness(M3_washer) + bed_thickness;

Z0 = floor(bed_height + nozzle_length - x_carriage_offset());

height = Z0 + Z_travel + limit_switch_offset + x_end_height() + bar_clamp_depth + axis_end_clearance + base_clearance;

gantry_thickness = height - max(bed_height + Z_travel + Z_clearance, Y_carriage_depth + 1);

gantry_setback = X_carriage_clearance + x_carriage_width() / 2;
gantry_Y = Y0 + gantry_setback;
ribbon_clamp_y = Y_carriage_depth / 2 - ribbon_clamp_width(cap_screw);
ribbon_clamp_z = cnc_sheets ? (Z_travel + Z0 + x_motor_height() + 5 + ribbon_clamp_width(frame_screw) / 2)
                            : (height - base_clearance - ribbon_clamp_width(frame_screw));
y_cable_strip_depth = Y_carriage_height - sheet_thickness(Y_carriage) / 2 - 2 * (ribbon_clamp_slot_depth() - cable_strip_thickness);
z_cable_strip_depth = gantry_Y - x_end_ribbon_clamp_y() - (ribbon_clamp_slot_depth() * 2 - cable_strip_thickness);

Z_bar_spacing = X_travel + limit_switch_offset + x_carriage_length() + 2 * x_end_clearance();

base_width = base_clearance - x_idler_overhang() + Z_bar_spacing -x_motor_overhang() + base_clearance;

window_width = ceil(Y_carriage_width + Y_carriage_clearance * 2);
stay_depth = stays_from_window ? window_width / 2 : base_depth / 2 - (gantry_Y + sheet_thickness(frame));
stay_height =  single_piece_frame && !stays_from_window ? height : height - gantry_thickness - 1;

idler_end = -base_width / 2 + base_clearance - x_idler_overhang();
motor_end =  base_width / 2 - base_clearance + x_motor_overhang();
X_origin = (idler_end + motor_end) / 2 + nozzle_x_offset() - limit_switch_offset / 2;
left_w  = ceil((base_width - window_width)/2 + X_origin);
right_w = ceil((base_width - window_width)/2 - X_origin);


z_slot_inset = max((washer_diameter(frame_washer) + 2),
                 ceil(NEMA_width(Z_motor)) / 2 - NEMA_holes(Z_motor)[1] + washer_diameter(M3_washer) / 2 + 1) / 2;

z_nut_offset = frame_nut_traps ? -z_slot_inset + nut_radius(frame_nut) + 0.5 : 0;

function z_motor_bracket_hole_offset() = ceil(NEMA_width(Z_motor)) / 2 - z_slot_inset + z_nut_offset;

left_stay_x = max(-base_width / 2 + left_w / 2,
                  idler_end - z_bar_offset() + z_motor_bracket_hole_offset() + washer_diameter(M4_washer) / 2 + 1) + sheet_thickness(frame) / 2;

right_stay_x = frame_nuts ? min(motor_end, motor_end + z_bar_offset() - z_motor_bracket_hole_offset() - washer_diameter(M4_washer) / 2 - 1 - sheet_thickness(frame) / 2)
                          : max(motor_end, base_width / 2 - right_w  + sheet_thickness(frame) / 2 + fixing_block_height() + base_clearance);

Y_belt_height = y_motor_height() + pulley_inner_radius + belt_thickness(Y_belt);

Y_bar_height = Y_belt_height;
Y_belt_clamp_height  =  Y_carriage_height - Y_belt_height - sheet_thickness(Y_carriage) / 2;
Y_bearing_holder_height = Y_carriage_height - Y_bar_height  - sheet_thickness(Y_carriage) / 2;

fan_y = gantry_Y + sheet_thickness(frame) + fixing_block_height() + fan_width(case_fan) / 2 + base_clearance;
fan_z = Y_carriage_height + fan_width(case_fan) / 2;

atx_bracket_width = (frame_nuts && cnc_sheets) ? 2 * (nut_radius(frame_nut) + 3 * filament_width)
                                               : washer_diameter(frame_washer) + 1;

psu_z = fixing_block_height() + psu_length(psu) / 2;
psu_y = base_depth / 2 - base_clearance - psu_width(psu) / 2 - (atx_psu(psu) ? atx_bracket_width : mains_inlet_inset());

psu_top = psu_z + psu_length(psu) / 2 + (atx_psu(psu) ? 0 : mains_inlet_depth());

controller_z = (height + psu_top) / 2 - controller_length(controller) / 2;
controller_y = (base_depth / 2 + gantry_Y + sheet_thickness(frame)) / 2 - controller_width(controller) / 2;

spool_z = height - gantry_thickness + spool_diameter(spool) / 2 + 10;
