### Free memory. ###


.section .bss


.lcomm mem_free_mem, 0x18


.section .rodata


.equ MEM_FREE_MEM_HD_SIZE, 0x10
.equ MEM_FREE_MEM_HD_MEM_OCC_OFFS, 0
.equ MEM_FREE_MEM_HD_MEM_SIZE_OFFS, 8

.equ MEM_FREE_MEM_SIZE, 0x18


.text


.globl main
.globl mem_free


.type main, @function
.type mem_free, @function


main:
    ### Test freeing memory. ###

    pushq %rbp
    movq %rsp, %rbp

    leaq mem_free_mem, %rdi
    movq $1, MEM_FREE_MEM_HD_MEM_OCC_OFFS(%rdi)
    movq $MEM_FREE_MEM_SIZE, MEM_FREE_MEM_HD_MEM_SIZE_OFFS(%rdi)
    movq $'a', MEM_FREE_MEM_HD_SIZE(%rdi)
    addq $MEM_FREE_MEM_HD_SIZE, %rdi
    callq mem_free

    movq $0, %rax

main_ret:

    movq %rbp, %rsp
    popq %rbp
    retq


mem_free:
    ### Free memory. ###

    pushq %rbp
    movq %rsp, %rbp

    # Free memory.
    movq $0, MEM_FREE_MEM_HD_MEM_OCC_OFFS - MEM_FREE_MEM_HD_SIZE(%rdi)

    movq $0, %rax

mem_free_ret:

    movq %rbp, %rsp
    popq %rbp
    retq
