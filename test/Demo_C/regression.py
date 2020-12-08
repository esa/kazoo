#!/usr/bin/env python3
import sys

timeout = 5

binaries = [
    "taste-simulate-leon3 output.rtems/binaries/demo_c_leon3_rtems.exe",
    "work/binaries/demo_c"
    ]

expected = [
    ['[Startup] Expected output: "Hello, world..." every 2 seconds',
     '[TASTE] Initialization completed for function Simple_C_Function'],
    'Hello, world...',
    'Hello, world...',
    'Hello, world...',
    'Hello, world...'
]

sys.path.append("..")
import commonRegression
result = commonRegression.test(binaries, expected, timeout)
sys.exit(result)
