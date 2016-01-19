//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Clip to fit around light strip profile
//
include <conf/config.scad>

wall = 2;
function light_strip_clip_depth(light) = 10;
function light_strip_clip_length(light) = light_strip_slot(light) + 2 * wall;
function light_strip_clip_width(light) = 2 + light_strip_thickness(light) + wall;
function light_strip_slot(light) = light_strip_width(light) + 0.2;
function light_strip_clip_gap(light) = light_strip_width(light) - 4;

module light_strip_clip(light) {
    linear_extrude(height = light_strip_clip_depth(light), convexity = 2)
        difference() {
            translate([-light_strip_clip_length(light) / 2, 0])
                square([light_strip_clip_length(light), light_strip_clip_width(light)]);

            translate([-light_strip_slot(light) / 2, wall])
                square([light_strip_slot(light), light_strip_thickness(light)]);

            translate([-light_strip_clip_gap(light) / 2, wall])
                square([light_strip_clip_gap(light),100]);
        }
}

light_strip_clip(RIGID5050_290);
