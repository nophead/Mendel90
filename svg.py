## {{{ http://code.activestate.com/recipes/325823/ (r1)
#!/usr/bin/env python
"""\
SVG.py - Construct/display SVG scenes.

The following code is a lightweight wrapper around SVG files. The metaphor
is to construct a scene, add objects to it, and then write it to a file
to display it.
"""

import os

class Scene:
    def __init__(self,name="svg",height=400,width=400):
        self.name = name
        self.items = []
        self.height = height
        self.width = width
        return

    def add(self,item): self.items.append(item)

    def strarray(self):
        var = ["<?xml version=\"1.0\"?>\n",
               '<svg xmlns="http://www.w3.org/2000/svg" version="1.1" height="%dmm" width="%dmm" >\n' % (self.height,self.width),
               ' <g style="fill-opacity:1.0; stroke:black; stroke-width:1;">\n'
              ]
        for item in self.items: var += item.strarray()
        var += [" </g>\n</svg>\n"]
        return var

    def write_svg(self,filename=None):
        if filename:
            self.svgname = filename
        else:
            self.svgname = self.name + ".svg"
        file = open(self.svgname,'w')
        file.writelines(self.strarray())
        file.close()
        return

    def display(self):
        os.system("%s" % (self.svgname))
        return


class Line:
    def __init__(self,start,end):
        self.start = start #xy tuple
        self.end = end     #xy tuple
        return

    def strarray(self):
        return ['  <line x1="%fmm" y1="%fmm" x2="%fmm" y2="%fmm" />\n' % (self.start[0],self.start[1],self.end[0],self.end[1])]


class Circle:
    def __init__(self,center,radius,color):
        self.center = center #xy tuple
        self.radius = radius
        self.color = color   #rgb tuple in range(0,256)
        return

    def strarray(self):
        return ['  <circle cx="%fmm" cy="%fmm" r="%fmm" fill="none"/>\n' % (self.center[0],self.center[1],self.radius)]

class Rectangle:
    def __init__(self,origin,height,width,color):
        self.origin = origin
        self.height = height
        self.width = width
        self.color = color
        return

    def strarray(self):
        return ['  <rect x="%dmm" y="%dmm" height="%dmm"\n' % (self.origin[0],self.origin[1],self.height),
                '    width="%dmm" style="fill:%s;" />\n' % (self.width,colorstr(self.color))]

class Text:
    def __init__(self,origin,text,size=24):
        self.origin = origin
        self.text = text
        self.size = size
        return

    def strarray(self):
        return ['  <text x="%dmm" y="%dmm" font-size="%d">\n' % (self.origin[0],self.origin[1],self.size),
                '   %s\n' % self.text,
                '  </text>\n']


def colorstr(rgb): return "#%x%x%x" % (rgb[0]/16,rgb[1]/16,rgb[2]/16)

def test():
    scene = Scene('test')
    scene.add(Rectangle((50,50),100,100,(0,255,255)))
    scene.add(Line((100,100),(150,100)))
    scene.add(Line((100,100),( 50,100)))
    scene.add(Line((100,100),(100,150)))
    scene.add(Line((100,100),(100, 50)))
    scene.add(Circle((100,100),15,(0,0,255)))
    scene.add(Circle((100,150),15,(0,255,0)))
    scene.add(Circle((150,100),15,(255,0,0)))
    scene.add(Circle(( 50,100),15,(255,255,0)))
    scene.add(Circle((100, 50),15,(255,0,255)))
    scene.add(Text((25,25),"Testing SVG"))
    scene.write_svg()
    scene.display()
    return

if __name__ == '__main__': test()
## end of http://code.activestate.com/recipes/325823/ }}}
