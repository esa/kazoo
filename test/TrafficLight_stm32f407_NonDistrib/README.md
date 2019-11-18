Embedded model of a traffic light controller

This version can be deployed on an STM32F407-Disovery board
It uses the leds on the board connected to PD12 (green) PD13 (orange) PD14 (red) PD15 (pedestrian go), and PD11 (pedestrian stop)
It also uses the onboard blue button to request a shorter timeout of the green light

The onboard LEDS should be fine, but you can also connect an external set of LEDs. (esp. PD11 which has no corresponding onboard led)

When the application starts, the 4 leds should light for a short period of time, then the system should run autonomously

use "sudo journalctl -f"  to monitor the activity on the USB bus
