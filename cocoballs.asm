;***************************************************************************
; DEFINE SECTION
;***************************************************************************
; load vectrex bios routine definitions
                    INCLUDE  "VECTREX.I"          ; vectrex function INCLUDEs

;***************************************************************************
; Variable / RAM SECTION
;***************************************************************************
; insert your variables (RAM usage) in the BSS section
; user RAM STARTS at $c880 
                    BSS      
                    ORG      $c880                ; STArt of our ram space 

; Malban Shroom Rand
random_a            DS       1                            ; vars for own "random" - is much better than the internal BIOS one! 
random_b            DS       1                            
random_c            DS       1 
random_x            DS       1 


ObjectSpace         EQU     $200           ;where game ojects go.

;Constants

BallMinX            EQU     -126              ;how far can ball bounce to the left
BallMaxX            EQU     127            ;how far can ball bounce to the right
BallMinY            EQU     -126              ;how faw can ball bounce to the top
BallMaxY            EQU     127             ;how faw can ball bounce to the bottom

;Object definition
            org     0
ObjControl          RMB     1               ;Control/STAtus 1 byte of object
ObjXpos             RMB     1               ;Reserve Memory 2 Bytes 
ObjYpos             RMB     1               ;Reserve Memory 2 Bytes
ObjXdelta           RMB     2               ;Reserve Memory 2 Bytes
ObjYdelta           RMB     2               ;Reserve Memory 2 Bytes
ObjectSize          RMB     0               ;the size of each object

;Direct page definitions
            org      0
Random_MSB          RMB     1
Random_LSB          RMB     1
counter             RMB     1       ;A temp counter
Xcounter            RMB     1       ;temp X counter
Ycounter            RMB     1       ;temp Y counter 

ObjEndofList        EQU     %10000000       ;This is then end of Object list flag
ObjInuse            EQU     %01000000       ;object in use flag
ObjMove             EQU     %00100000       ;Object will move flag
ObjDraw             EQU     %00010000       ;Object sprite turned on flag

;random to use
Random_Word         EQU     Random_MSB






;***************************************************************************
; HEADER SECTION
;***************************************************************************
; The cartridge ROM STARTS at address 0
                    CODE     
                    ORG      0 
; the first few bytes are mANDAtory, otherwise the BIOS will not load
; the ROM file, and will STArt MineStorm instead
                    DB       "g GCE 2020", $80    ; 'g' is copyright sign
                    DW       music1               ; music from the rom 
                    DB       $F8, $50, $20, -$80  ; hight, width, rel y, rel x (from 0,0) 
                    DB       "COCOBALLS", $80      ; some game information, ending with $80
                    DB       0                    ; end of game header 

;***************************************************************************
; CODE SECTION
;***************************************************************************
; here the cartridge program STARTS off
;main: 


Start:       
             
                    JSR             Wait_Recal 
                    JSR             Intensity_3F 
                    lBSR            InitRandom      ;setup the ramdom number generator - only once                 
           

;Init the a ball Objec's STArting position
                    LDA             #3              ;Get number of ball objects
                    STA             counter         ;save for counting
                    LDU             #ObjectSpace    ;Get address of first object
            
BuildObject:         
                    LDA             #ObjInuse+ObjMove+ObjDraw ;show object in use and more
                    STA             ObjControl,u    ;show object in use.
                    LDA             #1
                    STA             ObjYpos,u       ;save in object
                    
                    STA             ObjXpos,u        ;save in object

;Init the ball'a speed
                    lBSR            GetRandom       ;Get a random number generator
                    ANDA            #$3             ;make it from 0.0 to 3.99
                    INCA                            ;make it 1.0 to 4.99
                    BITB            #1              ;if the lowest bit zero?  (Flip a coin)
                    BEQ             BuildObj1       ;skip if zero or heaDS
                    NEGA                            ;make it from -1.0 to -2.99
BuildObj1:   
                    STD             ObjYdelta,u     ;update the Y speed of the object
                    lBSR            GetRandom       ;Get a random number generator
                    ANDA            #$1             ;make it from 0.0 to 1.99
                    INCA                            ;make it 1.0 to 2.99
                    BITB            #1              ;if the lowest bit zero?  (Flip a coin)
                    BEQ             BuildObj2       ;skip if zero or heaDS
                    NEGA                            ;make it from -1.0 to -2.99
BuildObj2:  
                    STD             ObjXdelta,u     ;update the X speed of the object
                    LEAU            ObjectSize,u    ;move to next object
                    DEC             counter         ;and more objects to build?
                    BNE             BuildObject     ;yes, then loop

             

                    LDA             #ObjEndofList   ;now, add in end of list flag.
                    STA             ,u              ;and record it at the end of object list
            


;Main loop of coco balls
MainLoop:

                    JSR      Wait_Recal 
                    JSR      Intensity_3F 
 
EraseDone:   
                    LDU             #ObjectSpace    ;get STArt of object list for drawing sprites

DrawObj1:   

                    LDA             ObjControl,u    ;get control flag of object
                    BMI             DrawObjDone     ;skip out if at the object list

                    ;save x
                    PSHS    x

                    LDA     ObjYpos,u       ;Get object y position
                    ldb     ObjXpos,u       ;Get object x position        
                    TFR      d,x            ; in x position of list 
                    LDA      #$80           ; scale positioning 
                    LDB      #$140          ; scale move in list 
                    ;save u
                    PSHS     u
                    LDU      #VballSprite0   
                    JSR      draw_synced_list 


                    ;restore u
                    PULS     u
                    ;restore x
                    PULS     x
DrawObj2:    
                    LEAU            ObjectSize,u    ;move to next object

                    BRA             DrawObj1        ;and loop back to draw more sprites

DrawObjDone:           
                    LDU             #ObjectSpace    ;get address of first object


MoveObj1:
                    LDA             ObjControl,u    ;get stsatus of this object
                    BMI             MoveObjDone     ;end move if we hit the end of list flag
                    ANDA            #ObjMove        ;is the move this object flag set
                    BEQ             MoveObj2        ;skip if not
                    BSR             MoveBall        ;call this movement type
MoveObj2:
                    LEAU            ObjectSize,u    ;move to next object
                    BRA             MoveObj1        ;and loop back for next object to move
            
MoveObjDone:
            
                    BRA             MainLoop          ;loop back to main loop for next dot position

          
MoveBall:

                    LDA             ObjYpos,u       ;get current y-position  
                    LDB             #0
                    ADDD            ObjYdelta,u     ;move to next y-position - BRAndon note: add to d but only COMPARE the top half (A)
                    CMPA            #BallMinY            ;did we move too far to the left?
                    BLE             MoveBall1            ;skip to NEGAtive the speed
                    CMPA            #BallMaxY       ;is it too far to left?
                    BLE             Yinrange        ;skip if it is in range

;this next bit of code reverses the direction of the Ydelta (y-speed) of the dot.
MoveBall1:
                    CLRA                         ;get the NEGAtive of the y delta
                    CLRB                         ;by subtracting it from zero
                    SUBD            ObjYdelta,u
                    STD             ObjYdelta,u     ;save NEGAtive speed
                    ADDA            ObjYpos,u       ;get new Y position

Yinrange:
                    STA             ObjYpos,u       ;save new Y - position

                    LDA             ObjXpos,u       ;get current X - position 
                    LDB             #0
                    ADDD            ObjXdelta,u     ;move to next X position - BRAndon note: add to d but only COMPARE the top half (A)
                    CMPA            #BallMinX     ;did we move too far left/right
                    BLE             MoveBall2       ;skip to NEGAtive the speed
                    CMPA            #BallMaxX   ;Are we too far down?
                    BLE             Xinrange          ;skip if it is in range

;This next bit of code reverses the direction of the Xdelta (x-speed) of the dot.
MoveBall2:
                    CLRA                         ;get the negtive of the y delta
                    CLRB                         ;by subtracting it from zero
                    SUBD            ObjXdelta,u
                    STD             ObjXdelta,u     ;save the NEGAtive speed
                    ADDA            ObjXpos,u          ;get new y position

Xinrange:     
                    STA             ObjXpos,u       ;save new y position
                    RTS


           


            
;***************************************************************************

;#######################################################
; FUNCTIONS & DATA INCLUDES
;#######################################################
                    INCLUDE       "functions.i"
                    INCLUDE       "data_graphics.i"
                    END      
;***************************************************************************
