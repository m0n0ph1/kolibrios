;��஬��� �������୮��� Maxxxx32, Diamond, Heavyiron
;� ��㣨� �ணࠬ���⠬, � ⠪�� ������� ������
use32
  org 0
  db 'MENUET01' ;������. �ᯮ��塞��� 䠩�� �ᥣ�� 8 ����
  dd 1,start,i_end,mem,stacktop,0,sys_path

include '../../proc32.inc'
include '../../macros.inc'
include '../../KOSfuncs.inc'
include '../../load_img.inc'
include '../../load_lib.mac'
include '../../develop/libraries/box_lib/trunk/box_lib.mac'

min_window_w equ 485 ;�������쭠� �ਭ� ����
min_window_h equ 325 ;�������쭠� ���� ����
otst_panel_left equ 265

include 'tile_fun.inc'
include 'pl_import.inc'

@use_library mem.Alloc,mem.Free,mem.ReAlloc, dll.Load

fn_metki db 'pl_metki.lst',0
ini_name db 'planet_v.ini',0
ini_sec  db 'Map',0
ini_k_cache db 'Cache',0
ini_def_cache db '/cache/sat',0
ini_ext  db 'ext'
.number  db '?'
.def db 0 ;���७�� �� 㬮�砭��


align 4
start:
	load_libraries l_libs_start,load_lib_end

	;�஢�ઠ �� ᪮�쪮 㤠筮 ���㧨���� ������⥪�
	mov	ebp,lib_0
	.test_lib_open:
	cmp	dword [ebp+ll_struc_size-4],0
	jz	@f
		mcall SF_TERMINATE_PROCESS ;exit not correct
	@@:
	add ebp,ll_struc_size
	cmp ebp,load_lib_end
	jl .test_lib_open

	copy_path ini_name,sys_path,file_name,0
	stdcall dword[ini_get_str],file_name,ini_sec,ini_k_cache,dword[edit1.text],dword[edit1.max],ini_def_cache
	stdcall [str_len],dword[edit1.text],dword[edit1.max]
	mov dword[edit1.size],eax
	mov dword[edit1.pos],eax

	stdcall dword[tl_data_init], tree1
	stdcall dword[tl_data_init], tree2

;���뢠�� ���७�� ���� �� *.ini 䠩��
	mov byte[ini_ext.number],'0'
@@: ;���뢠�� ��ࠬ���� �� ext1 �� ext9
  inc byte[ini_ext.number]
  stdcall dword[ini_get_str],file_name,ini_sec,ini_ext,txt_tile_type_0,dword[tree1.info_capt_len],ini_ext.def
  cmp byte[txt_tile_type_0],0
  je @f
    stdcall dword[tl_node_add], tree1, 0, txt_tile_type_0 
  jmp @b
@@:
  mov byte[ini_ext.number],'0' ;���뢠�� ��ࠬ��� �� ext0 ����� �㤥� ��࠭ � ᯨ᪥
  stdcall dword[ini_get_str],file_name,ini_sec,ini_ext,txt_tile_type_0,dword[tree1.info_capt_len],ini_ext.def
  cmp byte[txt_tile_type_0],0
  jne @f
    mov dword[txt_tile_type_0],'.bmp' ;�᫨ � *.ini 䠩�� ��祣� ��� ������塞 ���७�� .bmp
  @@:
  stdcall dword[tl_node_add], tree1, 0, txt_tile_type_0

; init bmp file
	stdcall mem.Alloc, dword RGB_TILE_SIZE+300 ;300 - ������ ����� � ��⮬ ��������� bmp 䠩��
	mov [bmp_icon],eax

	stdcall array_tile_function, tile_00,max_tiles_count,tile_init
	stdcall tiles_init_grid, tile_00,max_tiles_count,max_tiles_cols

	load_image_file 'tl_sys_16.png',tree_sys_icon
	mov eax,[tree_sys_icon]
	mov [tree1.data_img_sys],eax
	mov [tree2.data_img_sys],eax
	
	load_image_file 'tl_nod_16.bmp',tree_nod_icon
	mov eax,[tree_nod_icon]
	mov [tree1.data_img],eax
	mov [tree2.data_img],eax

	mcall SF_SET_EVENTS_MASK,0x27
	init_checkboxes2 ch1,checkboxes_end

	mcall SF_STYLE_SETTINGS,SSF_GET_COLORS,sc,sizeof.system_colors
	;��⠭���� ��⥬��� 梥⮢
	edit_boxes_set_sys_color edit1,editboxes_end,sc
	check_boxes_set_sys_color2 ch1,checkboxes_end,sc

	mov byte[file_name],0

	; OpenDialog initialisation
	stdcall [OpenDialog_Init],OpenDialog_data

