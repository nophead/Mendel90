//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Filament spool holder
//
include <conf/config.scad>
include <positions.scad>
use <wade.scad>

bearing = BB608;

thickness = 6;
wall = 2;
angle = 45;

hook = 8;
hook_overlap = 3;
tube_r = 4;
hook_r = 3;

left = left_stay_x + sheet_thickness(frame) / 2;
right =  right_stay_x - sheet_thickness(frame) / 2;
spool_x = (left + right) / 2;
spool_y = gantry_Y + sheet_thickness(frame) + 10 + spool_height(spool) / 2;

holes = psu_hole_list(psu);

bearing_r = (spool_diameter(spool) + ball_bearing_diameter(bearing)) / 2;
bearing_x = cos(angle) * bearing_r;
bearing_z = spool_z - sin(angle) * bearing_r;
bearing_y = spool_width(spool) / 2 + ball_bearing_width(bearing) / 2 - washer_thickness(M8_penny_washer);

bracket_width = right - (spool_x + bearing_x);
bracket_height =  height - bearing_z;
top_tube_x = bracket_width - tube_r;
top_tube_y = bracket_height + hook - tube_r;
bottom_tube_y = -bracket_height + tube_r;
middle_tube_x = washer_diameter(M8_washer) / 2 + 1 + tube_r;

dx = top_tube_x - middle_tube_x;
dy = top_tube_y;

tube_spacing = sqrt(dx * dx + dy * dy);

width = spool_width(spool) - 2 * (thickness + washer_thickness(M8_washer) + washer_thickness(M8_penny_washer));

sponge_length = 15;
sponge_depth  = 15;
sponge_height = 15;
sponge_wall = 2;

feed_clip_length = 2 * (tube_r + 3);
feed_clip_width = sponge_depth + sponge_wall;

feed_clip_thickness = 3;

module pie_slice(r, start_angle, end_angle) {
    R = r * sqrt(2) + 1;
    a0 = (4 * start_angle + 0 * end_angle) / 4;
    a1 = (3 * start_angle + 1 * end_angle) / 4;
    a2 = (2 * start_angle + 2 * end_angle) / 4;
    a3 = (1 * start_angle + 3 * end_angle) / 4;
    a4 = (0 * start_angle + 4 * end_angle) / 4;
    if(end_angle > start_angle)
        intersection() {
        circle(r);
        polygon([
            [0,0],
            [R * cos(a0), R * sin(a0)],
            [R * cos(a1), R * sin(a1)],
            [R * cos(a2), R * sin(a2)],
            [R * cos(a3), R * sin(a3)],
            [R * cos(a4), R * sin(a4)],
       ]);
    }
}


//
// Tube clips
//
module tube_clip() {
    angle = atan(0.6);
    linear_extrude(height = feed_clip_width, convexity = 5)
        union() {
            difference() {
                pie_slice(tube_r + feed_clip_thickness, -angle, 180 + angle);
                circle(tube_r);
            }
            for(a = [-angle, 180 + angle])
                rotate(a)
                    translate([tube_r + feed_clip_thickness / 2, 0])
                        circle(feed_clip_thickness / 2);
        }
}

filament_y = tube_r + feed_clip_thickness + feed_tube_tape_rad + eta;
filament_z = sponge_wall + sponge_depth / 2;

box_length = sponge_length + 2 * sponge_wall;
box_height = sponge_height + 2 * sponge_wall;
box_depth = sponge_depth + sponge_wall;

box_x = tube_spacing - box_length - feed_clip_length / 2 - 2;
box_y = filament_y - box_height / 2;

module dust_filter_stl() {
    stl("dust_filter");

    filament_hole_r = 2;


    difference() {
        union() {
            tube_clip();                                                    // clips at each end
            translate([tube_spacing, 0, 0])
                tube_clip();

            translate([0, tube_r + eta, 0])
                cube([tube_spacing, feed_clip_thickness, box_depth]);       // joining strip

            translate([box_x, box_y, 0])
                cube([box_length, box_height, box_depth]);                  // box for dust trap

            translate([0, filament_y, filament_z])
                    hull() {
                        rotate([-90, 0, 90])
                            cylinder(r = feed_tube_tape_rad + wall, h = wall + feed_tube_tape, center = true);

                        translate([-feed_tube_tape / 2, - wall, - filament_z])
                            cube([feed_tube_tape, 2 * wall, 1]);
                    }
        }
        translate([box_x + sponge_wall, box_y + sponge_wall, sponge_wall])
            cube([sponge_length, sponge_height, sponge_depth + 1]);

        translate([box_x + box_length / 2, filament_y, filament_z])
            rotate([90, 0, 90])
                teardrop(r = filament_hole_r, h = box_length + 1, center = true);

        translate([0, filament_y, filament_z])
            rotate([90, 0, 90])
                teardrop(r = feed_tube_rad, h = wall + feed_tube_tape + 1, center = true);

        translate([wall, filament_y, filament_z])
            rotate([90, 0, 90])
                teardrop(r = feed_tube_tape_rad, h = wall + feed_tube_tape, center = true);
    }
}


