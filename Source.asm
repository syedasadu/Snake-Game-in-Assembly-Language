[org 0x100]
		jmp start

; Start From here 
start:
        call clrscr
        call frontPage
        call load_border
        mov si, score_msg
        mov ax, 0xb800
        mov es, ax
        mov di, 58
        mov cx, 16
        mov ah, 0x04
    lable1:
        mov byte al, [si]
        mov word[es:di], ax
        add di, 2
        inc si
        loop lable1
        call print_food
        call move_right

        mov ax, 0x4c00
        int 0x21

;SCREEN CLEARING FUNCTION
clrscr:    
        push ax
        push es
        push di
        mov ax, 0xb800
        mov es, ax
        mov di, 0
    clrlab:
        mov word [es:di], 0x0720
        add di, 2
        cmp di, 4000
        jne clrlab
        pop di
        pop es
        pop ax
        ret

;STRING PRINTING FUNCTION
printstr: 
        push bp
        mov bp, sp
        push es
        push ax
        push cx
        push si
        push di
        push ds
        pop es 
        mov di, [bp+4]
        mov cx, 0xffff
        xor al, al 
        repne scasb 
        mov ax, 0xffff 
        sub ax, cx 
        dec ax 
        jz exit 
        mov cx, ax 
        mov ax, 0xb800
        mov es, ax 
        mov al, 80 
        mul byte [bp+8] 
        add ax, [bp+10] 
        shl ax, 1 
        mov di,ax 
        mov si, [bp+4] 
        mov ah, [bp+6] 
        cld
    nextchar: 
        lodsb 
        stosw
        loop nextchar
    exit: 
        pop di
        pop si
        pop cx
        pop ax
        pop es
        pop bp
        ret 8


; FRONT PAGE PRINTING
frontPage:

        push 5
        push 14
        mov ax, 0x02
        push ax
        mov ax, str3
        push ax
        call printstr

        push 5
        push 16
        mov ax, 0x03
        push ax
        mov ax, str1
        push ax
        call printstr

        push 5
        push 17
        mov ax, 0x03
        push ax
        mov ax, str2
        push ax
        call printstr

        mov cx, 40
        
        push 2
        push 2
        mov ax, 0x04
        push ax
        mov ax, msg1
        push ax
        call printstr

        push 2
        push 4
        mov ax, 0x03
        push ax
        mov ax, names
        push ax
        call printstr
        
        push 2
        push 6
        mov ax, 0x03
        push ax
        mov ax, names1
        push ax
        call printstr

        Call delay
        Call delay
        Call delay
        Call delay
        Call delay

; EATING FOOD FUNCTION
foodEated:
        push bp
        mov bp, sp
        sub sp, 2
        push ax
        push bx
        push cx
        push dx
        push si

        mov si, snakePosition
        mov ax, word[snakeLength]
        dec ax
        shl ax, 1
        add si, ax  ;calculating the head snakePositionition of snake
        mov ax, word[randNo]
        mov word[bp-2], ax
        cmp [si], ax
        jne no_eat
        mov ax, word[randNo]
        mov word[space], ax
        call print_space
        call print_food

        inc word[snakeLength]
        inc word[score]
        add si, 2

        mov ax, word[bp-2]
        mov word[si], ax
    no_eat:
        call print_score


        pop si
        pop dx
        pop cx
        pop bx
        pop ax

        mov sp, bp
        pop bp
        ret

; KEYBOARD INTTERUPT FUNCTION
keybordInterrupt:
        push ax
        mov ax, 0
        mov ah, 0x01 
        int 0x16 ; call BIOS keyboard service
        jz no_int
        call movement
        no_int:

        pop ax
        ret

; RANDOM randNoBER FUNCTION
rand_no:
        push ax
        push dx
        push cx
        push bx

        rdtsc	;using interenet power  (Read Time Stamp Counter)
        mov dx, 0
        mov cx, 3998
        div cx	
        mov word[randNo], dx
        pop bx
        pop cx
        pop dx
        pop ax
        ret


; DELAY FUNCTION
delay: 
        push ax
        mov eax, 200000
    delaylab:
        dec eax
        cmp eax, 0
        jne delaylab
        pop ax
        ret

; CLEAR SCREEN FUNCTION
clear_scr:
        push ax
        push es
        push di

        mov ax, 0xb800
        mov es, ax
        xor di, di
    clr:
        mov word [es:di], 0x0720
        add di, 2
        cmp di, 4000
        jne clr

        pop di
        pop es
        pop ax
        ret


; RANDOM FOOD GENERATING FUNCTION
print_food:
        push ax
        push es
        push di
        push cx
        push dx; change color

        mov ax, 0xb800
        mov es, ax
        call rand_no
        test word[randNo], 1
        jz ok
        dec word[randNo]
        ok:
        call checking_food
        call inner_checking_food
        mov ax, word[randNo]
        mov di, ax
        cmp byte[colurFlag], 10
        jne skip_color
        mov byte[colurFlag], 1
    skip_color:
        inc byte[colurFlag]
        mov ah, byte[colurFlag]
        mov al, 0x02;assici of food 
        mov word[es:di], ax
        pop dx; change color
        pop cx
        pop di
        pop es
        pop ax
        ret


; BORDER PRINTING FUNCTION
printGameBorder:                         
        push bp
        mov bp, sp
        push ax
        push cx
        push es
        push di
        push dx
        mov ax, 0xb800
        mov es, ax
        mov dx,[bp+8]; add 2 or 160
        mov di, [bp+6];strating point 
        mov cx, [bp+4];Ending point 
    printGameBorderlab: 
        mov word [es:di], 0x7020
        add di, dx
        loop printGameBorderlab

        pop dx
        pop di
        pop es
        pop cx
        pop ax
        pop bp
        ret 6


; ALL BORDER PRINTING AND CLEARING SCREEN FUNCTION
load_border:
        push ax

        call clear_scr
        push 160
        push 0
        push 25
        call printGameBorder
        push 160
        push 158
        push 25
        call printGameBorder
        push 2
        push 0
        push 80
        call printGameBorder
        push 2
        push 3840
        push 80
        call printGameBorder
        push 2
        push 1320
        push 40
        call printGameBorder
        push 2
        push 2760
        push 40
        call printGameBorder
        push 160
        push 1320
        push 3
        call printGameBorder
        push 160
        push 2440
        push 3
        call printGameBorder
        push 160
        push 1400
        push 3
        call printGameBorder
        push 160
        push 2520
        push 3
        call printGameBorder
        push 2
        push 1988
        push 14
        call printGameBorder
        pop ax
        ret


; SNAKE PRINTING FUNCTION
print_snake:
        push ax
        push es
        push di
        push cx 
        push bx

        mov ax, 0xb800
        mov es, ax
        mov bx, snakePosition       ;we start from 2nd line (snakePositiontion: 162)
        mov cx, word[snakeLength]
        dec cx
    snakeLable:        ;snake body printing 
        cmp byte[colurFlag], 10
        jne skip_color1
        mov byte[colurFlag], 1
    skip_color1:
        inc byte[colurFlag]
        mov ah, byte[colurFlag]
        mov al,01
        mov di,[bx]
        mov word[es:di],ax   ;emojee assicc
        add bx, 2 
        loop snakeLable
        mov di, [bx]    ;snake head printing
        mov word[es:di], 0x0A02  ;emojee

        pop bx
        pop cx
        pop di
        pop es
        pop ax
        ret


; SPACE PRINTING FUNCTION
print_space:
        push ax
        push es
        push di

        mov ax, 0xb800
        mov es, ax
        mov word di, [space]
        mov word [es:di], 0x0720

        pop di
        pop es
        pop ax
        ret


; MOVING TO NEXT LOCATION FUNCTION
movingSnake:
        push bp
        mov bp,sp
        push ax
        push cx
        push si
        push di
        push dx
        push bx


        mov dx,[bp+6] ; add or sub
        mov di, snakePosition
        mov si, snakePosition
        mov ax, [snakePosition];word 
        add si, 2
        mov [space], ax
        mov cx, [snakeLength]
        dec cx
    movlab:
        mov ax , [si]
        mov [di], ax
        add si, 2
        add di, 2
        loop movlab
        mov bx, snakePosition
        mov cx, [snakeLength]
        dec cx
        shl cx, 1
        add bx, cx
        cmp word[bp+4] , 0
        jne other1
        add word[bx], dx
    other1:
        cmp word[bp+4] , 1
        jne other2
        sub word[bx], dx
    other2:	
        pop bx
        pop dx
        pop di
        pop si
        pop cx
        pop ax
        pop bp
        ret 4