align 4
red_win:
	call draw_window
	call but_MetLoad
	call but_Refresh ; Auto Refresh after program start

align 4
still:
	mcall SF_WAIT_EVENT

	cmp al,0x1 ;���. ��������� ����
	jz red_win
	cmp al,0x2
	jz key
	cmp al,0x3
	jz button

	stdcall [check_box_mouse],ch2
	stdcall [check_box_mouse],ch1
	stdcall [edit_box_mouse], edit1
	stdcall [edit_box_mouse], edit2
	stdcall [tl_mouse], tree1
	stdcall [tl_mouse], tree2

	jmp still

align 4
key:
	push eax ebx
	mcall SF_GET_KEY
	stdcall [edit_box_key], edit1
	stdcall [edit_box_key], edit2

	stdcall [tl_key],tree1
	stdcall [tl_key],tree2

	mov ebx,dword[el_focus] ;��-�� ���� �� ��������� �᫨ ���� treelist � 䮪��
	cmp ebx, dword tree1
	je .end_f
	cmp ebx, dword tree2
	je .end_f

	;��-�� ���� �� ��������� �᫨ ⥪�⮢� ���� � 䮪��
	test word[edit1.flags],10b ;ed_focus
	jne .end_f
	test word[edit2.flags],10b ;ed_focus
	jne .end_f

    cmp ah,179 ;Right
    jne @f
      call CursorMoveRight
    @@:
    cmp ah,176 ;Left
    jne @f
    cmp dword[map.coord_x],0
    je @f
      dec dword[map.coord_x]
      ;ᤢ����� ��� ⠩��� ��ࠢ�, ��-�� ���� ⠩��� ᮢ���� � ��諮�� ����� ����㦠�� �����
      stdcall tiles_grid_move_right, tile_00,max_tiles_count,max_tiles_cols
      call but_Refresh
    @@:
    cmp ah,177 ;Down
    jne @f
      call CursorMoveDown
    @@:
    cmp ah,178 ;Up
    jne @f
    cmp dword[map.coord_y],0
    je @f
      dec dword[map.coord_y]
      ;ᤢ����� ��� ⠩��� ����
      stdcall tiles_grid_move_down, tile_00,max_tiles_count,max_tiles_rows
      call but_Refresh
    @@:

    cmp ah,45 ;-
    jne @f
      call but_ZoomM
    @@:
    cmp ah,61 ;+
    jne @f
      call but_ZoomP
    @@:

	.end_f:
	pop ebx eax
	jmp still


