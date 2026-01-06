@ Various macros to perform file I/O

@ The file descriptor parameter fd needs to be a register.
@ uses R0, R1, R7
@ return code is in R0

.equ	O_RDONLY,	0
.equ	O_WRONLY,	1
.equ	O_CREAT, 	0100
.equ	S_RDWR,		0666

.equ	sys_read, 	3	@ read from a file descriptor
.equ	sys_write, 	4	@ write to a file descriptor
.equ	sys_open, 	5	@ open and possibly create a file
.equ	sys_close, 	6	@ close a file descriptor
.equ	sys_fsync, 	118	@ sync a file in-core state with storage


.macro	openFile 	fileName, flags
	push	{R7}
	ldr	R0, =\fileName
	mov 	R1, #\flags
	ldr	R2, =S_RDWR 	@ Read/Write access rights
	mov	R7, #sys_open
	svc	0
	pop	{R7}
.endm

.macro	readFile	fd, buffer, length
	push	{R7}
	mov	R0, \fd			@ file descriptor
	ldr	R1, =\buffer
	mov	R2, \length
	mov	R7, #sys_read
	svc	0
	pop	{R7}
.endm

.macro  writeFile	fd, buffer, length
	push	{R7}
	mov	R0, \fd			@ file descriptor
	ldr	R1, =\buffer
	mov	R2, \length
	mov	R7, #sys_write
	svc	0
	pop	{R7}
.endm

.macro  flushClose 	fd
	push	{R7}
	mov	R0, \fd			@ file descriptor
	mov	R7, #sys_fsync
	svc	0
	mov	R0, \fd			@ file descriptor
	mov	R7, #sys_close
	svc	0
	pop	{R7}
.endm
