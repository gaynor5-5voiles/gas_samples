### Print stack. ###


.section .bss


.type const_val, @object


.lcomm const_val, 8


.text


.globl main


.type main, @function

.type print_str, @function


main:
    ### Program. ###

    pushq %rbp
    movq %rsp, %rbp

    main_while_st_setup:

        movq (%rsi), %rsi

    main_while_st:

        callq print_str

    main_while_st_cntl:

        movq %rax, %rsi

        leaq (%rsi), %rax
        cmpb $0, 1(%rax)
        je main_ret

        incq %rsi
        jmp main_while_st

main_ret:

    movq $0, %rax
    movq %rbp, %rsp
    popq %rbp
    retq


print_str:
    ### Print string. ###

    pushq %rbp
    movq %rsp, %rbp

    print_str_while_true_setup:

        movq $1, %rax
        movq $1, %rdi
        movq $1, %rdx

        movq $-1, %r8
        movq $0, %r9
        movb $'\n', const_val
        leaq const_val, %r10

    print_str_while_true:

        syscall

    print_str_while_true_check_teardown:

        cmpq %r8, %r9
        je print_str_ret

        movb (%rsi), %r9b
        cmpb $0, %r9b
        cmoveq %r8, %r9
        cmoveq %rsi, %r12
        cmoveq %r10, %rsi
        je print_str_while_true

    print_str_while_true_control:

        incq %rsi
        jmp print_str_while_true

print_str_ret:

    movq %r12, %rax
    movq %rbp, %rsp
    popq %rbp
    retq
