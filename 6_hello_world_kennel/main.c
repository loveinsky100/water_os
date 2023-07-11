#include "print.h"
#include <stdio.h>

int main(void) {
    put_str("Hello World\n");
    for (int i = 0; i<10; i++) {
        put_int(i);
    }

    while (1);
    return 0;
}