align 4
draw_window:
pushad
	mcall SF_REDRAW,SSF_BEGIN_DRAW

	mov edx,[sc.work]
	or  edx,0x33000000
	mcall SF_CREATE_WINDOW,20*65536+min_window_w,20*65536+min_window_h,,,hed

	mcall SF_THREAD_INFO,procinfo,-1

	cmp dword[procinfo.box.width],min_window_w ; �஢��塞 �ਭ� ����
	jge @f
		mov dword[procinfo.box.width],min_window_w ; �᫨ ���� �祭� 㧪��, 㢥��稢��� �ਭ� ��� ��������� ���
	@@:

	mov edi,dword[procinfo.box.width]
	sub edi,min_window_w-otst_panel_left
	mov dword[tree1.box_left],edi
	mov dword[tree2.box_left],edi

	mov eax,dword[tree2.box_left] ;������� �஫����
	add eax,dword[tree2.box_width]
	mov ebx,dword[tree2.p_scroll]
	mov word[ebx+2],ax

	mov dword[edit2.left],edi
	add dword[edit2.left],370-otst_panel_left

	stdcall dword[tl_draw],dword tree1
	stdcall dword[tl_draw],dword tree2
	mov dword[wScrMetki.all_redraw],1
	stdcall [scrollbar_ver_draw], dword wScrMetki

	mov esi,[sc.work_button]
	mcall SF_DEFINE_BUTTON,145*65536+20,5*65536+25,6

	mcall ,100*65536+20,5*65536+25,5

	mov ebx,170*65536+40 ;������ �맮�� ������� OpenDial
	mov edx,13
	int 0x40

	mov bx,di
	shl ebx,16
	mov bx,100
	mov ecx,265*65536+25
	mov edx,9
	int 0x40

	;ebx ...
	mov ecx,235*65536+25
	mov edx,8
	int 0x40

	mov bx,di
	add bx,410-otst_panel_left
	shl ebx,16
	mov bx,55
	mov ecx,5*65536+25
	mov edx,7
	int 0x40

	mov bx,di
	add bx,440-otst_panel_left
	shl ebx,16
	mov bx,30
	mov ecx,265*65536+25
	mov edx,12
	int 0x40

	mov bx,di
	add bx,405-otst_panel_left
	shl ebx,16
	mov bx,30
	mov edx,11
	int 0x40

	mov bx,di
	add bx,370-otst_panel_left
	shl ebx,16
	mov bx,30
	mov edx,10
	int 0x40

	mov ecx,[sc.work_button_text]
	or  ecx,0x80000000
	mcall SF_DRAW_TEXT,152*65536+13,,txt_zoom_p

	mov ebx,107*65536+13
	mov edx,txt_zoom_m
	int 0x40

  mov bx,di
  add bx,270-otst_panel_left
  shl ebx,16
  mov bx,243
  ;mov ebx,270*65536+243
  mov edx,txt151
  int 0x40

  mov bx,di
  add bx,270-otst_panel_left
  shl ebx,16
  mov bx,273
  ;mov ebx,270*65536+273
  mov edx,txt152
  int 0x40

  mov bx,di
  add bx,415-otst_panel_left
  shl ebx,16
  mov bx,13
  ;mov ebx,415*65536+13
  mov edx,txt_but_refresh
  int 0x40

  mov bx,di
  add bx,380-otst_panel_left
  shl ebx,16
  mov bx,275
  ;mov ebx,380*65536+275
  mov edx,txt_met_up
  int 0x40

  mov bx,di
  add bx,415-otst_panel_left
  shl ebx,16
  mov bx,275
  ;mov ebx,415*65536+275
  mov edx,txt_met_dn
  int 0x40


  mov bx,di
  add bx,450-otst_panel_left
  shl ebx,16
  mov bx,275
  ;mov ebx,450*65536+275
  mov edx,txt_met_sh
  int 0x40

  mov ebx,175*65536+13
  mov edx,txt_cache
  int 0x40

  mov ecx,[sc.work_text]
  or  ecx,0x80000000

  mov bx,di
  ;add bx,450-otst_panel_left
  shl ebx,16
  mov bx,35
  ;mov ebx,265*65536+35
  mov edx,txt141
  int 0x40

	mov bx,135
	mov edx,txt142
	int 0x40

	call draw_tiles

	stdcall [check_box_draw], ch1
	stdcall [check_box_draw], ch2
	stdcall [edit_box_draw], edit1
	stdcall [edit_box_draw], edit2

	mcall SF_REDRAW,SSF_END_DRAW
popad
	ret

system_dir0 db '/sys/lib/'
lib0_name db 'box_lib.obj',0

system_dir1 db '/sys/lib/'
lib1_name db 'libimg.obj',0

system_dir2 db '/sys/lib/'
lib2_name db 'str.obj',0

system_dir3 db '/sys/lib/'
lib3_name db 'libini.obj',0

system_dir4 db '/sys/lib/'
lib4_name db 'proc_lib.obj',0

