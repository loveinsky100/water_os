
; 定义一些常量，设置GDT的数据
; G 当为0时，长度单位就是字节，当为1时，长度单位就是4KB
G0 equ 0 << 23
G1 equ 1 << 23

; D/B 如果不做16位兼容，设置成1就行
D_B0 equ 0 << 22
D_B1 equ 1 << 22

; L 64位代码段标志
L32 equ 0 << 21
L64 equ 1 << 21

; AVL 通常给操作系统使用，处理器很少使用
AVL0 equ 0 << 20

DESC_LIMIT_CODE equ 1111b << 16
DESC_LIMIT_DATA equ DESC_LIMIT_CODE

; P 用来保存段是否存在于内存中的标志
P0 equ 0 << 15
P1 equ 1 << 15

; DPL 用来表示段的特权级别，从大到小分别是，0，1，2，3
DPL0 equ 0 << 14
DPL1 equ 01b << 13
DPL2 equ 10b << 13
DPL3 equ 11b << 13

; S 用来表示段的类型，0为系统段，1为代码/数据段
S0 equ 0 << 12
S1 equ 1 << 12

; TYPE 段的子权限, 执行/扩展/写/访问
TYPE_CODE equ 1000b << 8
TYPE_DATA equ 0010b << 8

; GDT定义
GDT_CODE equ (0x00 << 24) + G1 + D_B1 + L32 + AVL0 + DESC_LIMIT_CODE + P1 + DPL0 + S1 + TYPE_CODE + 0x00
GDT_DATA equ (0x00 << 24) + G1 + D_B1 + L32 + AVL0 + DESC_LIMIT_DATA + P1 + DPL0 + S1 + TYPE_DATA + 0x00