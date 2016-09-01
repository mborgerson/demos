;
; Matt Borgerson, 2016
;
; tinyelf
; =======
; This is an example of how to create a very minimal (but still valid) ELF
; executable using nothing but an assembler (NASM). No system linker required.
;

LOAD_ADDRESS equ 0x8048000
org LOAD_ADDRESS

elf_header:
.e_ident:
.e_ident_EI_MAG0:       db 0x7f, "ELF"
.e_ident_EI_CLASS:      db 0x01 ; 0x01 = ELFCLASS32 (32-bit objects)
.e_ident_EI_DATA:       db 0x01 ; 0x01 = ELFDATA2LSB (Little Endian)
.e_ident_EI_VERSION:    db 0x01 ; 0x01 = EV_CURRENT (ELF version 1)
.e_ident_EI_OSABI:      db 0x00 ; 0x00 = ELFOSABI_NONE
.e_ident_EI_ABIVERSION: db 0x00 ; (N/A)
.e_ident_EI_PAD:        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.e_type:                dw 0x02 ; 0x02 = ET_EXEC (Executable file)
.e_machine:             dw 0x03 ; 0x03 = EM_386 (Intel 80386)
.e_version:             dd 0x01 ; 0x01 = EV_CURRENT (ELF version 1)
.e_entry:               dd _start
.e_phoff:               dd PHOFF
.e_shoff:               dd SHOFF
.e_flags:               dd 0x00000000
.e_ehsize:              dw EHSIZE
.e_phentsize:           dw PHENTSIZE
.e_phnum:               dw PHNUM
.e_shentsize:           dw SHENTSIZE
.e_shnum:               dw SHNUM
.e_shstrndx:            dw SHSTRNDX
EHSIZE equ $-elf_header

; Program Headers
; ---------------
PHENTSIZE equ 0x0020
PHOFF     equ elf_program_headers-elf_header
elf_program_headers:
.p_type:                dd 0x00000001 ; PT_LOAD
.p_offset:              dd 0x00000000 ; Start of file
.p_vaddr:               dd LOAD_ADDRESS
.p_paddr:               dd LOAD_ADDRESS
.p_filesz:              dd IMAGE_SIZE
.p_memsz:               dd IMAGE_SIZE
.p_flags:               dd 0x00000005 ; 0x1 = Execute + 0x4 = Read
.p_align:               dd 0x00000010 ; 16-byte aligned
PHNUM equ ($-elf_program_headers)/PHENTSIZE

; Section Headers
; ---------------
SHENTSIZE equ 0x0028
SHOFF     equ 0x0000 ; No section table
SHNUM     equ 0x0000 ; No section headers
SHSTRNDX  equ 0x0000 ; No string table

; Start of Program Code
; ---------------------
message: db `TINYELFDEMO\n`
message_len equ $-message

align 16
bits 32

_start:
	; Print a message via the sys_write syscall
	;   - eax to 4 (sys_write)
	;   - ebx to 1 (stdout)
	;   - ecx to message address
	;   - edx to message length
	xor eax, eax                 ; 2 bytes
	mov al, 4                    ; 2 bytes
	xor ebx, ebx                 ; 2 bytes
	inc ebx                      ; 1 byte
	mov ecx, message             ; 5 bytes
	lea edx, [ebx-1+message_len] ; 3 bytes
	int 0x80                     ; 2 bytes

	; Exit the program via the sys_exit syscall
	;   - eax to 1 (sys_exit, assume sys_write successful and eax=message_len)
	;   - ebx to 0 (assume ebx=1)
	sub al, (message_len-1)      ; 2 bytes
	dec ebx                      ; 1 byte
	int 0x80                     ; 2 bytes

IMAGE_SIZE equ $-elf_header
