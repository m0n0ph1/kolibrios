use32
	org 0
	db 'MENUET01' ;������. �ᯮ��塞��� 䠩�� �ᥣ�� 8 ����
	dd 1,start,i_end,mem,stacktop,0,cur_dir_path

include '../../../../../macros.inc'
include '../../../../../proc32.inc'
include '../../../../../KOSfuncs.inc'
include '../../../../../load_lib.mac'
include '../../../../../dll.inc'

@use_library mem.Alloc,mem.Free,mem.ReAlloc, 0 ;dll.Load

struct FileInfoBlock
	Function dd ?
	Position dd ?
	Flags	 dd ?
	Count	 dd ?
	Buffer	 dd ?
		db ?
	FileName dd ?
ends

max_open_file_size equ 64*1024 ;64 Kb

align 4
open_file_vox dd 0 ;㪠��⥫� �� ������� ��� ������ 䠩���
run_file_70 FileInfoBlock
f_name db 'vaz2106.vox',0

BUF_STRUCT_SIZE equ 21
vox_offs_tree_table equ 4

;������ ��ꥪ� �� 90 �ࠤ�ᮢ
;x0y0 - x1y0
;x1y0 - x1y1
;x0y1 - x0y0
;x1y1 - x0y1
align 4
proc vox_obj_rot_z uses eax ebx ecx, v_obj:dword
	mov ebx,[v_obj]
	add ebx,vox_offs_tree_table
	mov ecx,2
	cld
	@@:
		mov eax,dword[ebx]
		mov byte[ebx+1],al
		mov byte[ebx+3],ah
		shr eax,16
		mov byte[ebx],al
		mov byte[ebx+2],ah
		add ebx,4
		loop @b
	ret
endp



align 4
start:
	load_library name_buf2d, library_path, system_path, import_buf2d_lib
	cmp eax,-1
	jz button.exit

	mcall SF_SET_EVENTS_MASK,0x27
	stdcall [buf2d_create], buf_0 ;ᮧ���� ����
	stdcall [buf2d_create], buf_z
	stdcall [buf2d_vox_brush_create], buf_vox, vox_6_7_z ;ᮧ���� ���ᥫ��� �����

	stdcall mem.Alloc,max_open_file_size
	mov dword[open_file_vox],eax

	copy_path f_name,[32],file_name,0

	mov eax,70 ;70-� �㭪�� ࠡ�� � 䠩����
	mov [run_file_70.Function], 0
	mov [run_file_70.Position], 0
	mov [run_file_70.Flags], 0
	mov dword[run_file_70.Count], max_open_file_size
	m2m [run_file_70.Buffer], [open_file_vox]
	mov byte[run_file_70+20], 0
	mov dword[run_file_70.FileName], file_name
	mov ebx,run_file_70
	int 0x40 ;����㦠�� ���ᥫ�� ��ꥪ�

	stdcall [buf2d_vox_obj_draw_3g], buf_0, buf_z, buf_vox,\
		[open_file_vox], 0,0, 0, 6 ;��㥬 ���ᥫ�� ��ꥪ�
	stdcall [buf2d_vox_obj_draw_3g_shadows], buf_0, buf_z, buf_vox,\
		0,0, 0, 6, 3 ;��㥬 ⥭�

	stdcall vox_obj_rot_z, [open_file_vox] ;�����稢���
	stdcall [buf2d_vox_obj_draw_3g], buf_0, buf_z, buf_vox, [open_file_vox], 0,0, 0, 5
	stdcall vox_obj_rot_z, [open_file_vox]
	stdcall [buf2d_vox_obj_draw_3g], buf_0, buf_z, buf_vox, [open_file_vox], 100,0, 0, 5
	stdcall vox_obj_rot_z, [open_file_vox]
	stdcall [buf2d_vox_obj_draw_3g], buf_0, buf_z, buf_vox, [open_file_vox], 200,0, 0, 5

align 4
red_win:
	call draw_window

align 4
still:
	mcall SF_WAIT_EVENT
	cmp al,1 ;���������� ��������� ����
	jz red_win
	cmp al,2
	jz key
	cmp al,3
	jz button
	jmp still

align 4
draw_window:
	pushad
	mcall SF_REDRAW,SSF_BEGIN_DRAW

	mov edx,0x33000000
	mcall SF_CREATE_WINDOW,(50 shl 16)+410,(30 shl 16)+480,,,caption

	stdcall [buf2d_draw], buf_0

	mcall SF_REDRAW,SSF_END_DRAW
	popad
	ret

align 4
key:
	mcall SF_GET_KEY

	cmp ah,27 ;Esc
	je button.exit

	jmp still

align 4
button:
	mcall SF_GET_BUTTON
	cmp ah,1
	jne still
