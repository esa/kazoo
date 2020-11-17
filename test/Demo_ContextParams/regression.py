#!/usr/bin/env python
import sys

timeout = 5

binaries = [
    "work/binaries/demo", 
    "work_ada/binaries/demo"]

expected = [
        ["[passive_function] startup done: 42 -42",
         "[cyclic function] startup done",
         "[TASTE] Initialization completed for function passive_function",
         "[TASTE] Initialization completed for function cyclic_function",
         "[Ada] Startup:  42 FALSE",
         "[TASTE] Initialization completed for function Function_in_Ada"],
    "cycle: input i=0, j=0",
    "test1 = 0",
    "   result of computation: 0",
    "cycle: input i=1, j=1",
    "test1 = 2",
    "   result of computation: 2",
    "cycle: input i=2, j=2",
    "test1 = 4",
    "   result of computation: 4",
    "cycle: input i=3, j=3",
    "test1 = 6",
    "   result of computation: 6",
    "cycle: input i=4, j=4",
    "test1 = 8",
    "   result of computation: 8",
    "cycle: input i=5, j=5",
    "test1 = 10",
    "   result of computation: 10"
]

sys.path.append("..")
import commonRegression
result = commonRegression.test(binaries, expected, timeout)
sys.exit(result)
