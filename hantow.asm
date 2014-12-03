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

  ; String for the peg base
  Peg_base db "XXXXXXXXXXXXXXXXXXX",0

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
      jne .Exit     ; If it's not, then return.
      add eax,4     ; Move pointer to next element.
      jmp Find_top  ; Keep checking
.Exit:
      ret           ; Return to caller.

;-----------------------------------------------------------------------------
; Takes peg addresses in eax and ebx, and returns those same addresses in
; eax and ebx, with the other peg in edx.
Find_mid:
      push eax      ; Save eax.
      mov eax,Peg_len ; Put peg length in eax.
      mov edx,3     ; Set edx to 3.
      mul edx       ; Set eax to 3*Peg_len
      mov edx,eax   ; Set edx to 3*Peg_len.
      pop eax       ; Restore eax.
      sub eax,Peg1  ; Set eax to its offset from Peg1.
      sub ebx,Peg1  ; Set ebx to its offset from Peg1.
      sub edx,eax   ; edx = 3*Peg_len - eax's offset from Peg1.
      sub edx,ebx   ; edx = 3*Peg_len - total offset of eax and ebx.
      add eax,Peg1  ; Restore eax's address.
      add ebx,Peg1  ; Restore ebx's address.
      add edx,Peg1  ; edx now contains the address of the intermediate peg.
      ret           ; Return.

;-----------------------------------------------------------------------------
; Moves the top disc of the array indexed by eax to the array addressed by
; ebx. eax == 1 means Peg1, eax == 2 means Peg2, etc.
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
; Print n characters, where the character is an argument in eax and n is
; an argument in ebx.
Print_chars:
      push ebx      ; We change ebx, so save it.
.Loop:
      cmp ebx,0     ; Check if ebx > 0.
      jle .Exit     ; Return if ebx <= 0.
      call print_char ; Print whatever character is in eax.
      dec ebx       ; --ebx.
      jmp .Loop
.Exit:
      pop ebx       ; Restore ebx and return.
      ret

;-----------------------------------------------------------------------------
; Prints 9-x[i] spaces, x[i] '+', a '|', x[i] '+', then 9-x[i] spaces then 
; a <TAB>
Print_row:
      push ecx      ; We use ecx and ebx, so save them.
      push ebx
      mov ecx,eax   ; Make ecx the pointer to the array, to free up eax.
      mov ebx,9     ; Set ebx to 9.
      sub ebx,[ecx] ; Set ebx to 9-x[i].
      mov eax,' '   ; Set eax to space.
      call Print_chars ; Print 9-x[i] spaces
      mov ebx,[ecx] ; Set ebx = xi
      mov eax,'+'   ; Set eax to '+'.
      call Print_chars ; Print x[i] '+'.
      mov eax,'|'   ; Set eax to '|'.
      call print_char ; Print '|'.
      mov eax,'+'   ; Set eax to '+'.
      call Print_chars ; Print x[i] '+'.
      neg ebx       ; ebx = -x[i].
      add ebx,9     ; ebx = 9 - x[i].
      mov eax,' '   ; Set eax to space.
      call Print_chars ; Print 9-x[i] spaces.
      mov eax,9     ; Set eax to ASCII value for <TAB>.
      call print_char ; Print <TAB>.
      mov eax,ecx   ; Restore eax.
      pop ebx       ; Restore registers and return.
      pop ecx
      ret

;-----------------------------------------------------------------------------
; Takes an offset from Peg1 as an argument.
; Prints a set of 3 rows of discs on the 3 different pegs.
Print_rows:
      push eax       ; We use eax, so save it.
      add eax,Peg1   ; Add the base address of Peg1 to eax.
      call Print_row ; Print first row.
      add eax,Peg_len ; Set eax to corresponding element of next peg.
      call Print_row ; Print second row.
      add eax,Peg_len ; Set eax to element of third peg.
      call Print_row ; Print 3rd row
      call print_nl ; Print newline.
      pop eax       ; Restore eax.
      ret           ; Return.

