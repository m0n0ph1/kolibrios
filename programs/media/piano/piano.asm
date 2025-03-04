;   ���⮩ �ਬ�� �ணࠬ�� ��� KolibriOS
;   ����稢��� ��� ����⮩ ������
;
;   �������஢��� FASM'��
;        ����� ������ example.asm �१ �ணࠬ�� FASM (�� ��� ����
;        �� ࠡ�祬 �⮫�)
;        � ����� ���� ������ F9 � Tinypad'�. ��� �������樨
;        �⮡ࠦ����� �� ��᪥ �⫠��� (�ணࠬ�� BOARD)
;
;   �� ����� ����� �� �ணࠬ��஢���� ��� ������:
;        ����� �㭪樨 ����頥��� � ॣ���� eax.
;        �맮� ��⥬��� �㭪樨 �����⢫���� �������� "int 0x40".
;        �� ॣ�����, �஬� � 㪠������ � �����頥��� ���祭��,
;        ������ ॣ���� 䫠��� eflags, ��࠭�����.
;
;    �ਬ��:
;        mov eax, 1    ;�㭪�� 1 - ���⠢��� ��� � ����
;                      ;ᯨ᮪ ���㭪権 �. � DOCPACK - sysfuncr.txt
;        mov ebx, 10   ; ���न��� x=10
;        mov ecx, 20   ; ���न��� y=10
;        mov edx, 0xFFFfff ;梥� �窨
;        int 0x40      ;�맢��� �㭪��
;
;    ���� ᠬ�� � �ᯮ�짮������ �����:
;        mcall 1, 10, 20, 0xFFFfff
;---------------------------------------------------------------------

  use32 	     ; ������� 32-���� ०�� ��ᥬ����
  org	 0	     ; ������ � ���

  db	 'MENUET01'  ; 8-����� �����䨪��� MenuetOS
  dd	 1	     ; ����� ��������� (�ᥣ�� 1)
  dd	 START	     ; ���� ��ࢮ� �������
  dd	 I_END	     ; ࠧ��� �ணࠬ��
  dd	 MEM	     ; ������⢮ �����
  dd	 STACKTOP    ; ���� ���設� �����
  dd	 0	     ; ���� ���� ��� ��ࠬ��஢
  dd	 0	     ; ��१�ࢨ஢���

include "lang.inc"
include "../../macros.inc" ; ������ �������� ����� ��ᥬ����騪��!

;---------------------------------------------------------------------
;---  ������ ���������  ----------------------------------------------
;---------------------------------------------------------------------

START:

red:			; ����ᮢ��� ����

    call draw_window	; ��뢠�� ��楤��� ���ᮢ�� ����

;---------------------------------------------------------------------
;---  ���� ��������� �������  ----------------------------------------
;---------------------------------------------------------------------

still:
    ;mcall 10            ; �㭪�� 10 - ����� ᮡ���
    mov eax, 10
    int 0x40

    cmp  eax,2		; ����� ������ ?
    je	 key		; �᫨ �� - �� key
    cmp  eax,3		; ����� ������ ?
    je	 button 	; �᫨ �� - �� button
    cmp  eax,1		; ����ᮢ��� ���� ?
    je	 red		; �᫨ �� - �� ���� red

    jmp  still		; �᫨ ��㣮� ᮡ�⨥ - � ��砫� 横��



;---------------------------------------------------------------------


  key:			; ����� ������ �� ���������
    mcall 2		; �㭪�� 2 - ����� ��� ᨬ���� (� ah)


	cmp   ah, 0x41	      ; A - if Caps Lock ON
	jnz   @f
	jmp   _07
    @@:
	cmp   ah, 0x5a	      ; Z
	jnz   @f
	jmp   _08
    @@:
	cmp   ah, 0x53	      ; S
	jnz   @f
	jmp   _09
    @@:
	cmp   ah, 0x58	      ; X
	jnz   @f
	jmp   _0a
    @@:
	cmp   ah, 0x44	      ; D
	jnz   @f
	jmp   _0b
    @@:
	cmp   ah, 0x43	      ; C
	jnz   @f
	jmp   _0c
    @@:
	cmp   ah, 0x56	      ; V
	jnz   @f
   _01:
	mov   ah, 0x01
	jmp   p
    @@:
	cmp   ah, 0x47	      ; G
	jnz   @f
   _02:
	mov   ah, 0x02
	jmp   p
    @@:
	cmp   ah, 0x42	      ; B
	jnz   @f
   _03:
	mov   ah, 0x03
	jmp   p
    @@:
	cmp   ah, 0x48	      ; H
	jnz   @f
   _04:
	mov   ah, 0x04
	jmp   p
    @@:
	cmp   ah, 0x4e	      ; N
	jnz   @f
   _05:
	mov   ah, 0x05
	jmp   p
    @@:
	cmp   ah, 0x4d	      ; M
	jnz   @f
   _06:
	mov   ah, 0x06
	jmp   p
    @@:
	cmp   ah, 0x4b	      ; K
	jnz   @f
   _07:
	mov   ah, 0x07
	jmp   p
    @@:
	cmp   ah, 0x3c	      ; <
	jnz   @f
   _08:
	mov   ah, 0x08
	jmp   p
    @@:
	cmp   ah, 0x4c	      ; L
	jnz   @f
   _09:
	mov   ah, 0x09
	jmp   p
    @@:
	cmp   ah, 0x3e	      ; >
	jnz   @f
   _0a:
	mov   ah, 0x0a
	jmp   p
    @@:
	cmp   ah, 0x3a	      ; :
	jnz   @f
   _0b:
	mov   ah, 0x0b
	jmp   p
    @@:
	cmp   ah, 0x3f	      ; ?
	jnz   @f
   _0c:
	mov   ah, 0x0c
	jmp   p
    @@:
	cmp   ah, 0x22	      ; "
	jnz   @f
	jmp   _11
    @@:
	cmp   ah, 0x21	      ; key !-------
	jnz   @f
	jmp   _0c
    @@:
	cmp   ah, 0x51	      ; key Q
	jnz   @f
   _11:
	mov   ah, 0x11
	jmp   p
    @@:
	cmp   ah, 0x40	      ; key @
	jnz   @f
   _12:
	mov   ah, 0x12
	jmp   p
    @@:
	cmp   ah, 0x57	      ; key W
	jnz   @f
   _13:
	mov   ah, 0x13
	jmp   p
    @@:
	cmp   ah, 0x23	      ; key #
	jnz   @f
   _14:
	mov   ah, 0x14
	jmp   p
    @@:
	cmp   ah, 0x45	      ; key E
	jnz   @f
   _15:
	mov   ah, 0x15
	jmp   p
    @@:
	cmp   ah, 0x52	      ; key R
	jnz   @f
   _16:
	mov   ah, 0x16
	jmp   p
    @@:
	cmp   ah, 0x25	      ; key %
	jnz   @f
	jmp   _17
    @@:
	cmp   ah, 0x54	      ; key T
	jnz   @f
	jmp   _18
    @@:
	cmp   ah, 0x5e	      ; key ^
	jnz   @f
	jmp   _19
    @@:
	cmp   ah, 0x59	      ; key Y
	jnz   @f
	jmp   _1a
    @@:
	cmp   ah, 0x26	      ; key &
	jnz   @f
	jmp   _1b
    @@:
	cmp   ah, 0x55	      ; key U
	jnz   @f
	jmp   _1c
    @@:
	cmp   ah, 0x49	      ; key I
	jnz   @f
	jmp   _21
    @@:
	cmp   ah, 0x28	      ; key (
	jnz   @f
	jmp   _22
    @@:
	cmp   ah, 0x4f	      ; key O
	jnz   @f
	jmp   _23
    @@:
	cmp   ah, 0x29	      ; key )
	jnz   @f
	jmp   _24
    @@:
	cmp   ah, 0x50	      ; key P
	jnz   @f
	jmp   _25
    @@:
	cmp   ah, 0x7b	      ; key {
	jnz   @f
	jmp   _26
    @@:
	cmp   ah, 0x2b	      ; key +
	jnz   @f
	jmp   _27
    @@:
	cmp   ah, 0x7d	      ; key }
	jnz   @f
	jmp   _28
    @@:
	cmp   ah, 0x7c	      ; key |
	jnz   @f
	jmp   _29
    @@:
	cmp   ah, 0x61	      ; a - if Caps Lock OFF
	jnz   @f
   _17:
	mov   ah, 0x17
	jmp   p
    @@:
	cmp   ah, 0x7a	      ; z
	jnz   @f
   _18:
	mov   ah, 0x18
	jmp   p
    @@:
	cmp   ah, 0x73	      ; s
	jnz   @f
   _19:
	mov   ah, 0x19
	jmp   p
    @@:
	cmp   ah, 0x78	      ; x
	jnz   @f
   _1a:
	mov   ah, 0x1a
	jmp   p
    @@:
	cmp   ah, 0x64	      ; d
	jnz   @f
   _1b:
	mov   ah, 0x1b
	jmp   p
    @@:
	cmp   ah, 0x63	      ; c
	jnz   @f
   _1c:
	mov   ah, 0x1c
	jmp   p
    @@:
	cmp   ah, 0x76	      ; v
	jnz   @f
   _21:
	mov   ah, 0x21
	jmp   p
    @@:
	cmp   ah, 0x67	      ; g
	jnz   @f
   _22:
	mov   ah, 0x22
	jmp   p
    @@:
	cmp   ah, 0x62	      ; b
	jnz   @f
   _23:
	mov   ah, 0x23
	jmp   p
    @@:
	cmp   ah, 0x68	      ; h
	jnz   @f
   _24:
	mov   ah, 0x24
	jmp   p
    @@:
	cmp   ah, 0x6e	      ; n
	jnz   @f
   _25:
	mov   ah, 0x25
	jmp   p
    @@:
	cmp   ah, 0x6d	      ; m
	jnz   @f
   _26:
	mov   ah, 0x26
	jmp   p
    @@:
	cmp   ah, 0x6b	      ; k
	jnz   @f
   _27:
	mov   ah, 0x27
	jmp   p
    @@:
	cmp   ah, 0x2c	      ; ,
	jnz   @f
   _28:
	mov   ah, 0x28
	jmp   p
    @@:
	cmp   ah, 0x6c	      ; l
	jnz   @f
   _29:
	mov   ah, 0x29
	jmp   p
    @@:
	cmp   ah, 0x2e	      ; .
	jnz   @f
   _2a:
	mov   ah, 0x2a
	jmp   p
    @@:
	cmp   ah, 0x3b	      ; ;
	jnz   @f
   _2b:
	mov   ah, 0x2b
	jmp   p
    @@:
	cmp   ah, 0x2f	      ; /
	jnz   @f
   _2c:
	mov   ah, 0x2c
	jmp   p
    @@:
	cmp   ah, 0x27	      ; '
	jnz   @f
  _31:
	mov   ah, 0x31
	jmp   p
    @@:
	cmp   ah, 0x60	      ; key `
	jnz   @f
	jmp   _2c
    @@:
	cmp   ah, 0x09	      ; key tab
	jnz   @f
	jmp   _31
    @@:
	cmp   ah, 0x31	      ; key 1
	jnz   @f
  _32:
	mov   ah, 0x32
	jmp   p
    @@:
	cmp   ah, 0x71	      ; key q
	jnz   @f
  _33:
	mov   ah, 0x33
	jmp   p
    @@:
	cmp   ah, 0x32	      ; key 2
	jnz   @f
  _34:
	mov   ah, 0x34
	jmp   p
    @@:
	cmp   ah, 0x77	      ; key w
	jnz   @f
  _35:
	mov   ah, 0x35
	jmp   p
    @@:
	cmp   ah, 0x65	      ; key e
	jnz   @f
  _36:
	mov   ah, 0x36
	jmp   p
    @@:
	cmp   ah, 0x34	      ; key 4
	jnz   @f
  _37:
	mov   ah, 0x37
	jmp   p
    @@:
	cmp   ah, 0x72	      ; key r
	jnz   @f
  _38:
	mov   ah, 0x38
	jmp   p
    @@:
	cmp   ah, 0x35	      ; key 5
	jnz   @f
  _39:
	mov   ah, 0x39
	jmp   p
    @@:
	cmp   ah, 0x74	      ; key t
	jnz   @f
  _3a:
	mov   ah, 0x3a
	jmp   p
    @@:
	cmp   ah, 0x36	      ; key 6
	jnz   @f
  _3b:
	mov   ah, 0x3b
	jmp   p
    @@:
	cmp   ah, 0x79	      ; key y
	jnz   @f
  _3c:
	mov   ah, 0x3c
	jmp   p
    @@:
	cmp   ah, 0x75	      ; key u
	jnz   @f
  _41:
	mov   ah, 0x41
	jmp   p
    @@:
	cmp   ah, 0x38	      ; key 8
	jnz   @f
	mov   ah, 0x42
	jmp   p
    @@:
	cmp   ah, 0x69	      ; key i
	jnz   @f
	mov   ah, 0x43
	jmp   p
    @@:
	cmp   ah, 0x39	      ; key 9
	jnz   @f
	mov   ah, 0x44
	jmp   p
    @@:
	cmp   ah, 0x6f	      ; key o
	jnz   @f
	mov   ah, 0x45
	jmp   p
    @@:
	cmp   ah, 0x70	      ; key p
	jnz   @f
	mov   ah, 0x46
	jmp   p
    @@:
	cmp   ah, 0x2d	      ; key -
	jnz   @f
	mov   ah, 0x47
	jmp   p
    @@:
	cmp   ah, 0x5b	      ; key [
	jnz   @f
	mov   ah, 0x48
	jmp   p
    @@:
	cmp   ah, 0x3d	      ; key =
	jnz   @f
	mov   ah, 0x49
	jmp   p
    @@:
	cmp   ah, 0x5d	      ; key ]
	jnz   @f
	mov   ah, 0x4a
	jmp   p
    @@:
	cmp   ah, 0x5c	      ; key \
	jnz   @f
	mov   ah, 0x4b
	jmp   p
    @@:
	cmp   ah, 0x08	      ; key backspace
	jnz   @f
	mov   ah, 0x4c
	jmp   p
    @@:
	cmp   ah, 0x0d	      ; key enter
	jnz   @f
	mov   ah, 0x51
	jmp   p
    @@:
	cmp   ah, 0x66	      ; key f
	jnz   @f
	mov   ah, 0x01
	jmp   p
    @@:
	cmp   ah, 0x6a	      ; key j
	jnz   @f
	mov   ah, 0x05
	jmp   p
    @@:
	cmp   ah, 0x33	      ; key 3
	jnz   @f
	mov   ah, 0x08
	jmp   p
    @@:
	cmp   ah, 0x37	      ; key 7
	jnz   @f
	jmp   _11
    @@:
	cmp   ah, 0x30	      ; key 0
	jnz   @f
	jmp   _15
    @@:
	cmp   ah, 0xb4	      ; key home
	jnz   @f
	mov   ah, 0x10
	jmp   p
    @@:
	cmp   ah, 0xb5	      ; key end
	jnz   @f
   _70:
	mov   ah, 0xfc
	jmp   p
    @@:
	cmp   ah, 0xb8	      ; key Page Up
	jnz   @f
	mov   ah, 0x20
	jmp   p
    @@:
	cmp   ah, 0xb7	      ; key Page Down
	jnz   @f
	jmp   _70
    @@:
	cmp   ah, 0xff	      ; key F12
	jnz   @f
	mov   ah, 0x00
	jmp   p
    @@:
	cmp   ah, 0xb6	      ; key Del
	jnz   @f
	jmp   _70
    @@:

  p:
    mov  [M+1], ah  ; ������� ��� ᨬ���� ��� ��� ����

    ; �㭪�� 55-55: ��⥬�� ������� ("PlayNote")
    ;   esi - ���� �������

       mov  eax,55
       mov  ebx,eax
       mov  esi,M
       int  0x40

    ; ��� ���⪮:
    ;mcall 55, , , , Music

    jmp  still		; �������� � ��砫� 横��


;---------------------------------------------------------------------

  button:
    mcall 17		; 17 - ������� �����䨪��� ����⮩ ������

	cmp  ah, 0xa1	    ; button 1
	jnz  @f
	jmp  _01
    @@:
	cmp  ah, 0x02	    ; button 2
	jnz  @f
	jmp  _02
    @@:
	cmp  ah, 0x03	    ; button 3
	jnz  @f
	jmp  _03
    @@:
	cmp  ah, 0x04
	jnz  @f
	jmp  _04
    @@:
	cmp  ah, 0x05
	jnz  @f
	jmp  _05
    @@:
	cmp  ah, 0x06
	jnz  @f
	jmp  _06
    @@:
	cmp  ah, 0x07
	jnz  @f
	jmp  _07
    @@:
	cmp  ah, 0x08	    ; button 8
	jnz  @f
	jmp  _08
    @@:
	cmp  ah, 0x09
	jnz  @f
	jmp  _09
    @@:
	cmp  ah, 0x0a	    ; button 10
	jnz  @f
	jmp  _0a
    @@:
	cmp  ah, 0x0b
	jnz  @f
	jmp  _0b
    @@:
	cmp  ah, 0x0c	    ; button 12
	jnz  @f
	jmp  _0c
    @@:

	cmp  ah, 0x11
	jnz  @f
	jmp  _11
    @@:
	cmp  ah, 0x12
	jnz  @f
	jmp  _12
    @@:
	cmp  ah, 0x13
	jnz  @f
	jmp  _13
    @@:
	cmp  ah, 0x14
	jnz  @f
	jmp  _14
    @@:
	cmp  ah, 0x15
	jnz  @f
	jmp  _15
    @@:
	cmp  ah, 0x16
	jnz  @f
	jmp  _16
    @@:
	cmp  ah, 0x17
	jnz  @f
	jmp  _17
    @@:
	cmp  ah, 0x18
	jnz  @f
	jmp  _18
    @@:
	cmp  ah, 0x19
	jnz  @f
	jmp  _19
    @@:
	cmp  ah, 0x1a
	jnz  @f
	jmp  _1a
    @@:
	cmp  ah, 0x1b
	jnz  @f
	jmp  _1b
    @@:
	cmp  ah, 0x1c
	jnz  @f
	jmp  _1c
    @@:

	cmp  ah, 0x21	    ; button 1
	jnz  @f
	jmp  _21
    @@:
	cmp  ah, 0x22
	jnz  @f
	jmp  _22
    @@:
	cmp  ah, 0x23	    ; button 3
	jnz  @f
	jmp  _23
    @@:
	cmp  ah, 0x24
	jnz  @f
	jmp  _24
    @@:
	cmp  ah, 0x25	    ; button 5
	jnz  @f
	jmp  _25
    @@:
	cmp  ah, 0x26
	jnz  @f
	jmp  _26
    @@:
	cmp  ah, 0x27	    ; button 7
	jnz  @f
	jmp  _27
    @@:
	cmp  ah, 0x28
	jnz  @f
	jmp  _28
    @@:
	cmp  ah, 0x29	    ; button 9
	jnz  @f
	jmp  _29
    @@:
	cmp  ah, 0x2a
	jnz  @f
	jmp  _2a
    @@:
	cmp  ah, 0x2b	    ; button 11
	jnz  @f
	jmp  _2b
    @@:
	cmp  ah, 0x2c
	jnz  @f
	jmp  _2c
    @@:
	cmp  ah, 0x31
	jnz  @f
	jmp  _31

    @@:
	cmp  ah, 0x32
	jnz  @f
	jmp  _32
    @@:
	cmp  ah, 0x33
	jnz  @f
	jmp  _33
    @@:
	cmp  ah, 0x34
	jnz  @f
	jmp  _34
    @@:
	cmp  ah, 0x35
	jnz  @f
	jmp  _35
    @@:
	cmp  ah, 0x36
	jnz  @f
	jmp  _36
    @@:
	cmp  ah, 0x37
	jnz  @f
	jmp  _37
    @@:
	cmp  ah, 0x38
	jnz  @f
	jmp  _38
    @@:
	cmp  ah, 0x39
	jnz  @f
	jmp  _39
    @@:
	cmp  ah, 0x3a
	jnz  @f
	jmp  _3a
    @@:
	cmp  ah, 0x3b
	jnz  @f
	jmp  _3b
    @@:
	cmp  ah, 0x3c
	jnz  @f
	jmp  _3c
    @@:
	cmp  ah, 0x41
	jnz  @f
	jmp  _41
    @@:

    cmp   ah, 1 	; �᫨ �� ����� ������ � ����஬ 1,
    jne   still 	;  ��������

  .exit:
    mcall -1		; ���� ����� �ணࠬ��


;---------------------------------------------------------------------
;---  ����������� � ��������� ����  ----------------------------------
;---------------------------------------------------------------------

WHITE_W=48   ; While key width
BLACK_W=30   ; Black key width
BLACK_X=34   ; Black key X offset

draw_window:

    mcall 12, 1       ; �㭪�� 12: ᮮ���� �� � ��砫� ���ᮢ��

    mcall 48, 3, sc,sizeof.system_colors

    ; �����: ᭠砫� ������ ��ਠ�� (���������஢����)
    ; ��⥬ ���⪨� ������ � �ᯮ�짮������ ����ᮢ

;   mov  eax,0                   ; �㭪�� 0: ��।����� ����
;   mov  ebx,200*65536+300       ; [x ����] *65536 + [x ࠧ���]
;   mov  ecx,200*65536+150       ; [y ����] *65536 + [y ࠧ���]
;   mov  edx, [sc.work]          ; 梥� 䮭�
;   or   edx, 0x33000000         ; � ⨯ ���� 3
;   mov  edi,header              ; ��������� ����
;   int  0x40

    mov   edx, [sc.work]	 ; 梥� 䮭�
    or	  edx, 0x33000000	 ; � ⨯ ���� 3
    mcall 0, <20,WHITE_W*15+9>, <200,250>, , ,caption
	
    mcall 8,  <WHITE_W*0,WHITE_W>, <0,100>, 0x21, 0xff7a74
    mcall 8,  <WHITE_W*1,WHITE_W>, <0,100>, 0x23, 0x907040
    mcall 8,  <WHITE_W*2,WHITE_W>, <0,100>, 0x25, 0xa08050
    mcall 8,  <WHITE_W*3,WHITE_W>, <0,100>, 0x26, 0xb09060
    mcall 8,  <WHITE_W*4,WHITE_W>, <00,100>, 0x28, 0xc0a070
    mcall 8,  <WHITE_W*5,WHITE_W>, <00,100>, 0x2a, 0xd0b080
    mcall 8,  <WHITE_W*6,WHITE_W>, <0,100>, 0x2c, 0xe0c090
    mcall 8,  <WHITE_W*7,WHITE_W>, <0,100>, 0x31, 0xffa97c
    mcall 8,  <WHITE_W*8,WHITE_W>, <0,100>, 0x33, 0xaf8d8d
    mcall 8,  <WHITE_W*9,WHITE_W>, <0,100>, 0x35, 0xbf9d9d
    mcall 8,  <WHITE_W*10,WHITE_W>, <0,100>, 0x36, 0xcfadad
    mcall 8,  <WHITE_W*11,WHITE_W>, <00,100>, 0x38, 0xdfbdbd
    mcall 8,  <WHITE_W*12,WHITE_W>, <00,100>, 0x3a, 0xefcdcd
    mcall 8,  <WHITE_W*13,WHITE_W>, <0,100>, 0x3c, 0xffdddd
    mcall 8,  <WHITE_W*14,WHITE_W>, <0,100>, 0x41, 0xffe558

    mcall 8,  <WHITE_W*0+BLACK_X,BLACK_W>, <0,50>, 0x22, 0x221100
    mcall 8,  <WHITE_W*1+BLACK_X,BLACK_W>, <0,50>, 0x24, 0x221100
    mcall 8,  <WHITE_W*3+BLACK_X,BLACK_W>, <0,50>, 0x27, 0x221100
    mcall 8,  <WHITE_W*4+BLACK_X,BLACK_W>, <0,50>, 0x29, 0x221100
    mcall 8,  <WHITE_W*5+BLACK_X,BLACK_W>, <0,50>, 0x2b, 0x221100
    mcall 8,  <WHITE_W*7+BLACK_X,BLACK_W>, <0,50>, 0x32, 0x221100
    mcall 8,  <WHITE_W*8+BLACK_X,BLACK_W>, <0,50>, 0x34, 0x221100
    mcall 8,  <WHITE_W*10+BLACK_X,BLACK_W>, <0,50>, 0x37, 0x221100
    mcall 8,  <WHITE_W*11+BLACK_X,BLACK_W>, <0,50>, 0x39, 0x221100
    mcall 8,  <WHITE_W*12+BLACK_X,BLACK_W>, <0,50>, 0x3b, 0x221100

    mcall 8,  <WHITE_W*0,WHITE_W>, <100,100>, 0xa1, 0x702050
    mcall 8,  <WHITE_W*1,WHITE_W>, <100,100>, 0x03, 0x683638
    mcall 8,  <WHITE_W*2,WHITE_W>, <100,100>, 0x05, 0x784648
    mcall 8,  <WHITE_W*3,WHITE_W>, <100,100>, 0x06, 0x885658
    mcall 8,  <WHITE_W*4,WHITE_W>, <100,100>, 0x08, 0x986668
    mcall 8,  <WHITE_W*5,WHITE_W>, <100,100>, 0x0a, 0xa87678
    mcall 8,  <WHITE_W*6,WHITE_W>, <100,100>, 0x0c, 0xb88688
    mcall 8,  <WHITE_W*7,WHITE_W>, <100,100>, 0x11, 0x880040
    mcall 8,  <WHITE_W*8,WHITE_W>, <100,100>, 0x13, 0x90622b
    mcall 8,  <WHITE_W*9,WHITE_W>, <100,100>, 0x15, 0xa0723b
    mcall 8,  <WHITE_W*10,WHITE_W>, <100,100>, 0x16, 0xb0824b
    mcall 8,  <WHITE_W*11,WHITE_W>, <100,100>, 0x18, 0xc0925b
    mcall 8,  <WHITE_W*12,WHITE_W>, <100,100>, 0x1a, 0xd0a26b
    mcall 8,  <WHITE_W*13,WHITE_W>, <100,100>, 0x1c, 0xe0b27b
    mcall 8,  <WHITE_W*14,WHITE_W>, <100,100>, 0x21, 0xff7a74

    mcall 8,  <WHITE_W*0+BLACK_X,BLACK_W>, <100,50>, 0x02, 0x221100
    mcall 8,  <WHITE_W*1+BLACK_X,BLACK_W>, <100,50>, 0x04, 0x221100
    mcall 8,  <WHITE_W*3+BLACK_X,BLACK_W>, <100,50>, 0x07, 0x221100
    mcall 8,  <WHITE_W*4+BLACK_X,BLACK_W>, <100,50>, 0x09, 0x221100
    mcall 8,  <WHITE_W*5+BLACK_X,BLACK_W>, <100,50>, 0x0b, 0x221100
    mcall 8,  <WHITE_W*7+BLACK_X,BLACK_W>, <100,50>, 0x12, 0x221100
    mcall 8,  <WHITE_W*8+BLACK_X,BLACK_W>, <100,50>, 0x14, 0x221100
    mcall 8,  <WHITE_W*10+BLACK_X,BLACK_W>, <100,50>, 0x17, 0x221100
    mcall 8,  <WHITE_W*11+BLACK_X,BLACK_W>, <100,50>, 0x19, 0x221100
    mcall 8,  <WHITE_W*12+BLACK_X,BLACK_W>, <100,50>, 0x1b, 0x221100


    ; �뢮� ⥪�⮢�� ��ப�
    mov   ecx, [sc.work_text]	 ; 梥� 䮭�
    or	  ecx, 0x90000000	 ; � ⨯ ��ப�
    mcall 4, <50, 205>, , message
    mcall 4, <10, 235>, , message1
    mcall 4, <10, 260>, , message2
    mcall 4, <10, 285>, , message3
    mcall 4, <10, 310>, , message4
    mcall 4, <16, 185>, , t_notes

    mcall 12, 2 		 ; �㭪�� 12.2, �����稫� �ᮢ���

    ret 			 ; ��室�� �� ��楤���


;---------------------------------------------------------------------
;---  ������ ���������  ----------------------------------------------
;---------------------------------------------------------------------


; ��ன ���� � M (Music) ��������� ����⨥� ������

M:
  db  0x90, 0x30, 0


sc system_colors

if lang eq ru
  message  db '��ࠢ��: �񫪭�� 2 ࠧ� �� ���������.',0
  message1 db '������ ���� ������� � ������᪮� �᪫���� - ',0
  message2 db '������ ������ ���஥��� ������� �������� (�� �������!)',0
  message3 db '��� "��" - ������ V,Tab,U,Enter',0
  message4 db '�� ����祭�� Caps Lock - ������ V,Q,I.',0
  t_notes  db '��    ��    ��    ��   ����   ��    ��    ��',0
  caption  db '���᪮� �������',0
else
  message  db 'To see help click twice on the window header',0
  message1 db 'Press any key in English keyboard layout - ',0
  message2 db 'so you will hear the sound from the PC-speaker (Beeper)',0
  message3 db 'Note "C" is the key V,Tab,U,Enter',0
  message4 db 'and when Caps Lock is on then the keys V,Q,I.',0
  t_notes  db 'C     D     E     F     G     A     B     C ',0
  caption  db 'Baby piano',0
end if

;---------------------------------------------------------------------

I_END:			; ��⪠ ���� �ணࠬ��
  rb 4096		; ������ ��� �⥪�
align 16
STACKTOP:		; ��⪠ ���設� �⥪� (�� ���������� �⥪
			; ���� � ��஭� 㬥��襭�� ���ᮢ, ��⮬�
			; ������ ��� ���� � ���� �ணࠬ�� ����砥���
			; ࠭�� 祬 ��� ���設�)
MEM:			; ��⪠ 㪠�뢠��� �� ����� �ணࠬ�� ����
			; ࠧ��� �ᯮ��㥬�� �� ����⨢��� �����
; ���� ��⪨ MEM �ᥣ�� ������ ���� ����� 祬 ���� ��⪨ I_END.
; ��⪠ STACKTOP ������ �ᯮ�������� ��᫥ ��⪨ I_END � ��। ��⪮�
;   MEM. STACKTOP ����� ��室���� � ��। I_END, �� �� �� �ࠢ��쭮.
; ����� ��⮪ ����� ���� � ��묨 �������ﬨ, ������� ᮡ���
;   �ࠢ���� ���冷� �� �ᯮ�������.