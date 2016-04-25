#!/usr/bin/env python

from __future__ import print_function
from make_machine import make_machine
from render import render
from views import views
from prune import prune
from set_machine import set_machine

machines   = ["dibond", "dibond_E3D", "sturdy", "mendel", "huxley", "sturdy_E3D"]
has_manual = ["dibond"]
has_views  = ["dibond", "sturdy", "huxley"]

for machine in machines:
    make_machine(machine)

    if machine in has_manual:
        render(machine)

    if machine in has_views:
        views(machine, False)

    if '_' in machine and machine.split('_')[0] in machines:
        prune(machine)
set_machine("dibond")
