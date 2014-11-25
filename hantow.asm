; Towers of Hanoi x86 assembly program
; Author: Brendan Duke
; Modified: November 25, 2014
; My program is an implementation of a recursive solution to the Towers of
; Hanoi problem, and works for 2 to 8 disks.
; We can specify the number of disks with a command line argument.
; For instance, we can type "hantow 8" to execute the problem for 8 disks.
%include "asm_io.inc"

SECTION .data
  ; Initialize the three pegs to be empty.
  Peg1 db 0,0,0,0,0,0,0,0,9
  Peg2 db 0,0,0,0,0,0,0,0,9
  Peg3 db 0,0,0,0,0,0,0,0,9

SECTION .bss

SECTION .text
   global asm_main

asm_main:
   enter 0,0    ; enter the subroutine 
   pushad       ; save all registers

   popad        ; restore all registers
   leave        ; leave the subroutine
   ret          ; return control