;library structures
l_libs_start:
	lib_0 l_libs lib0_name, file_name, system_dir0, boxlib_import
	lib_1 l_libs lib1_name, file_name, system_dir1, libimg_import
	lib_2 l_libs lib2_name, file_name, system_dir2, strlib_import
	lib_3 l_libs lib3_name, file_name, system_dir3, libini_import
	lib_4 l_libs lib4_name, file_name, system_dir4, proclib_import
load_lib_end:

align 4
button:
	mcall SF_GET_BUTTON
	cmp ah,5
	jne @f
		call but_ZoomM
		jmp still
	@@:
	cmp ah,6
	jne @f
		call but_ZoomP
		jmp still
	@@:
	cmp ah,7
	jne @f
		call but_Refresh
		jmp still
	@@:

	cmp ah,9
	jz  but_MetSave
	cmp ah,8
	jz  but_MetAdd

	cmp ah,10
	jne @f
		call but_met_up
		jmp still
	@@:
	cmp ah,11
	jne @f
		call but_met_dn
		jmp still
	@@:
	cmp ah,12
	jne @f
		call fun_goto_met
		jmp still
	@@:
	cmp ah,13 ;������ OpenDialog ��� ���᪠ �����
	jne @f
		call fun_opn_dlg
		jmp still
	@@:
	cmp ah,1
	jne still

.exit:
	push dword[bmp_icon]
	call mem.Free
	stdcall array_tile_function, tile_00,max_tiles_count,tile_destroy

	stdcall dword[tl_data_clear], tree1
	mov dword[tree2.data_img_sys],0 ;��⨬ 㪠��⥫� �� ��⥬�� ������,
		;�. �. ��� �뫨 㤠���� ���孥� �㭪樥� tl_data_clear
		;������ �맮� tl_data_clear ��� ��⪨ 㪠��⥫� �맢�� �訡��
	mov dword[tree2.data_img],0 ;��⨬ 㪠��⥫� �� ������ 㧫��
	stdcall dword[tl_data_clear], tree2

;  stdcall dword[img_destroy], dword[data_icon]
	mcall SF_TERMINATE_PROCESS


;input:
;data_rgb - pointer to rgb data
;size - count img pixels (size img data / 3(rgb) )
align 4
proc img_rgb_wdiv2 uses eax ebx ecx edx, data_rgb:dword, size:dword
  mov eax,dword[data_rgb]
  mov ecx,dword[size] ;ecx = size
  imul ecx,3
  @@: ;��⥬����� 梥� ���ᥫ��
    shr byte[eax],1
    and byte[eax],0x7f
    inc eax
    loop @b

  mov eax,dword[data_rgb]
  mov ecx,dword[size] ;ecx = size
  shr ecx,1
  @@: ;᫮����� 梥⮢ ���ᥫ��
    mov ebx,dword[eax+3] ;�����㥬 梥� �ᥤ���� ���ᥫ�
    add word[eax],bx
    shr ebx,16
    add byte[eax+2],bl

    add eax,6 ;=2*3
    loop @b

  mov eax,dword[data_rgb]
  add eax,3
  mov ebx,eax
  add ebx,3
  mov ecx,dword[size] ;ecx = size
  shr ecx,1
  dec ecx ;��譨� ���ᥫ�
  @@: ;�����⨥ ���ᥫ��
    mov edx,dword[ebx]
    mov word[eax],dx
    shr edx,16
    mov byte[eax+2],dl

    add eax,3
    add ebx,6
    loop @b
  ret
endp

