%include "boot.inc"
org LOADER_BASE_ADDR

jmp enter

; https://wiki.osdev.org/GDT_Tutorial
; 定义GDT的数据结构
; GDT一个8字节的容器，可以理解为一个int64的数组，每一个item存储一个int64
; 定义第一个描述符GDT信息，分别为两个int32，组成一个int64，第一个数据不会被使用，通常填充0
GDT_BASE: dd 0x00000000
          dd 0x00000000

; 第二个通常为内核代码段
; Base = 0
; Limit = 0xFFFFF
; Access Byte = 0x9A
; Flags = 0xC
KERNEL_CODE_BASE: dd 0x0000FFFF
                  dd GDT_CODE

; 第三为内核数据段
; Base = 0
; Limit = 0xFFFFF
; Access Byte = 0x92
; Flags = 0xC
KERNEL_DATA_BASE: dd 0x0000FFFF
                  dd GDT_DATA

; 文字显示段，0xb8000-0xbffff的内存地址就是显示器地址，往这里写数据就能直接输出
; 0xb8000 = 10111000000000000000
; 所以第一个32位为, 1000000000000000 + limit, limit = (0xbffff - 0xb8000) / 4k = 7
; 即: 10000000000000000000000000000111 = 0x80000007
; 另外GDT的高4位Limit则为：0x0000b
; 高16为基址则为：0000000000001011，再次拆分成00000000 + 00001011
; 最终基址则是：00000000000010111000000000000000
VIDEO_BASE: dd 0x80000007 ; 
            dd GDT_VIDEO ; 

; 获取总长度，即Offset
GDT_LENGTH equ $ - GDT_BASE ; 当前地址 - 起始地址
GDT_LIMIT equ GDT_LENGTH - 1

; 定义选择子，从第8位开始为KERNEL_CODE_BASE + 其他属性
SELECTOR_KERNEL_CODE equ (0x0001 << 3) + SELECTOR_TI_GDT + SELECTOR_RPL0
; 定义选择子，从第16位开始为KERNEL_DATA_BASE + 其他属性
SELECTOR_KERNEL_DATA equ (0x0002 << 3) + SELECTOR_TI_GDT + SELECTOR_RPL0
; 文本选择子，从第24位开始为VIDEO_BASE+ 其他属性
SELECTOR_VIDEO equ (0x0003 << 3) + SELECTOR_TI_GDT + SELECTOR_RPL0

; 构建GDT的48位结构，长度 & 起始地址
GTD_PRT dw GDT_LIMIT ; 总长度
        dd GDT_BASE ; 起始地址

loadermsg db 'loader in real then enter protected mode'

enter:
    ; 清屏
    mov ax, 0600h
    mov bx, 0700h
    mov cx, 0
    mov dx, 184fh
    int 10h

    ; 开始进入保护模式
    ; 载入到GTDR寄存器中
    lgdt [GTD_PRT]

    ; 当GDT载入到GDTR寄存器后，还需要打开cpu的保护模式，这样cpu才算切换完成。
    ; x86 cpu是通过设置CR0寄存器的PE位为1来进入保护模式。PE（Protection Enable）位在CR0的第1位（位0）。
    ; 保护模式
    mov eax, cr0            ; 读取cr0寄存器的信息
    or  eax, 0x00000001     ; 把第0位置为1
    mov cr0, eax            ; 回写到CR0寄存器

    ; 保护模式下使用选择子+函数地址
    jmp dword SELECTOR_KERNEL_CODE:hello_world

; 进入32位模式，最大寻址为4GB
[bits 32]
hello_world:
    ; 调整段寄存器
    mov ax, SELECTOR_KERNEL_DATA
    mov ds, ax

    mov es, ax
    mov ss, ax

    mov esp, LOADER_BASE_ADDR ; 栈地址
    mov ax, SELECTOR_VIDEO
    mov gs, ax

    ; 显示"PROTED"
    mov byte [gs:0], 'P'
    mov byte [gs:1], 0x1f
    mov byte [gs:2], 'R'
    mov byte [gs:3], 0x1f
    mov byte [gs:4], 'O'
    mov byte [gs:5], 0x1f
    mov byte [gs:6], 'T'
    mov byte [gs:7], 0x1f
    mov byte [gs:8], 'E'
    mov byte [gs:9], 0x1f
    mov byte [gs:10], 'D'
    mov byte [gs:11], 0x1f
    jmp $