	.text
	.globl	main
main:
	popq %rax
	popq %rbx
	addq %rbx, %rax
	pushq %rax
	popq %rdi
	call print_int
	pushq $100
	pushq $2
	popq %rbx
	popq %rax
	movq $0, %rdx
	idivq %rbx
	pushq %rax
	popq %rdi
	call print_int
	pushq $2
	pushq $100
	popq %rbx
	popq %rax
	movq $0, %rdx
	idivq %rbx
	pushq %rax
	popq %rdi
	call print_int
	pushq $10
	popq %rax
	movq %rax, x
	pushq x
	popq %rdi
	call print_int
	pushq x
	pushq x
	pushq $1
	popq %rax
	popq %rbx
	addq %rbx, %rax
	pushq %rax
	popq %rbx
	popq %rax
	imulq %rbx, %rax
	pushq %rax
	pushq $2
	popq %rbx
	popq %rax
	movq $0, %rdx
	idivq %rbx
	pushq %rax
	popq %rax
	movq %rax, y
	pushq y
	popq %rdi
	call print_int
	popq %rax
	popq %rbx
	addq %rbx, %rax
	pushq %rax
	popq %rdi
	call print_int
	pushq $20
	popq %rax
	movq %rax, x
	pushq x
	popq %rdi
	call print_int
	pushq x
	popq %rax
	popq %rbx
	addq %rbx, %rax
	pushq %rax
	pushq x
	popq %rax
	popq %rbx
	addq %rbx, %rax
	pushq %rax
	popq %rax
	movq %rax, x
	pushq x
	popq %rdi
	call print_int
	ret
print_int:
	movq %rdi, %rsi
	leaq .Sprint_int, %rdi
	movq $0, %rax
	call printf
	ret
	.data
x:
	.quad 1
y:
	.quad 1
.Sprint_int:
	.string "%d\n"
