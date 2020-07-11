# Versión incompleta del tetris 
# Sincronizada con tetris.s:r3228

# Proyecto realizado por Aurelio Gonzalez Almena (49308702Z) y Radoslaw Krzysztof Krolikowski (X8799447S)

        
	.data	

pantalla:
	.word	0
	.word	0
	.space	1024

campo:
	.word	0
	.word	0
	.space	1024
	
campo_siguiente:
	.word	0
	.word	0
	.space	1024	
	
pieza_siguiente:	
	.word	0
	.word	0
	.space	1024

pieza_actual:
	.word	0
	.word	0
	.space	1024

pieza_actual_x:
	.word 0

pieza_actual_y:
	.word 0

imagen_auxiliar:
	.word	0
	.word	0
	.space	1024

pieza_jota:
	.word	2
	.word	3
	.ascii		"\0#\0###\0\0"

pieza_ele:
	.word	2
	.word	3
	.ascii		"#\0#\0##\0\0"

pieza_barra:
	.word	1
	.word	4
	.ascii		"####\0\0\0\0"

pieza_zeta:
	.word	3
	.word	2
	.ascii		"##\0\0##\0\0"

pieza_ese:
	.word	3
	.word	2
	.ascii		"\0####\0\0\0"

pieza_cuadro:
	.word	2
	.word	2
	.ascii		"####\0\0\0\0"

pieza_te:
	.word	3
	.word	2
	.ascii		"\0#\0###\0\0"
game_over:
	.word	19
	.word	4
	.ascii 	"+-----------------+"	
	.ascii	"| FIN DE PARTIDA  |"
	.ascii	"| Pulsa una tecla |"
	.ascii	"+-----------------+"
piezas:
	.word	pieza_jota
	.word	pieza_ele
	.word	pieza_zeta
	.word	pieza_ese
	.word	pieza_barra
	.word	pieza_cuadro
	.word	pieza_te

acabar_partida:
	.byte	0
acabar_partida_campo_lleno:	
	.byte	0
buffer:
	.space 256
puntuacion:
	.word -1

	.align	2
procesar_entrada.opciones:
	.byte	'x'
	.space	3
	.word	tecla_salir
	.byte	'j'
	.space	3
	.word	tecla_izquierda
	.byte	'l'
	.space	3
	.word	tecla_derecha
	.byte	'k'
	.space	3
	.word	tecla_abajo
	.byte	'i'
	.space	3
	.word	tecla_rotar
	.byte	't'
	.space	3
	.word	tecla_truco

str000:
	.asciiz		"Tetris\n\n 1 - Jugar\n 2 - Salir\n\nElige una opción:\n"
str001:
	.asciiz		"\n¡Adiós!\n"
str002:
	.asciiz		"\nOpción incorrecta. Pulse cualquier tecla para seguir.\n"
str003:
	.asciiz		"Puntuacion: "

	.text	

imagen_pixel_addr:			# ($a0, $a1, $a2) = (imagen, x, y)
					# pixel_addr = &data + y*ancho + x
    	lw	$t1, 0($a0)		# $a0 = dirección de la imagen 
					# $t1 ← ancho
    	mul	$t1, $t1, $a2		# $a2 * ancho
    	addu	$t1, $t1, $a1		# $a2 * ancho + $a1
    	addiu	$a0, $a0, 8		# $a0 ← dirección del array data
    	addu	$v0, $a0, $t1		# $v0 = $a0 + $a2 * ancho + $a1
    	jr	$ra

imagen_get_pixel:			# ($a0, $a1, $a2) = (img, x, y)
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)		# guardamos $ra porque haremos un jal
	jal	imagen_pixel_addr	# (img, x, y) ya en ($a0, $a1, $a2)
	lbu	$v0, 0($v0)		# lee el pixel a devolver
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

imagen_set_pixel:	# a0 = img, a1 = x, a2 = y, a3 = color
	addiu	$sp, $sp -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	move	$s0, $a3	
	
	jal 	imagen_pixel_addr	# Pixel pixel = imagen_pixel_addr(img,x,y)
 	sb	$s0, 0($v0)		# *pixel = color
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addiu	$sp,$sp,8
	jr	$ra

imagen_clean:		# a0 = img, a1 = ancho, a2 = alto,  a3 = fondo
			# imagen clean necesita a0 = img , a1 = fondo
	addiu	$sp, $sp, -28
	sw	$s0, 0($sp)	# guarda $a0 la img
	sw	$s1, 4($sp)	# guardara img->ancho
	sw	$s2, 8($sp)	# guardara img->alto
	sw	$s3, 12($sp) 	# guardara indice X
	sw	$s4, 16($sp) 	# guardara indice Y
	sw	$s5, 20($sp)
	sw	$ra, 24($sp)
	
	move	$s0,$a0
	lw	$s1, 0($s0)	# img->ancho # s1 = 10
	lw	$s2, 4($s0)	# img->alto # s2 = 8
	move	$s5, $a1	# fondo
	#for (int y = 0; y < img->alto; y++
	li	$s4, 0		# y = 0
for_img_clean_y:	
	bgeu	$s4,$s2,fin_for_img_clean_y	# condicion del bucle
	li	$s3, 0		# x = 0
for_img_clean_x:
	bgeu	$s3,$s1,fin_for_img_clean_x	# condicion del bucle
	#PROBLEMA
	
	move	$a0, $s0		#a0 = s0
	move	$a1, $s3		#a1 = indice x
	move	$a2, $s4		#a2 = indice y
	move	$a3, $s5		#a3 = fondo
	jal	imagen_set_pixel	#a0 = img, $a1 = x, $a2 = y, $a3 = color  "fondo"		
	addiu	$s3,$s3,1	# x++
	j	for_img_clean_x			
