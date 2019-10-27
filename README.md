# Experimental HUB75 FPGA Driver

## Reference

https://github.com/hzeller/rpi-rgb-led-matrix

## Target panel

64 x 64 size with ABCDE control signal.

## Target FPGA borad

This design should be able to any kind of FPGA boards. It's tested on BeMicro Max 10 boads.

## How to use

Instantiate "Driver" module, and connect it's IO to the panel. Expected input clock frequency is 10MHz.
