#!/usr/bin/env python
import sys

timeout = 20

binaries = [
    "work/binaries/demo"
]

expected = [
    "[TASTE] Initialization completed for function demo_Timer_Manager",
    "[MASTER] Set timer and call Slave during init",
    "[TASTE] Initialization completed for function master",
    "[slave] Startup",
    "[TASTE] Initialization completed for function slave",
    "[slave] I am free? Really? I don't believe it",
    "[MASTER] Timer expired, Slave did not answer within 1 sec (as expected)",
    "[MASTER] Trying again",
    "[slave] Second call, I say thank you",
    "[MASTER] Got Answer from slave (should be after 2nd call)",
    "You may now press Ctrl-C to stop the application"
]

sys.path.append("..")
import commonRegression
result = commonRegression.test(binaries, expected, timeout)
sys.exit(result)
