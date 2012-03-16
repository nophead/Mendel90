import os
import sys
import shutil

def render(machine):
	render_dir = machine + "/render"
	print render_dir 
	try:
		os.stat(render_dir)
	except:
		os.mkdir(render_dir)
	li = os.listdir(machine+'/stls')
	stls = []
	for i in li:
		stls.append(i[:-4])
	for i in stls:
		command = 'blender -P utils/viz.py -- '+machine+'/stls/'+i+'.stl '+machine+'/render/'+i+'.png'
		print command

if __name__ == '__main__':
    if len(sys.argv) > 1:
        render(sys.argv[1])
    else:
        print "usage: bom [mendel|sturdy|your_machine]"
        sys.exit(1)
