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
    ["binary.linux.pohiada/binaries/mypartition"],
    expected, 
    timeout)
if 0!=result:
    sys.exit(1)
commonRegression.g_child.terminate(force=True)

result=commonRegression.test(
    ["binary.linux.pohic/binaries/mypartition"],
    expected, 
    timeout)
if 0!=result:
    sys.exit(1)
commonRegression.g_child.terminate(force=True)

# Stop here when running under CircleCI - the LXC containers
# don't allow us to modify the mqueue settings, and the
# rest of the tests fail.
if os.getenv("CIRCLECI") is not None:
    sys.exit(0)

binaries2 = [
    "python Test_TM_TC_with_Demo_Ada.py"
]
   
expected2 = [
    "Invoking TC",
    '{ destination   displayer ,  action   display:    "abc1" }',
    "Received Telemetry: gui_send_tm",
    "Parameter tm:",
    "abc1",
    "Received Telemetry: gui_send_tm",
    "Parameter tm:",
    "abc1"
]

def VerifyTM(binary):
    print "Verifying TMs sent by", binary
    p = None
    try:
	p = subprocess.Popen(binary, stdout=subprocess.PIPE)
	if p == None:
	    sys.exit(1)
    except:
	sys.exit(1)
    os.system("cp Test_TM_TC_with_Demo_Ada.py binary.linux.pohiada/GlueAndBuild/gluemygui/python/")
    os.chdir("binary.linux.pohiada/GlueAndBuild/gluemygui/python")
    result2=commonRegression.test(binaries2, expected2, timeout)
    p.kill()
    p.wait()
    os.chdir("../../../../")
    if 0!=result2:
	sys.exit(1)

VerifyTM("binary.linux.pohiada/binaries/mypartition")
VerifyTM("binary.linux.pohic/binaries/mypartition")
