# Configuracoes bitmap display													
# unit width/height pixel = 32x32										
# display width/height pixel = 512x512								
# base address for display = heap (0x10040000)


.data	
	novaLinha: .asciiz "\n"
	array: .word 0:10
	virgula: .asciiz ","
	teste: .asciiz "\nteste"
	perdeuMensagem: .asciiz "\nSequência Incorreta!!"
	ganhouMensagem: .asciiz "\nParabéns Você ganhou!!"
	testeMensagem: .asciiz "\nsequencia numero: "
	instruction: .asciiz "\n1. Azul 2. Vermelho 3.Verde 4.Amarelo"
	vermelhoA:    .word 0x00FF4500 #vermelho aceso
    	vermelho:    .word 0x008B0000 #vermelho 
    	azulA:        .word 0x000000FF #Azul aceso
    	azul:        .word 0x0000008B #Azul 
    	verde:        .word 0x00006400 #Verde
    	verdeA:        .word 0x0032CD32 #Verde aceso
    	amareloA:    .word 0x00FFD700 #Amarelo aceso
    	amarelo:    .word 0x00DAA520 #Amarelo 
    	preto:        .word 0x00000000 #preto
    	tela:     .word 0x10040000 #Endereco inicial
.text
	.macro wait()
        	li $v0, 32
        	li $a0, 350
        	syscall
    	.end_macro
    	
	.macro printarLinha(%pixel, %cor) 
        	add $t2, $zero, %pixel
        	addi $t3, $t2, 32  

        	lw $t4, tela
        	lacoLinha: 
            		beq $t3, $t2, fimLacoLinha 
            		sw  %cor, 0($t2) 
            		addi $t4, $t4, 4
            		addi $t2, $t2, 4
            		j lacoLinha 
        	fimLacoLinha: 
    	.end_macro

	.macro printarQuadrado(%pixel,%cor)
        	add $t7, $zero, %pixel     
        	addi $t5, $t7, 32  
        
        	lw $t6, tela
        	add $t6, $t6, %pixel 
        	lacoColuna:
            		beq $t5, $t7, fimLacoColuna  
            		printarLinha($t6, %cor)    
            		addi $t6, $t6, 64
            		addi $t7, $t7, 4         
            		j lacoColuna
        	fimLacoColuna:
    	.end_macro
    	
    	.macro printarTelaApagada()
        	addi $t0, $zero, 0 #primeiro quadrante 
        	lw $t1, azul 
        	printarQuadrado($t0, $t1)
        
        	addi $t0, $zero, 512 #terceiro quadrante
        	lw $t1, verde 
        	printarQuadrado($t0, $t1)
                
        	addi $t0, $zero, 32 #segundo quadrante
        	lw $t1, vermelho
        	printarQuadrado($t0, $t1)
        
        	addi $t0, $zero, 544 #quarto quadrante
        	lw $t1, amarelo 
        	printarQuadrado($t0, $t1)
    	.end_macro
    	
    	.macro printarAceso(%aceso, %cor2) #macro para apagar cor que estava acesa e acender a proxiuma
        	printarTelaApagada()
        
        	printarQuadrado(%aceso, %cor2) #acende proxima
        
        	wait()
    	.end_macro
    
    	.macro corSelecionada(%valor)
        	beq %valor, 1, azul
        	beq %valor, 2, vermelho
        	beq %valor, 3, verde
        	beq %valor, 4, amarelo
        	azul:
            		lw $k1, azulA
            		printarAceso($zero, $k1)
            		j exit
        	verde:
        		addi $k0, $zero, 512
            		lw $k1, verdeA
            		printarAceso($k0, $k1)
            		j exit
        	vermelho:
            		addi $k0, $zero, 32
            		lw $k1, vermelhoA
            		printarAceso($k0, $k1)
            		j exit
        	amarelo:
            		addi $k0, $zero, 544
            		lw $k1, amareloA
            		printarAceso($k0, $k1)
            		j exit
        	exit:
    	.end_macro
    	
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
		
			li $v0, 4
			la $a0, instruction
			syscall
		
		printarTelaApagada()
		# indice do array
		addi $s0, $zero, 0
		# indice da quantidade de sequências
		addi $s1, $zero, 0
		gameLoop:
			# se o loop chegar a 10 sequências ele acaba e o jogador ganha
			beq $s1, 10, ganhou
			# incrementa a quantidade de input pedido e a sequência
			addi $s1, $s1, 1
			# seta o indice do array de volta pra zero
			addi $s0, $zero, 0
			
			#teste
			jal mostraSequencia
			addi $s0, $zero, 0
			#teste
			
			# printa a quantidade de número que a sequência pede para testes
			li $v0, 4
			la $a0, testeMensagem
			syscall
			
			li $v0, 1
			move $a0, $s1
			syscall
			
			li $v0, 4
			la $a0, novaLinha
			syscall
			sequencia:
				# multiplica o valor de $t1 para definir a quantidade de indices do array necessarios
				mul $s2, $s1, 4
				
				# se a quantidade de indices do array for igual ao $t0 volta para o gameLoop
				beq $s0, $s2, gameLoop
				# carrega o indice do array especificado pelo $t0
				lw $s6, array($s0)
			
				# pega um inteiro do usuario para testes
				li $v0, 5
				syscall
				move $s3, $v0
				
				corSelecionada($s3)
				printarTelaApagada()
				
				# se o valor de $t6, que é o valor retirado do array, for diferente do input jogador perde
				bne $s6, $s3, perdeu
				
				# adiciona 4 ao $t0, ou seja proximo item do array
				addi $s0, $s0, 4
				
				# retorna ao inicio do loop sequencia
				j sequencia
    		
	# Termina o programa
	li $v0, 10
	li $a0, 0
	syscall
	
	# Função que acende as luzes na sequência antes do input do user
	mostraSequencia:
		# sleep de 0,5s
		li $v0, 32
		addi $a0, $zero, 500
		syscall
		whileMostraSequencia:
			mul $s2, $s1, 4
			beq $s0, $s2, exitWhileMostraSequencia
			lw $s6, array($s0)
			
			corSelecionada($s6)
			
			# sleep de 0,5s
			li $v0, 32
			addi $a0, $zero, 500
			syscall
			
			printarTelaApagada()
			
			# sleep de 0,5s
			li $v0, 32
			addi $a0, $zero, 500
			syscall
			
			addi $s0, $s0, 4
			j whileMostraSequencia
		exitWhileMostraSequencia:
		jr $ra
	
	ganhou:
		# printa a mensagem ganhou e finaliza o programa
		li $v0, 4
		la $a0, ganhouMensagem
		syscall
		
		# sleep de 0,25s
		li $v0, 32
		addi $a0, $zero, 250
		syscall
		
		# animação de vitoria
		addi $t0, $zero, 1
		
		corSelecionada($t0)
			
		printarTelaApagada()

		addi $t0, $zero, 2
		
		corSelecionada($t0)
			
		printarTelaApagada()
		
		addi $t0, $zero, 4
		
		corSelecionada($t0)
			
		printarTelaApagada()
		
		addi $t0, $zero, 3
		
		corSelecionada($t0)
			
		printarTelaApagada()
		
		addi $t0, $zero, 1
		
		corSelecionada($t0)
			
		printarTelaApagada()

		addi $t0, $zero, 2
		
		corSelecionada($t0)
			
		printarTelaApagada()
		
		addi $t0, $zero, 4
		
		corSelecionada($t0)
			
		printarTelaApagada()
		
		addi $t0, $zero, 3
		
		corSelecionada($t0)
			
		printarTelaApagada()
		
		li $v0, 10
		li $a0, 0
		syscall
	perdeu:
		# printa a mensagem perdeu
		li $v0, 4
		la $a0, perdeuMensagem
		syscall