;-----------------------------------------------------------------------------
; Prints a base and a tab.
Print_base:
      mov eax,Peg_base ; Put peg base string in eax.
      call print_string ; Call C to print.
      mov eax,9     ; Put <TAB> ASCII value in eax
      call print_char ; Print <TAB>.
      ret           ; Return.
      
;-----------------------------------------------------------------------------
; Prints disc move in the format required by Dr. Franek's assignment outline.
Print_arrays:
      push eax      ; We use eax, so save it.
      mov eax,0     ; Initialize eax to zero.
.Loop:
      call Print_rows ; Print first rows.
      add eax,4     ; Let eax point at the next element.
      cmp eax,32    ; Check if eax points past 8th element.
      jb .Loop       ; If not, keep printing rows.
      call Print_base ; Print a base.
      call Print_base ; Print a second base.
      call Print_base ; Print a third base.
      call print_nl ; Print a newline.
      pop eax       ; Restore eax and return.
      ret

;-----------------------------------------------------------------------------
; Waits for <Enter> to be pressed, discarding other characters.
Wait_enter:
      call read_char ; Read a character.
      cmp eax,10    ; Compare read character with ASCII code for newline.
      jne Wait_enter ; Keep reading characters until a newline is found
      ret           ; Return.

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
; This function is the map loop of the program, and will print all the moves
; to complete the "Towers of Hanoi" problem for the given number of discs.
; Waits for the user to press <Enter> between moves.
; Takes the number of discs as an argument in eax.
Hanoi:
      push ebx      ; We will use ebx, ecx and edx, so save them.
      push ecx      ; ecx will hold the current number of discs.
      push edx      ; edx will hold temporary calculations.
      push ebp      ; ebp will be our "bottom of stack." Save it.
      mov ebp,esp   ; ebp will hold the original stack pointer value.
      push Peg1     ; Set "from" peg to Peg1. 
      push Peg3     ; Set "to" peg to Peg3.
      push eax      ; Push "n" discs.
.While:
      pop ecx       ; Pop "k discs" into ecx.
      pop ebx       ; Pop "to" peg into ebx.
      pop eax       ; Pop "from" peg into eax.
      cmp ecx,1     ; Check if number of discs == 1.
      jne .Else     ; If k != 1, replace stack with 3 smaller stacks.
      call Move_disc ; Move the 1 disc from its source to destination.
      call Wait_enter ; Wait for <Enter>.
      call Print_arrays ; Print the pegs.
      cmp esp,ebp   ; Check if stack is "empty." 
      je .Exit      ; If so exit the function.
      jmp .While    ; Repeat loop.
.Else:
      ; Replace current move on stack with 3 moves: first put k-1 discs
      ; from source to intermediate, then put kth disc from source to dest,
      ; then put k-1 discs from intermediate to dest.
      ; Third, push k-1 disks from intermediate peg (!= eax and != ebx) to 
      ; destination.
      call Find_mid ; Set edx to intermediate between eax and ebx.
      dec ecx       ; ecx = k-1.
      push edx      ; Push new "from" peg (intermediate).
      push ebx      ; Push new "to" peg (dest).
      push ecx      ; Push k-1.
      ; Push the move corresponding to moving the bottom disc from source to
      ; destination.
      push eax      ; Push source.
      push ebx      ; Push dest.
      push 1        ; Push number of discs = 1.
      ; First, Push the move meaning move the k-1 discs from the source peg to 
      ; the intermediate peg.
      push eax      ; Push source peg.
      push edx      ; Push intermediate peg
      push ecx      ; Push k-1.
      jmp .While    ; Repeat Hanoi function.
.Exit:
      pop ebp       ; Restore all registers and return.
      pop edx       
      pop ecx       
      pop ebx       
      ret

;-----------------------------------------------------------------------------
; The program enters here (asm_main is called from a main in asm_io.asm).
asm_main:
      enter 0,0     ; Enter the subroutine.
      pushad        ; Save all registers.
      call ArgcCheck ; Check that argc = 2 (one extra argument).
      call RangeCheck ; Check that n is in the range [2,8].
      call Init     ; Initialize Peg1 with correct discs.
      call Print_arrays ; Print initial peg set-up.
      call Hanoi    ; Solve the Towers of Hanoi puzzle.
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
