.extern printf
.extern scanf

.include "Rx_Tx.s"

.text
.global main
main:
	GPIOExport	pin24					@ config GPIO24
	setSleepTime	#0, #100000000		@ 0.1 sec
	doSleep								@ sleep
	GPIODirectionOut  pin24				@ GPIO24 is output

	GPIOExport	pin23					@ config GPIO23
	setSleepTime	#0, #100000000		@ 0.1 sec
	doSleep								@ sleep
	GPIODirectionIn  pin23				@ GPIO23 is input

	GPIOWrite	pin24, high				@ Tx high
	setSleepTime	#0, #100000000		@ 0.1 sec
	doSleep								@ sleep

repeat:
	ldr		R0, =give_com	@ load address string
	bl		printf			@ call printf()
	ldr		R0, =f_str_i	@ format str
	ldr		R1, =command	@ address command
	bl		scanf			@ call scanf(,)
	ldr		R4, =command	@ load address command
	ldr		R4, [R4]		@ load command

	cmp		R4, #1			@ command cmp 1 ?
	debug   R4				@ debug command 1
	bne		elif1			@ next option
	mov		R0, R4			@ parameter send_byte
	bl		send_byte		@ call send_byte()
	b		get_answer		@ body done

elif1:
	cmp		R4, #2			@ command cmp 2 ?
	bne		elif2			@ next option
	debug   R4				@ debug command 2
	mov		R0, R4			@ parameter send_byte
	bl		send_byte		@ call send_byte()
	b		get_answer		@ body done

elif1:
	cmp		R4, #2			@ command cmp 2 ?
	bne		elif2			@ next option
	debug   R4				@ debug command 2
	mov		R0, R4			@ parameter send_byte
	bl		send_byte		@ call send_byte()
	b		get_answer		@ body done

elif2:
	cmp		R4, #3			@ command cmp 3 ?
	bne		elif3			@ next option
    debug   R4				@ debug command 3
	mov		R0, R4			@ parameter send_byte
	bl		send_byte		@ call send_byte()
	b		get_answer		@ body done

elif3:
	cmp		R4, #4			@ command cmp 4 ?
	bne		elif4			@ next option
	debug   R4				@ debug command 4
	mov		R0, R4			@ parameter send_byte
	bl		send_byte		@ call send_byte()
	b		end_repeat

elif4:
	cmp		R4, #0			@ command cmp 0 ?
	beq		end_repeat		@ until (command == 0)
	ldr		R0, =fout_com	@ load address string
	bl		printf			@ call printf()

end_repeat:
	mov		R0, #0			@ return code 0
	mov		R7, #1			@ exit
	svc		0				@ call Linux

get_answer:
	mov R0, #3
	bl receive_byte
	cmp R0, #1
	beq loser
	cmp R0, #2
	beq winner
	cmp R0, #3
	beq get_answer

loser:
	ldr R0, =str_buffer
	ldr R1, = "You lost!\n"
	bl printf
	b repeat

winner:
	ldr R0, =str_buffer
	ldr R1, = "You won!\n"
	bl printf
	b repeat

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
give_com: .asciz "Blad(1) Steen(2) Schaar(3) Exit(4) >>"
str_buffer: .space 128
