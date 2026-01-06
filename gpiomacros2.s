@ Various macros to access the GPIO pins
@ on the Raspberry Pi using a file device driver.
@
@ R11 - global register for file descriptor

.include "fileio.s"

.equ	sys_nanosleep,	162		@ high resolution sleep

@ Macro doSleep to sleep x sec
@ Calls Linux nanosleep service
@ R0 is time to sleep (in sec and nanosec)
@ R1 is time left to sleep if interrupted
.macro	doSleep
	push	{R7}
	ldr	R0, =timespecsec
	ldr	R1, =timespecsec
	mov	R7, #sys_nanosleep
	svc 	0
	pop	{R7}
.endm

@ Macro setSleepTime	timesec, timenanosec
@ set the timespecsec struct (timesec and timenanosec) to parameter values
.macro	setSleepTime	timesec, timenanosec
	push	{R7}
	ldr	R0, =\timesec
	ldr	R1, =\timenanosec
	ldr	R2, =timespecsec	@ R2 points to timespecsec
	str	R0, [R2],#4		@ set time sec and post index
	str	R1, [R2]		@ set time nanosec
	pop	{R7}
.endm

.macro	GPIOExport	pin
	openFile	gpioexp, O_WRONLY
	mov		R11, R0		@ save the file descriptor
	writeFile	R11, \pin, #2
	flushClose	R11
.endm

.macro	GPIODirectionOut	pin
	@ copy pin into filename pattern
	@ assumes a two-byte string as pin name, e.g. "18"
	push		{R7}
	ldr		R1, =\pin
	ldr		R2, =gpiopinfile
	add		R2, #20		@ index of 'xx' in gpioinfile name/string
	ldrb		R3, [R1], #1	@ load 1st char pin and post increment
	strb		R3, [R2], #1	@ store to filename (first 'x')
					@ and post increment
	ldrb		R3, [R1]	@ load 2nd char pin
	strb		R3, [R2]	@ store to filename (second 'x')
	openFile	gpiopinfile, O_WRONLY
	mov		R11, R0		@ save the file descriptor
	writeFile	R11, outstr, #3	@ write "out" to file
	flushClose	R11
	pop	{R7}
.endm

.macro	GPIODirectionIn	 pin
	@ copy pin into filename pattern
	@ assumes a two-byte string as pin name, e.g. "18"
	push		{R7}
	ldr		R1, =\pin
	ldr		R2, =gpiopinfile
	add		R2, #20		@ index of 'xx' in gpioinfile name/string
	ldrb		R3, [R1], #1	@ load 1st char pin and post increment
	strb		R3, [R2], #1	@ store to filename (first 'x')
					@ and post increment
	ldrb		R3, [R1]	@ load 2nd char pin
	strb		R3, [R2]	@ store to filename (second 'x')
	openFile	gpiopinfile, O_WRONLY
	mov		R11, R0		@ save the file descriptor
	writeFile	R11, instr, #2	@ write "in" to file
	flushClose	R11
	pop	{R7}
.endm

.macro	GPIOWrite	pin, value
	@ copy pin into filename pattern
	@ assumes a two-byte string as pin name, e.g. "12"
	push		{R7}
	ldr		R1, =\pin
	ldr		R2, =gpiovaluefile
	add		R2, #20		@ index of 'xx' in gpioinfile name/string
	ldrb		R3, [R1], #1	@ load 1st char pin and post increment
	strb		R3, [R2], #1	@ store to filename (first 'x')
					@ and post increment
	ldrb		R3, [R1]	@ load 2nd char pin
	strb		R3, [R2]	@ store to filename (first 'x')
	openFile	gpiovaluefile, O_WRONLY
	mov		R11, R0		@ save the file descriptor
	writeFile	R11, \value, #1	@ write high "1" or low "0" to file
	flushClose	R11
	pop		{R7}
.endm

.macro	GPIORead	pin, value
	@ copy pin into filename pattern
	@ assumes a two-byte string as pin name, e.g. "12"
	push		{R7}
	ldr		R1, =\pin
	ldr		R2, =gpiovaluefile
	add		R2, #20		@ index of 'xx' in gpioinfile name/string
	ldrb		R3, [R1], #1	@ load 1st char pin and post increment
	strb		R3, [R2], #1	@ store to filename (first 'x')
					@ and post increment
	ldrb		R3, [R1]	@ load 2nd char pin
	strb		R3, [R2]	@ store to filename (first 'x')
	openFile	gpiovaluefile, O_RDONLY
	mov		R11, R0		@ save the file descriptor
	readFile	R11, \value, #1	@ read high "1" or low "0" from file
	flushClose	R11
	pop		{R7}
.endm

@ Macro debug	Ri
@ print Ri to stdout
.macro  debug	Ri
	push	{R0-R3,LR}	@ save LR to stack
	mov	R1, \Ri		@ register to printf
	ldr	R0, =debugmsg	@ address debugmsg
	bl	printf		@ call printf()
	pop	{R0-R3,LR}	@ restore LR from stack
.endm

.data
timespecsec:	.word	0
timespecnano:	.word	500000000	@ 0.5 sec
gpioexp:	.asciz	"/sys/class/gpio/export"
gpiopinfile:	.asciz	"/sys/class/gpio/gpioxx/direction"	@ "xx" will be filled in macros
gpiovaluefile:	.asciz	"/sys/class/gpio/gpioxx/value"		@ "xx" will be filled in macros
outstr:		.asciz	"out"
instr:		.asciz	"in"
debugmsg:	.asciz	"debug... %d\n"
		.balign	4	@ avoid alignment issues for users including this file
