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

    call setup_page

    mov byte [gs:12], '!'
    mov byte [gs:13], 0x1f


    ; 保存gdt表
    sgdt [GTD_PRT]

    ; 重新设置gdt描述符的信息， 使虚拟地址指向内核的第一个页表的内核地址上，即低位的1GB空间
    ; 0xc0000000 - 0xffffffff
    mov ebx, [GTD_PRT + 2] ; 数据段
    or dword [ebx + 0x18 + 4], 0xc0000000 ; 调整地址
    add dword [GTD_PRT + 2], 0xc0000000 ; 调整地址
    
    add esp, 0xc0000000 ; 调整栈地址

    ; 页目录基地址寄存器
    mov eax, PAGE_DIR_TABLE_POS
    mov cr3, eax

    ; 打开分页
    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax

    lgdt [GTD_PRT]
    mov byte [gs:160], 'V'
    jmp $

; 构建页表
setup_page:
    ; 页目录项需要1024个表项，一个4kb，即4096
    mov ecx, 4096
    mov esi, 0
; 初始化内存，循环置0，PAGE_DIR_TABLE_POS为页表存放位置，0x100000，即8kb位置
.clear_page:
    mov byte [PAGE_DIR_TABLE_POS + esi], 0
    inc esi
    loop .clear_page
; 创建页表
.create_pde:
    ; PAGE_DIR_TABLE_POS为存放地址
    mov eax, PAGE_DIR_TABLE_POS
    add eax, 0x1000 ; 位置增加4kb，即直接跳过目录表，当前地址则是第一个页表
    mov ebx, eax

     ; 设置页目录项属性
    or eax, PG_US_U | PG_RW_W | PG_P
    ; 设置第一个页目录项
    mov [PAGE_DIR_TABLE_POS], eax
    ; 第768(内核空间的第一个)个页目录项，与第一个相同，这样第一个和768个都指向低端4MB空间
    ; 768的来源是因为为了实现系统调用，需要将高1GB的内存给操作系统
    mov [PAGE_DIR_TABLE_POS + 0xc00], eax
    ; 最后一个表项指向自己，用于访问页目录本身
    sub eax, 0x1000
    ; 4096是总长度，4092则是最后一项
    mov [PAGE_DIR_TABLE_POS + 4092], eax

; 创建页表，此时ebx是第一个页表
    mov ecx, 256
    mov esi, 0
    mov edx, PG_US_U | PG_RW_W | PG_P
.create_pte:
    mov [ebx + esi * 4], edx
    add edx, 4096
    inc esi
    loop .create_pte

; 创建内核的其它PDE
    mov eax, PAGE_DIR_TABLE_POS
    add eax, 0x2000
    or eax, PG_US_U | PG_RW_W | PG_P
    mov ebx, PAGE_DIR_TABLE_POS
    mov ecx, 254
    mov esi, 769
.create_kernel_pde:
    mov [ebx + esi * 4], eax
    inc esi
    add eax, 0x1000
    loop .create_kernel_pde
    ret