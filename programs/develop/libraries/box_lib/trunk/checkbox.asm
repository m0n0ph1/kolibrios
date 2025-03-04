;��������� ����������� 08.12.2020
;���� ������ 13.02.2009 <Lrz> �� ��� ��������� GPL2 ��������
;Checkbox

;������������� checkbox
align 16
init_checkbox:
;���������� ���-�� �������� � ������ ��������� ������.
	pushad
	mov	ebp,dword [esp+36]	;��������� ��������� �� ���������, ��������� �� �������� � �����
	mov	ebx,dword ch_text_margin	;eax=0
	mov	esi,dword ch_text_ptr   ;��������� �� �������
	lodsb	                        ;� al ������ ������ �� ������
	test	al,al
	jz	.ex_loop
@@:	
	add	ebx,6			;������ �������
	lodsb
	test	al,al
	jnz	@b
.ex_loop:

	mov	dword ch_sz_str,ebx     ;������� ������ ������ � ������ ������� �� ����������
	or	dword ch_text_color,0x80000000 ;��������� ��� ��� ������ ASCIIZ-������
		;�� ������ ���� ������������ ����� ��� �������������� ��������� � ���������
	popad
	ret 4


align 16
check_box_draw:
	pushad   ;�������� ��� �������� 
	mov	ebp,dword [esp+36]	;��������� ��������� �� ���������, ��������� �� �������� � �����
	mcall	SF_DRAW_RECT,ch_left_s,ch_top_s,ch_border_color		;������ ����� ��� �����, ���������� ������ ������������� � ����������� ��� ������ ������ ����� �����

	mov	edx,dword ch_color	;��������� ���� ����
	add	ebx,1 shl 16 - 2 
	add	ecx,1 shl 16 - 2 
	mcall ;����������� ������������ �������� �����

	test dword ch_flags,2  ;������� �������� ���� �� ���������� � ��������� �  ���� CF 
	jz   @f                ;� ���� CF=1, �� �������� ��������� ��������� ����� ������� �� ������ @@
	call check_box_draw_ch ;���������� ���������� ��� ����
@@:
;----------------------------
;������ ���� ����� ���������� ����� ������
;----------------------------
;        mov 	ebx,dword ch_left_s		;��������� �������� (� shl 16 + ������)  ��� ��� �����
;        add	ebx,dword ch_text_margin	;������� ������ ������� � ���������� �� ������� �������� ����� ������
;        shl	ebx,16				;������� �� 16 �������� � ���� (������� �� 65536)
;        add	ebx,dword ch_left_s             ;c������������ ������� �. �.�. ������ � ������� ����� ebx � ��� ����� ������ ������ ������ �� �

;        mov	eax,word ch_top_s		;�������� �������� �� (y shl 16 + ������) ��� ��� �����
;        shr	eax,16				;������� �� 16 �������� � ���� (������� �� 65536)
;        add	eax,dword ch_top_s		;c������������ ������� �. �.�. ������ � ������� ����� ebx � ��� ����� ������ ������ ������ �� Y
	
; ����������� ��� ��
	mov	ebx,dword ch_left_s		;��������� �������� (� shl 16 + ������)  ��� ��� �����
	mov	eax,dword ch_top_s		;�������� �������� �� (y shl 16 + ������) ��� ��� ����� 
	mov	ecx,eax
	add	ebx,dword ch_text_margin	;������� ������ ������� � ���������� �� ������� �������� ����� ������
	shr	eax,16				;������� �� 16 �������� � ����� (�������� �� 65536) � ax ������� �����
	shl	ebx,16				;������� �� 16 �������� � ���� (������� �� 65536)

	sub	ecx,8				;������������ ��������� ������ ������

	test 	dword ch_flags,ch_flag_bottom	;��������, ����� �� �������� ������ �������
	jnz	.bottom

	test 	dword ch_flags,ch_flag_middle	;��������, ����� �� �������� � ����� �������
	jz	.top				;������� ������ top
	
	shr	cx,1				;�������� �� 2
.bottom:
	add	ax,cx
.top:
	add	ebx,dword ch_left_s             ;c������������ ������� �. �.�. ������ � ������� ����� ebx � ��� ����� ������ ������ ������ �� �
	mov	bx,ax
						;ebx � shl 16 +y ���������� ������ �������

	mov	ecx,dword ch_text_color		;�������� ���� ������� + flags
	mov	edx,dword ch_text_ptr		;������ ����� �� ���� ����� �������� ������
	mcall	SF_DRAW_TEXT
	popad					;������������ �������� ��������� �� �����
	ret 4					;������ �� ��������� � ������ �� ����� ��������� �� ��������� (4 �����)

