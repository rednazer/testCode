nop
nop
nop
nop
nop
nop
nop
nop
nop
bkpt 0x01
jal test_target
bkpt 0x03
nop
nop
nop
nop
nop
halt
nop
nop
nop
nop
nop
nop
nop
test_target:
	nop
	nop
	bkpt 0x02
	jmpr r31, 0x00
	
