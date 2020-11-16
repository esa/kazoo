#!/usr/bin/env python3
#
# Automatically generated Python sequence chart (MSC) implementation


import os
import sys
import time
import signal
import queue
from PySide2.QtCore                  import QCoreApplication, Qt
# ----------------------------------------------------------------------------
from asn1_value_editor.Scenario      import Scenario, PollerThread
from asn1_value_editor.udpcontroller import tasteUDP

# Generated due to "mygui_trace_201604071040.msc"
# From the section: MSCDOCUMENT automade


@Scenario
def Exercise_mygui(queue):
    '''mygui processing'''
    queue.sendMsg('router_put_tc', '{ action display:"Hello", destination displayer }', lineNo=11)
    try:
        queue.expectMsg('gui_send_tm', '"Hello"', lineNo=12, timeout=3, ignoreOther=False)
    except TypeError as err:
        raise
    return 0

def runScenario(pipe_in=None, pipe_out=None, udpController=None):
    # Queue for getting scenario status
    log = queue.Queue()
    if udpController:
        mygui = Exercise_mygui(log, name='Scenario')
        udpController.slots.append(mygui.msq_q)
        mygui.wait()
        udpController.slots.remove(mygui.msg_q)
        return 0 # mygui.status
    else:
    # Use old-style message queue
        poller = PollerThread()
        mygui = Exercise_mygui(log, name='Scenario')
        poller.slots.append(mygui.msg_q)
        poller.start()
        mygui.start()
        # Wait and log messages from both scenarii
        while True:
            try:
                scenario, severity, msg = log.get(block=False)
            except queue.Empty:
                pass
            else:
                log.task_done()
                try:
                    # If called from the GUI, send log through pipe
                    pipe_out.send((scenario, severity, msg))
                except AttributeError:
                    print('[{level}] {name} - {msg}'.format
                        (level=severity, name=scenario, msg=msg))
                if severity == 'ERROR' or msg == 'END':
                    # Stop execution on first error or completed scenario
                    ret = 1 if severity == 'ERROR' else 0
                    try:
                        pipe_out.send(('All', 'COMMAND', 'END'))
                    except AttributeError:
                        mygui.stop()
                        poller.stop()
                        return ret
                try:
                    if pipe_out.poll():
                        cmd = pipe_out.recv()
                        if cmd == 'STOP':
                            mygui.stop()
                            poller.stop()
                            return 0
                except AttributeError:
                    pass


if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    udpController = None
    if '--udp' in sys.argv:
        # Create UDP Controller with default IP/Port values (127.0.0.1:7755:7756)
        udpController = tasteUDP()
    QCoreApplication(sys.argv)
    sys.exit(runScenario(udpController))
