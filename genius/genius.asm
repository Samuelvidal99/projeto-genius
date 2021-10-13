.data	
	novaLinha: .asciiz "\n"
	array: .word 0:10
	virgula: .asciiz ","
	perdeuMensagem: .asciiz "\nSequência Incorreta!!"
	ganhouMensagem: .asciiz "\nParabéns Você ganhou!!"
.text
	# Função main
	main:	
		# setando o indície $t0 pra 0
		addi $t0, $zero, 0
		# while para iniciar o array com números aleatorio de 1 a 4
		whileIniciaRandom:
			beq $t0, 40, exitWhileIniciaRandom
			
			li $a1, 4  # seta o limite superior 4
    			li $v0, 42  # generates the random number.
    			syscall
    			add $a0, $a0, 1  # seta o limite inferior 1
			
			addi $s0, $a0, 0
			sw $s0, array($t0) # guarda o número gerado no array
			
			addi $t0, $t0, 4
		j whileIniciaRandom
		exitWhileIniciaRandom:
		
		# setando o indície $t0 pra 0
		addi $t0, $zero, 0
		# while para printar os elementos do array
		whilePrinta: 
			beq $t0, 40, exitWhilePrinta
			
			lw $t6, array($t0)
			
			addi $t0, $t0, 4
			
			# printa o número atual.
			li $v0, 1
			move $a0, $t6
			syscall
			
			# printa nova linha
			li $v0, 4
			la $a0, virgula
			syscall
			
			j whilePrinta
		exitWhilePrinta:
		
		# Printa uma nova linha
		li $v0, 4
		la $a0, novaLinha
		syscall
		
		# setando o indície $t0 pra 0
		addi $t0, $zero, 0
		gameLoop:
			beq $t0, 40, ganhou
			
			lw $t6, array($t0)
			
			#inputPlayer
			li $v0, 5
			syscall
			move $t1, $v0
			
			bne $t6, $t1, perdeu
			
			addi $t0, $t0, 4
			
			j gameLoop
    		
	# Termina o programa
	li $v0, 10
	li $a0, 0
	syscall
	
	ganhou:
		li $v0, 4
		la $a0, ganhouMensagem
		syscall
		
		li $v0, 10
		li $a0, 0
		syscall
	perdeu:
		li $v0, 4
		la $a0, perdeuMensagem
		syscall
		
