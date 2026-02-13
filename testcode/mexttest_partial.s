#  mp3-cp1.s version 3.0
.align 4
.section .text
.globl _start
_start:

	lw		x1, negmax
	lw		x2, negone
	div 	x3, x1, x2
	rem		x4, x1, x2

	lw		x1, pos1
	add		x2, x0, 0
	div 	x3, x1, x2
	divu	x4, x1, x2
	rem 	x5, x1, x2
	remu	x6, x1, x2

	lw		x1, neg2
	add		x2, x0, 0
	div 	x3, x1, x2
	divu	x4, x1, x2
	rem 	x5, x1, x2
	remu	x6, x1, x2

	lw x1, pos1
	lw x2, pos2
	nop
	nop
    mul 	x3, x1, x2
	mulhsu	x4, x1, x2
	mulhu	x5, x1, x2
	mulh	x6, x1, x2
	div 	x7, x1, x2
	rem 	x8, x1, x2
	divu	x9, x1, x2
	remu	x10, x1, x2
	nop

	lw x1, pos1
	lw x2, neg2
	nop
	nop
    mul 	x3, x1, x2
	mulhsu	x4, x1, x2
	mulhu	x5, x1, x2
	mulh	x6, x1, x2
	nop

	lw x1, neg1
	lw x2, pos2
	nop
	nop
    mul 	x3, x1, x2
	mulhsu	x4, x1, x2
	mulhu	x5, x1, x2
	mulh	x6, x1, x2
	divu	x7, x1, x2
	remu	x7, x1, x2
	nop

	lw x1, neg1
	lw x2, neg2
	nop
	nop
    mul 	x3, x1, x2
	mulhsu	x4, x1, x2
	mulhu	x5, x1, x2
	mulh	x6, x1, x2
	divu	x7, x1, x2
	remu	x7, x1, x2
	nop

	lw x1, pos1
	add x2, x0, 0
	nop
	nop
    mul 	x3, x1, x2
	mulhsu	x4, x1, x2
	mulhu	x5, x1, x2
	mulh	x6, x1, x2
	divu	x7, x1, x2
	remu	x7, x1, x2
	nop

	lw x2, neg2
	add x1, x0, 0
	nop
	nop
    mul 	x3, x1, x2
	mulhsu	x4, x1, x2
	mulhu	x5, x1, x2
	mulh	x6, x1, x2
	divu	x7, x1, x2
	remu	x7, x1, x2
	nop
	
    beq x0, x0, HALT
    nop
    nop
    nop
    nop
    nop
    nop
    nop

HALT:	
    beq x0, x0, HALT

.section .rodata
.balign 256
pos1:	.word 0x0350f008
pos2:	.word 0x50d70003
neg1:	.word 0xfffc8ffb
neg2:	.word 0xf3f12ffe
negmax:	.word 0x80000000
negone:	.word 0xffffffff

result: .word 0xdeadbeef
