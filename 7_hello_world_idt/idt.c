#include "idt.h"
#include "stdint.h"
#include "init.h"
#include "print.h"
#include "io.h"

# define IDT_DESC_CNT 0x21
# define PIC_M_CTRL 0x20
# define PIC_M_DATA 0x21
# define PIC_S_CTRL 0xa0
# define PIC_S_DATA 0xa1

// 门描述符
struct gate_desc {
    uint16_t func_offset_low_word;
    uint16_t selector;
    uint8_t dcount;
    uint8_t attribute;
    uint16_t func_offset_high_word;
};

struct idt_desc
{
    uint8_t num;
    char* name;     // 名称
    void* handler;  // 函数指针
};

void* idt_handler_table[IDT_DESC_CNT]; // 中断函数数组
static struct idt_desc idt_info[IDT_DESC_CNT]; // 中断数组
static struct gate_desc idt[IDT_DESC_CNT]; // idt
extern void* intr_entry_table[IDT_DESC_CNT]; // 定义在idt.asm

static void make_idt_desc(struct gate_desc* p_gdesc, uint8_t attr, void* function) {
    p_gdesc->func_offset_low_word = (uint32_t) function & 0x0000FFFF;
    p_gdesc->selector = SELECTOR_K_CODE;
    p_gdesc->dcount = 0;
    p_gdesc->attribute = attr;
    p_gdesc->func_offset_high_word = ((uint32_t) function & 0xFFFF0000) >> 16;
}

static void init_idt_desc() {
    for (int i = 0; i < IDT_DESC_CNT; i ++) {
        make_idt_desc(&idt[i], IDT_DESC_ATTR_DPL0, intr_entry_table[i]);
    }
}

static void make_idt_info(uint8_t num, char *name, void* function) {
    idt_info[num].name = name;
    idt_info[num].num = num;
    idt_info[num].handler = function;
    idt_handler_table[num] = function;
}

static void general_intr_handler(uint8_t vec_nr) {
    if (vec_nr == 0x27 || vec_nr == 0x2f) {
        // 伪中断，无需处理
        return;
    }

    put_str("int vector: 0x");
    put_int(vec_nr);
    put_str(" name: ");
    put_str(idt_info[vec_nr].name);
    put_char('\n');
}

static void init_idt_info() {
    make_idt_info(0, "#DE Divide Error", general_intr_handler);
    make_idt_info(1, "#DB Debug Exception", general_intr_handler);
    make_idt_info(2, "NMI Interrupt", general_intr_handler);
    make_idt_info(3, "#BP Breakpoint Exception", general_intr_handler);
    make_idt_info(4, "#OF Overflow Exception", general_intr_handler);
    make_idt_info(5, "#BR BOUND Range Exceeded Exception", general_intr_handler);
    make_idt_info(6, "#UD Invalid Opcode Exception", general_intr_handler);
    make_idt_info(7, "#NM Device Not Available Exception", general_intr_handler);
    make_idt_info(8, "#DF Double Fault Exception", general_intr_handler);
    make_idt_info(9, "Coprocessor Segment Overrun", general_intr_handler);
    make_idt_info(10, "#TS Invalid TSS Exception", general_intr_handler);
    make_idt_info(11, "#NP Segment Not Present", general_intr_handler);
    make_idt_info(12, "#SS Stack Fault Exception", general_intr_handler);
    make_idt_info(13, "#GP General Protection Exception", general_intr_handler);
    make_idt_info(14, "#PF Page-Fault Exception", general_intr_handler);
    make_idt_info(15, "Unknown", general_intr_handler);
    make_idt_info(16, "#MF 0x87 FPU Floating-Point Error", general_intr_handler);
    make_idt_info(17, "#AC Alignment Check Exception", general_intr_handler);
    make_idt_info(18, "#MC Machine-Check Exception", general_intr_handler);
    make_idt_info(19, "#XF SIMD Floating-Point Exception", general_intr_handler);
    for (uint8_t i = 20; i < IDT_DESC_CNT; i++) {
        make_idt_info(i, "Unknown", general_intr_handler);
    }
}

static void pic_init(void) {
    // 初始化主片
    outb(PIC_M_CTRL, 0x11);
    outb(PIC_M_DATA, 0x20);

    outb(PIC_M_DATA, 0x04);
    outb(PIC_M_DATA, 0x01);

    outb(PIC_S_CTRL, 0x11);
    outb(PIC_S_DATA, 0x28);

    outb(PIC_S_DATA, 0x02);
    outb(PIC_S_DATA, 0x01);

    outb(PIC_M_DATA, 0xfe);
    outb(PIC_S_DATA, 0xff);

    put_str("pic_init done.\n");
}

void init_idt() {
    init_idt_info();
    init_idt_desc();
    pic_init(); // 初始化8259A

    // 加载idt
    uint64_t idt_operand = ((sizeof(idt) - 1) | ((uint64_t) ((uint32_t) idt << 16)));
    asm volatile ("lidt %0" : : "m" (idt_operand));
    put_str("idt_init done.\n");
}