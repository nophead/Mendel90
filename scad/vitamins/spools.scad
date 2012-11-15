//
// Mendel90
//
// nop.head@gmail.com
// hydraraptor.blogspot.com

// Filament spool models

spool_300x85 = [300, 85, 60, 4, 8, 52, 250, 280];
spool_200x55 = [200, 55, 40, 5, 5, 52, 200, 200];

function spool_diameter(type)      = type[0];
function spool_width(type)         = type[1];
function spool_depth(type)         = type[2];
function spool_rim_thickness(type) = type[3];
function spool_hub_thickness(type) = type[4];
function spool_hub_bore(type)      = type[5];
function spool_hub_diameter(type)  = type[6];
function spool_hub_taper(type)     = type[7];
function spool_height(type)        = spool_width(type) + 2 * spool_hub_thickness(type);

module spool(type) {

    h = spool_height(type);
    r1 = spool_hub_bore(type) / 2;
    r2 = spool_hub_diameter(type) / 2;
    r3 = spool_hub_taper(type) / 2;
    r4 = spool_diameter(type) / 2;
    r5 = r4 - spool_depth(type);

    color([0.2, 0.2, 0.2]) render() translate([0,0, - h / 2]) rotate_extrude(convextity = 5)
        polygon([
            [r1, h],
            [r1, 0],
            [r2, 0],
            [r3, spool_hub_thickness(type) - spool_rim_thickness(type)],
            [r4, spool_hub_thickness(type) - spool_rim_thickness(type)],
            [r4, spool_hub_thickness(type)],
            [r5, spool_hub_thickness(type)],
            [r5, h - spool_hub_thickness(type)],
            [r4, h - spool_hub_thickness(type)],
            [r4, h - spool_hub_thickness(type) + spool_rim_thickness(type)],
            [r3, h - spool_hub_thickness(type) + spool_rim_thickness(type)],
            [r2, h],
        ]);
}
