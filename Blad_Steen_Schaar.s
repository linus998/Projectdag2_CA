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
	b		exit			@ body done

elif4:
	cmp		R4, #0			@ command cmp 0 ?
	beq		exit			@ until (command == 0)
	ldr		R0, =fout_com	@ load address string
	bl		printf			@ call printf()

exit:
	mov		R0, #0			@ return code 0
	mov		R7, #1			@ exit
	svc		0				@ call Linux

get_answer:
	mov R0, #5				@ set byte standard
	bl receive_byte			@ call receive_byte()
	debug R0				@ debug received byte
	cmp R0, #1				@ compare with 1 (winner is player 1)
	beq loser				@ branch if lost
	cmp R0, #2				@ compare with 2 (winner is player 2)
	beq winner				@ branch if won
	cmp R0, #3				@ compare with 3 (draw)
	beq draw				@ branch if draw
	cmp R0, #4				@ compare with 4 (error)
	beq exit				@ exit program
	cmp R0, #5				@ compare with 5 (standard begin value)
	beq get_answer			@ branch if error, get new answer

loser:
	ldr		R0, =loser_str	@ load address string
	bl		printf			@ call printf()
	b 		repeat			@ back to loop

winner:
	ldr		R0, =winner_str	@ load address string
	bl		printf			@ call printf()
	b 		repeat			@ back to loop

draw:
	ldr		R0, =draw_str	@ load address string
	bl		printf			@ call printf()
	b 		repeat			@ back to loop

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
loser_str: .asciz "You lost!\n"
winner_str: .asciz "You won!\n"
draw_str: .asciz "Draw!\n"
str_buffer: .space 128