fin_for_img_clean_x:	
	addiu	$s4,$s4,1	# y++
	j	for_img_clean_y
fin_for_img_clean_y:
	lw	$s0, 0($sp)	# guarda $a0 la img
	lw	$s1, 4($sp)	# guardara img->ancho
	lw	$s2, 8($sp)	# guardara img->alto
	lw	$s3, 12($sp) 	# guardara indice X
	lw	$s4, 16($sp) 	# guardara indice Y
	lw	$s5, 20($sp)
	lw	$ra, 24($sp)
	addiu	$sp,$sp,28
	jr	$ra	# return de todo procedimiento
        
imagen_init:	# a0 img, a1 = x, a2 = y, a3 = fondo
	addiu 	$sp,$sp -12
	sw	$ra,8($sp)
	sw	$s1,4($sp)
	sw	$s0,0($sp)
	
	
	move	$s0, $a0	# s0 es img
	sw	$a1, 0($s0)	# img->ancho = ancho
	sw	$a2, 4($s0)	# img->alto = alto
	move	$a1,$a3
	jal	imagen_clean
	
	
	
	lw	$ra,8($sp)
	lw	$s1,4($sp)
	lw	$s0,0($sp)
	addiu	$sp,$sp 12
	jr	$ra
	

imagen_copy:			# a0 = img_destino, a1 = img_source
	addiu	$sp,$sp,-28
	sw	$s0,0($sp)
	sw	$s1,4($sp)
	sw	$s2,8($sp)
	sw	$s3,12($sp)
	sw	$s4,16($sp)
	sw	$s5,20($sp)
	sw	$ra,24($sp)
	
	move	$s0, $a0	# s0 = img_dst
	move	$s1, $a1	# s1 = img_src
	
	lw	$t0, 0($s1)	# t0 = img_src->ancho
	lw	$t1, 4($s1)	# t1 = img_src->alto		
	
	sw	$t0, 0($s0)	# img_dst->ancho = img_stc->ancho 
	sw	$t1, 4($s0)	# img_dst->alto = img_src->alto
	
	move	$s2, $t0	#s2 = img_src->ancho 
	move	$s3, $t1	#s3 = img_src-alto
	#for (int y = 0; y< src->alto;y++)
	li	$s4,0		# y = 0	
for_imagen_copy_y:
	bgeu	$s4,$s3,fin_for_imagen_copy_y
	li	$s5,0		#x = 0
for_imagen_copy_x:	
	bgeu	$s5,$s2,fin_for_imagen_copy_x
	move 	$a0, $s1	# a0 = img_src
	move	$a1, $s5	# a1 = x 
	move	$a2, $s4	# a2 = y
	jal	imagen_get_pixel # v0 = p
	
	move	$a0, $s0	# a0 = img_dst
	move	$a1, $s5	# a1 = x
	move	$a2, $s4	# a2 = y
	move	$a3, $v0	# a3 = v0
	jal	imagen_set_pixel
	addiu	$s5,$s5,1
	j	for_imagen_copy_x
fin_for_imagen_copy_x:	
	addiu	$s4,$s4,1
	j	for_imagen_copy_y
fin_for_imagen_copy_y:	
	lw	$s0,0($sp)
	lw	$s1,4($sp)
	lw	$s2,8($sp)
	lw	$s3,12($sp)
	lw	$s4,16($sp)
	lw	$s5,20($sp)
	lw	$ra,24($sp)
	addiu	$sp,$sp,28
	
	jr	$ra

	

imagen_print:				# $a0 = img
	addiu	$sp, $sp, -24
	sw	$ra, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	
	move	$s0, $a0
	lw	$s3, 4($s0)		# img->alto
	lw	$s4, 0($s0)		# img->ancho
        #  for (int y = 0; y < img->alto; ++y)
	li	$s1, 0			# y = 0
B6_2:	bgeu	$s1, $s3, B6_5		# acaba si y ≥ img->alto
	#    for (int x = 0; x < img->ancho; ++x)
	li	$s2, 0			# x = 0
B6_3:	bgeu	$s2, $s4, B6_4		# acaba si x ≥ img->ancho
	move	$a0, $s0		# Pixel p = imagen_get_pixel(img, x, y)
	move	$a1, $s2
	move	$a2, $s1
	jal	imagen_get_pixel
	move	$a0, $v0		# print_character(p)
	jal	print_character
	addiu	$s2, $s2, 1		# ++x
	j	B6_3
	#    } // for x
B6_4:	li	$a0, 10			# print_character('\n')
	jal	print_character
	addiu	$s1, $s1, 1		# ++y
	j	B6_2
	#  } // for y
B6_5:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$ra, 20($sp)
	addiu	$sp, $sp, 24
	jr	$ra

imagen_dibuja_imagen:		# a0 =img_dst, a1 = img_src, a2 = dst_x, a3 = dst_y
	addiu	$sp,$sp,-36
	sw	$ra,0($sp)
	sw	$s0,4($sp)
	sw	$s1,8($sp)
	sw	$s2,12($sp)
	sw	$s3,16($sp)
	sw	$s4,20($sp)
	sw	$s5,24($sp)
	sw	$s6,28($sp)
	sw	$s7,32($sp)
	
	move	$s0, $a0	# s0 = img_dst
	move	$s1, $a1	# s1 = img_src	
	move	$s2, $a2	# s2 = dst_x
	move	$s3, $a3	# s3 = dst_y
	
	lw	$s4, 0($s1)	# s4 = img_src->ancho
	lw	$s5, 4($s1)	# s3 = img_src->alto
	
	li	$s6,0		# y = 0
