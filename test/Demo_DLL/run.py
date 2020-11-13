#!/usr/bin/python

from ctypes import CDLL
import time

def RunTest():
    taste_DLL = CDLL("./binary.linux.pohic/binaries/demo_c.so")
    taste_DLL.aadl_start()
    
RunTest()
