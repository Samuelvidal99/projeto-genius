.data
	hello: .asciiz "Hello World!!"
.text
	# Fun��o main
	main:
		li $v0, 4
		la $a0, hello
		syscall
	# Termina o programa
	li $v0, 10
	li $a0, 0
	syscall