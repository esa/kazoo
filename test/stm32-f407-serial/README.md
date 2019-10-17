STM32-F407-Discovery test

Serial must be connecter to PA2/PA3
On the Discovery shield, that corresponds to the built-in USB

Tested with GNAT2019 
run picocom --baud 115200 --imap lfcrlf /dev/ttyUSB0

flash with taste-flash-stm32 serial
Result: should display periodically Hello world
(run picocom before flashing, in case)
and the leds should flash every second

type text and enter in picocom -> the stm32 should answer



