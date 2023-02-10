/* Use GNU Assembler memory allocator, memory freeing function. */


#include <stdio.h>
#include "gssrc_mem_alloc.h"


int main() {
    /* Main. */

    // Program.

    char *a1 = mem_alloc(500);
    char *a2 = mem_alloc(1000);
    char *a3 = mem_alloc(100);

    fprintf(stdout, "Memory allocations: %p, %p, %p.\n", a1, a2, a3);

    mem_free(a1);

    char *a4 = mem_alloc(1000);
    char *a5 = mem_alloc(250);
    char *a6 = mem_alloc(250);
    fprintf(stdout, "Memory allocations: %p, %p, %p, %p, %p, %p.\n", a1, a2, a3, a4, a5, a6);

    fscanf(stdin, "%249s", a5);
    fprintf(stdout, "%s\n", a5);

    // Teardown.

    mem_free(a1);
    mem_free(a2);
    mem_free(a3);
    mem_free(a4);
    mem_free(a5);
    mem_free(a6);

    return 0;
}
