### Calculate exponent. ###


.section .data


.type read_in_base_msg, @object
.type read_in_base_form, @object
.type read_in_exp_msg, @object
.type read_in_exp_form, @object
.type read_in_rerun_msg, @object
.type read_in_rerun_form, @object

.type read_out_res_form, @object


.equ LOCAL_READ_BASE_OFFS, -8
.equ LOCAL_READ_EXP_OFFS, -16

.equ LOCAL_RERUN_CHOICE_OFFS, -1


read_in_base_msg:

    .ascii "Base: \0"

read_in_base_form:

    .ascii "%lld\0"

read_in_exp_msg:

    .ascii "Exponent: \0"

read_in_exp_form:

    .ascii "%lld\0"

read_in_choice_msg:

    .ascii "Rerun? (Y/n): \0"

read_in_choice_form:

    .ascii "\n%c\0"


read_out_res_form:

    .ascii "%lld ^ %lld = %lld.\n\0"


.section .text


.globl main


.type main, @function

.type read, @function

.type calc, @function

.type rerun, @function


main:
    ### Main. ###

    pushq %rbp
    movq %rsp, %rbp

    main_rerun:

        # Read, calculate, print values, result.
        callq read
        # Check if user wants to rerun.
        callq rerun
        cmpq $-1, %rax
        je main_ret_err
        cmpq $1, %rax
        je main_rerun

main_ret:

    movq $0, %rax
    movq %rbp, %rsp
    popq %rbp
    retq

main_ret_err:

    movq $-1, %rax
    movq %rbp, %rsp
    popq %rbp
    retq


read:
    ### Read data. ###

    pushq %rbp
    movq %rsp, %rbp
    subq $0x10, %rsp

    # Print base input message.
    movq stdout, %rdi
    leaq read_in_base_msg, %rsi
    movq $0, %rax
    callq fprintf
    # Input base.
    movq stdin, %rdi
    leaq read_in_base_form, %rsi
    leaq LOCAL_READ_BASE_OFFS(%rbp), %rdx
    movq $0, %rax
    callq fscanf

    # Print exponent input message.
    movq stdout, %rdi
    leaq read_in_exp_msg, %rsi
    movq $0, %rax
    callq fprintf
    # Input exponent.
    movq stdin, %rdi
    leaq read_in_exp_form, %rsi
    leaq LOCAL_READ_EXP_OFFS(%rbp), %rdx
    movq $0, %rax
    callq fscanf

    # Calculate exponent.
    movq LOCAL_READ_BASE_OFFS(%rbp), %rdi
    movq LOCAL_READ_EXP_OFFS(%rbp), %rsi
    callq calc

    # Print result.
    movq stdout, %rdi
    leaq read_out_res_form, %rsi
    movq LOCAL_READ_BASE_OFFS(%rbp), %rdx
    movq LOCAL_READ_EXP_OFFS(%rbp), %rcx
    movq %rax, %r8
    movq $0, %rax
    callq fprintf

read_ret:

    movq $0, %rax
    movq %rbp, %rsp
    popq %rbp
    retq


calc:
    ### Calculate exponent. ###

    pushq %rbp
    movq %rsp, %rbp

    # Check exponent value.
    cmpq $0, %rsi
    jb calc_ret_err
    je calc_ret_1

    # Decrement exponent.
    decq %rsi

    # Recurse.
    callq calc

    # Exponentiate.
    mulq %rdi

calc_ret:

    movq %rbp, %rsp
    popq %rbp
    retq

calc_ret_1:

    movq $1, %rax
    movq %rbp, %rsp
    popq %rbp
    retq

calc_ret_err:

    movq $-1, %rax
    movq %rbp, %rsp
    popq %rbp
    retq


rerun:
    ### Check if user wants to rerun. ###

    pushq %rbp
    movq %rsp, %rbp
    subq $0x10, %rsp

    # Print rerun input message.
    movq stdout, %rdi
    leaq read_in_choice_msg, %rsi
    movq $0, %rax
    callq fprintf
    # Input rerun.
    movq stdin, %rdi
    leaq read_in_choice_form, %rsi
    leaq LOCAL_RERUN_CHOICE_OFFS(%rbp), %rdx
    movq $0, %rax
    callq fscanf
    # Check if user wants to rerun.
    movb LOCAL_RERUN_CHOICE_OFFS(%rbp), %al
    cmpb $'Y', %al
    je rerun_ret_1
    cmpb $'n', %al
    je rerun_ret_0
    jmp rerun_ret_err

rerun_ret_1:

    movq $1, %rax
    movq %rbp, %rsp
    popq %rbp
    retq

rerun_ret_0:

    movq $0, %rax
    movq %rbp, %rsp
    popq %rbp
    retq

rerun_ret_err:

    movq $-1, %rax
    movq %rbp, %rsp
    popq %rbp
    retq