for_imagen_dibuja_y:
	bgeu	$s6,$s5,fin_for_imagen_dibuja_y
	li	$s7,0		# x = 0
for_imagen_dibuja_x:
	bgeu	$s7,$s4, fin_for_imagen_dibuja_x
	# imgen_get_pixel (src,x,y)
	move	$a0,$s1
	move	$a1,$s7
	move	$a2,$s6
	jal	imagen_get_pixel	#v0 = p
if_imagen_dibuja:
	beqz	$v0,fi_imagen_dibuja
	move	$a0, $s0
	addu	$a1, $s2,$s7 # t3 = dist_x + x		
	addu	$a2, $s3,$s6 # t3 = dist_y + y
	move	$a3,$v0
	jal	imagen_set_pixel	# a0 = img_dst, a1 = dst_x + x, a2 = dst_y +y, a3 = p
fi_imagen_dibuja:	 
	addiu	$s7,$s7,1	# x++
	j	for_imagen_dibuja_x	
fin_for_imagen_dibuja_x:	
	addiu	$s6,$s6,1	#y++
	j	for_imagen_dibuja_y
fin_for_imagen_dibuja_y:

	lw	$ra,0($sp)
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	lw	$s2,12($sp)
	lw	$s3,16($sp)
	lw	$s4,20($sp)
	lw	$s5,24($sp)
	lw	$s6,28($sp)
	lw	$s7,32($sp)
	addiu	$sp,$sp,36
	jr	$ra
	
imagen_dibuja_imagen_rotada:
	addiu	$sp,$sp,-36
	sw	$ra,0($sp)
	sw	$s0,4($sp)
	sw	$s1,8($sp)
	sw	$s2,12($sp)
	sw	$s3,16($sp)
	sw	$s4,20($sp)
	sw	$s5,24($sp)
	sw	$s6,28($sp)
	sw	$s7,32($sp)
	
	move	$s0, $a0	# s0 = img_dst
	move	$s1, $a1	# s1 = img_src	
	move	$s2, $a2	# s2 = dst_x
	move	$s3, $a3	# s3 = dst_y
	
	lw	$s4, 0($s1)	# s4 = img_src->ancho
	lw	$s5, 4($s1)	# s3 = img_src->alto
	
	li	$s6,0		# y = 0
for_imagen_dibuja_rotada_y:
	bgeu	$s6,$s5,fin_for_imagen_dibuja_y_rotada
	li	$s7,0		# x = 0
for_imagen_dibuja_rotada_x:
	bgeu	$s7,$s4, fin_for_imagen_dibuja_x_rotada
	# imgen_get_pixel (src,x,y)
	move	$a0,$s1
	move	$a1,$s7
	move	$a2,$s6
	jal	imagen_get_pixel	#v0 = p
if_imagen_dibuja_rotada:
	beqz	$v0,fi_imagen_dibuja_rotada
	move	$a0, $s0
	add	$t3,$s2,$s5	# t3 = dst_x + src->alto 
	addi	$t4, $s6,1	# t4 = 1+y
	sub	$t5, $t3,$t4	# t5 = dst_x + src->alto - 1 + y
	move	$a1, $t5 	
	addu	$a2, $s3,$s7	# dst_y + x
	move	$a3,$v0
	jal	imagen_set_pixel	# a0 = img_dst, a1 = dst_x + x, a2 = dst_y +y, a3 = p
fi_imagen_dibuja_rotada:	 
	addiu	$s7,$s7,1	# x++
	j	for_imagen_dibuja_rotada_x	
fin_for_imagen_dibuja_x_rotada:	
	addiu	$s6,$s6,1	#y++
	j	for_imagen_dibuja_rotada_y
fin_for_imagen_dibuja_y_rotada:

	lw	$ra,0($sp)
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	lw	$s2,12($sp)
	lw	$s3,16($sp)
	lw	$s4,20($sp)
	lw	$s5,24($sp)
	lw	$s6,28($sp)
	lw	$s7,32($sp)
	addiu	$sp,$sp,36
	jr	$ra

pieza_aleatoria:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	li	$a0, 0
	li	$a1, 7
	jal	random_int_range	# $v0 ← random_int_range(0, 7)
	sll	$t1, $v0, 2
	la	$v0, piezas
	addu	$t1, $v0, $t1		# $t1 = piezas + $v0*4
	lw	$v0, 0($t1)		# $v0 ← piezas[$v0]
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

actualizar_pantalla:
	addiu	$sp, $sp, -16
	sw	$s3, 12($sp)
	sw	$ra, 8($sp)
	sw	$s2, 4($sp)
	sw	$s1, 0($sp)
	la	$s2, campo
	la	$s3, campo_siguiente
	la	$a0, pantalla
	li	$a1, ' '
	jal	imagen_clean		# imagen_clean(pantalla, ' ')
        # for (int y = 0; y < campo->alto; ++y) {
	li	$s1, 0			# y = 0
B10_2:	lw	$t1, 4($s2)		# campo->alto
	bge	$s1, $t1, B10_3		# sigue si y < campo->alto
	la	$a0, pantalla
	li	$a1, 0                  # pos_campo_x - 1
	addi	$a2, $s1, 2             # y + pos_campo_y
	li	$a3, '|'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, 0, y, '|')
	la	$a0, pantalla
	lw	$t1, 0($s2)		# campo->ancho
	addiu	$a1, $t1, 1		# campo->ancho + 1
	addiu	$a2, $s1, 2             # y + pos_campo_y
	li	$a3, '|'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, campo->ancho + 1, y, '|')
        addiu	$s1, $s1, 1		# ++y
        j       B10_2
        # } // for y
	# for (int x = 0; x < campo->ancho + 2; ++x) { 
B10_3:	li	$s1, 0			# x = 0
B10_5:  lw	$t1, 0($s2)		# campo->ancho
        addiu   $t1, $t1, 2             # campo->ancho + 2
        bge	$s1, $t1, B10_10	# sigue si x < campo->ancho + 2
	la	$a0, pantalla
	move	$a1, $s1                # pos_campo_x - 1 + x
        lw	$t1, 4($s2)		# campo->alto
	addiu	$a2, $t1, 2		# campo->alto + pos_campo_y
	li	$a3, '-'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, x, campo->alto + 1, '-')
	addiu	$s1, $s1, 1		# ++x
	j       B10_5
        # } // for x
        
   	 # Dibujar el otro campo
	# for (int y = 0; y < campo_auxiliar->alto; ++y){	
B10_10:	li	$s1,0			# y = 0
B10_7:	lw	$t1, 4($s3)		# t1 = campo_auxiliar->alto
	bge	$s1,$t1,B10_8
	la	$a0, pantalla
	li	$a1, 18			# pos_campo_auxiliar_x
	addi	$a2, $s1,2		# y + pos_campo_y
	li	$a3, '|'		# pixel a dibujar
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, pos_campo_auxiliar_x, y+pos_campo_y, '|')
	la	$a0, pantalla
	lw	$t1, 0($s3)
	addiu	$a1,$t1, 20
	addiu	$a2,$s1, 2
	li	$a3, '|'
	jal	imagen_set_pixel	#imagen_set_pixel(pantalla,pos_campo_auxiliar + campo_auxiliar->ancho, y + pos_campo_auxliar_y, '|')
	addiu	$s1,$s1,1
	j	B10_7
	# }   
	#for (int x = 0; x < campo_siguiente->ancho + 2; ++x) { 
 B10_8:	li	$s1, 0
 B10_12:lw	$t1, 0($s3)
	addiu	$t1, $t1,3
	bge	$s1, $t1,B10_6
	la	$a0, pantalla
	addiu	$a1, $s1,18
	lw	$t1, 4($s3)
	addiu	$a2, $t1, 2
	li	$a3, '-'
	jal	imagen_set_pixel
	addiu	$s1, $s1, 1
	j	B10_12 
 	#}      
B10_6:	
	la	$a0, pantalla
	move	$a1, $s2
	li	$a2, 1                  # pos_campo_x
	li	$a3, 2                  # pos_campo_y
	jal	imagen_dibuja_imagen	# imagen_dibuja_imagen(pantalla, campo, 1, 2)
	la	$a0, pantalla
	la	$a1, pieza_actual
	lw	$t1, pieza_actual_x
	addiu	$a2, $t1, 1		# pieza_actual_x + pos_campo_x
	lw	$t1, pieza_actual_y
	addiu	$a3, $t1, 2		# pieza_actual_y + pos_campo_y
	jal	imagen_dibuja_imagen	# imagen_dibuja_imagen(pantalla, pieza_actual, pieza_actual_x + pos_campo_x, pieza_actual_y + pos_campo_y)x
	
	la	$a0, pantalla
	la	$a1, pieza_siguiente
	li	$a2, 19
	li	$a3, 2
	jal	imagen_dibuja_imagen	# imagen_dibuja_imagen(pantalla, pieza_siguiente, pieza_siguiente_x + pos_campo_x, pieza_siguiente_y + pos_campo_y)
	
	# imagen_dibuja_cadena
	la	$a0,pantalla
	li	$a1,0
	li	$a2,0
	la	$a3,buffer
	jal	imagen_dibuja_cadena	#(pantalla,x,y,buffer)
	
	
	
	
	jal	clear_screen		# clear_screen()
	la	$a0, pantalla
	jal	imagen_print		# imagen_print(pantalla)
	lw	$s1, 0($sp)
	lw	$s2, 4($sp)
	lw	$ra, 8($sp)
	lw	$s3, 12($sp)
	addiu	$sp, $sp, 16
	jr	$ra

nueva_pieza_actual: # void nueva_pieza_actual(void)
	addiu	$sp,$sp, -8
	sw	$ra,0($sp)
	sw	$s0,4($sp)
	
	la	$a0,pieza_actual
	la	$a1,pieza_siguiente
	jal 	imagen_copy	#imagen_copy(pieza_actual,pieza_siguiente)
	
	jal	pieza_aleatoria		#elegida = v0
	move	$s0,$v0			#elegida = $s0
	
	move	$a0,$v0
	li	$a1,8
	li	$a2,0
	jal	probar_pieza	# ($a0, $a1, $a2) = (pieza, x, y) v0 = 1 si true, v0 = 0 si false
	beqz	$v0,fin_npa #	if(probar_pieza(elegida,8,0 == 1)
	
	la	$a0, pieza_siguiente
	move	$a1, $s0
	jal	imagen_copy		# imagen_copy(pieza_siguiente, elegida)
	
	la	$t1, pieza_actual_x
	la	$t2, pieza_actual_y
	li	$t3, 8
	sw	$t3,0($t1)
	sw	$0,0($t2)
	
	# Aumentar la puntuacion
	la	$t0, puntuacion
	lw	$t1, 0($t0)
	addiu	$t1, $t1, 1
	sw	$t1, 0($t0)
	j	nva_ok
