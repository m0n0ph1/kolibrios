;-----------------------;
; CPU - process manager ;
;-----------------------;

format binary as ""

        use32
        org 0x0
        db 'MENUET01'           ; 8 byte id
        dd 0x01                 ; header version
        dd START                ; start of code
        dd IM_END               ; size of image
        dd U_END                ; memory for app
        dd stack_area           ; esp
        dd 0x0                  ; boot parameters
        dd cur_dir_path         ; path
;------------------------------------------------------------------------------
include 'lang.inc'
include '../../../macros.inc'
include '../../../develop/libraries/box_lib/trunk/box_lib.mac'
include '../../../KOSfuncs.inc'
include '../../../load_lib.mac'
;------------------------------------------------------------------------------
display_processes=24    ;32             ; number of processes to show
window_x_size=524
window_y_size=430
;------------------------------------------------------------------------------
@use_library    ;use load lib macros
;------------------------------------------------------------------------------
START:                          ; start of execution
        mcall   SF_SYS_MISC,SSF_HEAP_INIT
sys_load_library  library_name, library_path, system_path, myimport
        inc     eax
        jz      close
;------------------------------------------------------------------------------
        mcall   SF_SET_EVENTS_MASK,0x80000027 ;set event
;------------------------------------------------------------------------------
;set window size and position for 0 function
;to [winxpos] and [winypos] variables
;get screen size
        mcall   SF_GET_SCREEN_SIZE
        mov     ebx,eax
;calculate (x_screen-window_x_size)/2
        shr     ebx,16+1
        sub     ebx,window_x_size/2
        shl     ebx,16
        mov     bx,window_x_size
;winxpos=xcoord*65536+xsize
        mov     [winxpos],ebx
;calculate (y_screen-window_y_size)/2
        and     eax,0xffff
        shr     eax,1
        sub     eax,window_y_size/2
        shl     eax,16
        mov     ax,window_y_size
;winypos=ycoord*65536+ysize
        mov     [winypos],eax
;------------------------------------------------------------------------------
        init_checkboxes2 check1,check1_end
        mcall   SF_STYLE_SETTINGS,SSF_GET_COLORS,sc,40
        edit_boxes_set_sys_color edit1,edit1_end,sc             ;set color
        ;check_boxes_set_sys_color2 check1,check1_end,sc ;set color
;------------------------------------------------------------------------------
align 4
;main loop when process name isn't edited.
red:
        call    draw_window             ; redraw all window
;------------------------------------------------------------------------------
align 4
still:
        mcall   SF_WAIT_EVENT_TIMEOUT,100          ; wait here for event 1 sec.

	test	eax,eax
	jz	still_end

        dec     eax                   ; redraw request ?
        jz      red

        dec     eax                   ; key in buffer ?
        jz      key

        dec     eax                   ; button in buffer ?
        jz      button

        push    dword edit1
        call    [edit_box_mouse]

        push    dword[check1.flags]

        push    dword check1
        call    [check_box_mouse]

        pop     eax

        cmp     eax, dword[check1.flags]
        jz      still_end

        push    dword check1
        call    [check_box_draw]
;--------------------------------------
align 4
show_process_info_1:
        mcall   SF_SYSTEM_GET,SSF_TIME_COUNT
        add     eax,100
        mov     [time_counter],eax

        call    show_process_info       ; draw new state of processes
        jmp     still
;------------------------------------------------------------------------------
align 4
still_end:
        mcall   SF_SYSTEM_GET,SSF_TIME_COUNT
        cmp     [time_counter],eax
        ja      still

        add     eax,100
        mov     [time_counter],eax

        call    show_process_info       ; draw new state of processes
        jmp     still
;------------------------------------------------------------------------------
align 4
key:                            ; key
        mcall   SF_GET_KEY

        cmp     ah,184          ; PageUp
        jz      pgdn

        cmp     ah,183
        jz      pgup                    ; PageDown

        cmp     ah,27
        jz      close                   ; Esc

        push    dword edit1
        call    [edit_box_key]
                                ; Check ENTER with ed_focus edit_box
        lea     edi,[edit1]
        test    word ed_flags,ed_focus
        jz      still_end

        sub     ah,13                   ; ENTER?
        jz      program_start           ; RUN a program

        jmp     still
;------------------------------------------------------------------------------
align 4
button:
; get button id
        mcall   SF_GET_BUTTON
        mov     bl, al ; save mouse button to bl
        shr     eax,8
