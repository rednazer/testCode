; r30 = sp
; r31 = lr

lih r30, 0x0
lil r30, 0x1f4
addi r1, r1, 0x02
addi r2, r1, 0x02
addi r3, r1, 0x02
addi r4, r1, 0x02
addi r5, r1, 0x02
addi r6, r1, 0x02
addi r7, r1, 0x02
addi r8, r1, 0x02
addi r9, r1, 0x02
addi r10, r1, 0x02

bkpt 0x01
jal call_function		; Jump to call function
bkpt 0x03

halt

call_function:
	; Add function to stack
	addi r30, r30, -0x58
	st36 [r30+0x00], r1
	st36 [r30+0x08], r2
	st36 [r30+0x10], r3
	st36 [r30+0x18], r4
	st36 [r30+0x20], r5
	st36 [r30+0x28], r6 
	st36 [r30+0x30], r7
	st36 [r30+0x38], r8
	st36 [r30+0x40], r9
	st36 [r30+0x48], r10
	st36 [r30+0x50], r31

	; Change vals
	addi r1, r1, 0x02
	addi r2, r1, 0x02
	addi r3, r1, 0x02
	addi r4, r1, 0x02
	addi r5, r1, 0x02
	addi r6, r1, 0x02
	addi r7, r1, 0x02
	addi r8, r1, 0x02
	addi r9, r1, 0x02
	addi r10, r1, 0x02

	bkpt 0x02

	; Return from function
	ld36 r1, [r30+0x00]
	ld36 r2, [r30+0x08]
	ld36 r3, [r30+0x10]
	ld36 r4, [r30+0x18]
	ld36 r5, [r30+0x20]
	ld36 r6, [r30+0x28]
	ld36 r7, [r30+0x30]
	ld36 r8, [r30+0x38]
	ld36 r9, [r30+0x40]
	ld36 r10, [r30+0x48]
	ld36 r31, [r30+0x50]
	addi r30, r30, 0x58
	jmpr r31, 0x00

