.data	
	novaLinha: .asciiz "\n"
	array: .word 0:10
	virgula: .asciiz ","
	perdeuMensagem: .asciiz "\nSequência Incorreta!!"
	ganhouMensagem: .asciiz "\nParabéns Você ganhou!!"
	testeMensagem: .asciiz "\nsequencia numero: "
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
		
		# indice do array
		addi $t0, $zero, 0
		# indice da quantidade de sequências
		addi $t1, $zero, 0
		gameLoop:
			# se o loop chegar a 10 sequências ele acaba e o jogador ganha
			beq $t1, 10, ganhou
			# incrementa a quantidade de input pedido e a sequência
			addi $t1, $t1, 1
			# seta o indice do array de volta pra zero
			addi $t0, $zero, 0
			
			# printa a quantidade de número que a sequência pede para testes
			li $v0, 4
			la $a0, testeMensagem
			syscall
			
			li $v0, 1
			move $a0, $t1
			syscall
			
			li $v0, 4
			la $a0, novaLinha
			syscall
			sequencia:
				# multiplica o valor de $t1 para definir a quantidade de indices do array necessarios
				mul $t2, $t1, 4
				
				# se a quantidade de indices do array for igual ao $t0 volta para o gameLoop
				beq $t0, $t2, gameLoop
				# carrega o indice do array especificado pelo $t0
				lw $t6, array($t0)
			
				# pega um inteiro do usuario para testes
				li $v0, 5
				syscall
				move $t3, $v0
				
				# se o valor de $t6, que é o valor retirado do array, for diferente do input jogador perde
				bne $t6, $t3, perdeu
				
				# adiciona 4 ao $t0, ou seja proximo item do array
				addi $t0, $t0, 4
				
				# retorna ao inicio do loop sequencia
				j sequencia
    		
	# Termina o programa
	li $v0, 10
	li $a0, 0
	syscall
	
	ganhou:
		# printa a mensagem ganhou e finaliza o programa
		li $v0, 4
		la $a0, ganhouMensagem
		syscall
		
		li $v0, 10
		li $a0, 0
		syscall
	perdeu:
		# printa a mensagem perdeu
		li $v0, 4
		la $a0, perdeuMensagem
		syscall
		