;input:
;data_rgb - pointer to rgb data
;size - count img pixels (size img data / 3(rgb) )
;size_w - width img in pixels
align 4
proc img_rgb_hdiv2, data_rgb:dword, size:dword, size_w:dword
  pushad

  mov eax,dword[data_rgb] ;eax =
  mov ecx,dword[size]	  ;ecx = size
  imul ecx,3
  @@: ;��⥬����� 梥� ���ᥫ��
    shr byte[eax],1
    and byte[eax],0x7f
    inc eax
    loop @b

  mov eax,dword[data_rgb] ;eax =
  mov edi,dword[size_w]
  lea esi,[edi+edi*2] ;esi = width*3(rgb)
  mov ebx,esi
  add ebx,eax
  mov ecx,dword[size]  ;ecx = size
  shr ecx,1
  xor edi,edi
  @@: ;᫮����� 梥⮢ ���ᥫ��
    mov edx,dword[ebx] ;�����㥬 梥� ������� ���ᥫ�
    add word[eax],dx
    shr edx,16
    add byte[eax+2],dl

    add eax,3
    add ebx,3
    inc edi
    cmp edi,dword[size_w]
    jl .old_line
      add eax,esi
      add ebx,esi
      xor edi,edi
    .old_line:
    loop @b


  mov eax,dword[data_rgb] ;eax =
  add eax,esi ;esi = width*3(rgb)
  mov ebx,esi
  add ebx,eax
  mov ecx,dword[size] ;ecx = size
  shr ecx,1
  sub ecx,dword[size_w] ;����� ��ப� ���ᥫ��
  xor edi,edi
  @@: ;�����⨥ ���ᥫ��
    mov edx,dword[ebx] ;�����㥬 梥� ������� ���ᥫ�
    mov word[eax],dx
    shr edx,16
    mov byte[eax+2],dl

    add eax,3
    add ebx,3
    inc edi
    cmp edi,dword[size_w]
    jl .old_line_2
      add ebx,esi
      xor edi,edi
    .old_line_2:
    loop @b

  popad
  ret
endp

;input:
;data_rgb - pointer to rgb data
;size - count img pixels (size img data / 3(rgb) )
align 4
proc img_rgb_wmul2 uses eax ebx ecx edx, data_rgb:dword, size:dword
	;eax - source
	;ebx - destination
	mov ecx,dword[size] ;ecx = size
	mov eax,ecx
	dec eax
	lea eax,[eax+eax*2] ;eax = (size-1)*3
	mov ebx,eax ;ebx = size*3
	add eax,dword[data_rgb] ;eax = pointer + size*3
	add ebx,eax ;ebx = pointer + 2*size*3
	@@:
		mov edx,dword[eax] ;edx = pixel color
		mov word[ebx],dx
		mov word[ebx+3],dx
		shr edx,16
		mov byte[ebx+2],dl
		mov byte[ebx+3+2],dl
		sub eax,3
		sub ebx,6
		loop @b
	ret
endp

;�㭪�� ��� �������� ����ࠦ���� �� ���� � 2 ࠧ�
;� 㪠��⥫� data_rgb ����� ������ ���� � 2 ࠧ� ����� 祬 size*3
;���� �� �������� �㤥� �訡��, ��室� �� ���� ������
;input:
;data_rgb - pointer to rgb data
;size - count img pixels (size img data / 3(rgb) )
;size_w - width img in pixels
align 4
proc img_rgb_hmul2, data_rgb:dword, size:dword, size_w:dword
  pushad

  mov esi,dword[size_w]
  lea esi,[esi+esi*2] ;esi = width * 3(rgb)
  mov eax,dword[size]
  lea eax,[eax+eax*2]
  mov edi,eax
  shl edi,1
  add eax,dword[data_rgb] ;eax = pointer to end pixel (old image) + 1
  add edi,dword[data_rgb] ;edi = pointer to end pixel (new image) + 1
  mov ebx,edi
  sub ebx,esi

  .beg_line:
  mov ecx,dword[size_w]
  @@:
    sub eax,3
    sub ebx,3
    sub edi,3

    mov edx,dword[eax] ;edx = pixel color
    mov word[ebx],dx
    mov word[edi],dx
    shr edx,16
    mov byte[ebx+2],dl
    mov byte[edi+2],dl

    loop @b

  sub ebx,esi
  sub edi,esi

  cmp eax,dword[data_rgb]
  jg .beg_line

  popad
  ret
endp

