![Eridan](Eridan_Logo_RGB.png)
# MIRACLE-MATLAB

MATLAB API for MIRACLE DevKit.

[Eridan MIRACLE DevKit](https://eridan.io/devkit/)

The **TX** repo contains MATLAB code intended to drive the MIRACLE TX.
- `MIRACLETX.m` is a MATLAB class structure used for controlling a DevKit board connected to a ZC706.  Most of the functions in this class contain wrappers for the functions outlined in the **Using Serial Communication Terminal** section of the DevKit User guide.  These commands are sent as strings over a serial connection to the ZC706.
- `MIRACLETXExamples.m` is an initialization script for setup of the TX.  This script also contains commented examples at the end of the file for various TX functions.

The **RX** repo contains a MATLAB script to control the AD9361 **RX ONLY** on the MIRACLE DevKit module. Please refer to the MIRACLE DevKit User Guide for more information.
