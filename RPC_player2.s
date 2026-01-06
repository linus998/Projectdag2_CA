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
    @ get input player 1
	bl		receive_byte	
	mov		R4, R0		    

    @ player 1 blad
	cmp		R4, #1		    
	bne		elif		    
	ldr		R0, =f_str_i	
	mov		R1, #1
    debug   R4	    

    @ get input player 2
    ldr     R0, =give_com   
    bl      printf

	ldr		R0, =f_str_i	    @ format str
	ldr		R1, =command	    @ address command
	bl		scanf		        @ call scanf(,)

    mov     R4, R0
    debug   R0

    @ player 2 blad
    cmp     R4, #1
    beq     tie
    @player 2 steen
    cmp     R4, #2
    beq     win_player_1 
    @player 2 schaar
    cmp     R4, #3 
    beq     win_player_2 

    @ anders naar volgende
	b		elif

elif:
    @player1 steen
	cmp		R4, #2
	bne		elif2
    debug   R4

    @ get input player 2
    ldr     R0, =give_com   
    bl      printf

   	ldr		R0, =f_str_i	    @ format str
	ldr		R1, =command	    @ address command
	bl		scanf		        @ call scanf(,)

    mov     R4, R0

    @ player 2 blad
    cmp     R4, #1
    beq     win_player_2
    @player 2 steen
    cmp     R4, #2
    beq     tie 
    @player 2 schaar
    cmp     R4, #3 
    beq     win_player_1 

    @ anders naar volgende
    b       elif2

elif2:
	@player1 schaar
	cmp		R4, #3
	bne		leave_program
    debug   R4

    @ get input player 2
    ldr     R0, =give_com   
    bl      printf

    ldr		R0, =f_str_i	    @ format str
	ldr		R1, =command	    @ address command
	bl		scanf		        @ call scanf(,)

    mov     R4, R0

    @ player 2 blad
    cmp     R4, #1
    beq     win_player_1
    @player 2 steen
    cmp     R4, #2
    beq     win_player_2 
    @player 2 schaar
    cmp     R4, #3 
    beq     tie 

    @ anders naar volgende
    b       leave_program

leave_program:
    @ end other program
    mov     R0, #4
    bl      send_byte

    @exit
    mov		R0, #0		@ return code 0
	mov		R7, #1		@ exit
	svc		0		    @ call Linux

end_if:
	b		while		@ back to loop

tie:
    mov     R0, #3
    bl      send_byte
    ldr     R0, =tie_str
    bl      printf
    b       while

win_player_1:
    mov     R0, #2
    bl      send_byte
    ldr     R0, =lose_str
    bl      printf
    b       while

win_player_2:
    mov     R0, #1
    bl      send_byte
    ldr     R0, =win_str
    bl      printf
    b       while

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
give_com: .asciz "Enter command: "
tie_str: .asciz "tie!!\n"
win_str: .asciz "You won!!\n"
lose_str: .asciz "You lost!!\n"
command: .space 4