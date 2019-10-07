        .text
        .globl main
main:
        mov $1, %rdi
        and $0, %rdi
        call print_bool

        mov $3, %rax
        cmp $4, %rax
        jne then
        mov $14, %rdi
        jmp print
then:
        mov $10, %rdi
        sal $1, %rdi        
print:
        call print_int

        mov $2, %rax
        sub $3, %rax
        mov $3, %rbx
        sal $1, %rbx
        mov $0, %rdi
        mov $1, %r9
        cmp $4, %rbx
        cmovns %r9, %rdi
        or %rax, %rdi
        call print_bool


        ret


print_bool:
        mov %rdi, %rsi
        mov $false, %rdi
        mov $true, %rax
        test %rsi, %rsi
        cmovne %rax, %rdi
        mov $0, %rax
        call printf
        ret


print_int:
        mov     %rdi, %rsi
        mov     $message, %rdi  # arguments pour printf
        mov     $0, %rax
        call    printf
        ret


        .data
true:   .string "true\n"
false:  .string "false\n"
message:    .string "%d\n"
