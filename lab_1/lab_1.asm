%include "io.inc"

section .bss
	buf: resb 1025
	len: resd 1
	tmp_crc: resd 1 
	crc_table: resd 256

section .text
	global main

	main:

		; Ввод строки (длина вычисляется программой)

		PRINT_STRING "Enter the string: "
		GET_STRING buf, 1025

		; Вычисление длины введённой строки

		mov ecx, -1
		loop_start:
			add ecx, 1
			mov al, [buf+ecx]
			cmp al, 0
			jne loop_start
		sub ecx, 1
		mov dword[len], ecx

		; Основная часть программы

		mov eax, 0
		for_i:
			cmp eax, 256
			je next
			mov ebx, eax
			mov ecx, 0

			for_j:
				cmp ecx, 8
				je end_for_i
				mov edx, ebx
				and edx, 1
				cmp edx, 0
				je false

				true:
					shr ebx, 1
					xor ebx, 0xEDB88320
					jmp end_for_j

				false:
					shr ebx, 1

			end_for_j:
				add ecx, 1
				jmp for_j

		end_for_i:
			mov dword[crc_table + 4*eax], ebx
			add eax, 1
			jmp for_i


		next:
			mov ebx, 0xFFFFFFFF ; crc = 0xFFFFFFFF
			mov eax, dword[len] ; eax = len
			mov ecx, 0
			while:
				cmp eax, 0
				je end
				sub eax, 1
				mov dword[tmp_crc], ebx
				xor ebx, dword[buf + ecx]
				add ecx, 1
				and ebx, 0xFF
				mov edx, dword[crc_table + 4*ebx]
				mov ebx, dword[tmp_crc]
				shr ebx, 8
				xor edx, ebx
				mov ebx, edx
				jmp while


		end:
			xor edx, 0xFFFFFFFF
			PRINT_STRING "CRC32 control sum: "
			PRINT_UDEC 4, edx
			NEWLINE
			ret



