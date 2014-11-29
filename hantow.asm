; Towers of Hanoi x86 assembly program
; Author: Brendan Duke
; Modified: November 28, 2014
; My program is an implementation of a recursive solution to the Towers of
; Hanoi problem, and works for 2 to 8 disks.
; We can specify the number of disks with a command line argument.
; For instance, we can type "hantow 8" to execute the problem for 8 disks.
%include "asm_io.inc"

SECTION .data
  ; Initialize the three pegs to be empty.
  Peg1 dd 0,0,0,0,0,0,0,0,9
  Peg2 dd 0,0,0,0,0,0,0,0,9
  Peg3 dd 0,0,0,0,0,0,0,0,9
  Peg_len equ $-Peg3 ; Peg_len contains the length in bytes of a peg array.

  ; String for errors.
  ErrMsg1 db "Invalid number of arguments.",10,0
  ErrMsg2 db "Invalid argument.",10,0

SECTION .bss

SECTION .text
   global asm_main

;-----------------------------------------------------------------------------
; Takes an argument in eax that is the number of discs, and initializes
; Peg1 properly.
Init:
      push ebx      ; We will use ebx, ecx and edx, so save them.
      push ecx
      push edx
      mov ebx,8     ; Set ebx to max numebr of discs.
      ; ebx is the element of Peg1 that the smallest disc should start at
      sub ebx,eax
      shl ebx,2     ; Make ebx a double-word pointer.
      mov ecx,eax   ; Copy number of discs to ecx.
      dec ecx       ; Make ecx start at n-1.
.Loop:
      mov edx,eax   ; Set edx to eax-ecx
      sub edx,ecx
      mov [Peg1+ebx],edx ; Put next disc on Peg1
      add ebx,4     ; Increment pointer to next element.
      dec ecx       ; --ecx
      cmp ecx,0     ; Check if ecx is below 0.
      jge .Loop     ; Keep setting up peg until ecx < 0.
      pop edx       ; Restore registers and return.
      pop ecx
      pop ebx
      ret

;-----------------------------------------------------------------------------
; Determines the address of the first non-zero element of an array starting at 
; eax.
Find_top:
      cmp dword [eax],0   ; Check if array element at eax is 0
      jne .Exit      ; If it's not, then return.
      add eax,4     ; Move pointer to next element.
      jmp Find_top  ; Keep checking
.Exit:
      ret           ; Return to caller.

;-----------------------------------------------------------------------------
; Moves the top disc of the array addressed by eax to the array addressed by
; ebx.
Move_disc:
      push ecx      ; We will use ecx, so save it.
      call Find_top ; Put index of top element of "from" array in eax.
      mov ecx,[eax] ; Move disc pointed to by eax temporarily to ecx.
      mov [eax],dword 0 ; Zero the spot where the disc at eax used to be.
      mov eax,ebx   ; Move address of "to" peg to eax.
      call Find_top ; Find top of the "to" peg.
      mov [eax-4],ecx ; Put disc from top of "from" peg to top of "to" peg.
      pop ecx       ; Restore ecx and return.
      ret

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
      mov eax,ebx   ; Restore base of array to eax.
      pop esi       ; Restore registers and return.
      pop ebx
      ret

Print_arrays:
      push eax      ; We will use eax so we save it on the stack.
      mov eax,Peg1  ; Set eax to base of first array.
      call Display_array ; Print first array.
      mov eax,9     ; Put ASCII value for TAB in eax.
      call print_char ; Print a tab.
      mov eax,Peg2  ; Set eax to base of second array.
      call Display_array ; Print second array.
      mov eax,9     ; Put ASCII value for TAB in eax.
      call print_char ; Print a tab.
      mov eax,Peg3  ; Set eax to base of third array.
      call Display_array ; Print third array.
      call print_nl ; Print formatting newline
      pop eax       ; Restore eax and return.
      ret

;-----------------------------------------------------------------------------
; Checks that we only have one.
ArgcCheck:
      push eax      ; We will use eax, so we save it on the stack.
      push ebx      ; We will use ebx, so we save it on the stack.
      mov eax,[ebp] ; Put main's ebp in eax
      mov ebx,[eax+8] ; Put argc in ebx
      cmp ebx,2     ; Check if ebx != 2 (e.g. ./hantow 3 is valid).
      pop ebx       ; Restore used registers.
      pop eax
      jne ArgcErr   ; print Error
      ret           ; Return.

;-----------------------------------------------------------------------------
; Checks that our argument n is an integer in the range [2,8].
; Returns n as an integer in eax.
RangeCheck:
      push ebx      ; We will use ebx and ecx so we save them on the stack.
      push ecx
      mov ebx,[ebp+0xC] ; Put pointer to argv table in ebx.
      mov ebx,[ebx+4]   ; Put second argument in ebx (pointer to a string).
      mov eax,0     ; Zero eax.
      ; Set lowest byte of eax to the ASCII value of the first char of string
      ; pointed to by argv[1].
      mov al,[ebx]
      cmp eax,'2'   ; Check if eax < '2'.
      jl .Error     ; If so print a range error.
      cmp eax,'8'   ; Check if eax > '8'.
      jg .Error     ; If so print a range error.
      sub eax,'0'   ; Convert eax to an integer to return it.
      pop ecx       ; Pop used registers.
      pop ebx
      ret           ; Return
.Error:
      pop ecx       ; Pop used registers.
      pop ebx
      jmp RangeErr ; Print a range error.

;-----------------------------------------------------------------------------
; The program enters here (asm_main is called from a main in asm_io.asm).
asm_main:
      enter 0,0     ; Enter the subroutine.
      pushad        ; Save all registers.
      call ArgcCheck ; Check that argc = 2 (one extra argument).
      call RangeCheck ; Check that n is in the range [2,8].
      call Init     ; Initialize Peg1 with correct discs.
      call Print_arrays ; Test printing arrays.
      jmp Exit      ; Jump over ArgcErr to program exit.      

;-----------------------------------------------------------------------------
; Below are two blocks for printing error messages, and the instruction 
; sequence to exit.
ArgcErr:
      add esp,4     ; Pop extra return address from error jump.
      mov eax,ErrMsg1 ; Put pointer to error message string in eax.     
      call print_string ; Print error message.
      jmp Exit

RangeErr:
      add esp,4     ; Pop extra return address from error jump.
      mov eax,ErrMsg2 ; Put error message 2 base pointer in eax.
      call print_string ; Print error message

Exit:
      popad         ; Restore all registers.
      leave         ; Leave the subroutine.
      ret           ; Return control.