;id in [10,50] corresponds to terminate buttons.
        cmp     eax,10
        jb      noterm

        cmp     eax,50
        jg      noterm
;calculate button index
        sub     eax,11
;calculate process slot
        mov     ecx,[tasklist+4*eax]
;ignore empty buttons
        test    ecx,ecx
        jle     still_end
        test    bl, bl ; check mouse button
        jz     .terminate
        mov    eax, ecx
        mov    edi, tinfo.params_buf
;; number in eax
;; buffer in edi
; int2str:
        push   0
        mov    ecx, 10
.push:
        xor    edx, edx
        div    ecx
        add    edx, 48
        push   edx
        test   eax, eax
        jnz     .push
.pop:
        pop    eax
        stosb
        test   eax, eax
        jnz    .pop
; launch tinfo app
        mov     ebx, tinfo
        mov     eax, SF_FILE
        int     64
        jmp     show_process_info_1
.terminate:
;terminate application
        mcall   SF_SYSTEM,SSF_TERMINATE_THREAD
        jmp     show_process_info_1
;--------------------------------------
align 4
noterm:
;special buttons
        dec     eax
        jz      close

        sub     eax,50
        jz      pgdn      ;51

        dec     eax
        jz      pgup      ;52

        dec     eax
        jz      program_start   ;53

        dec     eax
        jz      reboot  ;54

        jmp     still_end
;buttons handlers
;------------------------------------------------------------------------------
align 4
pgdn:
        sub     [list_start],display_processes
        jge     show_process_info_1
        mov     [list_start],0
        jmp     show_process_info_1
;------------------------------------------------------------------------------
align 4
pgup:
        mov     eax,[list_add]  ;maximal displayed process slot
        mov     [list_start],eax
        jmp     show_process_info_1
;------------------------------------------------------------------------------
align 4
program_start:
        mcall   SF_FILE,file_start
        jmp     show_process_info_1
;------------------------------------------------------------------------------
align 4
reboot:
        mcall   SF_FILE,sys_reboot
;close program if we going to reboot
;------------------------------------------------------------------------------
align 4
close:
        or      eax,SF_TERMINATE_PROCESS ; close this program
        mcall
;------------------------------------------------------------------------------
align 4
draw_empty_slot:
        cmp     [draw_window_flag],1
        je      @f
        mov     ecx,[curposy]
        shl     ecx,16
        mov     cx,10   ; button height
        mcall   SF_DRAW_RECT,<111,393>,,[bar_bacground_color]
@@:
        ret
;------------------------------------------------------------------------------
align 4
draw_next_process:
;input:
;  edi - current slot
;  [curposy] - y position
;output:
;  edi - next slot (or -1 if no next slot)
;registers corrupted!
;create terminate process button
        mov     ecx,[curposy]
        shl     ecx,16
        mov     cx,13   ; button height
        mov     edx,[index]
        add     edx,11
        mov     esi,0xccddee
        test    dword [index],1
        jz      @f
        mov     esi,0xaabbcc
@@:
		add     edx,0x80000000 ; delete a button
		mcall   SF_DEFINE_BUTTON ; before create
		sub     edx,0x80000000 ; a new one below
        mcall   SF_DEFINE_BUTTON,<10,99>
        mov     [btn_bacground_color],esi
;draw background for proccess information
        mov     edx,0xddffdd
        test    dword [index],1
        jz      @f
        mov     edx,0xffffff
@@:
        inc     cx
        cmp     [draw_window_flag],0
        je      @f
        mcall   SF_DRAW_RECT,<110,395>
@@:
        mov     [bar_bacground_color],edx
;nothing else should be done if there is no process for this button
        cmp     edi,-1
        jne     .return_1

        call    draw_empty_slot
        or      edi,-1
        jmp     .ret
;--------------------------------------
align 4
.return_1:
;find process
        inc     edi
;more comfortable register for next loop
        mov     ecx,edi
;precacluate pointer to process buffer
        mov     ebx,process_info_buffer
;--------------------------------------
align 4
.find_loop:
        cmp     ecx,256
        jge     .no_processes
;load process information in buffer
        mcall   SF_THREAD_INFO
;if current slot greater than maximal slot,
;there is no more proccesses.
        cmp     ecx,eax
        jg      .no_processes
;if slot state is equal to 9, it is empty.
        cmp     [process_info_buffer+process_information.slot_state],9
        jnz     .process_found

        inc     ecx
        jmp     .find_loop
