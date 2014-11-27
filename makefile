# Makefile for Towers of Hanoi x86 assembly project
# Author: Brendan Duke
# Modified: November 25, 2014
sandbox: sandbox.o
	ld -o sandbox sandbox.o
sandbox.o: sandbox.asm
	nasm -f elf64 -g -F stabs sandbox.asm -l sandbox.lst

asm_io.o: asm_io.asm
	nasm -f elf32 -d ELF_TYPE asm_io.asm

hantow: hantow.o asm_io.o
	gcc -m32 -o hantow hantow.o driver.c asm_io.o
hantow.o: hantow.asm
	nasm -f elf32 -g -F stabs hantow.asm

clean:
	rm -f *.o *~ sandbox hantow