screw_tab = screw_boss_diameter(frame_screw);
tab_thickness = part_base_thickness + ((frame_nut_traps) ? nut_trap_depth(nut) : 0);
nut_offset = frame_nut_traps ? -screw_tab / 2 + nut_radius(frame_nut) + 0.5 : 0;


//
// Tube with a dowel on top
//
module tube(height) {
    difference() {
        union() {
            cylinder(r = tube_r, h = height);
            cylinder(r = tube_r - min_wall, h = height + thickness - wall - layer_height);        // dowel
        }
        translate([0, 0, wall])
            cylinder(r = tube_r - wall, h = height - 2 * wall);
    }
}

//
// The outline of the bracket, triangle with rounded corners
//
module shape(width, height) {
    hull() {
        circle(washer_diameter(M8_washer) / 2 + 1);

        translate([width - tube_r, height + hook - tube_r])
            circle(tube_r);

        translate([width - tube_r, -height + tube_r])
            circle(tube_r);
    }
}
//
// Inset to remove most of the plastic leaving a frame
//
frame_bar_width = 8;

module inner_shape(width, height) {
    rad = 4;
    inset = frame_bar_width + rad;

    minkowski() {
        render() difference() {
            shape(width, height);
            union() {
               minkowski() {
                    difference() {
                        minkowski() {
                            shape(width, height);
                            circle(r = 1, center = true);
                        }
                        shape(width, height);
                        translate([width -1, -inset])
                            square([3, 2 * inset + 1]);
                    }
                    circle(r = inset);
                }
                translate([width - inset - eta, -2 * inset])
                    square([2 * inset + 1 + 2 * eta, 4 * inset]);
            }
        }
        circle(rad);
    }
}

//
// A bisexual bracket
//
module spool_bracket(width, height, tube) {
    hole_r = screw_clearance_radius(M8_cap_screw);

    difference() {
        union() {
            linear_extrude(height = thickness, convexity = 5)
                difference() {
                    union() {
                        shape(width, height);
                        hull() {
                            translate([width - tube_r - eta, height - hook_overlap])
                                square([tube_r + 1, hook + hook_overlap]);

                            translate([width + sheet_thickness(frame) + hook - hook_r, height - hook_overlap + hook_r])
                                circle(hook_r);

                            translate([width + sheet_thickness(frame) + hook - hook_r, height + hook - hook_r])
                                circle(hook_r);
                        }
                    }
                    difference() {
                        inner_shape(width, height);
                        circle(washer_diameter(M8_washer) / 2 + 1 + 2 * tube_r);
                    }

                    poly_circle(hole_r);                                                    // hole for axel screw

                    translate([width, height - hook])
                        square([sheet_thickness(frame) + 0.2, hook]);                       // slot for frame

                }
                if(tube > 0) {
                    for(v = [
                        [top_tube_x, bottom_tube_y, thickness - eta],
                        [top_tube_x, top_tube_y,    thickness - eta],
                        [middle_tube_x, 0,          thickness - eta],
                    ]) translate(v)
                        tube(tube);

                    translate([width - tab_thickness, -height + tube_r, thickness - eta])
                        cube([tab_thickness, screw_tab + tube_r, screw_tab]);
                }
        }
        translate([width - part_base_thickness, -height + 2 * tube_r + screw_tab / 2 + nut_offset, thickness + screw_tab / 2 + nut_offset])
            rotate([90, 0, -90])
                part_screw_hole(frame_screw, frame_nut, horizontal = true);

        if(tube < 0)
            for(v = [
                [top_tube_x, bottom_tube_y, thickness],
                [top_tube_x, top_tube_y,    thickness],
                [middle_tube_x, 0,          thickness],
            ]) translate(v)
                cylinder(r = tube_r - min_wall + 0.1, h = - 2 * tube, center = true);           // socket for dowel
    }
}
//
// Male and female versions
//
module spool_bracket_female_stl() {
    stl("spool_bracket_female");
    spool_bracket(bracket_width, bracket_height, wall - thickness);
}

module spool_bracket_male_stl() {
    stl("spool_bracket_male");
    mirror([0, 1, 0]) spool_bracket(bracket_width, bracket_height, width);
}