;--------------------------------------
align 4
.no_processes:
        call    draw_empty_slot
        or      edi,-1
        ret
;--------------------------------------
align 4
.process_found:
;check on/off check box
        push    edi
        lea     edi,[check1]
        test    dword ch_flags,ch_flag_en
        pop     edi
        jnz     .no_filter

        cmp     dword [process_info_buffer+10],'ICON'
	jnz	@f
        cmp     dword [process_info_buffer+10+4],0
        jz      .return_1
@@:
        cmp     dword [process_info_buffer+10],'IDLE'
	jnz	@f
        cmp     dword [process_info_buffer+10+4],0
        jz      .return_1
@@:
        cmp     word [process_info_buffer+10],'OS'
	jnz	@f
        cmp     dword [process_info_buffer+10+2],0
        jz      .return_1
@@:
        cmp     byte [process_info_buffer+10],'@'
        jz      .return_1
;--------------------------------------
align 4
.no_filter:
        mov     edi,ecx
        mov     [list_add],ecx
;get processor cpeed
;for percent calculating
        mcall   SF_SYSTEM,SSF_GET_CPU_FREQUENCY
        xor     edx,edx
        mov     ebx,100
        div     ebx
;eax = number of operation for 1% now
;calculate process cpu usage percent
        mov     ebx,eax
        mov     eax,[process_info_buffer+process_information.cpu_usage]
;       cdq
        xor     edx,edx ; for CPU more 2 GHz - mike.dld
        div     ebx
        mov     [cpu_percent],eax
;set text color to display process information
;0%      : black
;1-80%   : green
;81-100% : red
        test    eax,eax
        jnz     .no_black

        mov     esi,eax
        jmp     .color_set
;--------------------------------------
align 4
.no_black:
        cmp     eax,80
        ja      .no_green

        mov     esi,0x107a30
        jmp     .color_set
;--------------------------------------
align 4
.no_green:
        mov     esi,0xac0000
;--------------------------------------
align 4
.color_set:
;show slot number
;ecx haven't changed since .process_found
        push    edi
        mov     edx,[curposy]
        add     edx,15*65536+3
        mcall   SF_DRAW_NUMBER,<2,256>
;show process name
        mov     ebx,[curposy]
        add     ebx,40*65536+3
        mov     ecx,esi
        mcall   SF_DRAW_TEXT,,,process_info_buffer.process_name,11
;show pid
        mov     edx,[curposy]
        add     edx,125*65536+3
        mov     esi,ecx
        or      esi,0x40000000
        mcall   SF_DRAW_NUMBER,<8,256>,[process_info_buffer.PID],,,[bar_bacground_color]
;show cpu usage
        add     edx,60*65536
        mcall   ,,[process_info_buffer.cpu_usage]
;show cpu percent
        add     edx,60*65536
        mcall   ,<3,0>,[cpu_percent]
;show memory start - obsolete
        add     edx,30*65536
        mcall   ,<8,256>,[process_info_buffer.memory_start]
;show memory usage
        mov     ecx,[process_info_buffer.used_memory]
        inc     ecx
        add     edx,60*65536
        mcall
;show window stack and value
        add     edx,60*65536
        mcall   ,,dword [process_info_buffer.window_stack_position]
;show window xy size
        mov     ecx,[process_info_buffer.box.left]
        shl     ecx,16
        add     ecx,[process_info_buffer.box.top]
        add     edx,60*65536
        mcall
        pop     edi
;--------------------------------------
align 4
.ret:
;build index->slot map for terminating processes.
        mov     eax,[index]
        mov     [tasklist+4*eax],edi
        ret
;------------------------------------------------------------------------------
align 4
f11:
;full update
        push    edi
        call    draw_window
        pop     edi
;------------------------------------------------------------------------------
;   *********************************************
;   *******  WINDOW DEFINITIONS AND DRAW ********
;   *********************************************
align 4
draw_window:
        mcall   SF_REDRAW, SSF_BEGIN_DRAW
; DRAW WINDOW
        xor     eax,eax                         ; function 0 : define and draw window
        xor     esi,esi
        mcall   ,[winxpos],[winypos],0x74ffffff,,title  ;0x34ddffdd

        mcall   SF_THREAD_INFO,process_info_buffer,-1

        mov     eax,[ebx+70]
        mov     [window_status],eax
        test    [window_status],100b            ; window is rolled up
        jnz     .exit

        test    [window_status],10b             ; window is minimized to panel
        jnz     .exit

        mov     eax,[ebx+62]
        inc     eax
        mov     [client_area_x_size],eax
        mov     eax,[ebx+66]
        inc     eax
        mov     [client_area_y_size],eax

        mov     ebx,[client_area_x_size]
        mcall   SF_DRAW_RECT,,<0,20>,0xffffff
