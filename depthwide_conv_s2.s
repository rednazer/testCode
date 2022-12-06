;%define FLOAT_SIZE 0x04

lih r1, 0x0
lih r2, 0x0
lih r3, 0x0
lih r4, 0x0
lih r5, 0x0
lih r6, 0x0

lil r1, 0x4
lil r2, 0x4
lil r3, 0x4
lil r4, 0x4
lil r5, 0x7
lil r6, 0x20

bkpt 0x01
jal depthwise_convolution_stride2
bkpt 0x05

halt

;; Information we need
; r1 = Input_matrix (also output of current)		- location 1
; r2 = Output location for padded matrix			- location 2
; r3 = Output location for im2col					- location 3
; r4 = Filter input location						- location 4
; r5 = width of matrix (x and y)
; r6 = depth of matrix (z) (number of filters)
;
depthwise_convolution_stride2:
	;; Pad matrix
	; r1 = Location 1 (input)
	; r2 = Location 2 (ouptut)
	; r3 = width (x and y length)
	; r4 = depth (z length)
	
	; Reorganizes Registers for Padding
	; r1 <= r1; r2 <= r2; r3 <= r5; r4 <= r6
	and r3, r5, r5
	and r4, r6, r6
	
	; pad the matrix
	;push_stack_caller(padMatrix) ;;;; SKIP FOR TESTING
	bkpt 0x02 ; Instead print out context to determine is the correct

	;; For loop iterating through each z layer
	lih r9, 0x0000
	lil r9, 0x0000		; Z loop var
	
	layer_loop:
		;; im2col (stride 2 2d)
		; r1 = Location 2 + offset1 (input)
		; r2 = Location 3 + offset2 (output)
		; r3 = width (x and y) - pad matrix (width + 2)
		; r4 = num im2col columns - this is calculated from width (width/2 == width >> 1)
		; Reorganizes Registers for imTwoColStrideTwoTwoD
		;peek_stack()
		lih r1, 0x0
		lih r2, 0x0
		lih r3, 0x0
		lih r4, 0x0
		lih r5, 0x0
		lih r6, 0x0

		lil r1, 0x4
		lil r2, 0x4
		lil r3, 0x4
		lil r4, 0x4
		lil r5, 0x7
		lil r6, 0x20

		; r1 <= r2 + offset1; r2 <= r3 + offset2; r3 <= r5 + 2;
		; offset1 = (r5 * r5) * r9 * FLOAT_SIZE
		mul r12, r5, r5
		mul r12, r12, r9
		shli r12, r12, 0x02
		; offset2 = ((num im2col cols) * 9) * r9 * FLOAT_SIZE
		lih r13, 0x0000
		lil r13, 0x0009		; r13 = 9
		shli r13, r13, 0x02
		addi r16, r5, 0x02	; width (r16 = r5 + 2)
		shri r15, r16, 0x01	; num im2col cols (r15 = r16/2)
		mul r14, r15, r13
		mul r14, r14, r9
		
		; Assign input register values
		add r1, r2, r12
		add r2, r3, r14
		and r3, r16, r16
		and r4, r15, r15
		
		; reformat the data with im2col
		;push_stack_caller(imTwoColStrideTwoTwoD)
		bkpt 0x03
	
		;; MatMul
		; r1 = Location 4 (Input) - weights for A matrix (r4 + 9 * FLOAT_SIZE * r9)
		; r2 = Location 3 (Input) - data for B matrix (r3 + num im2col cols * 9 * FLOAT_SIZE * r9)
		; r3 = Location 1 (Output) - output matrix (r1 + r5 * r5 * FLOAT_SIZE)
		; r4 = width of matrix - common length (3x3 for filter size)
		; r5 = # cols for r1 (A matrix) - number of filters
		; r6 = # rows in r2 (B matrix) - number of im2col columns
		; TODO: REORGANIZE REGS FOR MatMul
		;peek_stack()
		lih r1, 0x0
		lih r2, 0x0
		lih r3, 0x0
		lih r4, 0x0
		lih r5, 0x0
		lih r6, 0x0

		lil r1, 0x4
		lil r2, 0x4
		lil r3, 0x4
		lil r4, 0x4
		lil r5, 0x7
		lil r6, 0x20

		lih r12, 0x0000
		lil r12, 0x0009
		shli r13, r12, 0x02
		mul r13, r13, r9		; 9 * FLOAT_SIZE * r9
		add r14, r4, r13		; r1 input
		
		addi r15, r5, 0x02
		shri r15, r15, 0x01		; num im2col cols
		mul r16, r15, r13
		add r16, r3, r16		; r2 input
		mul r17, r5, r5
		shli r17, r17, 0x02		; r5 * r5 * FLOAT_SIZE
		add r18, r1, r17		; r3 input
		
		; Assigns intermediates to regs to pass in
		and r1, r14, r14
		and r2, r16, r16
		and r3, r18, r17
		and r4, r12, r12
		and r5, r6, r6
		and r6, r15, 15
		
		; Do a matrix multiply
		;push_stack_caller(matmulmodule)
		bkpt 0x04
	
	;; Check loop condition
	; branch if r9 < r6 (r9-r6<0)
	addi r9, r9, 0x01
	sub r20, r9, r6
	blzi layer_loop
	
	; Return to caller function



