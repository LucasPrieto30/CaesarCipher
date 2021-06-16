.data
msj: .asciz "Mensaje: "
mensaje_encriptado: .asciz "\nEste mensaje esta encriptado\n"
desplazamiento_usado: .asciz "\nDesplazamiento usado = -  "
salto_de_linea: .asciz "   \n"
caracteres_procesados: .asciz "\nSe procesaron   "
caracteres: .asciz "   caracteres\n"
texto_entrada: .asciz "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" 
mensaje: .asciz "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" 
clave_en_texto: .asciz ""
offset: .word 0
offset2: .word 0
offset3: .word 0
offset4: .word 0
offset5: .word 0
opcion: .asciz ""
texto_codificado: .asciz ""
.text
.global main

extraer_mensaje:
	.fnstart
	push {lr}
	ciclo_mensaje:
	STR r5, [r3, r8] //concatena el caracter que esta apuntado por r5 al registro de mensaje
	ADD r1, #1	//aumenta una posicion en la cadena
	LDRB r5, [r1]	//pasa al siguiente caracter de la cadena
	ADD r8, #1	//aumenta para que el siguiente caracer se concatene al final de mensaje
	CMP r5, #59	//compara el caracter apuntado con el punto y coma (;)
	BNE ciclo_mensaje //si el caracter es distinto a un punto y coma vuelve a ejecutar la rutina
	ADD r1, #1
	LDRB r5, [r1]
	pop {lr}
	bx lr
	.fnend

extraer_clave:
	.fnstart
	push {lr}
	ciclo_clave:
	STRB r5, [r4, r8]
	ADD r1, #1
	LDRB r5, [r1]
	ADD r8, #1
	CMP r5, #59
	BNE ciclo_clave
	ADD r1, #1
	LDRB r5, [r1]
	MOV r8, #0
	pop {lr}
	bx lr
	.fnend

convertir_ascii_a_entero:
	.fnstart
	push {lr}
	ciclo_convertir_ascii:
	LDRB r9, [r4] //carga en r9 el caracter actual del numero (r4 es la posicion)
	CMP r9, #0
	BEQ fin_ciclo_convertir_ascii
	MUL r12, r6, r10
	MOV r6, r12
	SUB r9, #0x30
	ADD r6, r9
	ADD r4, #1
	BAL ciclo_convertir_ascii
	fin_ciclo_convertir_ascii:
	pop {lr}
	bx lr
	.fnend

convertir_entero_a_ascii:
	.fnstart
	push {lr}
	CMP r10, #10
	BLT fin_ciclo_convertir_entero
	ciclo_convertir_entero:
	SUB r10, #10
	ADD r8, #1
	CMP r10, #10
	BGE ciclo_convertir_entero
	fin_ciclo_convertir_entero:
	pop {lr}
	bx lr
	.fnend

extraer_opcion:
	.fnstart
	push {lr}
	STRB r5, [r8] //concatena el caracter que esta apuntado por r5 al registro de mensaje
	ADD r1, #1	//aumenta una posicion en la cadena
	LDRB r5, [r1]	//pasa al siguiente caracter de la cadena
	pop {lr}
	bx lr
	.fnend


