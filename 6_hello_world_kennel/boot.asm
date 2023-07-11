org 07c00h ;告诉编译器加载到07c00h处

mov ax, cs
mov ds, ax
mov es, ax

; 从0x900开始，读取4个扇区
mov eax, 0x2
mov ebx, 0x900
mov cx, 4
call rd_disk_m_16

; 直接跳到loader的起始代码执行
jmp 0x900

;-----------------------------------------------------------
; eax=LBA扇区号
; ebx=将数据写入的内存地址
; ecx=读入的扇区数
rd_disk_m_16:
;-----------------------------------------------------------

    mov esi, eax
    mov di, cx

    mov dx, 0x1f2
    mov al, cl
    out dx, al

    mov eax, esi

    mov dx, 0x1f3
    out dx, al

    mov cl, 8
    shr eax, cl
    mov dx, 0x1f4
    out dx, al

    shr eax, cl
    mov dx, 0x1f5
    out dx, al

    shr eax, cl
    and al, 0x0f
    or al, 0xe0
    mov dx, 0x1f6
    out dx, al

    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

.not_ready:
    nop
    in al, dx
    and al, 0x88
    cmp al, 0x08
    jnz .not_ready

    mov ax, di
    mov dx, 256
    mul dx
    mov cx, ax
    mov dx, 0x1f0

.go_on_read:
    in ax, dx
    mov [bx], ax
    add bx, 2
    loop .go_on_read
    ret

    times 510-($-$$) db 0
    db 0x55, 0xaa
