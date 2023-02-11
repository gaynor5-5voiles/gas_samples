### Allocate, free memory. ###


.section .bss


# Allocated memory low address.
.lcomm mem_alloc_mem_low_addr, 8
# Allocated memory high address.
.lcomm mem_alloc_mem_high_addr, 8


.section .rodata


.type MEM_ALLOC_RBX_OFFS, @object
.type MEM_ALLOC_R12_OFFS, @object
.type MEM_ALLOC_R13_OFFS, @object
.type MEM_ALLOC_R14_OFFS, @object
.type MEM_ALLOC_R15_OFFS, @object

.type MEM_ALLOC_BRK_SYSC, @object


.equ MEM_ALLOC_RBX_OFFS, -8
.equ MEM_ALLOC_R12_OFFS, -0x10
.equ MEM_ALLOC_R13_OFFS, -0x18
.equ MEM_ALLOC_R14_OFFS, -0x20
.equ MEM_ALLOC_R15_OFFS, -0x28

.equ MEM_ALLOC_BRK_SYSC, 0xc

.equ MEM_ALLOC_MEM_ALIGN_SH, 0x3c
.equ MEM_ALLOC_MEM_ALIGN_BITMAP, 0b1111

.equ MEM_ALLOC_MEM_HD_SIZE, 0x10
.equ MEM_ALLOC_MEM_HD_MEM_OCC_OFFS, 0
.equ MEM_ALLOC_MEM_HD_MEM_SIZE_OFFS, 8


.text


.globl mem_alloc
.globl mem_free


.type mem_alloc, @function
.type mem_free, @function


mem_alloc:
    ### Allocate memory. ###

    pushq %rbp
    movq %rsp, %rbp
    subq $0x30, %rsp
    # Backup registers.
    movq %rbx, MEM_ALLOC_RBX_OFFS(%rbp)
    movq %r12, MEM_ALLOC_R12_OFFS(%rbp)
    movq %r13, MEM_ALLOC_R13_OFFS(%rbp)
    movq %r14, MEM_ALLOC_R14_OFFS(%rbp)
    movq %r15, MEM_ALLOC_R15_OFFS(%rbp)

    # Set error return code.
    movq $-1, %r15

    movq %r15, %rax
    # Validate requested size.
    cmpq $0, %rdi
    je mem_alloc_ret
    movq %rdi, %rbx
    shlq $1, %rbx
    jc mem_alloc_ret

    mem_alloc_while_mem_alloc_setup:

        # Set allocated memory low address.
        movq mem_alloc_mem_low_addr, %r12

        # Set allocated memory high address.
        movq mem_alloc_mem_high_addr, %r13

        # Add memory header size to requested memory amount.
        addq $MEM_ALLOC_MEM_HD_SIZE, %rdi
        # Align requested memory amount.
        callq mem_alloc_mem_align
        # Set requested memory amount.
        movq %rax, %r14

    mem_alloc_while_mem_alloc:

        # Check if allocated memory low address is less than 0.
        cmpq $0, %r12
        # Return error code.
        cmovbq %r15, %rax
        jb mem_alloc_ret

        # Check if allocated memory high address is less than 0.
        cmpq $0, %r13
        # Return error code.
        cmovbq %r15, %rax
        jb mem_alloc_ret

        # Check if allocated memory high address is less than allocated
        # memory low address.
        cmpq %r12, %r13
        # Return error code.
        cmovbq %r15, %rax
        jb mem_alloc_ret
        # Check if allocated memory low address is equal to allocated
        # memory high address.
        # Teardown.
        je mem_alloc_while_mem_alloc_td

        # Check if memory address is occupied.
        cmpq $0, MEM_ALLOC_MEM_HD_MEM_OCC_OFFS(%r12)
        # Check next memory address.
        jne mem_alloc_while_mem_alloc_cntl
        # Check if memory address fits request memory amount.
        cmpq %r14, MEM_ALLOC_MEM_HD_MEM_SIZE_OFFS(%r12)
        jb mem_alloc_while_mem_alloc_cntl
        # Set memory address as occupied.
        movq $1, MEM_ALLOC_MEM_HD_MEM_OCC_OFFS(%r12)
        # Set allocated memory address.
        addq $MEM_ALLOC_MEM_HD_SIZE, %r12
        movq %r12, %rax
        jmp mem_alloc_ret

    mem_alloc_while_mem_alloc_cntl:

        # Check next memory address.
        addq MEM_ALLOC_MEM_HD_MEM_SIZE_OFFS(%r12), %r12
        jmp mem_alloc_while_mem_alloc

    mem_alloc_while_mem_alloc_td:

        mem_alloc_while_mem_alloc_td_init:

            # Check if allocated memory low, high addresses are eqeual
            # to 0.
            cmpq $0, %r12
            # Teardown.
            jne mem_alloc_while_mem_alloc_td_td

            # Get allocated memory break address.
            movq $MEM_ALLOC_BRK_SYSC, %rax
            movq $0, %rdi
            syscall
            # Set allocated memory low, high addresses.
            movq %rax, mem_alloc_mem_low_addr
            movq %rax, %r12
            movq %rax, %r13

        mem_alloc_while_mem_alloc_td_td:

            # Set allocated memory break address.
            addq %r14, %r13
            movq $MEM_ALLOC_BRK_SYSC, %rax
            movq %r13, %rdi
            syscall

            # Set allocated memory high address.
            movq %r13, mem_alloc_mem_high_addr

            # Set allocated memory header.
            movq $1, MEM_ALLOC_MEM_HD_MEM_OCC_OFFS(%r12)
            movq %r14, MEM_ALLOC_MEM_HD_MEM_SIZE_OFFS(%r12)

            # Set allocated memory address.
            addq $MEM_ALLOC_MEM_HD_SIZE, %r12
            # Return allocated memory address.
            movq %r12, %rax

mem_alloc_ret:

    # Set backed up registers.
    movq MEM_ALLOC_RBX_OFFS(%rbp), %rbx
    movq MEM_ALLOC_R12_OFFS(%rbp), %r12
    movq MEM_ALLOC_R13_OFFS(%rbp), %r13
    movq MEM_ALLOC_R14_OFFS(%rbp), %r14
    movq MEM_ALLOC_R15_OFFS(%rbp), %r15
    movq %rbp, %rsp
    popq %rbp
    retq


mem_alloc_mem_align:
    ### Align request memory. ###

    pushq %rbp
    movq %rsp, %rbp
    subq $0x20, %rsp
    # Backup registers.
    movq %rbx, MEM_ALLOC_RBX_OFFS(%rbp)
    movq %r12, MEM_ALLOC_R12_OFFS(%rbp)
    movq %r13, MEM_ALLOC_R13_OFFS(%rbp)

    # Get requested memory align bits.
    movq %rdi, %rbx
    shlq $MEM_ALLOC_MEM_ALIGN_SH, %rbx
    shrq $MEM_ALLOC_MEM_ALIGN_SH, %rbx

    # Check if requested memory is aligned.
    movq $MEM_ALLOC_MEM_ALIGN_BITMAP, %r12
    movq $MEM_ALLOC_MEM_ALIGN_BITMAP, %r13
    subq %rbx, %r12
    cmpq %r12, %r13
    # Requested memory is aligned.
    cmoveq %rdi, %rax
    je mem_alloc_mem_align_ret

    # Align memory.
    addq %r12, %rdi
    incq %rdi
    movq %rdi, %rax

mem_alloc_mem_align_ret:

    # Set backed up registers.
    movq MEM_ALLOC_RBX_OFFS(%rbp), %rbx
    movq MEM_ALLOC_R12_OFFS(%rbp), %r12
    movq MEM_ALLOC_R13_OFFS(%rbp), %r13
    movq %rbp, %rsp
    popq %rbp
    retq


mem_free:
    ### Free memory. ###

    pushq %rbp
    movq %rsp, %rbp

    # Free memory.
    movq $0, MEM_ALLOC_MEM_HD_MEM_OCC_OFFS - MEM_ALLOC_MEM_HD_SIZE(%rdi)

    movq $0, %rax

mem_free_ret:

    movq %rbp, %rsp
    popq %rbp
    retq