check_box_clear_ch:				;������� ��� �����
	mov	edx,dword ch_color   		;���� ������ ��� �����
	jmp	@f				;����������� ������ �� ������ ����� @@
check_box_draw_ch:				;���������� ���������� ��� ����
        mov	edx,dword ch_border_color	;��������� ����
@@:
;���������� ��������� checkbox
	mov	ebx,dword ch_left_s		;��������� � shl 16 + ������ �� �
	mov	ecx,dword ch_top_s		;��������� Y shl 16 + ������ �� Y
	add	ebx,2 shl 16 - 4		;����� ���� ��������� (X+2) shl 16 +������ �� (�-2)
	add	ecx,2 shl 16 - 4		;����� ���� ��������� (Y+2) shl 16 +������ �� (Y-2)
	mcall	SF_DRAW_RECT ;���������� ������� ������ checkbox
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;���������� mouse
;��� ��������� ����� + ������ ������� � ������� checkbox ��������� ����� ������ ������� �������� - �� ��������.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
align 16
check_box_mouse:      ;��������� ���� 
pushad
	mov	ebp,dword [esp+36]	;��������� ��������� �� ���������, ��������� �� �������� � �����
	mcall	SF_MOUSE_GET,SSF_BUTTON ;��������� ��������� ������ �����. ���� �� ������� ������� ������� �� �����.
	test    eax,eax			;�������� ���� � ��� � eax=0, ������
	jz	.check_box_mouse_end    ;��������� �����������
; �� �������: ������� ������� ����� ���������.        
@@:
	mcall	SF_MOUSE_GET,SSF_WINDOW_POSITION ;�������� ���������� ������� ������������ ����
					;�� ������ � eax x shl 16 + y
;��������� ������� ����� �� Y
	mov	ecx,dword ch_top_s	;y shl 16 +������ �� y
	mov	ebx,ecx
	shr	ebx,16                  ;bx = ���������� �� y
	cmp	ax,bx
	jb	.check_box_mouse_end	;��������� ����� ������ ��������� ���������� �� y ��� ���������� �� Y � �����
;��������� ������ ����� �� Y
	add	cx,bx			;������ ������ �� y � ���������� ������� ����� �� y ������� ���������� ������ ����� �� Y
	cmp	ax,cx
	ja	.check_box_mouse_end	;��������� ����� ������ �������� ���������� �� y ��� ���������� �� Y � �����
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	shr	eax,16			;������� ���������� �� � � ������ ����� �������� �.�. � ax
;��������� �� ��������� ����� �
	mov	ecx,dword ch_left_s	;��������� �������� (� shl 16 + ������)  ��� ��� �����
	mov	ebx,ecx
	shr	ebx,16                  ;bx = ���������� �� X
	cmp	ax,bx
	jb	.check_box_mouse_end	;��������� ����� ������ ��������� ���������� �� X ��� ���������� �� X � �����
;��������� �������� ����� �� X
	add	bx,cx			;������ ������ �� x � ���������� ����� �� � ������� ���������� �������� ����� �� �
	add	bx,word ch_sz_str	;������� ������ ������ ������ � �������� �������������� ������� �� � ������ �������������
	cmp	ax,bx
	ja	.check_box_mouse_end	;��������� ����� ������ �������� ���������� �� � ��� ���������� �� � � �����
;���� ��� �������� ���� ������� �������� �� ������� �������� ��������� �����
	btc	dword	ch_flags,1	;������� 2-�� ���� � cf � �������� ���
	jnc	.enable_box		;���� CF=1 �� ��������� ���������� ���� � ������
	push	dword .check_box_mouse_end	;����� -�����, �������� ����� ������ check_box_clear_ch �� ����� check_box_mouse_end
	jmp	check_box_clear_ch     ;��������� ��� ���� �.�. �� ����� ������������ �������������� ���������� ���� ����.	

.enable_box:
	call	check_box_draw_ch	;���������� ���������� ��� ����
.check_box_mouse_end:
popad					;������������ �������� �� �����
	ret 4				;����� � ����������� ����
