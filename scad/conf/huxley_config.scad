//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Configuration file
//
echo("Huxley:");
Z_bearings = LM6UU;
Y_bearings = LM6UU;
X_bearings = LM6UU;

X_motor = NEMA14;
Y_motor = NEMA14;
Z_motor = NEMA14;

X_travel = 140;
Y_travel = 140;
Z_travel = 110;

bed_depth = 150;
bed_width = 150;
bed_pillars = M3x20_pillar;
bed_glass = glass2;
bed_thickness = 1.6 + sheet_thickness(bed_glass);    // PCB heater plus glass sheet
bed_holes = 146;

base = PMMA10;               // Sheet material used for the base. Needs to be thick enough to screw into.
base_corners = 50;

frame = PMMA6;
frame_corners = 25;
frame_nuts = false;

case_fan = fan80x38;

single_piece_frame = true;
stays_from_window = false;

Y_carriage = PMMA6;

extruder_width = 30;        // actually 28 but offset
nozzle_x_offset = 16;       // offset from centre of the extruder
nozzle_length = 50;         // from base of extruder to nozzle tip

X_belt = T5x6;
Y_belt = T5x6;
motor_shaft = 5;
Z_screw_dia = 6;            // Studding for Z axis

Y_carriage_depth = bed_depth + 10;
Y_carriage_width = bed_width + 10;

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
frame_soft_screw = No4_screw;               // Used when sheet material is soft, e.g. wood
frame_thin_screw = M3_cap_screw;            // Used with nuts when sheets are thin
frame_thick_screw = M3_pan_screw;           // Used with tapped holes when sheets are thick and hard, e.g. plastic or metal
//
// Feature sizes
//
default_wall = 3;
thick_wall = 3;