;input:
;data_rgb - pointer to rgb data
;size - count img pixels (size img data / 3(rgb) )
;size_w - width img in pixels
align 4
proc img_rgb_hoffs uses eax ebx ecx edx esi, data_rgb:dword, size:dword, size_w:dword, hoffs:dword
	mov esi,dword[size_w]
	lea esi,[esi+esi*2] ;esi = width * 3(rgb)
	imul esi,dword[hoffs]

	mov eax,dword[size]
	lea eax,[eax+eax*2]
	add eax,dword[data_rgb] ;eax = pointer to end pixel + 1
	sub eax,3
	mov ebx,eax
	add ebx,esi

	mov ecx,dword[size]
	dec ecx
	@@:
		mov edx,dword[eax] ;edx = pixel color
		mov word[ebx],dx
		shr edx,16
		mov byte[ebx+2],dl

		sub eax,3
		sub ebx,3
		loop @b
	ret
endp


;input:
;data_rgb - pointer to rgb data
;size_w_old - width img in pixels
;size_w_new - new width img in pixels
;size_h - height img in pixels
align 4
proc img_rgb_wcrop, data_rgb:dword, size_w_old:dword, size_w_new:dword, size_h:dword
  pushad
    mov eax, dword[size_w_old]
    lea eax, dword[eax+eax*2] ;eax = width(old) * 3(rgb)
    mov ebx, dword[size_w_new]
    lea ebx, dword[ebx+ebx*2] ;ebx = width(new) * 3(rgb)
    mov edx, dword[size_h]
    ;dec edx
    mov edi, dword[data_rgb] ;edi - ����砥� �����
    mov esi, edi
    add edi, ebx
    add esi, eax
    cld
  @@:
    dec edx ;㬥��蠥� ���稪 ��⠢���� ��ப �� 1
    cmp edx,0
    jle @f

    mov ecx, ebx
    rep movsb ;��७�� (����஢����) ��ப� ���ᥫ��
;stdcall mem_copy,esi,edi,ebx

    add esi,eax ;���室 �� ����� ����� ����ࠦ����
    sub esi,ebx
;add esi,eax
;add edi,ebx
    jmp @b
  @@:

  popad
  ret
endp

align 4
proc mem_copy uses ecx esi edi, source:dword, destination:dword, len:dword
	cld
	mov esi, dword[source]
	mov edi, dword[destination]
	mov ecx, dword[len]
	rep movsb
	ret
endp

align 4
proc mem_clear uses eax ecx edi, mem:dword, len:dword
	cld
	xor al,al
	mov edi, dword[mem]
	mov ecx, dword[len]
	repne stosb
	ret
endp

align 4
fun_opn_dlg: ;�㭪�� ��� �맮�� OpenFile �������
	pushad
	copy_path open_dialog_name,communication_area_default_path,file_name,0
	mov [OpenDialog_data.type],2
	mov dword[plugin_path],0 ;��-�� �� ����⨨ ����������� ���� ���� �ᥣ�� �ࠫ�� �� OpenDialog_data.dir_default_path

	stdcall [OpenDialog_Start],OpenDialog_data
	cmp [OpenDialog_data.status],2
	je @f
		stdcall [str_len],dword[edit1.text],dword[edit1.max]
		mov [edit1.size],eax
		mov [edit1.pos],eax
		stdcall [edit_box_draw], edit1
	@@:
	popad
	ret

txt_met_up db 24,0
txt_met_dn db 25,0
txt_met_sh db '*',0
txt_zoom_m db '-',0
txt_zoom_p db '+',0
txt151 db '�������� ����',0
txt152 db '���࠭��� ��⪨',0
txt_but_refresh db '��������',0
txt_cache db 'Cache:',0
txt141 db '��� �����',0
txt142 db '�롮� ��⪨',0

; check_boxes
ch1 check_box2 (5 shl 16)+12,  (5 shl 16)+12, 6, 0xffffd0, 0x800000, 0, ch_text1, ch_flag_en
ch2 check_box2 (5 shl 16)+12, (20 shl 16)+12, 6, 0xffffd0, 0x800000, 0, ch_text2, ch_flag_en
checkboxes_end:

ch_text1 db '���� ᢥ���',0
ch_text2 db '���� ᭨��',0

