#!/usr/bin/env python

from math import *
from svg import *

def parse_dxf(fn):
    f = open(fn)

    # skip to entities section
    s = f.next()
    while s.strip() != 'ENTITIES':
        s = f.next()

    in_line = False
    in_circle = False

    pt_list = []
    cir_list = []

    for line in f:
        line = line.strip()
        # In ENTITIES section, iteration can cease when ENDSEC is reached
        if line == 'ENDSEC':
            break

        elif in_line:
            keys = dict.fromkeys(['8','10','20','30','11','21','31'], 0.0)
            while line != '0':
                if line in keys:
                    keys[line] = float(f.next().strip())
                line = f.next().strip()
            pt_list.append( ((keys['10'], keys['20']), (keys['11'], keys['21'])) )
            in_line = False

        elif in_circle:
            keys = dict.fromkeys(['8','10','20','30','40'], 0.0)
            while line != '0':
                if line in keys:
                    keys[line] = float(f.next().strip())
                line = f.next().strip()
            cir_list.append([[keys['10'], keys['20'], keys['30']], keys['40']])
            in_circle = False

        else:
            if line == 'LINE':
                in_line = True
            elif line == 'CIRCLE' or line == 'ARC':
                in_circle = True
    f.close()
    return pt_list, cir_list

def is_circle(path):
    points = len(path)
    if points < 9:
        return None
    for i in range(points) :
        p1 = path[0]
        p2 = path[int(points /3 )]
        p3 = path[int(points * 2 / 3)]
        if p1[0] != p2[0] and p2[0] != p3[0]:
            ma = (p2[1] - p1[1]) / (p2[0] - p1[0])
            mb = (p3[1] - p2[1]) / (p3[0] - p2[0])
            if ma == mb:
                return None
            x = (ma * mb *(p1[1] - p3[1]) + mb * (p1[0] + p2[0]) - ma * (p2[0] + p3[0])) / (2 * (mb - ma))
            if ma == 0:
                y = -(x - (p2[0] + p3[0]) / 2) / mb + (p2[1] + p3[1]) / 2
            else:
                y = -(x - (p1[0] + p2[0]) / 2) / ma + (p1[1] + p2[1]) / 2
            r = sqrt((p1[0] - x) * (p1[0] - x) + (p1[1] - y) * (p1[1] - y))
            for p in path:
                if abs(sqrt((p[0] - x) * (p[0] - x) + (p[1] - y) * (p[1] - y)) - r) > 0.1:
                    #print "error too big", abs(sqrt((p[0] - x) * (p[0] - x) + (p[1] - y) * (p[1] - y)) - r), points, 2 * r
                    #print p, path
                    return None
            return [x,y, 2 * r, points]
        path = path[1:] + path[:1]                  #rotate and try again
    return None

def dxf_to_svg(fn):
    ptList, cirList = parse_dxf(fn)

    loops = []
    for pt1, pt2 in ptList:
        found = False
        for i in range(len(loops)):
            loop = loops[i]
            p0 = loop[0]
            p1 = loop[-1]
            if pt1 == p0:
                loops[i] = [pt2] + loop; found = True
            elif pt2 == p0:
                loops[i] = [pt1] + loop; found = True
            elif pt1 == p1:
                loops[i] = loop + [pt2]; found = True
            elif pt2 == p1:
                loops[i] = loop + [pt2]; found = True
        if not found:
            loops.append([pt1, pt2])

    xmax = ymax = 0
    xmin = ymin = 99999999
    for loop in loops:
        if len(loop) < 4 or loop[0] != loop[-1]:
            raise Exception, "loop not closed " + str(loop)
        for point in loop:
            if point[0] > xmax: xmax = point[0]
            if point[0] < xmin: xmin = point[0]
            if point[1] > ymax: ymax = point[1]
            if point[1] < ymin: ymin = point[1]

    def p(x, y): return (x - xmin, ymax - y)

    print xmin, ymin, xmax, ymax
    scene = Scene(fn[:-4], ceil(ymax - ymin + 10), ceil(xmax - xmin + 10))
    for loop in loops:
        circle = is_circle(loop)
        if circle:
            x ,y, d, n = circle
            scene.add(Circle(p(x, y), d / 2, (255,0,0)))
            scene.add(Line( p(x + d, y), p(x - d, y) ))
            scene.add(Line( p(x, y + d), p(x, y - d) ))
            scene.add(Text( p(x + d / 2, y + d / 2), str(round(d,1)) ))
            #scene.add(Text( p(x + d, y - d - 3), "[%0.1f, %0.1f]" % (x, y), 12 ))
        else:
            last = loop[-1]
            for point in loop:
                scene.add(Line(p(last[0],last[1]),p(point[0],point[1])))
                last = point
    scene.write_svg()

if __name__ == '__main__':
    import sys
    dxf_to_svg(sys.argv[1])
