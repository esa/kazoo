#!/usr/bin/env python2
import sys

timeout = 5

binaries = [
    "output.c/binaries/demo_c"
    ]

expected = [
    '\[Startup\] Expected output: "Hello, world..." every 2 seconds',
    'Hello, world...',
    'Hello, world...',
    'Hello, world...',
    'Hello, world...'
]

sys.path.append("..")
import commonRegression
result = commonRegression.test(binaries, expected, timeout)
sys.exit(result)