edit1 edit_box 190, 215,  10, 0xd0ffff, 0xff, 0x80ff, 0, 0xa000, 4090, openfile_path, mouse_dd, 0
edit2 edit_box 100, 370, 240, 0xd0ffff, 0xff, 0x80ff, 0, 0xa000,  30, ed_buffer.2, mouse_dd, 0
editboxes_end:

tree1 tree_list 10,10, tl_list_box_mode+tl_key_no_edit, 16,16,\
    0x8080ff,0x0000ff,0xffffff, 265,45,90,85, 0,0,0,\
    el_focus, 0,fun_new_map_type
tree2 tree_list 32,300, tl_draw_par_line, 16,16,\
    0x8080ff,0x0000ff,0xffffff, 265,145,190,85, 0,12,0,\
    el_focus, wScrMetki,fun_goto_met

align 4
wScrMetki scrollbar 16,0, 100,0, 15, 100, 30,0, 0xeeeeee, 0xbbddff, 0, 1

ed_buffer: ;����� ��� edit
.2: rb 32

el_focus dd tree1

tree_sys_icon dd 0
tree_nod_icon dd 0

bmp_icon   dd 0 ;������ ��� ����㧪� ����ࠦ����
data_icon  dd 0 ;������ ��� �८�ࠧ������ ���⨭�� �㭪�ﬨ libimg

run_file_70 FileInfoBlock


txt_tile_path db 'tile path',0
	rb 300
txt_tile_type dd txt_tile_type_0 ;㪠��⥫� �� ��࠭�� ⨯ 䠩���
txt_tile_type_0 db 0
	rb 10

;---------------------------------------------------------------------
align 4
OpenDialog_data:
.type			dd 2
.procinfo		dd procinfo	;+4
.com_area_name		dd communication_area_name	;+8
.com_area		dd 0	;+12
.opendir_path		dd plugin_path	;+16
.dir_default_path	dd default_dir ;+20
.start_path		dd file_name ;+24 ���� � ������� ������ 䠩���
.draw_window		dd draw_window	;+28
.status 		dd 0	;+32
.openfile_path		dd openfile_path	;+36 ���� � ���뢠����� 䠩��
.filename_area		dd filename_area	;+40
.filter_area		dd Filter
.x:
.x_size 		dw 420 ;+48 ; Window X size
.x_start		dw 10 ;+50 ; Window X position
.y:
.y_size 		dw 320 ;+52 ; Window y size
.y_start		dw 10 ;+54 ; Window Y position

default_dir db '/rd/1',0 ;��४��� �� 㬮�砭��

communication_area_name:
	db 'FFFFFFFF_open_dialog',0
open_dialog_name:
	db 'opendial',0
communication_area_default_path:
	db '/rd/1/File managers/',0

Filter:
dd Filter.end - Filter.1
.1:
db 'TXT',0
.end:
db 0

align 4
map: ;���न���� �����
  .coord_x dd 0 ;���न��� x
  .coord_y dd 0 ;���न��� y
  .zoom    db 1 ;����⠡

align 4
tile_00 rb size_tile_struc * max_tiles_count

;input:
; eax - �᫮
; edi - ���� ��� ��ப�
; len - ������ ����
;output:
align 4
proc convert_int_to_str, len:dword
pushad
	mov esi,[len]
	add esi,edi
	dec esi
	call .str
popad
	ret
endp

align 4
.str:
	mov ecx,10
	cmp eax,ecx
	jb @f
		xor edx,edx
		div ecx
		push edx
		;dec edi  ;ᬥ饭�� ����室���� ��� ����� � ���� ��ப�
		call .str
		pop eax
	@@:
	cmp edi,esi
	jge @f
		or al,0x30
		stosb
		mov byte[edi],0 ;� ����� ��ப� �⠢�� 0, ��-�� �� �뫠��� ����
	@@:
	ret

hed db 'Planet viewer 16.02.16',0 ;������� ����
mouse_dd dd 0 ;�㦭� ��� Shift-� � editbox

align 16
i_end:
	procinfo process_information
	sc system_colors  ;��⥬�� 梥�
	rb 1024
align 16
stacktop:
sys_path rb 4096
file_name rb 4096
plugin_path rb 4096
openfile_path rb 4096
filename_area rb 256
mem:

