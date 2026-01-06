@ ARM program to do serial communication
@ This is the slave
@ config GPIO pin 24 for output
@ config GPIO pin 23 for input
@ GPIOWrite	pin24, high	@ Tx high
@ delay 0.1 sec
@
@ while (true)
@    command = receive_byte()
@    if (command == 1)
@	printf ("%d\n", 1)
@    elif (command == 2)
@	param1 = receive_byte()
@	in_char = char(param1)
@	printf ("%s\n", in_char)
@    elif (command == 3)
@	param1 = receive_byte()
@	param2 = receive_byte()
@	delay 2 PERIOD (compensate for 2 stop bits)
@	res = param1 + param2
@	send_byte (res)		@ overflow ignored
@    elif (command == 4)
@	< additional command here >
@    else
@       printf ("%d\n", command)   @ for debugging
@ R0: parameter printf () and result receive_byte()
@ R4: command
@ R5: param1
@ R6: param2
@ R7: res

.extern printf
.include "Rx_Tx.s"

.text
.global main
main:
	GPIOExport	pin24		@ config GPIO24
	setSleepTime	#0, #100000000	@ 0.1 sec
	doSleep				@ sleep
	GPIODirectionOut  pin24		@ GPIO24 is output

	GPIOExport	pin23		@ config GPIO23
	setSleepTime	#0, #100000000	@ 0.1 sec
	doSleep				@ sleep
	GPIODirectionIn  pin23		@ GPIO23 is output

	GPIOWrite	pin24, high	@ Tx high
	setSleepTime	#0, #100000000	@ 0.1 sec
	doSleep				@ sleep

while:
	bl		receive_byte	@ call receive_byte
	mov		R4, R0		@ command = receive_byte()
	cmp		R4, #1		@ command cmp 1 ?
	bne		elif		@ command != 1
	ldr		R0, =f_str_i	@ address "%d\n"
	mov		R1, #1		@ 1
	bl		printf		@ call printf(,)
	b		end_if		@ body done
elif:
	cmp		R4, #2		@ command cmp 2 ?
	bne		elif2		@ command != 2
@ command 2
	b		end_if		@ body done
elif2:
	cmp		R4, #3		@ command cmp 3 ?
	bne		elif3		@ command != 3
@ command 3
	b		end_if		@ body done
elif3:
	cmp		R4, #4		@ command cmp 4 ?
	bne		elif4		@ command != 4
@ command 4
	b		end_if		@ body done
elif4:
	mov		R1, R0		@ printf (wrong) command
	ldr		R0, =f_str_i	@ for debug purposes
	bl		printf		@
end_if:
	b		while		@ back to loop
end_while:
	mov		R0, #0		@ return code 0
	mov		R7, #1		@ exit
	svc		0		@ call Linux

.data
pin23:	.asciz	"23"
pin24:	.asciz	"24"
low:	.asciz	"0"
high:	.asciz	"1"
pin_val: .asciz	"?"
f_str_c: .asciz "%c"
f_str_sn: .asciz "%s\n"
f_str_i: .asciz	"%d\n"
in_char: .asciz "?"
new_line: .asciz "\n"
