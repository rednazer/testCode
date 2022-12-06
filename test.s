bkpt 0x01
jal test_target
top:
	bkpt 0x03
	halt

test_target:
	bkpt 0x02
	lih r1, 0x0000
	lih r2, 0x0000
	lil r1, 0x0001
	lil r2, 0x0002
	sub r20, r1, r2 ; 1-2 < 0
	blzi top
	blei top
	;bnzi top
	sub r20, r2, r1 ; 2-1 > 0
	bgzi top
	bgei top
	sub r20, r1, r1 ; 1-1 == 0
	bezi top
	bkpt 0x04
	halt
