Embedded model of a traffic light controller

This version can be deployed on an STM32F407-Disovery board
It uses the leds on the board connected to PD12 (green) PD13 (orange) PD14 (red) and PD15 (blue)
The onboard LEDS should be fine, but you can also connect an external set of LEDs.

you can connect a debug interface on PC6-PC7 and run picocom --baud 115200 --imap lfcrlf /dev/ttyUSB2
(carefully select the interface to which it is connected)
The GUI binary should be connected via PA2/PA3 pins
The deployment view defines which ttyUSB interface isused.. you must cross-check with your own configuration (use dmesg)
WARNING: this may not work at all inside a free-Virtualbox VM because of the port forwarding that requires a licence and a non-free component

When the application starts, the 4 leds should be blinking, until the initialize command is sent from the GUI
In the picocom terminal you should see an alternance of "ping" and "pong". When the initialize signal is received, the terminal should display "initialized"