; function 4 : write text to window
        xor     ecx,ecx
        mcall   SF_DRAW_TEXT,<17,8>,,text,text_len

        mcall   SF_DRAW_RECT,<0,10>,<20,336>,0xffffff

        mov     ebx,[client_area_x_size]
        sub     ebx,10+100+395
        add     ebx,(10+100+395) shl 16
        mcall

        mcall   SF_SYSTEM_GET,SSF_TIME_COUNT
        add     eax,100
        mov     [time_counter],eax

        mov     [draw_window_flag],1
        call    show_process_info
        mov     [draw_window_flag],0

        mov     ebx,[client_area_x_size]
        mov     ecx,[client_area_y_size]
        sub     ecx,20+336
        add     ecx,(20+336) shl 16
        mcall   SF_DRAW_RECT,,,0xffffff

        push    dword edit1
        call    [edit_box_draw]

        push    dword check1
        call    [check_box_draw]

; previous page button
        mcall   SF_DEFINE_BUTTON,<25,96>,<361,14>,51,0xccddee  ;0xaabbcc
; next page button  52
        inc     edx
        mcall   ,<125,96>
; ">" (text enter) button
        add     ecx,20 shl 16
; run button 53
        inc     edx
        mcall   ,<456,50>
; reboot button
        sub     ebx,120*65536
        add     ebx,60
        sub     ecx,20 shl 16
        inc     edx
        mcall
;"PREV PAGE", "NEXT PAGE" and "REBOOT" labels
        xor     ecx,ecx
        mcall   SF_DRAW_TEXT,<45,365>,,tbts,tbte-tbts
;"RUN" labels
        mcall   ,<464,385>,,tbts_3,tbte_2-tbts_3
;print application name in text box
;--------------------------------------
align 4
.exit:
        mcall   SF_REDRAW, SSF_END_DRAW
        ret
;------------------------------------------------------------------------------
align 4
show_process_info:
        test    [window_status],100b            ; window is rolled up
        jnz     .exit

        test    [window_status],10b             ; window is minimized to panel
        jnz     .exit

        mov     ecx,display_processes
        mov     edi,tasklist
        xor     eax,eax
        cld
        rep     stosd

        mov     edi,[list_start]
        mov     [list_add],edi
        mov     dword [index],0
        mov     dword [curposy],20
;--------------------------------------
align 4
.loop_draw:
        call    draw_next_process
        inc     dword [index]
        add     dword [curposy],14
        cmp     [index],display_processes
        jl      .loop_draw
;--------------------------------------
align 4
.exit:
        ret
;------------------------------------------------------------------------------
; DATA AREA
;------------------------------------------------------------------------------
system_path      db '/sys/lib/'
library_name     db 'box_lib.obj',0

;------------------------------------------------------------------------------
align 4
myimport:
edit_box_draw           dd aEdit_box_draw
edit_box_key            dd aEdit_box_key
edit_box_mouse          dd aEdit_box_mouse
;version_ed             dd aVersion_ed

init_checkbox           dd aInit_checkbox
check_box_draw          dd aCheck_box_draw
check_box_mouse         dd aCheck_box_mouse
;version_ch             dd aVersion_ch

;option_box_draw        dd aOption_box_draw
;option_box_mouse       dd aOption_box_mouse
;version_op             dd aVersion_op

                dd 0
                dd 0

aEdit_box_draw          db 'edit_box',0
aEdit_box_key           db 'edit_box_key',0
aEdit_box_mouse         db 'edit_box_mouse',0
;aVersion_ed            db 'version_ed',0

aInit_checkbox          db 'init_checkbox2',0
aCheck_box_draw         db 'check_box_draw2',0
aCheck_box_mouse        db 'check_box_mouse2',0
;aVersion_ch            db 'version_ch',0

