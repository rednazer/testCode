; Setup mem

; Setup Regs

; Call padmatrix
bkpt 0x01
jal test_target
bkpt 0x06


;; Used for all convolutions that aren't pointwise convolutions
;; pads 1 layer of 0's around the x and y of the matrices
;; Moves the input and output as the program writes
; r1 = input_data start location
; r2 = output_data write location
; r3 = width of input data (x_len and y_len)
; r4 = number of filters (z_len)
padMatrix:
	
	lih r10, 0x00000	; Load 0 into a reg for padding
	lil r10, 0x00000
	vsplat 0b1111, v2, r10	; load 0s into v2 vector register
	
	lih r7, 0x00000		; Set up z loop var
	lil r7, 0x00000
	
	; Get the number of floats to push to array (ceil to nearest 4)
	addi r9, r3, 0x05	; (r3 + 2 + 3) >> 2 << 2
	shri r9, r9, 0x02
	shli r9, r9, 0x02
	
	;; For loop z layer starts
	padding_z_loop_start:
		
		bkpt 0x02

		lih r6, 0x00000		; init y loop var = 0
		lil r6, 0x00000
		
		;; Add full row of 0's at start array
		lih r5, 0x00000		; init zero loop var = 0
		lil r5, 0x00000
		padding_zero_loop_one_start:
			; Write zero vector to dest
			vsti 0b1111, [r2+0x00], v2
			addi r2, r2, 0x10
		addi r5, r5, 0x04
		sub r20, r5, r9		; (r5 - r9 < 0)
		blzi padding_zero_loop_one_start
		
		;; For loop y layer starts
		padding_y_loop_start:
			
			bkpt 0x03

			lih r5, 0x00000		; init x loop var = 0
			lil r5, 0x00000
			
			lih r17, 0x0000		; Initialize start of row to be 0
			lil r17, 0x0000
			
			padding_x_loop_start:
				
				bkpt 0x04

				; Pull vector: start + ((x val) + (ceil x len) * (y val) + (ceil x len) * (y len) * (z val)) * 0x04
				; Address: r1 + (r5 + r9 * r6 + r9 * r3 * r7) << 0x02
				mul r12, r9, r6			; r12=r9*r6
				mul r13, r9, r3
				mul r13, r13, r7		; r13=r9*r3*r7
				add r14, r5, r12
				add r14, r14, r13
				shli r14, r14, 0x02		; (r5 + r9 * r6 + r9 * r3 * r7) << 0x02
				vldr 0b1111, v1, [r1+r14]
				
				; Shift reg values right 1 (store V1.3 into reg)
				vindx r16, v1, 3
				vswizzle 0b1111, v1, v1, 0, 0, 1, 2
				
				; Write to prev reg val into V1.0
				vsplat 0b1000, v1, r17
				
				; Write to destination (destination increments as written to)
				vsti 0b1111, [r2+0x00], v1
				addi r2, r2, 0x10
				
				; new reg val into old reg val
				and r17, r16, r16
				
			; X loop branch conditionals (r5 - r9 < 4)
			addi r5, r5, 0x04
			sub r20, r5, r9
			subi r20, r20, 0x04
			blzi padding_x_loop_start
			
			bkpt 0x05

			;; Write last vector 
			; Pull vector
			mul r12, r9, r6			; r12=r9*r6
			mul r13, r9, r3
			mul r13, r13, r7		; r13=r9*r3*r7
			add r14, r5, r12
			add r14, r14, r13
			shli r14, r14, 0x02		; (r5 + r9 * r6 + r9 * r3 * r7) << 0x02
			vldr 0b1111, v1, [r1+r14]
			
			; Check number of remaining vals (width + 1) - (padded # floats - 4)
			; # left = r3 - r9 + 5
			sub r21, r3, r9
			addi r21, r21, 0x05			; Between 0-3
			
			; If 0, then write whole vector of 0's (we have r10 = 0)
			subi r20, r21, 0x00
			bgzi, padding_one
			vsplat 0b1111, v1, r10		; vector of zeros
			jmp padding_end_of_row
			
			; If 1, then write V1.0=r17, V1.234=0
			padding_one:
				subi r20, r21, 0x01
				bgzi, padding_two
				vsplat 0b1000, v1, r17
				vsplat 0b0111, v1, r10
				jmp padding_end_of_row
				
			; If 2, then write V1.0=r17, V1.1 <- V1.0, V1.23 = 0
			padding_two:
				subi r20, r21, 0x01
				bgzi, padding_three
				vswizzle 0b1111, v1, v1, 0, 0, 1, 2
				vsplat 0b1000, v1, r17
				vsplat 0b0011, v1, r10
				jmp padding_end_of_row
			
			; If 3, then write V1.0=r17, V1.1 <- V1.0, V1.2 <- V1.1, V1.3 = 0
			padding_three:
				vswizzle 0b1111, v1, v1, 0, 0, 1, 2
				vsplat 0b1000, v1, r17
				vsplat 0b0011, v1, r10
				
			padding_end_of_row:
				vsti 0b1111, [r2+0x00], v1
				addi r2, r2, 0x10
				
		; Y loop branch conditionals (r6 - r3 < 0)
		addi r6, r6, 0x01
		sub r20, r6, r3
		blzi padding_y_loop_start
		
		;; Add full row of 0's at end array
		lih r5, 0x00000		; init zero loop var = 0
		lil r5, 0x00000
		padding_zero_loop_two_start:
			; Write zero vector to dest
			vsti 0b1111, [r2+0x00], v2
			addi r2, r2, 0x10
		addi r5, r5, 0x04
		sub r20, r5, r9		; (r5 - r9 < 0)
		blzi padding_zero_loop_two_start
		
	; Z loop branch conditionals (r7 - r4 < 0)
	addi r7, r7, 0x01
	sub r20, r7, r4
	blzi padding_z_loop_start