LOADER_BASE_ADDR equ 0x900

; ; 定义一些常量，设置GDT的数据
; ; G 当为0时，长度单位就是字节，当为1时，长度单位就是4KB
; G0 equ 000000000000000000000000b
; G1 equ 100000000000000000000000b

; ; D/B 如果不做16位兼容，设置成1就行
; D_B0 equ 00000000000000000000000b
; D_B1 equ 10000000000000000000000b

; ; L 64位代码段标志
; L32 equ 0000000000000000000000b
; L64 equ 1000000000000000000000b

; ; AVL 通常给操作系统使用，处理器很少使用
; AVL0 equ 000000000000000000000b

; DESC_LIMIT_CODE equ 11110000000000000000b
; DESC_LIMIT_DATA equ 11110000000000000000b
; DESC_LIMIT_VIDEO equ 00000000000000000000000000001011b

; ; P 用来保存段是否存在于内存中的标志
; P0 equ 0000000000000000b
; P1 equ 1000000000000000b

; ; DPL 用来表示段的特权级别，从大到小分别是，0，1，2，3
; DPL0 equ 000000000000000b
; DPL1 equ 010000000000000b
; DPL2 equ 100000000000000b
; DPL3 equ 110000000000000b

; ; S 用来表示段的类型，0为系统段，1为代码/数据段
; S0 equ 0000000000000b
; S1 equ 1000000000000b

; ; TYPE 段的子权限, 执行/扩展/写/访问
; TYPE_CODE equ 100000000000b
; TYPE_DATA equ 001000000000b


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
DESC_LIMIT_VIDEO equ 0000b << 16

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
GDT_CODE    equ    G1 + D_B1 + L32 + AVL0 + DESC_LIMIT_CODE + P1 + DPL0 + S1 + TYPE_CODE + 0x00
GDT_DATA    equ    G1 + D_B1 + L32 + AVL0 + DESC_LIMIT_DATA + P1 + DPL0 + S1 + TYPE_DATA + 0x00
GDT_VIDEO   equ    G1 + D_B1 + L32 + AVL0 + DESC_LIMIT_VIDEO + P1 + DPL0 + S1 + TYPE_DATA + 00001011b

; 定义选择子的常量
SELECTOR_TI_GDT equ 000b
SELECTOR_TI_LDT equ 100b
SELECTOR_RPL0 equ 00b
SELECTOR_RPL1 equ 01b
SELECTOR_RPL2 equ 10b
SELECTOR_RPL3 equ 11b

; 页表存放地址
PAGE_DIR_TABLE_POS equ 0x100000

; 页表相关属性
PG_P equ 1b
PG_RW_R equ 00b
PG_RW_W equ 10b
PG_US_S equ 000b
PG_US_U equ 100b