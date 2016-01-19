//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Configuration file
//
echo("DiBond:");

Z_bearings = LM8UU;
Y_bearings = LM8UU;
X_bearings = LM8UU;

X_motor = NEMA17;
Y_motor = NEMA17;
Z_motor = NEMA17;

hot_end = e3dv6;

X_travel = 200;
Y_travel = 200;
Z_travel = 200;

bed_depth = 214;
bed_width = 214;
bed_pillars = M3x20_pillar;
bed_glass = glass2;
bed_thickness = pcb_thickness + sheet_thickness(bed_glass);    // PCB heater plus glass sheet
bed_holes = [209, 209];

base = DiBond;                  // Sheet material used for the base. Needs to be thick enough to screw into.
base_corners = 25;
base_nuts = true;

frame = DiBond;
frame_corners = 25;
frame_nuts = true;

case_fan = fan80x38;
psu = ALPINE500;
controller = Melzi;
spool = spool_300x85;
bottom_limit_switch = false;
top_limit_switch = true;

single_piece_frame = true;
stays_from_window = false;
cnc_sheets = true;                 // If sheets are cut by CNC we can use slots, etc instead of just round holes
//raspberry_pi = true;
//raspberry_pi_camera = true;
//light_strip = SPS125;

Y_carriage = DiBond;

pulley_type = GT2x20_metal_pulley;
X_belt = GT2x6;
Y_belt = GT2x6;

motor_shaft = 5;
Z_screw_dia = 6;            // Studding for Z axis

Y_carriage_depth = bed_holes[1] + 7;
Y_carriage_width = bed_holes[0] + 7;

Z_nut_radius = M6_nut_radius;
Z_nut_depth = M6_nut_depth;
Z_nut = M6_nut;

//
// Default screw use where size doesn't matter
//
cap_screw = M3_cap_screw;
hex_screw = M3_hex_screw;
//
// Screw for the frame and base
//
frame_soft_screw = No6_screw;               // Used when sheet material is soft, e.g. wood
frame_thin_screw = M4_cap_screw;            // Used with nuts when sheets are thin
frame_thick_screw = M4_pan_screw;           // Used with tapped holes when sheets are thick and hard, e.g. plastic or metal
//
// Feature sizes
//
default_wall = 3;
thick_wall = 4;
