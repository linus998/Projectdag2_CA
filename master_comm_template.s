@ ARM program to do serial communication
@  This is the master
@ config GPIO pin 24 for output
@ config GPIO pin 23 for input
@ GPIOWrite	pin24, high	@ Tx high
@ delay 0.1 sec
@
@ repeat
@ printf ("Command >>")
@ scanf ("%d", &command)
@ if (command == 1)
@   send_byte (command)
@ elif (command == 2)
@   send_byte (command)
@   send_byte ('a')
@ elif (command == 3)
@   send_byte (command)
@   send_byte (32)
@   send_byte (23)
@   receive_byte () @ result in R0
@   printf (R0)
@ elif (command == 4)
@   <additional command here>
@ elif (command != 0)
@   printf ("fout commando\n")
@ until command == 0
@ R4: parameter printf ()
@ R4: command
@ R5: copy address str_buffer

.extern printf
.extern scanf

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
	GPIODirectionIn  pin23		@ GPIO23 is input

	GPIOWrite	pin24, high	@ Tx high
	setSleepTime	#0, #100000000	@ 0.1 sec
	doSleep				@ sleep

repeat:
	ldr		R0, =give_com	@ load address string
	bl		printf		@ call printf()
	ldr		R0, =f_str_i	@ format str
	ldr		R1, =command	@ address command
	bl		scanf		@ call scanf(,)
	ldr		R4, =command	@ load address command
	ldr		R4, [R4]	@ load command
	cmp		R4, #1		@ command cmp 1 ?

	@ hier code voor comando 1
	debug   R4

	bne		elif1		@ next option
	mov		R0, R4		@ parameter send_byte
	bl		send_byte	@ call send_byte()
	b		end_if		@ body done
elif1:
	cmp		R4, #2		@ command cmp 2 ?
	bne		elif2		@ next option

	@ hier code voor comando 2
	debug   R4

	b		end_if		@ body done
elif2:
	cmp		R4, #3		@ command cmp 3 ?
	bne		elif3		@ next option

	@ hier code voor comando 3
    debug   R4

	b		end_if		@ body done
elif3:
	cmp		R4, #4		@ command cmp 4 ?
	bne		elif4		@ next option

	@ hier code voor comando 2
	debug   R4
	
	b		end_if		@ body done
elif4:
	cmp		R4, #0		@ command cmp 0 ?
	beq		end_repeat	@ until (command == 0)
	ldr		R0, =fout_com	@ load address string
	bl		printf		@ call printf()
end_if:
	b		repeat		@ back to loop
end_repeat:
	mov		R0, #0		@ return code 0
	mov		R7, #1		@ exit
	svc		0		@ call Linux

.data
command: .space 4
pin23:	.asciz	"23"
pin24:	.asciz	"24"
low:	.asciz	"0"
high:	.asciz	"1"
pin_val: .asciz	"?"
f_str_i: .asciz "%d"
f_str_s: .asciz "%s"
fout_com: .asciz "fout commando\n"
give_com: .asciz "Command >>"
result: .asciz "Som is: %d\n"
str_buffer: .space 128
