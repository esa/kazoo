#!/usr/bin/env python
import sys

timeout = 5

binaries = [
    "work/binaries/demo"
]

expected = [
    ["[A] startup", "[B] startup"],
    ["[B] startup", "[A] startup"],
    "[A] Cyclic_Run (value = 1)",
    "[B] Hello (value = 1)",
    "[A] Cyclic_Run (value = 2)",
    "[B] Hello (value = 2)",
    "[A] Cyclic_Run (value = 3)",
    "[B] Hello (value = 3)",
    "[A] Cyclic_Run (value = 4)",
    "[B] Hello (value = 4)",
    "[A] Cyclic_Run (value = 5)",
    "[B] Hello (value = 5)",
    "[A] Cyclic_Run (value = 6)",
    "[B] Hello (value = 6)",
    "[A] Cyclic_Run (value = 7)",
    "[B] Hello (value = 7)",
    "[A] Cyclic_Run (value = 8)",
    "[B] Hello (value = 8)",
    "[A] Cyclic_Run (value = 9)",
    "[B] Hello (value = 9)",
    "[A] Cyclic_Run (value = 10)",
    "[B] Hello (value = 10)",
    "[A] Cyclic_Run (value = 1)",
    "[B] Hello (value = 1)"
]

sys.path.append("..")
import commonRegression
result = commonRegression.test(binaries, expected, timeout)
sys.exit(result)
