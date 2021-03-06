;
; The GDT
;
; boot.asm
;

; Set Program Origin
[org 0x7C00]

; 16-bit Mode
[bits 16]

; Initialize the base pointer and the stack pointer
; The initial values should be fine for what we've done so far,
; but it's better to do it explicitly
mov bp, 0x0500
mov sp, bp

; Before we do anything else, we want to save the ID of the boot
; drive, which the BIOS stores in register dl. We can offload this
; to a specific location in memory
mov byte[boot_drive], dl

; Print Message
mov bx, msg_hello_world
call print_bios

; Load the next sector

; The first sector's already been loaded, so we start with the second sector
; of the drive. Note: Only bl will be used
mov bx, 0x0002

; We only want to load one sector from the disk for now. This will
; be higher later. Note: Only cl will be used
mov cx, 0x0001

; Finally, we want to store the new sector immediately after the first
; loaded sector, at adress 0x7E00. This will help a lot with jumping between
; different sectors of the bootloader.
mov dx, 0x7E00

; Now we're fine to load the new sectors
call load_bios

; We should now be able to read the loaded string
mov bx, loaded_msg
call print_bios

; Infinite Loop
bootsector_hold:
jmp $               ; Infinite loop

; INCLUDES
%include "real_mode/print.asm"
%include "real_mode/print_hex.asm"
%include "real_mode/load.asm"
%include "real_mode/gdt.asm"

; DATA STORAGE AREA

; String Message
msg_hello_world:                db `\r\nHello World, from the BIOS!\r\n`, 0

; Boot drive storage
boot_drive:                     db 0x00

; Pad boot sector for magic number
times 510 - ($ - $$) db 0x00

; Magic number
dw 0xAA55

bootsector_extended:

loaded_msg:                     db `\r\nNow reading from the next sector!`, 0

; Fill with zeros to the end of the sector
times 512 - ($ - bootsector_extended) db 0x00
bu: