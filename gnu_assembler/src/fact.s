### Calculate factorial. ###


.section .rodata


.equ LOCAL_CALC_VAL_OFFS, -8


.type read_in_fact_msg, @object
.type read_in_fact_form, @object

.type read_in_rerun_msg, @object
.type read_in_rerun_form, @object

.type read_out_res_form, @object
.type read_out_res_val, @object


read_in_fact_msg:

    .string "Value: "

read_in_fact_form:

    .string "%lld"


read_in_rerun_msg:

    .asciz "Rerun? (Y/n): "

read_in_rerun_form:

    .asciz "\n%c"


read_out_res_form:

    .ascii "%lld! = \0"

read_out_res_val_form:

    .asciz "%lld.\n"


.section .bss


.type read_in_fact_val, @object

.type read_in_rerun_val, @object

.type read_out_res_val, @object


.lcomm read_in_fact_val, 8


read_in_rerun_val:

    .skip 1


read_out_res_val:

    .zero 8


.section .data


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

        callq read

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

    movq %rbp, %rsp
    popq %rbp
    retq


read:
    ### Read data. ###

    pushq %rbp
    movq %rsp, %rbp

    movq stdout, %rdi
    leaq read_in_fact_msg, %rsi
    movq $0, %rax
    callq fprintf

    movq stdin, %rdi
    leaq read_in_fact_form, %rsi
    leaq read_in_fact_val, %rdx
    movq $0, %rax
    callq fscanf

    movq read_in_fact_val, %rdi
    callq calc
    cmpq $-1, %rax
    je read_ret
    movq %rax, read_out_res_val

    movq stdout, %rdi
    leaq read_out_res_form, %rsi
    movq read_in_fact_val, %rdx
    movq $0, %rax
    callq fprintf

    movq stdout, %rdi
    leaq read_out_res_val_form, %rsi
    movq read_out_res_val, %rdx
    movq $0, %rax
    callq fprintf

read_ret:

    movq %rbp, %rsp
    popq %rbp
    retq


calc:
    ### Calculate factorial. ###

    pushq %rbp
    movq %rsp, %rbp
    subq $0x10, %rsp

    cmpq $0, %rdi
    jb calc_ret_err
    je calc_ret_1

    movq %rdi, LOCAL_CALC_VAL_OFFS(%rbp)

    decq %rdi
    callq calc
    mulq LOCAL_CALC_VAL_OFFS(%rbp)

calc_ret:

    movq %rbp, %rsp
    popq %rbp
    retq

calc_ret_err:

    movq $-1, %rax
    movq %rbp, %rsp
    popq %rbp
    retq

calc_ret_1:

    movq $1, %rax
    movq %rbp, %rsp
    popq %rbp
    retq


rerun:
    ### Check if user wants to rerun program. ###

    pushq %rbp
    movq %rsp, %rbp

    movq stdout, %rdi
    leaq read_in_rerun_msg, %rsi
    movq $0, %rax
    callq fprintf

    movq stdin, %rdi
    leaq read_in_rerun_form, %rsi
    leaq read_in_rerun_val, %rdx
    movq $0, %rax
    callq fscanf

    movb read_in_rerun_val, %al
    cmpb $'Y', %al
    je rerun_ret_1
    cmpb $'n', %al
    je rerun_ret_0

rerun_ret_err:

    movq $-1, %rax
    leave
    retq

rerun_ret_1:

    movq $1, %rax
    leave
    retq

rerun_ret_0:

    movq $0, %rax
    leave
    retq