//
// One bearing and bracket
//
module spool_bracket_assembly(male)
{
    rotate([-90, 0, 0]) {
        translate([0, 0, exploded * 15]) {
            ball_bearing(bearing);

            translate([0, 0, ball_bearing_width(bearing) / 2 + exploded * 5])
                washer(M8_washer)
                    translate([0, 0, exploded * 5])
                        washer(M8_penny_washer)
                            screw(M8_cap_screw, 30);
        }

        rotate([180, 0, 0])
            translate([0, 0, ball_bearing_width(bearing) / 2]) {
                translate([0, 0, exploded * -10])
                    washer(M8_washer) translate([0, 0, exploded * 5]) group() {
                        if(male)
                            color(plastic_part_color("lime")) render() mirror([0, 1, 0]) spool_bracket_male_stl();
                        else
                            color(plastic_part_color("red")) render() spool_bracket_female_stl();

                        translate([0, 0, thickness]) {
                            translate([0, 0, exploded * 5])
                                washer(M8_washer)
                                    nut(M8_nut, true);

                        }
                    }
            }
        if(male)
            translate([right - (spool_x + bearing_x), height - bearing_z - tube_r, -bearing_y]) {
                translate([-part_base_thickness, -tube_r - screw_tab / 2 - nut_offset, width / 2 - screw_tab / 2 - nut_offset])
                    rotate([0, -90, 0])
                        rotate([0, 0, 30])
                            frame_screw(part_base_thickness);
            }
    }
}

//
// The full assembly
//
module spool_assembly(show_spool = true) {
    angle = atan(dx / dy);
    tube_length = 750;
    truncated = show_spool ? 200 : 100;
    sponge_scale = 0.75 + exploded * 0.25;

    assembly("spool_holder_assembly");

    if(show_spool)
        translate([spool_x, spool_y, spool_z])
            rotate([90, 0, 0])
                spool(spool);

    for(side = [-1, 1]) {
        translate([spool_x + side * bearing_x, spool_y + side * bearing_y, bearing_z])
            rotate([0, 0, 90 - side * 90])
                spool_bracket_assembly(false);

        translate([spool_x + side * bearing_x, spool_y - side * bearing_y, bearing_z])
            rotate([0, 0, 90 - side * 90])
                mirror([0, 1, 0])
                    spool_bracket_assembly(true);

        if(side == -1)
            translate([spool_x + side * (bearing_x + top_tube_x), spool_y + feed_clip_width / 2 + sponge_wall / 2, bearing_z + top_tube_y])
                rotate([90, 90 - angle, 0]) {
                    color("red") render() dust_filter_stl();
                    translate([box_x + box_length / 2, box_y + box_height / 2, sponge_height / 2 + sponge_wall])
                        explode([-30, 50, 70]) difference() {
                            scale([sponge_scale, sponge_scale, sponge_scale])
                                sheet(Foam20, 20, 20);

                            translate([0, 0, sponge_depth / 2])
                                cube([22, 1, sponge_depth], center = true);
                        }
                    rotate([90, 0, 90])
                        translate([filament_y, feed_clip_width / 2 + sponge_wall / 2, -tube_length / 2 + (wall + feed_tube_tape) / 2]) {
                            difference() {
                                tubing(PF7, tube_length);
                                translate([0, 0, -truncated + tube_length / 2])
                                    rotate([180, 0, 0])
                                        cylinder(r = 20, h = 1000);
                                translate([0, 0, -truncated /2 + tube_length / 2])
                                    rotate([30, 0, 0])
                                        cylinder(r = 40, h = 5);
                            }

                        }
                }
    }


    vitamin("PLA3040: PLA sample 3mm ~50m");

    end("spool_holder_assembly");
}

module spool_holder_holes()
    for(side = [-1, 1])
        translate([side < 0 ? left: right, spool_y + side * (-width / 2 + screw_tab / 2 + nut_offset), bearing_z - bracket_height + 2 * tube_r + screw_tab / 2 + nut_offset])
            rotate([0, 90, 0])
                frame_screw_hole();


//
// All four laid out for building
//
module spool_holder_brackets_stl() {

    w = top_tube_y - bottom_tube_y;
    gap = 2 * tube_r + 2;
    h = w / 2 + gap / sqrt(2);
    x = h - top_tube_x;
    for(i = [0:3]) assign(odd = i % 2)
        rotate([0, 0, i * 90])
            translate([x, (odd ? -1 : 1)  * (top_tube_y + bottom_tube_y) / 2,0])
                if(odd)
                    spool_bracket_female_stl();
                else
                    spool_bracket_male_stl();
}


module spool_holder_tall_brackets_x4_stl() {

    w = top_tube_y - bottom_tube_y;
    gap = 2 * tube_r + 2;
    h = w / 2 + gap / sqrt(2);
    x = h - top_tube_x;
    for(i = [0:3])
        rotate([0, 0, i * 90])
            translate([x, (top_tube_y + bottom_tube_y) / 2,0])
                spool_bracket_male_stl();

}

if(1)
    translate([0, 0, - spool_z])
        spool_assembly();
else
    if(1)
        spool_holder_brackets_stl();
    else
        dust_filter_stl();
