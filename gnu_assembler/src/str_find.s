### Find string. ###


.section .rodata


.type main_out_str_find_ret_form, @object

.type str_find_str, @object
.type str_find_substr, @object


main_out_str_find_ret_form:
    .ascii "Substring starting index = %lld.\n\0"

str_find_str:
    .ascii "Hello, World!\0"
str_find_substr:
    .ascii "Hello\0"


.text


.globl main


.type main, @function
.type str_find, @function


main:
    ### Program. ###

    pushq %rbp
    movq %rsp, %rbp

    leaq str_find_str, %rdi
    leaq str_find_substr, %rsi
    callq str_find
    cmpq $-1, %rax
    je main_ret

    movq stdout, %rdi
    leaq main_out_str_find_ret_form, %rsi
    movq %rax, %rdx
    movq $0, %rax
    callq fprintf

    movq $0, %rax

main_ret:

    movq %rbp, %rsp
    popq %rbp
    retq


str_find:
    ### Find string. ###

    pushq %rbp
    movq %rsp, %rbp

    str_find_while_find_setup:

        movq %rdi, %r8
        xorq %r9, %r9

    str_find_while_find:

        movb (%rdi), %ch
        movb (%rsi), %cl
        cmpb $0, %cl
        je str_find_while_find_trd
        cmpb $0, %ch
        je str_find_while_find_trd
        cmpb %ch, %cl
        je str_find_while_find_cntl
        subq %r9, %rdi
        incq %rdi
        subq %r9, %rsi
        xorq %r9, %r9
        jmp str_find_while_find

    str_find_while_find_cntl:

        incq %r9
        incq %rdi
        incq %rsi
        jmp str_find_while_find

    str_find_while_find_trd:

        cmpb $0, %cl
        jne str_find_ret_err
        cmpq $0, %r9
        je str_find_ret_err
        jmp str_find_ret_suc

str_find_ret_err:

    movq $-1, %rax
    movq %rbp, %rsp
    popq %rbp
    retq

str_find_ret_suc:

    subq %r9, %rdi
    subq %r8, %rdi

    movq %rdi, %rax
    movq %rbp, %rsp
    popq %rbp
    retq
