//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Tubing and sleeving
//

PVC64     = ["PVC aquarium tubing", 6,        4, tubing_color];
PVC85     = ["PVC aquarium tubing", 8,        5, tubing_color];
NEOP85    = ["Neoprene tubing",     8,        5, [0.2,0.2,0.2]];
PTFE07    = ["PTFE sleeving",       1.2,   0.71, tubing_color];
PTFE20    = ["PTFE sleeving",       2.6,      2, tubing_color];
PF7       = ["PTFE tubing",         46/10, 3.84, tubing_color];
HSHRNK16  = ["Heatshrink sleeving", 2.0,    1.6, "grey"];
HSHRNK24  = ["Heatshrink sleeving", 2.8,    2.4, "grey"];
HSHRNK32  = ["Heatshrink sleeving", 3.6,    3.2, "grey"];
HSHRNK64  = ["Heatshrink sleeving", 6.8,    6.4, "grey"];
HSHRNK100 = ["Heatshrink sleeving",10.4,   10.0,  [0.2,0.2,0.2]];

function tubing_material(type) = type[0];
function tubing_od(type)       = type[1];
function tubing_id(type)       = type[2];
function tubing_color(type)    = type[3];

module tubing(type, length = 15, forced_id = 0) {
    original_od = tubing_od(type);
    original_id = tubing_id(type);
    id = forced_id ? forced_id : original_id;
    od = original_od + id - original_id;
    if(tubing_material(type) == "Heatshrink sleeving")
        vitamin(str("TB", round(original_od * 10), round(original_id * 10), length,": ", tubing_material(type), " ID ", original_id,"mm x ",length, "mm"));
    else
        vitamin(str("TB", round(original_od * 10), round(original_id * 10), length,": ", tubing_material(type), " OD ", original_od, "mm ID ", original_id,"mm x ",length, "mm"));
    color(tubing_color(type)) render(convexity = 5) difference() {
        cylinder(r = od / 2, h = length,     center = true);
        cylinder(r = id / 2, h = length + 1, center = true);
    }
}
