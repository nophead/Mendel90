//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Springs
//

extruder_spring = [ 7,    1, 10, 5];
hob_spring      = [12, 0.75, 10, 6];

function spring_od(type)     = type[0];
function spring_gauge(type)  = type[1];
function spring_length(type) = type[2];
function spring_coils(type)  = type[3];

// taken from openscad example 20
module coil(r1 = 100, r2 = 10, h = 100, twists)
{
    hr = h / (twists * 2);
    stepsize = 1/16;
    module segment(i1, i2) {
        alpha1 = i1 * 360*r2/hr;
        alpha2 = i2 * 360*r2/hr;
        len1 = sin(acos(i1*2-1))*r2;
        len2 = sin(acos(i2*2-1))*r2;
        if (len1 < 0.01)
            polygon([
                [ cos(alpha1)*r1, sin(alpha1)*r1 ],
                [ cos(alpha2)*(r1-len2), sin(alpha2)*(r1-len2) ],
                [ cos(alpha2)*(r1+len2), sin(alpha2)*(r1+len2) ]
            ]);
        if (len2 < 0.01)
            polygon([
                [ cos(alpha1)*(r1+len1), sin(alpha1)*(r1+len1) ],
                [ cos(alpha1)*(r1-len1), sin(alpha1)*(r1-len1) ],
                [ cos(alpha2)*r1, sin(alpha2)*r1 ],
            ]);
        if (len1 >= 0.01 && len2 >= 0.01)
            polygon([
                [ cos(alpha1)*(r1+len1), sin(alpha1)*(r1+len1) ],
                [ cos(alpha1)*(r1-len1), sin(alpha1)*(r1-len1) ],
                [ cos(alpha2)*(r1-len2), sin(alpha2)*(r1-len2) ],
                [ cos(alpha2)*(r1+len2), sin(alpha2)*(r1+len2) ]
            ]);
    }
    linear_extrude(height = h, twist = 180*h/hr,
            $fn = (hr/r2)/stepsize, convexity = 5) {
        for (i = [ stepsize : stepsize : 1+stepsize/2 ])
            segment(i-stepsize, min(i, 1));
    }
}


module comp_spring(type, l = 0) {
    l = (l == 0) ? spring_length(type) : l;

    vitamin(str("SPR", spring_od(type), spring_gauge(type) * 100, type[2],
                ": Spring ", spring_od(type), "mm OD, ", spring_gauge(type), "mm gauge x ", spring_length(type), "mm long" ));

    color(spring_color) render()
        coil(r1 = (spring_od(type) - spring_gauge(type)) / 2, r2 = spring_gauge(type) / 2, h = l, twists = spring_coils(type));

    if($children)
        translate([0, 0, l])
            children();
}

//comp_spring(extruder_spring);