.exit:
	stdcall [buf2d_delete],buf_0 ;㤠�塞 ����
	stdcall [buf2d_delete],buf_z
	stdcall [buf2d_vox_brush_delete],buf_vox
	stdcall mem.Free,[open_file_vox]
	mcall SF_TERMINATE_PROCESS

caption db 'Test buf2d library, [Esc] - exit',0

;--------------------------------------------------
align 4
import_buf2d_lib:
	dd sz_lib_init
	buf2d_create dd sz_buf2d_create
	buf2d_clear dd sz_buf2d_clear
	buf2d_draw dd sz_buf2d_draw
	buf2d_delete dd sz_buf2d_delete

	;���ᥫ�� �㭪樨:
	buf2d_vox_brush_create dd sz_buf2d_vox_brush_create
	buf2d_vox_brush_delete dd sz_buf2d_vox_brush_delete
	;buf2d_vox_obj_draw_1g dd sz_buf2d_vox_obj_draw_1g
	;buf2d_vox_obj_get_img_w_3g dd sz_buf2d_vox_obj_get_img_w_3g
	;buf2d_vox_obj_get_img_h_3g dd sz_buf2d_vox_obj_get_img_h_3g
	buf2d_vox_obj_draw_3g dd sz_buf2d_vox_obj_draw_3g
	;buf2d_vox_obj_draw_3g_scaled dd sz_buf2d_vox_obj_draw_3g_scaled
	buf2d_vox_obj_draw_3g_shadows dd sz_buf2d_vox_obj_draw_3g_shadows
	;buf2d_vox_obj_draw_pl dd sz_buf2d_vox_obj_draw_pl
	;buf2d_vox_obj_draw_pl_scaled dd sz_buf2d_vox_obj_draw_pl_scaled

	dd 0,0
	sz_lib_init db 'lib_init',0
	sz_buf2d_create db 'buf2d_create',0
	sz_buf2d_clear db 'buf2d_clear',0
	sz_buf2d_draw db 'buf2d_draw',0
	sz_buf2d_delete db 'buf2d_delete',0

	;���ᥫ�� �㭪樨:
	sz_buf2d_vox_brush_create db 'buf2d_vox_brush_create',0
	sz_buf2d_vox_brush_delete db 'buf2d_vox_brush_delete',0
	;sz_buf2d_vox_obj_draw_1g db 'buf2d_vox_obj_draw_1g',0
	;sz_buf2d_vox_obj_get_img_w_3g db 'buf2d_vox_obj_get_img_w_3g',0
	;sz_buf2d_vox_obj_get_img_h_3g db 'buf2d_vox_obj_get_img_h_3g',0
	sz_buf2d_vox_obj_draw_3g db 'buf2d_vox_obj_draw_3g',0
	;sz_buf2d_vox_obj_draw_3g_scaled db 'buf2d_vox_obj_draw_3g_scaled',0
	sz_buf2d_vox_obj_draw_3g_shadows db 'buf2d_vox_obj_draw_3g_shadows',0
	;sz_buf2d_vox_obj_draw_pl db 'buf2d_vox_obj_draw_pl',0
	;sz_buf2d_vox_obj_draw_pl_scaled db 'buf2d_vox_obj_draw_pl_scaled',0

align 4
buf_0: ;���� �᭮����� ����ࠦ����
	dd 0 ;㪠��⥫� �� ���� ����ࠦ����
	dw 5 ;+4 left
	dw 3 ;+6 top
	dd 6*64 ;+8 w
	dd 7*64 ;+12 h
	dd 0xffffff ;+16 color
	db 24 ;+20 bit in pixel

align 4
buf_z: ;���� ��㡨��
	dd 0 ;㪠��⥫� �� ���� ����ࠦ����
	dw 0 ;+4 left
	dw 0 ;+6 top
	dd 6*64 ;+8 w
	dd 7*64 ;+12 h
	dd 0 ;+16 color
	db 32 ;+20 bit in pixel

;����� ��� ᮧ����� �������쭮�� �����筮�� ���ᥫ�
align 4
vox_6_7_z:
dd 0,0,1,1,0,0,\
   0,2,2,2,2,0,\
   2,2,2,2,2,2,\
   2,3,2,2,3,2,\
   2,3,3,3,3,2,\
   0,3,3,3,3,0,\
   0,0,3,3,0,0

align 4
buf_vox:
	db 6,7,4,3 ;w,h,h_osn,n
	rb BUF_STRUCT_SIZE*(2+1)

;--------------------------------------------------
system_path db '/sys/lib/'
name_buf2d db 'buf2d.obj',0
;--------------------------------------------------

align 16
i_end: ;����� ����
file_name:
		rb 4096
cur_dir_path:
	rb 4096
library_path:
	rb 4096
	rb 1024
stacktop:
mem:

