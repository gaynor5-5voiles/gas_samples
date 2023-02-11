### Use memory allocator. ###


.section .bss


.lcomm mem_size, 8


.section .rodata


.type mem_size_in_msg, @object
.type mem_size_in_form, @object

.type mem_add_out_form, @object


.equ USE_MEM_ALLOC_RBX_OFFS, -8
.equ USE_MEM_ALLOC_R12_OFFS, -0x10
.equ USE_MEM_ALLOC_R13_OFFS, -0x18

.equ USE_MEM_ALLOC_MEM_ALLOC_HD_SIZE, 0x10
.equ USE_MEM_ALLOC_MEM_ALLOC_HD_MEM_SIZE_OFFS, -8


mem_size_in_msg:
    .ascii "Memory size to allocate: \0"
mem_size_in_form:
    .ascii "%lld\0"

mem_addr_out_form:
    .ascii "Allocated memory address: %p\n\0"

mem_out_form:
    .ascii "%s\n\0"


.text


.globl main


.type main, @function


main:
    ### Program. ###

    pushq %rbp
    movq %rsp, %rbp
    subq $0x20, %rsp
    # Backup registers.
    movq %rbx, USE_MEM_ALLOC_RBX_OFFS(%rbp)
    movq %r12, USE_MEM_ALLOC_R12_OFFS(%rbp)
    movq %r13, USE_MEM_ALLOC_R13_OFFS(%rbp)

    # Set error return code.
    movq $-1, %r13

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
    shlq $1, %rbx
    cmovcq %r13, %rax
    jc main_ret
    movq %rax, %r12

    # Output allocated memory address.
    movq stdout, %rdi
    leaq mem_addr_out_form, %rsi
    movq %r12, %rdx
    movq $0, %rax
    callq fprintf

    # Get allocated memory size.
    movq USE_MEM_ALLOC_MEM_ALLOC_HD_MEM_SIZE_OFFS(%r12), %rcx

    # Set memory.
    use_mem_alloc_while_set_mem_setup:

        # Set requested memory address.
        movq %r12, %rbx
        # Set allocated memory size to use.
        subq $USE_MEM_ALLOC_MEM_ALLOC_HD_SIZE, %rcx
        # Reserve 1 byte for null character.
        decq %rcx

    use_mem_alloc_while_set_mem:

        # Set memory to "a".
        movb $'a', (%rbx)

    use_mem_alloc_while_set_mem_cntl:

        # Get next allocated memory byte.
        incq %rbx
        loopq use_mem_alloc_while_set_mem

    use_mem_alloc_while_set_mem_td:

        # Set null character.
        movq $0, (%rbx)

    # Output memory.
    movq stdout, %rdi
    leaq mem_out_form, %rsi
    movq %r12, %rdx
    movq $0, %rax
    callq fprintf

    movq $0, %rax

main_ret:

    # Set backed up registers.
    movq USE_MEM_ALLOC_RBX_OFFS(%rbp), %rbx
    movq USE_MEM_ALLOC_R12_OFFS(%rbp), %r12
    movq USE_MEM_ALLOC_R13_OFFS(%rbp), %r13
    movq %rbp, %rsp
    popq %rbp
    retq
