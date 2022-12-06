bkpt 0x01
jal test_target
bkpt 0x03
halt
halt
halt
halt
halt
halt
halt
test_target:
	bkpt 0x02
	jmpr r31, 0x00
	bkpt 0x04
	halt
