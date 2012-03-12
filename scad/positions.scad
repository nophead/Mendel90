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


Y_carriage_height = y_motor_bracket_height() + X_carriage_clearance + sheet_thickness(Y_carriage) / 2;

bed_height =  Y_carriage_height + sheet_thickness(Y_carriage) / 2 + pillar_height(bed_pillars) + washer_thickness(M3_washer) + bed_thickness;

Z0 = floor(bed_height + nozzle_length - x_carriage_offset());

height = Z0 + Z_travel + x_end_height() + bar_clamp_depth + axis_endstop_clearance + base_clearance;

gantry_thickness = height - max(bed_height + Z_travel + Z_clearance, Y_carriage_depth + 1);

gantry_setback = X_carriage_clearance + x_carriage_width() / 2;

Z_bar_spacing = X_travel + x_carriage_length() + 2 * (axis_endstop_clearance + Z_bearings[1] / 2);

base_width = base_clearance - x_idler_overhang() + Z_bar_spacing -x_motor_overhang() + base_clearance;

base_depth = Y_travel + Y_carriage_depth + 2 * base_clearance + 2 * axis_endstop_clearance;

window_width = ceil(Y_carriage_width + Y_carriage_clearance * 2);
stay_depth = stays_from_window ? window_width / 2 : base_depth / 2 - (gantry_setback + sheet_thickness(frame));
stay_height =  single_piece_frame && !stays_from_window ? height : height - gantry_thickness - 1;

idler_end = -base_width / 2 + base_clearance - x_idler_overhang();
motor_end =  base_width / 2 - base_clearance + x_motor_overhang();
X_origin = (idler_end + motor_end) / 2 + nozzle_x_offset;
left_w  = ceil((base_width - window_width)/2 + X_origin);
right_w = ceil((base_width - window_width)/2 - X_origin);


Y_belt_height = y_motor_height() + pulley_inner_radius + belt_thickness(Y_belt);

Y_bar_height = Y_belt_height;
Y_belt_clamp_height  =  Y_carriage_height - Y_belt_height - sheet_thickness(Y_carriage) / 2;
Y_bearing_holder_height = Y_carriage_height - Y_bar_height  - sheet_thickness(Y_carriage) / 2;
