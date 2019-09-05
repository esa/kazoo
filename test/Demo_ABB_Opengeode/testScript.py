#!/usr/bin/env python
#
# Automatically generated Python sequence chart (MSC) implementation

import os
import sys
import signal

taste_inst = os.popen('taste-config --prefix').readlines()[0].strip()
sys.path.append(taste_inst+'/share/asn1-editor')

from Scenario import Scenario, PollerThread
from PySide.QtCore import QCoreApplication, Qt
from udpcontroller import tasteUDP

status = 0
# Generated due to "user_trace_201212131443.msc"
# From the section: MSCDOCUMENT automade


@Scenario
def Exercise_user(self):
    '''user processing'''
    global status
    self.sendMsg('Manual_Control', '{ door door-open, direction down, brake off, motor on }', lineNo=17)
    self.sendMsg('Start', 'nb-of-cycle:100', lineNo=18)
    while True:
        (msgId, val) = self.getNextMsg(timeout=1)
        if not msgId:
            break
        if msgId == 'position':
            continue
        elif msgId == 'door_status':
            print 'Received door status, value=', val.Get()
    return 0

def runScenario(udpController=None, callback=None):
    global user
    global poller
    poller = None
    if udpController:
        user = Exercise_user()
        udpController.slots.append(user.Q)
        user.wait()
        udpController.slots.remove(user.Q)
        if callback:
            user.done.connect(callback)
        return user.status
    else:
    # Use old-style message queue
        poller = PollerThread()
        user = Exercise_user()
        if callback:
            user.done.connect(callback)
        poller.slots.append(user.Q)
        poller.start()
        user.start()

def killThreads():
    global user
    user.wait()
    user = None
    if poller:
        poller._bDie = True
        poller.wait()


if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    udpController = None
    if '--udp' in sys.argv:
        # Create UDP Controller with default IP/Port values (127.0.0.1:7755:7756)
        udpController = tasteUDP()
    app = QCoreApplication(sys.argv)
    app.aboutToQuit.connect(killThreads)
    status = runScenario(udpController, app.quit)
    app.exec_()
    sys.exit(status)
