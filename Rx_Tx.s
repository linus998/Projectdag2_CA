@ include file holding 
@ send_byte (out_byte) and byte receive_byte()
@

.include "gpiomacros2.s"

.equ	PERIOD, 10000000	@ 0.01 sec
.equ	HALF_PERIOD, 5000000	@ 0.005 sec

.text

@@@@@@@@@@@@@@@@@@@@@@@@@
@ send_byte (out_byte)
@ R0: out_byte
@ R4: b
@ R5: out_byte & (1 << b)
@ R6: copy out_byte
@
@ GPIOWrite	pin24, low	@ Tx low -- startbit
@ delay PERIOD
@ for (int b=0; b<8; b++)
@    if (out_byte & (1<<b))
@       GPIOWrite  pin24, high
@    else
@       GPIOWrite  pin24, low
@    delay PERIOD
@ GPIOWrite	pin24, high	@ Tx high -- stopbit
@ delay PERIOD
@ delay PERIOD

send_byte:
	push		{R4-R6, LR}	@ save Ri to stack
	mov		R6, R0		@ copy out_byte

	GPIOWrite	pin24, low	@ Tx low -- startbit
	setSleepTime	#0,#PERIOD	@ PERIOD sec
	doSleep				@ sleep

	mov		R4, #0		@ b = 0
send_for:
	cmp		R4, #8		@ b cmp 8 ?
	bge		send_endfor	@ b <= 8 -> end loop
	mov		R5, #1		@ R5 = 1
	lsl		R5, R5, R4	@ R5 = 1 << b
	ands		R5, R6, R5	@ R5 = out_byte & (1 << b)
					@ and set condition flags
	beq		send_else
	GPIOWrite	pin24, high	@ Tx high bit b
	b		send_endif
send_else:
	GPIOWrite	pin24, low	@ Tx low bit b
send_endif:
	setSleepTime	#0,#PERIOD	@ PERIOD sec
	doSleep				@ sleep
	add		R4, R4, #1	@ b++
	b		send_for	@ next iteration
send_endfor:

	GPIOWrite	pin24, high	@ Tx high -- stopbits
	setSleepTime	#0,#PERIOD	@ PERIOD sec
	doSleep				@ sleep 1st stopbit
	doSleep				@ sleep 2nd stopbit
	pop		{R4-R6, LR}	@ restore Ri from stack
	bx		LR


@@@@@@@@@@@@@@@@@@@@@@@@@
@ byte receive_byte ()
@ R0: return value
@ R1: pin_val
@ R4: b
@ R5: 1 << b
@ R6: in_byte
@ R7: start_bit
@
@ in_byte = 0
@ start_bit = false
@ while (!start_bit)
@    GPIORead	pin23, pin_val
@    if (pin_val == '0')
@	start_bit = true
@ delay HALF_PERIOD
@ for (int b=0; b<8; b++)
@    delay PERIOD
@    GPIORead	pin23, pin_val
@    if (pin_val == '1')
@	in_byte |= (1 << b)
@ delay PERIOD
@ return in_byte
receive_byte:
	push	{R4-R7, LR}	@ save Ri and LR to stack
	mov	R6, #0		@ in_byte = 0
	mov	R7, #0		@ start_bit = false
rec_while:
	cmp	R7, #1		@ start_bit cmp true ?
	beq	rec_end_while	@ start_bit == true
	GPIORead  pin23, pin_val
	ldr	R1, =pin_val	@ load address pin_val
	ldrb	R1, [R1]	@ load pin_val
	cmp	R1, #'0'	@ pin_val cmp '0' ?
	bne	rec_end_if	@ pin_val != '0'
	mov	R7, #1		@ start_bit = true
rec_end_if:
	b	rec_while	@ next iteration
rec_end_while:
 	setSleepTime #0,#HALF_PERIOD	@ HALF_PERIOD sec
	doSleep	 		@ sleep
	mov	R4, #0		@ b = 0
rec_for:
	cmp	R4, #8		@ b cmp 8 ?
	bge	rec_end_for	@ forloop done
 	setSleepTime #0,#PERIOD	@ PERIOD sec
	doSleep	 		@ sleep
	GPIORead  pin23, pin_val
	ldr	R1, =pin_val	@ load address pin_val
	ldrb	R1, [R1]	@ load pin_val
	cmp	R1, #'1'	@ pin_val cmp '1' ?
	bne	rec_end_if2	@ pin_val != '0'
	mov	R5, #1		@ R5 = 1
	lsl	R5, R5, R4	@ R5 = 1 << b
	orr	R6, R6, R5	@ in_byte |= (1 << b)
rec_end_if2:
	add	R4, R4, #1	@ b++
	b	rec_for		@ next iteration
rec_end_for:
 	setSleepTime #0,#PERIOD	@ PERIOD sec
	doSleep	 		@ sleep
	mov	R0, R6		@ return value = in_byte
	pop	{R4-R7, LR}	@ restore Ri and LR from stack
	bx	LR

