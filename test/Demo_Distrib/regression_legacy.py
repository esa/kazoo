#!/usr/bin/env python
import sys, os, subprocess
sys.path.append(os.path.abspath(".."))
import commonRegression

timeout = 5

expected = [
    "\[B\] Startup",
    "\[B\] ping! \(0\)",
    "\[B\] ping! \(1\)",
    "\[B\] ping! \(2\)",
    "\[B\] ping! \(3\)",
    "\[B\] ping! \(4\)",
    "\[B\] ping! \(5\)",
    "\[B\] ping! \(6\)",
    "\[B\] ping! \(7\)",
    "\[B\] ping! \(8\)",
    "\[B\] ping! \(9\)",
]

p = None
try:
    p = subprocess.Popen("binary.linux.pohic/binaries/pinger", stdout=subprocess.PIPE)
    if p == None:
	sys.exit(1)
except:
    sys.exit(1)
result=commonRegression.test(
    ["binary.linux.pohic/binaries/pingee"],
    expected, 
    timeout)
if 0!=result:
    p.kill()
    sys.exit(1)
p.kill()
p.wait()
commonRegression.g_child.terminate(force=True)
sys.exit(result)
