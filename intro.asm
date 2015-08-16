;
; aW50cm8=
;
; 1k intro by knl & Ishy
;
; Released @ Assembly 2015 (5th place)
;
; Initially built upon dx9 example in hitchhikr's 1kpack release v0.9c,
; later ported to Crinkler 2.0 for better compression.
; 
bits    32

%include "d3d9_nasm.inc"

SCREENX                         equ     1920
SCREENY                         equ     1080

WS_EX_TOPMOST                   equ     0x8
VK_ESCAPE                       equ     0x1b
PM_REMOVE                       equ     0x1
SCREENDEPTH                     equ     D3DFMT_A8R8G8B8 ; 32 bits
D3DFVF_XYZRHW_SIZE              equ     (4 * 4)


    global _entry

    extern __imp__CreateWindowExA@48
    extern __imp__SetCursor@4
    extern __imp__GetAsyncKeyState@4
    extern __imp__Direct3DCreate9@4
    extern __imp__QueryPerformanceFrequency@4
    extern __imp__QueryPerformanceCounter@4
    extern __imp__midiOutOpen@20
    extern __imp__midiOutShortMsg@8
    extern __imp__ExitProcess@4
    extern __imp__D3DXCompileShader@40 

    section main text align=1
    _entry: 

    push    Device ; CreateDevice
    push    Present_Buffer
    push    D3DCREATE_SOFTWARE_VERTEXPROCESSING

    push    D3D_SDK_VERSION ; Direct3DCreate9

    push    0 ; D3DXCompileShader
    push    0
    push    PixelShader
    push    0
    push    PShaderProfileName
    push    ProcedureName
    push    0
    push    0
    push    (fPShader - PShader)
    push    PShader

    push    0 ; SetCursor

    push    0 ; CreateWindowEx
    push    0
    push    0
    push    0
    push    0
    push    0
    push    0
    push    0
    push    0
    push    0
    push    ClassName
    push    WS_EX_TOPMOST
    call    [__imp__CreateWindowExA@48]
    mov     ebx, eax
    call    [__imp__SetCursor@4]

    call    [__imp__D3DXCompileShader@40]

    call    [__imp__Direct3DCreate9@4]

    push    ebx
    push    D3DDEVTYPE_HAL
    push    D3DADAPTER_DEFAULT       
    push    eax
    mov     ebx, [eax]
    call    [ebx + IDirect3D9.CreateDevice]

    mov     eax,PixelShader
    push    eax
    mov     eax, [eax]
    push    eax
    mov     ebx, [eax]
    call    [ebx + ID3DXConstantTable.GetBufferPointer]

    push    eax
    mov     eax, [Device]
    push    eax
    mov     ebx, [eax]
    call    [ebx + IDirect3DDevice9.CreatePixelShader]

    mov     eax,OldTime
    push    eax
    call    [__imp__QueryPerformanceCounter@4]

    ;calling midiOutOpen
    push    0
    push    0
    push    0
    push    0
    push    bss_hMidi
    call    [__imp__midiOutOpen@20]

    ;change instrument ch1
    push    0101110111000000b ;metallic
    push    dword [bss_hMidi]
    call    [__imp__midiOutShortMsg@8]

    ;change instrument ch2
    push    0101100111000001b ;warm
    push    dword [bss_hMidi]
    call    [__imp__midiOutShortMsg@8]

    push    0111010111000010b ;melodic tom
    push    dword [bss_hMidi]
    call    [__imp__midiOutShortMsg@8]

    Set_Note:
    fldz
    fstp    dword [Music_Count]

    cmp     dword [Beat_Total],38
    ja      Quit

    cmp     dword [Beat_Total],36
    ja      End_Channel_Two
    ; tom
    mov     eax,011001000010101010010010b
    push    eax
    push    dword [bss_hMidi]
    call    [__imp__midiOutShortMsg@8]
    ; kill sound ch1
    push    0111101110110000b
    push    dword [bss_hMidi]
    call    [__imp__midiOutShortMsg@8]
    ; kill sound ch2
    push    0111101110110001b
    push    dword [bss_hMidi]
    call    [__imp__midiOutShortMsg@8]

    cmp     byte [Beat_Count],8
    jne     No_Flip

    ; set 0 back to 8
    mov     byte [Beat_Count],0
    No_Flip:
    cmp     dword [Beat_Total],34
    ja      End_Music
    ; channel 1
    mov     eax,011001000000111110010000b 
    mov     edx,01110010101000111010000011000000b 
    mov     cl,[Beat_Count] 
    add     cl,cl
    add     cl,cl          
    shr     edx,cl       
    and     ah,dl       
    or      ah,100000b 
    push    eax
    push    dword [bss_hMidi]
    call    [__imp__midiOutShortMsg@8]

    cmp     dword [Beat_Total],8
    jb      End_Channel_Two
    ; channel 2
    mov     eax, 010100000000111110010001b 
    mov     edx, 01100010101000111010000000000000b 
    mov     cl,[Beat_Count]     
    add     cl,cl
    add     cl,cl              
    shr     edx, cl           
    and     ah, dl           
    or      ah, 101100b       
    push    eax
    push    dword [bss_hMidi]
    call    [__imp__midiOutShortMsg@8]

    jmp     End_Channel_Two
    End_Music:
    cmp     dword [Beat_Total],35
    ja      End_Music_2
    mov     eax, 011001000010110010010000b
    push    eax
    push    dword [bss_hMidi]
    call    [__imp__midiOutShortMsg@8]
    jmp     End_Music_3 

    End_Music_2:
    mov     eax, 011001000010000010010000b
    push    eax
    push    dword [bss_hMidi]
    call    [__imp__midiOutShortMsg@8]
    End_Music_3:

    mov     eax, 011001000010110010010001b
    push    eax
    push    dword [bss_hMidi]
    call    [__imp__midiOutShortMsg@8]
    ; channel 2 end
    End_Channel_Two:
    inc     byte [Beat_Count]
    inc     dword [Beat_Total]
    jmp     Back_Note
    MainLoop:
    fild    qword [OldTime] 
    mov     eax,OldTime
    push    eax
    call    [__imp__QueryPerformanceCounter@4]
    fild    qword [OldTime] 
    fsubp   st1, st0 
    mov     eax, HTimerFreq
    push    eax
    call    [__imp__QueryPerformanceFrequency@4]
    fild    qword [HTimerFreq] 
    fdivp   st1, st0 

    fld     st0 
    fsubr   dword [Scroll_Pos] 
    fstp    dword [Scroll_Pos] 
    fsubr   dword [Music_Count]
    fst     dword [Music_Count]
    fldpi 
    fcomip st1

    jb      Set_Note
    Back_Note:

    push    VK_ESCAPE ; GetAsyncKeyState

    push    0 ; Present
    push    0
    push    0
    push    0
    mov     eax, [Device]
    push    eax
    mov     ebx, [eax]

    push    eax ; EndScene

    push    D3DFVF_XYZRHW_SIZE ; DrawPrimitiveUP
    push    BigTriangle
    push    1
    push    D3DPT_TRIANGLELIST
    push    eax

    push    D3DFVF_XYZRHW ; SetFVF
    push    eax

    push    dword [PixelShader]
    push    eax

    push    1; SetPixelShaderConstantF
    push    Scroll_Pos
    push    0   
    push    eax

    push    1 ; SetPixelShaderConstantF
    push    Music_Count
    push    1
    push    eax

    push    eax
    call    [ebx + IDirect3DDevice9.BeginScene]
    call    [ebx + IDirect3DDevice9.SetPixelShaderConstantF]
    call    [ebx + IDirect3DDevice9.SetPixelShaderConstantF]
    call    [ebx + IDirect3DDevice9.SetPixelShader]
    call    [ebx + IDirect3DDevice9.SetFVF]
    call    [ebx + IDirect3DDevice9.DrawPrimitiveUP]
    call    [ebx + IDirect3DDevice9.EndScene]
    call    [ebx + IDirect3DDevice9.Present]
    call    [__imp__GetAsyncKeyState@4]

    sahf
    jns     MainLoop
    Quit:
    call    [__imp__ExitProcess@4]

    section rest data
    ClassName:           db      "edi"
    ProcedureName:       db      "t", 0
    PShaderProfileName:  db      "ps_3_0", 0
    bss_hMidi:           dd      0


    PShader:
    %include "pixelshader1_minified.inc"
    fPShader:


    Present_Buffer:                 
    dd      SCREENX                
    dd      SCREENY                
    dd      SCREENDEPTH            
    dd      0                      
    dd      0                      
    dd      0                      
    BigTriangle:                   
    dd      D3DSWAPEFFECT_DISCARD  
    dd      0                      
    dd      0
    dd      0                      
    dd      3840.0                
    dd      0                      
    dd      0                      
    dd      0                      
    dd      0
    dd      3840.0

    section vars bss
    Vars:
    Device:       resb 4
    OldTime:      resb 8
    HTimerFreq:   resb 8
    PixelShader:  resb 4
    Scroll_Pos:   resb 4
    Music_Count:  resb 4
    Beat_Total:   resb 4
    Beat_Count:   resb 1
