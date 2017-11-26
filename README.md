# Blender
Demonstration code for iOS and OS X using a [RedBearLab Blend board](http://redbearlab.com/blend/) and Bluetooth LE to control a hacked R/C toy. The sketch that runs on the board leverages [RedBearLab's BLE library](https://github.com/RedBearLab/nRF8001). 

The R/C toy started out life as a Thunder Tumbler which features two drive motors that can be controlled 
independently. It was purchased at a thrift store and was a great candidate for an Arduino hack. Here's how it looks:

![the actual toy](https://raw.githubusercontent.com/tingraldi/Blender/master/Hacked%20Tumbler.jpg "Hacked Tumbler")

See it in action [here](https://youtu.be/vqGI7RXqzFA)

Here's a sketch of the circuit, not including the wires that connect the H-bridge to the motors or the power coming 
from the Tumbler. Pretend that the board shown in the sketch is a RedBearLab Blend instead of a Leonardo.

![the circuit](https://github.com/tingraldi/Blender/blob/master/Tumbler%20Controller_bb.png "Sketch of Circuit")

The control circuit is very simple--a single L293D H-bridge chip that is wired to a RedBearLab Blend board. The 
motor power is supplied by the battery pack on the Tumbler. The board power is supplied by a 9V battery. You can
power the board over a USB, but be careful when exercising the motor controls or you are likely to break something.

There's an LED and a piezo thrown in to the mix for fun and to show how various control messages can be sent. The 
iOS demo project features controls for the motors, the LED, and the piezo. The OS X demo project just controls
the LED and the piezo.
