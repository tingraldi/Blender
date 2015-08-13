# Blender
Demonstration code for iOS and OS X using a RedBearLab Blend board and Bluetooth LE to control a hacked R/C toy.

The R/C toy started out life as a Thunder Tumbler which features two drive motors that can be controlled 
independently. It was purchased at a thrift store and was a great candidate for an Arduino hack.

The control circuit is very simple--a single L293D H-bridge chip that is wired to a RedBearLab Blend board. The 
motor power is supplied by the battery pack on the Tumbler. The board power is supplied by a 9V battery. You can
power the board over a USB, but be careful when exercisin the motor controls are you are likely to break something.

There's an LED and a piezo thrown in to the mix for fun and to show how various control messages can be sent.
