; org 07c00h ;告诉编译器加载到07c00h处

BOOTSEG	equ	07c0h
	jmp BOOTSEG:start
start:
mov ax, cs
mov ds, ax
mov es, ax

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
BootMessge: db "hello, world!!!!!!!"
times 510 - ($ - $$) db 0
dw 0aa55h