fin_npa:
	li	$t0, 1
	sb	$t0, acabar_partida # acabar_partida = true
	sb	$t0, acabar_partida_campo_lleno #  acabar_partida_campo_lleno = true
nva_ok:	
	lw	$s0,4($sp)
	lw	$ra,0($sp)
	addiu	$sp,$sp,8
	jr	$ra
	

probar_pieza:				# ($a0, $a1, $a2) = (pieza, x, y)
	addiu	$sp, $sp, -32
	sw	$ra, 28($sp)
	sw	$s7, 24($sp)
	sw	$s6, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	
	move	$s0, $a2		# y
	move	$s1, $a1		# x
	move	$s2, $a0		# pieza
	
	li	$v0, 0
	bltz	$s1, B12_13		# if (x < 0) return false
	lw	$t1, 0($s2)		# pieza->ancho
	addu	$t1, $s1, $t1		# x + pieza->ancho
	la	$s4, campo
	lw	$v1, 0($s4)		# campo->ancho
	bltu	$v1, $t1, B12_13	# if (x + pieza->ancho > campo->ancho) return false
	bltz	$s0, B12_13		# if (y < 0) return false
	lw	$t1, 4($s2)		# pieza->alto
	addu	$t1, $s0, $t1		# y + pieza->alto
	lw	$v1, 4($s4)		# campo->alto
	bltu	$v1, $t1, B12_13	# if (campo->alto < y + pieza->alto) return false
	# for (int i = 0; i < pieza->ancho; ++i) {
	lw	$t1, 0($s2)		# pieza->ancho
	beqz	$t1, B12_12
	li	$s3, 0			# i = 0
	#   for (int j = 0; j < pieza->alto; ++j) {
	lw	$s7, 4($s2)		# pieza->alto
B12_6:	beqz	$s7, B12_11
	li	$s6, 0			# j = 0
B12_8:	move	$a0, $s2
	move	$a1, $s3
	move	$a2, $s6
	jal	imagen_get_pixel	# imagen_get_pixel(pieza, i, j)
	beqz	$v0, B12_10		# if (imagen_get_pixel(pieza, i, j) == PIXEL_VACIO) sigue
	move	$a0, $s4
	addu	$a1, $s1, $s3		# x + i
	addu	$a2, $s0, $s6		# y + j
	jal	imagen_get_pixel
	move	$t1, $v0		# imagen_get_pixel(campo, x + i, y + j)
	li	$v0, 0
	bnez	$t1, B12_13		# if (imagen_get_pixel(campo, x + i, y + j) != PIXEL_VACIO) return false
B12_10:	addiu	$s6, $s6, 1		# ++j
	bltu	$s6, $s7, B12_8		# sigue si j < pieza->alto
        #   } // for j
B12_11:	lw	$t1, 0($s2)		# pieza->ancho
	addiu	$s3, $s3, 1		# ++i
	bltu	$s3, $t1, B12_6 	# sigue si i < pieza->ancho
        # } // for i
B12_12:	li	$v0, 1			# return true
B12_13:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s6, 20($sp)
	lw	$s7, 24($sp)
	lw	$ra, 28($sp)
	addiu	$sp, $sp, 32
	jr	$ra

intentar_movimiento:	# bool intentar_movimiento(int x, int y)
	addiu	$sp,$sp,-12
	sw	$s0,0($sp)
	sw	$s1,4($sp)
	sw	$ra,8($sp)
	
	move	$s0, $a0	#s0 = x
	move	$s1, $a1	#s1 = y
	# probar_pieza(pieza_actual, x, y)
	la	$a0, pieza_actual
	move	$a1, $s0
	move	$a2, $s1
	jal	probar_pieza	# v0 = 1 si true, v0 = 0 si false
	move	$t3, $v0	# guardo el resultado de probar_pieza
	li	$v0, 0		# inicializo a false el resultado de intentar_movimiento
if_intentar_movimiento:
	blez	$t3,fi_intentar_movimiento	
	la	$t0, pieza_actual_x
	la	$t1, pieza_actual_y
	sw	$s0,0($t0)	# pieza_actual_x = x
	sw	$s1,0($t1)	# pieza_actual_y = y
	li	$v0, 1		# v0 = true
fi_intentar_movimiento:	
	lw	$s0,0($sp)
	lw	$s1,4($sp)
	lw	$ra,8($sp)	
	addiu	$sp,$sp,12
	jr	$ra
	
comprobar_linea_llena: # a0 = y
	addiu	$sp,$sp,-20
	sw	$ra,0($sp)
	sw	$s0,4($sp)
	sw	$s1,8($sp)
	sw	$s2,12($sp)
	sw	$s3,16($sp)
	li	$s0, 0		# s0 = x
	la	$s1, campo	# s1 = campo
	lw	$s2, 0($s1)	# s2 = campo->ancho
	move	$s3, $a0	# s3 = y (parametro funcion)
	#for(x = 0; x < campo->ancho; x++) {
for_cll:	
	bgeu	$s0, $s2,fin_for_cll
	#if(imagen_get_pixel(campo,x,y) == PIXEL VACIO){
	move	$a0, $s1
	move	$a1, $s0
	move	$a2, $s3
	jal 	imagen_get_pixel	# imagen_get_pixel(campo,x,y)
	bnez	$v0, fin_if_cll		# si v0 es PIXELVACIO
	li	$v0, 0			# v0 = false
	j	fin_cll
	#return false
	#}
fin_if_cll:		
	addiu	$s0,$s0,1
	j	for_cll	
	#}
fin_for_cll:
	li	$v0,1	# v0 = true

fin_cll:		
	lw	$ra,0($sp)
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	lw	$s2,12($sp)
	lw	$s3,16($sp)
	addiu	$sp,$sp,20
	jr	$ra	
bajar_pieza_actual:	
	addiu	$sp,$sp,-12
	sw	$ra,0($sp)
	sw	$s0,4($sp)
	sw	$s1,8($sp)
	lw	$a0, pieza_actual_x
	lw	$a1,pieza_actual_y
	addiu	$a1,$a1,1	# pieza_actual_y + 1	
	jal	intentar_movimiento	#v0 = 0 si false, v0 = 1 si true
	bnez  	$v0, bajar_pieza_fin_if	# cambie beq por bneq
	la	$a0, campo
	la	$a1, pieza_actual
	lw	$a2, pieza_actual_x
	lw	$a3, pieza_actual_y
	jal	imagen_dibuja_imagen
	#for( int y = pieza_actual_y; y < pieza_actual_y + pieza_actual->alto; ++y){
	lw	$s0, pieza_actual_y 	# t0 = y
	la	$t1, pieza_actual	# t1 = pieza_actual
	lw	$t2,4($t1)		# t2 = pieza_actual->alto
	addu	$s1,$s0,$t2		# s1 = pieza_actual_y + pieza_actual->alto
for_bnp:	
	bgeu	$s0,$s1,fin_for_bnp
		#if(comprobar_llena(y)){
	move	$a0,$s0
	jal	comprobar_linea_llena # v0 = 0 si false y v0 = 1 si true
	beqz	$v0, fin_if_bnp       # si v0 == 1
		#puntuacion = puntacion + 10
	la	$t4, puntuacion
	lw	$t5, 0($t4)
	addiu	$t5, $t5, 10
	sw	$t5, 0($t4)
		#}
fin_if_bnp:			
	addiu	$s0,$s0,1
	j	for_bnp	
	#}
fin_for_bnp:	
	jal	nueva_pieza_actual	
bajar_pieza_fin_if:		
	
	lw	$ra,0($sp)
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	addiu	$sp,$sp,12
	jr	$ra

intentar_rotar_pieza_actual:
	addiu	$sp,$sp,-12
	sw	$ra,0($sp)
	sw	$s0,4($sp)
	sw	$s1,8($sp)
	
	la	$s0, imagen_auxiliar	# s0 = pieza_rotada
	la	$s1, pieza_actual	# s1 = pieza_actual
	move	$a0, $s0
	lw	$a1,4($s1)	# pieza_actual->alto
	lw	$a2,0($s1)	# pieza_actual->ancho
	li	$a3,0		# PIXEL VACIO
	jal	imagen_init
	move	$a0,$s0		
	move	$a1,$s1
	li	$a2, 0
	li	$a3, 0
	jal	imagen_dibuja_imagen_rotada
	move	$a0,$s0
	lw	$a1,pieza_actual_x
	lw	$a2,pieza_actual_y
	jal	probar_pieza
	blez	$v0,fin_if_intentar_rotar_pieza_actual
	move	$a0, $s1
	move	$a1,$s0
	jal	imagen_copy
fin_if_intentar_rotar_pieza_actual:	
	lw	$ra,0($sp)
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	addiu	$sp,$sp,12
	jr	$ra

tecla_salir:
	li	$v0, 1
	sb	$v0, acabar_partida	# acabar_partida = true
	jr	$ra

tecla_izquierda:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	lw	$a1, pieza_actual_y
	lw	$t1, pieza_actual_x
	addiu	$a0, $t1, -1
	jal	intentar_movimiento	# intentar_movimiento(pieza_actual_x - 1, pieza_actual_y)
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_derecha:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	lw	$a1, pieza_actual_y
	lw	$t1, pieza_actual_x
	addiu	$a0, $t1, 1
	jal	intentar_movimiento	# intentar_movimiento(pieza_actual_x + 1, pieza_actual_y)
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_abajo:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	bajar_pieza_actual	# bajar_pieza_actual()
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_rotar:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	intentar_rotar_pieza_actual	# intentar_rotar_pieza_actual()
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_truco:
	addiu	$sp, $sp, -20
	sw	$ra, 16($sp)
	sw	$s4, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
       	li	$s4, 18
	#  for (int y = 13; y < 18; ++y) {         
	li	$s0, 13
	#  for (int x = 0; x < campo->ancho - 1; ++x) {
B21_1:	li	$s1, 0
B21_2:	lw	$t1, campo
	addiu	$t1, $t1, -1
	bge	$s1, $t1, B21_3
	la	$a0, campo
	move	$a1, $s1
	move	$a2, $s0
	li	$a3, '#'
	jal	imagen_set_pixel	# imagen_set_pixel(campo, x, y, '#'); 
	addiu	$s1, $s1, 1	# 245   for (int x = 0; x < campo->ancho - 1; ++x) { 
	j	B21_2
B21_3:	addiu	$s0, $s0, 1
	bne	$s0, $s4, B21_1
	la	$a0, campo
	li	$a1, 10
	li	$a2, 16
	li	$a3, 0
	jal	imagen_set_pixel	# imagen_set_pixel(campo, 10, 16, PIXEL_VACIO); 
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s4, 12($sp)
	lw	$ra, 16($sp)
	addiu	$sp, $sp, 20
	jr	$ra

procesar_entrada:
	addiu	$sp, $sp, -20
	sw	$ra, 16($sp)
	sw	$s4, 12($sp)
	sw	$s3, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	jal	keyio_poll_key
	move	$s0, $v0		# int c = keyio_poll_key()
        # for (int i = 0; i < sizeof(opciones) / sizeof(opciones[0]); ++i) { 
	li	$s1, 0			# i = 0, $s1 = i * sizeof(opciones[0]) // = i * 8
	la	$s3, procesar_entrada.opciones	
	li	$s4, 48			# sizeof(opciones) // == 5 * sizeof(opciones[0]) == 5 * 8
B22_1:	addu	$t1, $s3, $s1		# procesar_entrada.opciones + i*8
	lb	$t2, 0($t1)		# opciones[i].tecla
	bne	$t2, $s0, B22_3		# if (opciones[i].tecla != c) siguiente iteración
	lw	$t2, 4($t1)		# opciones[i].accion
	jalr	$t2			# opciones[i].accion()
	jal	actualizar_pantalla	# actualizar_pantalla()
B22_3:	addiu	$s1, $s1, 8		# ++i, $s1 += 8
	bne	$s1, $s4, B22_1		# sigue si i*8 < sizeof(opciones)
        # } // for i
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s3, 8($sp)
	lw	$s4, 12($sp)
	lw	$ra, 16($sp)
	addiu	$sp, $sp, 20
	jr	$ra
	
#PROCEDIMIENTOS NUEVOS

integer_to_string: # Parametros: (n,bufer) a0 = n, a1 = bufer
	# TODO
	move    $t0, $a1		# char *p = buff
	li	$t4, 10			# base = 10 y es t4
	beqz	$a0,finzero		# # if (n = 0)
	# for (int i = n; i > 0; i = i / base) {
        move	$t1, $a0		# int i = abs(n) valor absoluto
        abs     $t1, $a0
B3_3:   blez	$t1, B3_7		# si i <= 0 salta el bucle
	div	$t1, $t4		# i / base
	mflo	$t1			# i = i / base
	mfhi	$t2			# d = i % base
	addiu	$t2, $t2, '0'		# d + '0'
	sb	$t2, 0($t0)		# *p = $t2 
	addiu	$t0, $t0, 1		# ++p
	j	B3_3			# sigue el bucle     
B3_7:	
	#SI n es NEGATIVO
	# *p = '-'
	# p++
	bgtz	$a0,if3
	li	$t1,'-'
	sb	$t1,0($t0)
	addiu	$t0,$t0,1
if3:	
	j	else1
finzero:
	li	$t4,'0'
	sb	$t4,0($t0)
	addiu	$t0,$t0,1
	
else1:	
	sb	$zero, 0($t0)		# *p = '\0'
	addiu	$t0, $t0, -1		# --p	
	# while (!p <= buff)
	# while (p > buff)
while3:				#dar la vuelta
	bgeu	$a1,$t0,fin3
	lb	$t2,0($a1)	# $t2 = 1º posicion
	lb	$t3,0($t0)	# $t3 = ultima poscion
	sb	$t2,0($t0)
	sb	$t3,0($a1)	
	addiu	$t0,$t0,-1
	addiu	$a1,$a1,1
	j	while3
fin3:	
B3_10:	jr	$ra

imagen_dibuja_cadena: #a0 = pantalla, a1 = px, a2 = py, a3 = buffer
	addiu	$sp,$sp,-32
	sw	$ra,0($sp)
	sw	$s0,4($sp)
	sw	$s1,8($sp)
	sw	$s2,12($sp)
	sw	$s3,16($sp)
	sw	$s4,20($sp)
	sw	$s5,24($sp)
	sw	$s6,28($sp)
	
	move	$s0,$a0		#s0 = pantalla
	move	$s1,$a1		#s1 = px
	move	$s2,$a2		#s2 = py
	move	$s3,$a3		#s3 = buffer[0]
	
	# CONVIERTE LA PUNTUACION EN CADENA DE TEXTO
	la	$t0,puntuacion
	lw	$a0,0($t0)	#a0 = puntuacion
	move	$a1, $s3	#a1 = buffer
	jal	integer_to_string 
	
	la	$s4,str003	#t1 = "Puntuacion: "
	lb	$s5,0($s4)	#s4 = 'P'
	lb	$s6,0($s3)	#s6 = *buffer
	
	#Recorrer "Puntuacion: "
while_idc:
	beqz	$s5,fin_while_idc # while(str003[] != \0)
	# set pixel en pantalla
	move	$a0, $s0	#pantalla
	move	$a1, $s1	#px
	move	$a2, $s2	#py
	move	$a3, $s5	#str003[0] = 'P'
	jal	imagen_set_pixel	# a0 = img, a1 = x, a2 = y, a3 = color
	#avanzar en str003
	addiu	$s4,$s4,1	
	#avanzar en el eje x
	addiu	$s1,$s1,1
	#actualizo el valor a comparar
	lb	$s5,0($s4)
	j 	while_idc
fin_while_idc:	
	#Recorrer buffer
	beqz	$s6,fin_while_idc_buffer
	move	$a0,$s0
	move	$a1,$s1
	move	$a2,$s2
	move	$a3,$s6
	jal	imagen_set_pixel
	#avanzar
	addiu	$s3,$s3,1 # buffer++
	addiu	$s1,$s1,1 # px++
	lb	$s6,0($s3) # s6 = buffer++
	j	fin_while_idc								
fin_while_idc_buffer:	
	lw	$ra,0($sp)
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	lw	$s2,12($sp)
	lw	$s3,16($sp)
	lw	$s4,20($sp)
	lw	$s5,24($sp)
	lw	$s6,28($sp)
	addiu	$sp,$sp,32
	jr	$ra	
######################################################################################################
jugar_partida:
	addiu	$sp, $sp, -12	
	sw	$ra, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	la	$a0, pantalla
	li	$a1, 30
	li	$a2, 22
	li	$a3, 32
	jal	imagen_init		# imagen_init(pantalla, 20, 22, ' ')
	la	$a0, campo
	li	$a1, 14
	li	$a2, 18
	li	$a3, 0
	jal	imagen_init		# imagen_init(campo, 14, 18, PIXEL_VACIO)
	la	$a0, campo_siguiente
	li	$a1, 3
	li	$a2, 4
	li	$a3, 0
	jal	imagen_init		# imagen_init(campo_auxiliar, 5, 5, PIXEL_VACIO)
	
	
	jal	pieza_aleatoria		# devuelve la pieza en v0
	la	$a0, pieza_siguiente	# a0 = pieza_siguiente
	move	$a1, $v0		# a1 = pieza_aleatoria ($v0)
	jal	imagen_copy		# imagen_copy(pieza_siguiente,pieza_aleatoria())
	
	jal	nueva_pieza_actual	# nueva_pieza_actual()
	sb	$zero, acabar_partida	# acabar_partida = false
	sb	$zero,acabar_partida_campo_lleno	#acabar_partida_campo_lleno = false
	jal	get_time		# get_time()
	move	$s0, $v0		# Hora antes = get_time()
	jal	actualizar_pantalla	# actualizar_pantalla()
	j	B23_2
        # while (!acabar_partida) { 
B23_2:	lbu	$t1, acabar_partida
	bnez	$t1, B23_5		# if (acabar_partida != 0) sale del bucle
	jal	procesar_entrada	# procesar_entrada()
	jal	get_time		# get_time()
	move	$s1, $v0		# Hora ahora = get_time()
	subu	$t1, $s1, $s0		# int transcurrido = ahora - antes
	ble	$t1, 1000, B23_2	# if (transcurrido < pausa) siguiente iteración
B23_1:	jal	bajar_pieza_actual	# bajar_pieza_actual()
	jal	actualizar_pantalla	# actualizar_pantalla()
	move	$s0, $s1		# antes = ahora
        j	B23_2			# siguiente iteración
       	# } 
       	
B23_5:       	# if (acabar_partido_campo_lleno){
       	lb	$t5, acabar_partida_campo_lleno # t5 = 1 si true, 0 si false
       	beqz	$t5,B23_6		# si acabar_partida_campo_lleno = true
       	la	$a0, pantalla
       	la	$a1, game_over
       	li	$a2, 1
       	li	$a3, 8
       	jal	imagen_dibuja_imagen	#(pantalla,imagen_game_over,1,8)
       	jal	clear_screen		# clear_screen()
	la	$a0, pantalla
	jal	imagen_print		# imagen_print(pantalla)
	# leer caracter
	jal	read_character		# read_character()    	
       #}
B23_6:       	
       	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$ra, 8($sp)
	addiu	$sp, $sp, 12
	jr	$ra

	.globl	main
main:					# ($a0, $a1) = (argc, argv) 
	B24_2:	jal	clear_screen		# clear_screen()
	la	$a0, str000
	jal	print_string		# print_string("Tetris\n\n 1 - Jugar\n 2 - Salir\n\nElige una opción:\n")
	jal	read_character		# char opc = read_character()
	beq	$v0, '2', B24_1		# if (opc == '2') salir
	bne	$v0, '1', B24_5		# if (opc != '1') mostrar error
	jal	jugar_partida		# jugar_partida()
	j	B24_2
B24_1:	la	$a0, str001
	jal	print_string		# print_string("\n¡Adiós!\n")
	li	$a0, 0
	jal	mips_exit		# mips_exit(0)
	j	B24_2
B24_5:	la	$a0, str002
	jal	print_string		# print_string("\nOpción incorrecta. Pulse cualquier tecla para seguir.\n")
	jal	read_character		# read_character()
	j	B24_2
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

print_character:
	li	$v0, 11
	syscall	
	jr	$ra

print_string:
	li	$v0, 4
	syscall	
	jr	$ra

get_time:
	li	$v0, 30
	syscall	
	move	$v0, $a0
	move	$v1, $a1
	jr	$ra

read_character:
	li	$v0, 12
	syscall	
	jr	$ra

clear_screen:
	li	$v0, 39
	syscall	
	jr	$ra

mips_exit:
	li	$v0, 17
	syscall	
	jr	$ra

random_int_range:
	li	$v0, 42
	syscall	
	move	$v0, $a0
	jr	$ra

keyio_poll_key:
	li	$v0, 0
	lb	$t0, 0xffff0000
	andi	$t0, $t0, 1
	beqz	$t0, keyio_poll_key_return
	lb	$v0, 0xffff0004
keyio_poll_key_return:
	jr	$ra
