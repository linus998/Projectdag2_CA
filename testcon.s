.text
.global loop
loop:
    mov     r0, #0x55
    bl      send_byte
    b       loop