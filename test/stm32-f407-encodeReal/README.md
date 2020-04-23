STM32-F407-Discovery test

Serial must be connected to PA2/PA3 on the STM32
On the Discovery shield, that corresponds to the built-in USB

Tested with GNAT2019 
run picocom --baud 115200 --imap lfcrlf /dev/ttyUSB0

flash with taste-flash-stm32 serial
or run st-util on the computer connected to the board and:
arm-eabi-gdb work/binaries/serial
  > tar extended-remote IP_OF_MACHINE_CONNECTED_TO_THE_BOARD:4242
  > load work/binaries/serial
  > c

Result: should display:
[SDL] System startup
OUT: 3.1415000
OUT: 3.6415000
...
(value increased by 0.5 at each cycle)

The leds should flash every second
