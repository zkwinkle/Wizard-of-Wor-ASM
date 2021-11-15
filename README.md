Wizard of Wor-ASM
==========

This project is a MIPS assembly copy of the old arcade game Wizard of Wor. 

Forked from the [MIPS-PONG](https://github.com/AndrewHamm/MIPS-Pong) game, it uses some of the same basics and is also meant to be run in the MARS simulator.  It uses both the Bitmap Dislay and the Keyboard and Display MIMO Simulator tools.

## How To Run

The Mars copy that comes with this repo also comes from the MIPS-PONG repo. It fixes some bugs regarding the Bitmap Display and MMIO Simulator, go to the MIPS-PONG repo for more information.

1. Open the Mars .jar file in the repo.
2. Load the wor.asm file into Mars with File -> Open.
3. Go to Run -> Assemble
4. Go to tools -> Bitmap Display
5. The Bitmap Display settings should be as follows:
  - Unit Width: 8
  - Unit Height: 8
  - Display Width: 512
  - Display Height: 256
  - Base Address: $gp
6. Go to tools -> Keyboard and Display MMIO Simulator
7. Press connect to MIPS on both of the displays
8. Go to Run -> Go
9. All controls should take place in the lower portion of the Keyboard and Display Simulator

## Controls
Move with WASD keys.
Shoot with spacebar.
