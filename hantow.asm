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
  Peg1: dd 0,0,0,0,0,0,0,0,9
  Peg2: dd 0,0,0,0,0,0,0,0,9
  Peg3: dd 0,0,0,0,0,0,0,0,9
  Peg_len equ $-Peg3

SECTION .bss

SECTION .text
   global asm_main

;-----------------------------------------------------------------------------
; Prints the array currently addressed by eax, using eax as a pointer to each
; element.
Display_array:
      push ebx      ; We will use ebx, so we save it.
      push esi      ; We will use esi, so we save it.
      mov esi,0     ; esi will index the array so we set it to zero.
      mov ebx,eax   ; Put base address of array in eax.
.Loop:
      mov eax,dword [ebx+esi] ; Put current element of array in eax. 
      call print_int ; Print element.
      mov eax,' '   ; Put format character ' ' in eax.
      call print_char ; Print space.
      add esi,4     ; eax+esi points to next int in array.
      cmp esi,Peg_len ; Check if pointer points to end of array
      jl .Loop      ; If not, print next number.
      call print_nl ; Print a formatting newline.
      mov eax,ebx   ; Restore base of array to eax.
      pop esi       ; Restore registers and return.
      pop ebx
      ret

asm_main:
      enter 0,0     ; Enter the subroutine.
      pushad        ; Save all registers.
      mov eax,Peg1  ; Test printing Peg1
      call Display_array ; Call print array function.
      popad         ; Restore all registers.
      leave         ; Leave the subroutine.
      ret           ; Return control.
