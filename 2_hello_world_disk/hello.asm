org 0x9000 ; 0x7c00
jmp start
start:
    mov ax, cs
    mov ds, ax
    mov es, ax

; 清屏
;---------------------------------------------------
    mov ax, 0600h
    mov bx, 0700h
    mov cx, 0
    mov dx, 184fh
    int 10h

call DispStr ;调用显示字符串函数

jmp $; 无限循环

DispStr:
    mov ax, BootMessge
    mov bp, ax
    mov cx, 16
    mov ax, 01301h
    mov bx, 000ch
    mov dl, 0
    int 10h
    ret
    
BootMessge: db "hello, disk!!!!!"