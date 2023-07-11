#include "print.h"
#include "idt.h"

int main(void) {
    put_str("Hello World\n");
    for (int i = 0; i<10; i++) {
        put_int(i);
    }

    put_str("\n");
    init_idt();

    asm volatile ("sti"); // 开启中断

    while (1);
    return 0;
}