obtener_desplazamiento_para_decodificar:
	.fnstart
	push {lr}
	MOV r8, #0
	MOV r9, #0
	LDRB r5, [r3,r8]
	LDRB r10, [r4,r9]

	CMP r5, r10
	ADDLT r5, #26

	SUB r2, r5, r10
	ADD r8, #1
	ADD r9, #1
	LDRB r5, [r3, r8]
	LDRB r10, [r4,r9]

	CMP r5, r10
	ADDLT r5, #26

	SUB r1, r5, r10
	ciclo_obtener_desplazamiento:
	CMP r10, #0
	BEQ fin_obtener_desplazamiento
	CMP r5, #32
	BEQ saltar_espacio_desplazamiento
	CMP r1, r2
	BNE siguiente_palabra
	ADD r8, #1
	ADD r9, #1
	LDRB r5, [r3, r8]
	LDRB r10, [r4,r9]

	CMP r5, r10
	ADDLT r5, #26

	SUB r1, r5, r10
	BAL ciclo_obtener_desplazamiento
	siguiente_palabra:
	ADD r8, #1
	LDRB r5, [r3, r8]
	CMP r5,#32
	BNE siguiente_palabra
	ADD r8, #1
	LDRB r5, [r3, r8]
	MOV r9, #0
	LDRB r10, [r4, r9]

	CMP r5, r10
	ADDLT r5, #26
	SUB r2, r5, r10
	ADD r8, #1
	ADD r9, #1
	LDRB r5, [r3, r8]
	LDRB r10, [r4,r9]

	CMP r5, r10
	ADDLT r5, #26
	SUB r1, r5, r10
	BAL ciclo_obtener_desplazamiento
	saltar_espacio_desplazamiento:
	ADD r8, #1
	LDRB r5, [r3, r8]
	MOV r9, #0
	LDRB r10, [r4, r9]

	CMP r5, r10
	ADDLT r5, #26
	SUB r2, r5, r10
	ADD r8, #1
	ADD r9, #1
	LDRB r5, [r3, r8]
	LDRB r10, [r4,r9]

	CMP r5, r10
	ADDLT r5, #26
	SUB r1, r5, r10
	BAL ciclo_obtener_desplazamiento
	fin_obtener_desplazamiento:
	MOV r6, r2
	pop {lr}
	bx lr
	.fnend

codificar:
	.fnstart
	push {lr}
	ciclo_codificar:
	CMP r11, #0
	BEQ agregar_bit_de_paridad
	CMP r11, #0x20
	BEQ saltar_espacio
	ADD r11, r6
	CMP r11,#122
	BGT vuelta_al_principio_del_abecedario
	STR r11, [r1, r9]
	ADD r10, #1 	//contador de caracteres procesados
	ADD r3, #1
	LDRB r11, [r3]
	ADD r9, #1
	CMP r11, #0
	BNE ciclo_codificar
	agregar_bit_de_paridad:
	SUB r9, #2
	CMP r9, #2
	BGE agregar_bit_de_paridad
	ADD r9, #48
	STR r9, [r1,r10]
	BAL fin_ciclo_codificar
	saltar_espacio:
	STR r11,[r1, r9]
	ADD r10, #1
	ADD r3, #1
	LDRB r11, [r3]
	ADD r9, #1
	BAL ciclo_codificar
	vuelta_al_principio_del_abecedario:
	SUB r11, #26
	STR r11, [r1, r9]
	ADD r10, #1
	ADD r3, #1
	LDRB r11, [r3]
	ADD r9, #1
	BAL ciclo_codificar
	fin_ciclo_codificar:
	pop {lr}
	bx lr
	.fnend

decodificar:
	.fnstart
	push {lr}
	ciclo_decodificar:
	CMP r11, #0
	BEQ fin_ciclo_decodificar
	CMP r11, #0x20
	BEQ saltar_espacio_decodificar
	SUB r11, r6
	CMP r11,#97
	BLT vuelta_al_final_del_abecedario
	STR r11, [r1, r9]
	ADD r3, #1
	LDRB r11, [r3]
	ADD r9, #1
	CMP r11, #0
	BNE ciclo_decodificar
	BAL fin_ciclo_decodificar
	saltar_espacio_decodificar:
	STR r11,[r1, r9]
	ADD r3, #1
	LDRB r11, [r3]
	ADD r9, #1
	BAL ciclo_decodificar
	vuelta_al_final_del_abecedario:
	ADD r11, #26
	STR r11, [r1, r9]
	ADD r3, #1
	LDRB r11, [r3]
	ADD r9, #1
	BAL ciclo_decodificar
	fin_ciclo_decodificar:
	pop {lr}
	bx lr
	.fnend