; INNER BORDER DEATH CHECKING FUNCTION
check_border_inner:
        push ax
        push cx
        push dx
        push si
        push bx

        mov cx, word[snakeLength]
        dec cx
        shl cx, 1
        mov bx, snakePosition
        add bx, cx
        mov ax, [bx]
        
        mov cx ,1320
    check_inner_up1:
        cmp ax,cx
        je found1
        add cx ,2
        cmp cx,1400
        jne check_inner_up1
        
        mov cx ,2760
    check_inner_down1:
        cmp ax,cx
        je found1
        add cx ,2
        cmp cx,2840
        jne check_inner_down1	
        
        mov cx ,1320
    check_inner_left11:
        cmp ax,cx
        je found1
        add cx ,160
        cmp cx, 1800
        jne check_inner_left11
        
        mov cx ,2440
    check_inner_left21:
        cmp ax,cx
        je found1
        add cx ,160
        cmp cx, 2920
        jne check_inner_left21
        
        mov cx ,1400
    check_inner_right11:
        cmp ax,cx
        je found1
        add cx ,160
        cmp cx, 1880
        jne check_inner_right11
        
        mov cx ,2520
    check_inner_right21:
        cmp ax,cx
        je found1
        add cx ,160
        cmp cx, 3000
        jne check_inner_right21


        jmp skip_checking1
    found1:
        mov byte[dieFlag], 1
    skip_checking1:

        pop bx
        pop si
        pop dx
        pop cx
        pop ax
        ret
	
; BORDER DEATH CHECKING FUNCTION
check_border:
        push ax
        push cx
        push dx
        push si
        push bx

        mov cx, word[snakeLength]
        dec cx
        shl cx, 1
        mov bx, snakePosition
        add bx, cx
        mov ax, [bx]
        mov cx, 0
    check_left:
        cmp ax, cx
        je found
        add cx, 160
        cmp cx, 3840
        jne check_left;

        mov cx, 158
    check_right:
        cmp ax, cx
        je found
        add cx, 160
        cmp cx, 3998
        jne check_right

        mov cx, 0
    check_up:
        cmp ax, cx
        je found
        add cx, 2
        cmp cx, 158
        jne check_up

        mov cx, 3840
    check_down:
        cmp ax, cx
        je found
        add cx, 2
        cmp cx, 3998
        jne check_down
        
        mov bx ,1988
    midLine1:
        cmp ax,bx
        je found
        add bx ,2
        cmp bx, 2016
        jne midLine1	
        call check_border_inner
        
        jmp skip_checking
    found:
        mov byte[dieFlag], 1
    skip_checking:

        pop bx
        pop si
        pop dx
        pop cx
        pop ax
        ret


; INNER BORDER FOOD CHECKING FUNCTION

inner_checking_food:
        push ax
        push bx
        mov ax, word[randNo]


        mov bx ,2760
        check_inner_down:
            cmp ax,bx
            je regenrate
            add bx ,2
            cmp bx,2840
            jne check_inner_down	
            
            mov bx ,1320
        check_inner_left1:
            cmp ax,bx
            je regenrate
            add bx ,160
            cmp bx, 1800
            jne check_inner_left1
            
            mov bx ,2440
        check_inner_left2:
            cmp ax,bx
            je regenrate
            add bx ,160
            cmp bx, 2920
            jne check_inner_left2
            
            mov bx ,1400
        check_inner_right1:
            cmp ax,bx
            je regenrate
            add bx ,160
            cmp bx, 1880
            jne check_inner_right1
            
            mov bx ,2520
        check_inner_right2:
            cmp ax,bx
            je regenrate
            add bx ,160
            cmp bx, 3000
            jne check_inner_right2
            mov bx ,1988
        midLine:
            cmp ax,bx
            je regenrate
            add bx ,2
            cmp bx, 2016
            jne midLine


        jmp skip_check1
        regenrate:
            call print_food
        skip_check1:

        pop bx
        pop ax
        ret

; BORDER FOOD CHECKING FUNCTION

checking_food:
            push ax
            push cx

            mov ax, word[randNo]
            mov cx, 0
        checking_left:
            cmp ax, cx
            je founded
            add cx, 160
            cmp cx, 3840
            jne checking_left

            mov cx, 158
        checking_right:
            cmp ax, cx
            je founded
            add cx, 160
            cmp cx, 3998
            jne checking_right

            mov cx, 0
        checking_up:
            cmp ax, cx
            je founded
            add cx, 2
            cmp cx, 158
            jne checking_up

            mov cx, 3840
        checking_down:
            cmp ax, cx
            je founded
            add cx, 2
            cmp cx, 3998
            jne checking_down
            

            jmp skip_check
        founded:
            call print_food
        skip_check:

            pop cx
            pop ax
            ret


; LEFT MOVEMENT FUNCTION
        move_left:
        push ax

        mov byte[movFlag], 2
    left_move_lab:
        mov byte[dieFlag], 0
        call check_border
        cmp byte[dieFlag], 1
        je death_left
        call print_snake
        push 2
        push 1
        call movingSnake ; for left
        call delay
        call print_space
        call foodEated
        call self_collision
        call keybordInterrupt
        jmp left_move_lab

    death_left:
        call game_over
        pop ax
        ret


; RIGHT MOVEMENT FUNCTION
move_right:
        mov byte[movFlag], 1;movement flag
        push cx
        push ax

    right_move_Lab:
        mov byte[dieFlag], 0;death flag
        call check_border; set death flag
        cmp byte[dieFlag],1
        je death_right
        call print_snake
        push 2
        push 0
        call movingSnake
        call delay
        call print_space
        call foodEated
        call self_collision
        call keybordInterrupt
        jmp right_move_Lab
    death_right:
        call game_over
        pop ax
        pop cx
        ret


; UP MOVEMENT FUNCTION
move_up:
        push ax

        mov byte[movFlag], 3
    up_move_lab:
        mov byte[dieFlag], 0
        call check_border
        cmp byte[dieFlag], 1
        je death_is
        call print_snake
        push 160
        push 1
        call movingSnake ; for up
        call delay
        call print_space
        call foodEated
        call self_collision
        call keybordInterrupt
        call delay
        jmp up_move_lab
    death_is:
        call game_over
        pop ax
        pop cx
        ret


;DOWN MOVEMENT FUNCTION
move_down:
        push ax

        mov byte[movFlag], 4
    down_move_lab:
        mov byte[dieFlag], 0
        call check_border
        cmp byte[dieFlag], 1
        je death_down
        call print_snake
        push 160
        push 0
        call movingSnake
        call delay
        call print_space
        call foodEated
        call self_collision
        call keybordInterrupt
        call delay
        jmp down_move_lab
    death_down:
        call game_over
        pop ax
        ret

; OVERALL MOVEMENT CONTROLLER
movement:
    push ax
    mov ah, 0
    int 0x16

        cmp al, 'a';[A1]
        jne skip1
        cmp byte[movFlag], 1
        jne move_left
    skip1:
        cmp al, 'd';[D1]
        jne skip2
        cmp byte[movFlag], 2
        jne move_right
    skip2:
        cmp al, 'w';[W1]
        jne skip3
        cmp byte[movFlag], 4
        jne move_up
    skip3:
        cmp al, 's';[S1]
        cmp byte[movFlag], 3
        jne move_down
	
    pop ax
    ret


; SCORE PRINTING FUNCTION
print_score:
        push es
        push ax
        push bx
        push cx
        push dx
        push di
        mov ax, 0xb800
        mov es, ax 
        mov ax, word[score]
        mov bx, 10 
        mov cx, 0
        nextdigit: mov dx, 0
            div bx ; divide by 10
            add dl, 0x30
            push dx
            inc cx
            cmp ax, 0
            jnz nextdigit
            mov di, 90
        nextsnakePosition: 
            pop dx
            mov dh, 0x13 
            mov [es:di], dx 
            add di, 2 
        loop nextsnakePosition 
        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        pop es
        ret 


; SELF-COLLISION DEATH CHECK FUNCTION
self_collision:
        push bx
        push ax
        push cx

        mov bx, snakePosition
        mov ax, word[snakeLength]
        dec ax
        shl ax, 1
        add bx, ax
        mov ax, word[bx]
        mov bx, snakePosition
        mov cx, word[snakeLength]
        sub cx, 2
        selfLab:
            cmp [bx], ax
            jne skip_self
            call game_over
        skip_self:
            add bx, 2
            dec cx
            jnz selfLab

        pop cx
        pop ax
        pop bx
        ret
    
; GAME OVER FUNCTION
game_over:
    call clear_scr
    mov ax, 0xb800
    mov es, ax
    mov si, msgOver
    mov di, 338
    mov cx, 44
    mov ah, 0x04
    lableOver:
        mov byte al, [si]
        mov word[es:di], ax
        add di, 2
        inc si
    loop lableOver

    mov ax, 0x4c00
    int 0x21
    ret


    movFlag: db 0
    colurFlag: db 1
    dieFlag: db 0
    randNo: dw 260
    msgOver: db 'Thanks For Playing Our Beautiful Snake Game'
    score_msg: db ' Your Score is : '
    score: dw 0
    msg1:  db "****..........SNAKE GAME..........**** ",0
    names: db "-_  Asad Raza (22F-3850)",0
    names1: db "-_  Sharaz (22F-3425)",0
    str1: db "1.      UP(w) ", 0
    str2: db "2.      Left(A)  3.   Down(S)     4.  Right(D)", 0
    str3: db "CONTROLLING KEYS: ", 0
    snakeLength: dw 3
    space: dw 162
    snakePosition: dw 162, 164, 166
