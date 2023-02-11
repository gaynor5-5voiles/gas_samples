### Use memory allocated in loop. ###


.section .bss


.type mem_size, @object


.lcomm mem_size, 8

.lcomm rerun, 1


.section .rodata


.equ USE_MEM_ALLOC_LOOP_BK_RBX_OFFS, -8
.equ USE_MEM_ALLOC_LOOP_BK_R12_OFFS, -0x10
.equ USE_MEM_ALLOC_LOOP_BK_R13_OFFS, -0x18
.equ USE_MEM_ALLOC_LOOP_BK_R14_OFFS, -0x20

.equ USE_MEM_ALLOC_LOOP_MEM_ALLOC_HD_MEM_SIZE_OFFS, -8
.equ USE_MEM_ALLOC_LOOP_MEM_ALLOC_HD_SIZE, 0x10


mem_size_in_msg:
    .ascii "Memory size to allocate: \0"
mem_size_in_form:
    .ascii "%lld\0"

mem_addr_out_form:
    .ascii "Allocated memory address: %p\n\0"

mem_out_form:
    .ascii "%s\n\0"

rerun_in_msg:
    .ascii "Rerun program? (Y/n): \0"
rerun_in_form:
    .ascii "\n%c\0"


.text


.globl main


.type main, @function


main:
    ### Program. ###

    pushq %rbp
    movq %rsp, %rbp
    subq $0x20, %rsp
    # Backup registers.
    movq %rbx, USE_MEM_ALLOC_LOOP_BK_RBX_OFFS(%rbp)
    movq %r12, USE_MEM_ALLOC_LOOP_BK_R12_OFFS(%rbp)
    movq %r13, USE_MEM_ALLOC_LOOP_BK_R13_OFFS(%rbp)

    # Set error return code.
    movq $-1, %r13

    use_mem_alloc_loop_loop:

        # Output memory size to allocate input message.
        movq stdout, %rdi
        leaq mem_size_in_msg, %rsi
        movq $0, %rax
        callq fprintf

        # Input memory size to allocate.
        movq stdin, %rdi
        leaq mem_size_in_form, %rsi
        leaq mem_size, %rdx
        movq $0, %rax
        callq fscanf

        # Allocate requested memory size.
        movq mem_size, %rdi
        callq mem_alloc
        # Check if error code returned.
        movq %rax, %rbx
        shl $1, %rbx
        cmovcq %r13, %rax
        jc main_ret
        movq %rax, %r12

        # Print allocated memory address.
        movq stdout, %rdi
        leaq mem_addr_out_form, %rsi
        movq %r12, %rdx
        movq $0, %rax
        callq fprintf

        # Set allocated memory.
        use_mem_alloc_loop_while_mem_set_setup:

            # Set allocated memory size.
            movq %r12, %rbx
            # Get allocated memory size.
            movq USE_MEM_ALLOC_LOOP_MEM_ALLOC_HD_MEM_SIZE_OFFS(%rbx), %rcx
            # Set allocated memory size to use.
            subq $USE_MEM_ALLOC_LOOP_MEM_ALLOC_HD_SIZE, %rcx
            # Leave space for null character.
            decq %rcx

        use_mem_alloc_loop_while_mem_set:

            # Set requested memory.
            movq $'a', (%rbx)

        use_mem_alloc_loop_while_mem_set_cntl:

            # Set next requested memory address.
            incq %rbx
            loopq use_mem_alloc_loop_while_mem_set

        use_mem_alloc_loop_while_mem_set_td:

            # Set null character.
            movq $0, (%rbx)

        # Print requested memory.
        movq stdout, %rdi
        leaq mem_out_form, %rsi
        movq %r12, %rdx
        movq $0, %rax
        callq fprintf

        # Free requested memory.
        movq %r12, %rdi
        callq mem_free

        callq use_mem_alloc_loop_rerun
        cmpq $-1, %rax
        cmoveq %r13, %rax
        je main_ret
        cmpq $1, %rax
        je use_mem_alloc_loop_loop

    movq $0, %rax

main_ret:

    # Set backed up registers.
    movq USE_MEM_ALLOC_LOOP_BK_RBX_OFFS(%rbp), %rbx
    movq USE_MEM_ALLOC_LOOP_BK_R12_OFFS(%rbp), %r12
    movq USE_MEM_ALLOC_LOOP_BK_R13_OFFS(%rbp), %r13
    movq %rbp, %rsp
    popq %rbp
    retq


use_mem_alloc_loop_rerun:
    ### Check if user wants to rerun program. ###

    pushq %rbp
    movq %rsp, %rbp
    subq $0x20, %rsp
    # Backup registers.
    movq %rbx, USE_MEM_ALLOC_LOOP_BK_RBX_OFFS(%rbp)
    movq %r12, USE_MEM_ALLOC_LOOP_BK_R12_OFFS(%rbp)
    movq %r13, USE_MEM_ALLOC_LOOP_BK_R13_OFFS(%rbp)
    movq %r14, USE_MEM_ALLOC_LOOP_BK_R14_OFFS(%rbp)

    # Set true, false return values.
    movq $1, %r13
    movq $0, %r14

    # Output rerun input message.
    movq stdout, %rdi
    leaq rerun_in_msg, %rsi
    movq $0, %rax
    callq fprintf

    # Input rerun.
    movq stdin, %rdi
    leaq rerun_in_form, %rsi
    leaq rerun, %rdx
    movq $0, %rax
    callq fscanf
    movb rerun, %r12b

    # Validate rerun.
    cmpb $'Y', %r12b
    cmoveq %r13, %rax
    je use_mem_alloc_loop_rerun_ret
    cmpb $'n', %r12b
    cmoveq %r14, %rax
    je use_mem_alloc_loop_rerun_ret
    movq $-1, %rax

use_mem_alloc_loop_rerun_ret:

    # Set backed up registers.
    movq USE_MEM_ALLOC_LOOP_BK_RBX_OFFS(%rbp), %rbx
    movq USE_MEM_ALLOC_LOOP_BK_R12_OFFS(%rbp), %r12
    movq USE_MEM_ALLOC_LOOP_BK_R13_OFFS(%rbp), %r13
    movq USE_MEM_ALLOC_LOOP_BK_R14_OFFS(%rbp), %r14
    movq %rbp, %rsp
    popq %rbp
    retq