main:
	//preparo el sistema para la entrada del mensaje
	MOV r7, #3
	MOV r0, #0

	MOV r2, #150	//longitud del texto_entrada
	LDR r1, =texto_entrada	//guardo el mensaje en r1
	SWI 0 //manda interrupcion

	MOV r8, #0 //contador para concatenar y armar la cadena del mensaje
	LDR r3, =mensaje
	LDRB r5, [r1] //puntero de la cadena
	BL extraer_mensaje

	MOV r8, #0 //reinicio contador
	LDR r4, =clave_en_texto
	MOV r6, #0	//en r6 se va a guardar la clave de codificacion
	BL extraer_clave

	LDR r8, =offset // desplazamiento para que no se guarde la opcion junto a la clave
	LDR r8, =offset2
	LDR r8, =offset3
	LDR r8, =offset4
	LDR r8, =offset5
	LDR r8, =opcion
	BL extraer_opcion

	LDRB r10, [r8]
	CMP r10, #99
	BEQ llamar_codificar
	CMP r10, #100
	BEQ llamar_decodificar

llamar_codificar:
	LDR r1, =texto_codificado
	MOV r9, #0
	LDRB r11, [r3] // puntero de la cadena del mensaje
	MOV r10, #10
	MOV r2, #0
	BL convertir_ascii_a_entero
	MOV r10, #0 //contador de caracteres procesados
	BL codificar
	BL imprimir_codificado
	MOV r8, #0
	BL convertir_entero_a_ascii
	BL imprimir_caracteres_procesados
	BAL fin

llamar_decodificar:
	BL imprimir_aviso_encriptado
	BL obtener_desplazamiento_para_decodificar
	BL imprimir_desplazamiento
	BL imprimir_msj
	LDR r1, =texto_codificado
	MOV r9, #0
	LDRB r11, [r3]
	BL decodificar
	BL imprimir_decodificado
	BAL fin

imprimir_codificado:
	.fnstart
	push {lr}
	MOV r7, #4
	MOV r0, #1
	MOV r2, #150
	LDR r1, =texto_codificado
	SWI 0
	pop {lr}
	bx lr
	.fnend

imprimir_decodificado:
	.fnstart
	push {lr}
	MOV r7, #4
	MOV r0, #1
	MOV r2, #150
	LDR r1, =texto_codificado
	SWI 0

	MOV r7, #4
	MOV r0, #1
	MOV r2, #4
	LDR r1, =salto_de_linea
	SWI 0
	pop {lr}
	bx lr
	.fnend

imprimir_desplazamiento:
	.fnstart
	push {lr}
	MOV r10, r6
	MOV r8, #0
	BL convertir_entero_a_ascii
	LDR r1, =desplazamiento_usado
	ADD r8, #48
	ADD r10, #48
	STR r8, [r1,#25]
	STR r10, [r1, #26]

	MOV r7, #4
	MOV r0, #1
	MOV r2, #27
	LDR r1, =desplazamiento_usado
	SWI 0

	MOV r7, #4
	MOV r0, #1
	MOV r2, #4
	LDR r1, =salto_de_linea
	SWI 0
	pop {lr}
	bx lr
	.fnend

imprimir_msj:
	.fnstart
	push {lr}
	MOV r7, #4
	MOV r0, #1
	MOV r2,#9
	LDR r1, =msj
	SWI 0
	pop {lr}
	bx lr
	.fnend


imprimir_aviso_encriptado:
	.fnstart
	push {lr}
	MOV r7, #4
	MOV r0, #1
	MOV r2,#30
	LDR r1, =mensaje_encriptado
	SWI 0
	pop {lr}
	bx lr
	.fnend

imprimir_caracteres_procesados:
	.fnstart
	push {lr}
	LDR r1, =caracteres_procesados
	ADD r8, #48
	ADD r10, #48
	STR r8, [r1, #15]
	STR r10, [r1, #16]
	MOV r7, #4
	MOV r0, #1
	MOV r2, #18
	LDR r1, =caracteres_procesados
	SWI 0

	MOV r7, #4
	MOV r0, #1
	MOV r2,#14
	LDR r1, =caracteres
	SWI 0
	pop {lr}
	bx lr
	.fnend


fin:
	MOV r7, #1
	SWI 0