;aOption_box_draw       db 'option_box_draw',0
;aOption_box_mouse      db 'option_box_mouse',0
;aVersion_op            db 'version_op',0
;------------------------------------------------------------------------------
align 4
check1 check_box2 (10 shl 16)+12,(383 shl 16)+12,6, 0x80D6DEE7,0x4C5258,0,check_text, ch_flag_middle ;ch_flag_en
check1_end:
edit1 edit_box 350,95,381,0xffffff,0x6f9480,0,0xAABBCC,0,start_application_c,\
   start_application,mouse_dd,ed_focus,start_application_e,start_application_e
edit1_end:
list_start  dd 0
;------------------------------------------------------------------------------
align 4
sys_reboot:
            dd SSF_START_APP
            dd 0
            dd 0
            dd 0
            dd 0
            db '/sys/end',0
;------------------------------------------------------------------------------
if lang eq de
text:
        db 'NAME/BEENDEN        PID     CPU-LAST   % '
        db 'SPEICHER START/NUTZUNG  W-STACK  W-POS'
text_len = $-text

tbts:   db 'SEITE ZURUECK     SEITE VOR                        REBOOT SYSTEM'
tbte:
tbts_3  db 'START'
tbte_2:
check_text      db 'System',0
title   db 'Prozesse  - Ctrl/Alt/Del',0
;--------------------------------------
else if lang eq et
text:
        db 'NIMI/LÕPETA         PID    CPU-KASUTUS %   '
        db 'MÄLU ALGUS/KASUTUS  W-PUHVER  W-SUURUS'
text_len = $-text

tbts:   db 'EELMINE LEHT   JÄRGMINE LEHT                     REBOODI SÜSTEEM'
tbte:
tbts_3  db 'START'
tbte_2:
check_text      db 'System',0
title   db 'Protsessid - Ctrl/Alt/Del'
;--------------------------------------
else if lang eq ru
text:
        db '/      PID     CPU- %  '
        db ' /  W-STACK  W-POS'
text_len = $-text

tbts:   db '.        .                          '
tbte:
tbts_3  db ''
tbte_2:
check_text      db '¨áâ¥¬­ë¥',0
title   db '¨á¯¥âç¥à ¯à®æ¥áá®¢ - Ctrl/Alt/Del',0
;--------------------------------------
else if lang eq it
text:
        db 'NOME-PROGRAMMA    PID       USO CPU    % '
        db 'MEMORY START/USAGE  W-STACK  W-POS'
text_len = $-text

tbts:   db 'INDIETRO         AVANTI                           RIAVVIA SISTEMA'
tbte:
tbts_3  db 'START'
tbte_2:
check_text      db 'System',0
title   db 'Gestore processi  - Ctrl/Alt/Del',0
;--------------------------------------
else
text:
        db 'NAME/TERMINATE    PID       CPU-USAGE  %   '
        db 'MEMORY START/USAGE  W-STACK   W-POS'
text_len = $-text

tbts:   db 'PREV PAGE       NEXT PAGE                         REBOOT SYSTEM'
tbte:
tbts_3  db ' RUN'
tbte_2:
check_text      db 'System',0
title   db 'Process manager - Ctrl/Alt/Del',0

end if
; ---------------------------------------------------------------------------- ;
align 4
tinfo:
                    dd SSF_START_APP
                    dd 0
.params             dd .params_buf
                    dd 0
                    dd 0
                    db 0
.file_path          dd sz_tinfo_file_path
align 4
.params_buf:
times 11 db 0 ; at now 4 bytes will be enough, but may be in the future not
align 4
sz_tinfo_file_path  db "/sys/tinfo",0
; ---------------------------------------------------------------------------- ;
align 4
file_start:
        dd SSF_START_APP
        dd 0
        dd 0
        dd 0
        dd 0
start_application: db '/sys/LAUNCHER',0
start_application_e=$-start_application-1
;                   times 60 db 0
        rb 60
start_application_c=$-start_application-1
;------------------------------------------------------------------------------
IM_END:
;------------------------------------------------------------------------------
align 4
sc system_colors
winxpos         rd 1
winypos         rd 1
mouse_dd        rd 1
cpu_percent     rd 1
list_add        rd 1
curposy         rd 1
index           rd 1
tasklist        rd display_processes
time_counter    rd 1

window_status           rd 1
client_area_x_size      rd 1
client_area_y_size      rd 1
bar_bacground_color     rd 1
btn_bacground_color     rd 1
draw_window_flag        rd 1
;------------------------------------------------------------------------------
align 4
library_path:
process_info_buffer process_information
;------------------------------------------------------------------------------
align 4
cur_dir_path:
        rb 1024
        rb 1024
stack_area:
U_END:
