#!/usr/bin/env python
import sys, os, time, pexpect, subprocess
sys.path.append(os.path.abspath(".."))
import commonRegression

timeout = 15

expected = [
    ["init of displayer done", "init of router done"],
    ["init of displayer done", "init of router done"],
    "cyclicdisplayer",
    "cyclicdisplayer"
]

result=commonRegression.test(
    ["work/binaries/mypartition"],
    expected, 
    timeout)
if 0!=result:
    sys.exit(1)
commonRegression.g_child.terminate(force=True)

