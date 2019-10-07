        .text
        .globl main
main:
    mov $4, %rdi
    add $6, %rdi
    call print_int

    mov $21, %rdi
    sal $1, %rdi
    call print_int

    mov $7, %rdi
    shr $1, %rdi
    add $4, %rdi
    call print_int

    mov $10, %rax
    mov $0, %rdx
    mov $5, %r9
    div %r9
    imul $6, %rax
    mov $3, %rdi
    sub %rax, %rdi
    call print_int

    ret


print_int:
        mov     %rdi, %rsi
        mov     $message, %rdi  # arguments pour printf
        mov     $0, %rax
        call    printf
        ret


        .data
message:    .string "%d\n"

