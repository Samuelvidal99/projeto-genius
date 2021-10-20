# Configuracoes bitmap display: 												
# unit width/height pixel = 32x32										
# display width/height pixel = 512x512								
# base address for display = heap (0x10040000)


.data	
	novaLinha: .asciiz "\n"
	array: .word 0:10
	virgula: .asciiz ","
	teste: .asciiz "\nteste"
	perdeuMensagem: .asciiz "\nSequ�ncia Incorreta!!"
	ganhouMensagem: .asciiz "\nParab�ns Voc� ganhou!!"
	testeMensagem: .asciiz "\nsequencia numero: "
	instruction: .asciiz "\n1. Azul 2. Vermelho 3.Verde 4.Amarelo"
	vermelhoA:    .word 0x00FF0000 #vermelho aceso
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
    	
    	#primeiro pixel da linha, cor da linha
	.macro printLine(%pixel, %cor) 
        	#contador que possui o valor do pixel no inicio
        	add $t2, $zero, %pixel 
        	#pixel +32 para limita��o
        	addi $t3, $t2, 32 

		#carrega posicionamento dos quadrantes no registrador $t2 
        	lw $t4, tela 
        	lacoLinha: 
            		beq $t3, $t2, fimLacoLinha 
            		#insere valor no endere�o de memoria $t2
            		sw  %cor, 0($t2) 
            		#incrementa��o $t2 = $t2+4
            		addi $t4, $t4, 4 
            		#incrementa��o $t1 = $t1+4
            		addi $t2, $t2, 4 
            		#retorna para o inicio
            		j lacoLinha 
        	fimLacoLinha: 
    	.end_macro

	.macro printSquare(%pixel,%cor)
        	
        	#contador que possui o valor do pixel no inicio
        	add $t7, $zero, %pixel     
        	#pixel +32 para limita��o
        	addi $t5, $t7, 32  
        
        	#carrega posicionamento dos quadrantes no registrador $t2 
        	lw $t6, tela
        	add $t6, $t6, %pixel 
        	lacoColuna:
            		#fim do la�o
            		beq $t5, $t7, fimLacoColuna  
            		printLine($t6, %cor)    
            		#pula linha
            		addi $t6, $t6, 64
            		#incrementa��o $t1=$t1+4
            		addi $t7, $t7, 4         
            		j lacoColuna
        	fimLacoColuna:
    	.end_macro
    	
    	.macro printBlankScreen()
        	
        	#primeiro quadrante 
        	addi $t0, $zero, 0
        	#cor azul apagada
        	lw $t1, azul 
        	printSquare($t0, $t1)
        
        	#terceiro quadrante
        	addi $t0, $zero, 512 
        	#cor verde apagada
        	lw $t1, verde 
        	printSquare($t0, $t1)
                
                #segundo quadrante
        	addi $t0, $zero, 32
        	#cor vermelha apagada 
        	lw $t1, vermelho
        	printSquare($t0, $t1)
        
        	#quarto quadrante
        	addi $t0, $zero, 544 
        	#cor amarelo apagada 
        	lw $t1, amarelo 
        	printSquare($t0, $t1)
    	.end_macro
    	
    	 #apaga a cor que estava acesa e acende a proxiuma b
    	.macro printBright(%aceso, %cor2)
        	printBlankScreen()
        	
        	#acende proxima
        	printSquare(%aceso, %cor2) 
        
        	wait()
    	.end_macro
    
    	.macro selectedColour(%valor)
        	#Compara o valor da cor com o numero do imput
        	beq %valor, 1, azul
        	beq %valor, 2, vermelho
        	beq %valor, 3, verde
        	beq %valor, 4, amarelo
        	
        	#acende a cor selecionada
        	azul:
            		lw $k1, azulA
            		printBright($zero, $k1)
            		j exit
        	verde:
        		addi $k0, $zero, 512
            		lw $k1, verdeA
            		printBright($k0, $k1)
            		j exit
        	vermelho:
            		addi $k0, $zero, 32
            		lw $k1, vermelhoA
            		printBright($k0, $k1)
            		j exit
        	amarelo:
            		addi $k0, $zero, 544
            		lw $k1, amareloA
            		printBright($k0, $k1)
            		j exit
        	exit:
    	.end_macro
    	
	# Fun��o main
	main:	
		# setando o ind�cie $t0 pra 0
		addi $t0, $zero, 0
		# while para iniciar o array com n�meros aleatorio de 1 a 4
		whileIniciaRandom:
			beq $t0, 40, exitWhileIniciaRandom
			
			li $a1, 4  # seta o limite superior 4
    			li $v0, 42  # generates the random number.
    			syscall
    			add $a0, $a0, 1  # seta o limite inferior 1
			
			addi $s0, $a0, 0
			sw $s0, array($t0) # guarda o n�mero gerado no array
			
			addi $t0, $t0, 4
		j whileIniciaRandom
		exitWhileIniciaRandom:
		
		# setando o ind�cie $t0 pra 0
		addi $t0, $zero, 0
		
			li $v0, 4
			la $a0, instruction
			syscall
		
		printBlankScreen()
		# indice do array
		addi $s0, $zero, 0
		# indice da quantidade de sequ�ncias
		addi $s1, $zero, 0
		gameLoop:
			# se o loop chegar a 10 sequ�ncias ele acaba e o jogador ganha
			beq $s1, 10, ganhou
			# incrementa a quantidade de input pedido e a sequ�ncia
			addi $s1, $s1, 1
			# seta o indice do array de volta pra zero
			addi $s0, $zero, 0
			
			#teste
			jal mostraSequencia
			addi $s0, $zero, 0
			#teste
			
			# printa a quantidade de n�mero que a sequ�ncia pede para testes
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
				
				selectedColour($s3)
				printBlankScreen()
				
				# se o valor de $t6, que � o valor retirado do array, for diferente do input jogador perde
				bne $s6, $s3, perdeu
				
				# adiciona 4 ao $t0, ou seja proximo item do array
				addi $s0, $s0, 4
				
				# retorna ao inicio do loop sequencia
				j sequencia
    		
	# Termina o programa
	li $v0, 10
	li $a0, 0
	syscall
	
	# Fun��o que acende as luzes na sequ�ncia antes do input do user
	mostraSequencia:
		# sleep de 0,5s
		li $v0, 32
		addi $a0, $zero, 500
		syscall
		whileMostraSequencia:
			mul $s2, $s1, 4
			beq $s0, $s2, exitWhileMostraSequencia
			lw $s6, array($s0)
			
			selectedColour($s6)
			
			# sleep de 0,5s
			li $v0, 32
			addi $a0, $zero, 500
			syscall
			
			printBlankScreen()
			
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
		
		# anima��o de vitoria
		addi $t0, $zero, 1
		
		selectedColour($t0)
			
		printBlankScreen()

		addi $t0, $zero, 2
		
		selectedColour($t0)
			
		printBlankScreen()
		
		addi $t0, $zero, 4
		
		selectedColour($t0)
			
		printBlankScreen()
		
		addi $t0, $zero, 3
		
		selectedColour($t0)
			
		printBlankScreen()
		
		addi $t0, $zero, 1
		
		selectedColour($t0)
			
		printBlankScreen()

		addi $t0, $zero, 2
		
		selectedColour($t0)
			
		printBlankScreen()
		
		addi $t0, $zero, 4
		
		selectedColour($t0)
			
		printBlankScreen()
		
		addi $t0, $zero, 3
		
		selectedColour($t0)
			
		printBlankScreen()
		
		li $v0, 10
		li $a0, 0
		syscall
	perdeu:
		# printa a mensagem perdeu
		li $v0, 4
		la $a0, perdeuMensagem
		syscall