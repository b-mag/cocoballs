;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
; Sub routines will live here! 
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; best viewed with VIDE!
;
;***************************************************************************
; SUBROUTINE SECTION
;***************************************************************************

;ZERO ing the integrators takes time. Measures at my vectrex show e.g.:
;If you move the beam with a to x = -127 and y = -127 at diffferent scale values, the time to reach zero:
;- scale $ff -> zero 110 cycles
;- scale $7f -> zero 75 cycles
;- scale $40 -> zero 57 cycles
;- scale $20 -> zero 53 cycles
ZERO_DELAY          EQU      7                            ; delay 7 counter is exactly 111 cycles delay between zero SETTING and zero unsetting (in moveto_d) 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;U = address of vectorlist
;X = (y,x) position of vectorlist (this will be point 0,0), positioning on screen
;A = scalefactor "Move" (after sync)
;B = scalefactor "Vector" (vectors in vectorlist)
;
;     mode, rel y, rel x,                                             
;     mode, rel y, rel x,                                             
;     .      .      .                                                
;     .      .      .                                                
;     mode, rel y, rel x,                                             
;     0x02
; where mode has the following meaning:         
; negative draw line                    
; 0 move to specified endpoint                              
; 1 sync (and move to list start and than to place in vectorlist)      
; 2 end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
draw_synced_list: 
                    pshs     a                            ; remember out different scale factors 
                    pshs     b 
                                                          ; first list entry (first will be a sync + moveto_d, so we just stay here!) 
                    lda      ,u+                          ; this will be a "1" 
sync: 
                    deca                                  ; test if real sync - or end of list (2) 
                    bne      drawdone                     ; if end of list -> jump 
; zero integrators
                    ldb      #$CC                         ; zero the integrators 
                    stb      <VIA_cntl                    ; store zeroing values to cntl 
                    ldb      #ZERO_DELAY                  ; and wait for zeroing to be actually done 
; reset integrators
                    clr      <VIA_port_a                  ; reset integrator offset 
                    lda      #%10000010 
; wait that zeroing surely has the desired effect!
zeroLoop: 
                    sta      <VIA_port_b                  ; while waiting, zero offsets 
                    decb     
                    bne      zeroLoop 
                    inc      <VIA_port_b 
; unzero is done by moveto_d
                    lda      1,s                          ; scalefactor move 
                    sta      <VIA_t1_cnt_lo               ; to timer t1 (lo= 
                    tfr      x,d                          ; load our coordinates of "entry" of vectorlist 
                    jsr      Moveto_d                     ; move there 
                    lda      ,s                           ; scale factor vector 
                    sta      <VIA_t1_cnt_lo               ; to timer T1 (lo) 
moveTo: 
                    ldd      ,u++                         ; do our "internal" moveto d 
                    beq      nextListEntry                ; there was a move 0,0, if so 
                    jsr      Moveto_d 
nextListEntry: 
                    lda      ,u+                          ; load next "mode" byte 
                    beq      moveTo                       ; if 0, than we should move somewhere 
                    bpl      sync                         ; if still positive it is a 1 pr 2 _> goto sync 
; now we should draw a vector 
                    ldd      ,u++                         ;Get next coordinate pair 
                    STA      <VIA_port_a                  ;Send Y to A/D 
                    CLR      <VIA_port_b                  ;Enable mux 
                    LDA      #$ff                         ;Get pattern byte 
                    INC      <VIA_port_b                  ;Disable mux 
                    STB      <VIA_port_a                  ;Send X to A/D 
                    LDB      #$40                         ;B-reg = T1 interrupt bit 
                    CLR      <VIA_t1_cnt_hi               ;Clear T1H 
                    STA      <VIA_shift_reg               ;Store pattern in shift register 
setPatternLoop: 
                    BITB     <VIA_int_flags               ;Wait for T1 to time out 
                    beq      setPatternLoop               ; wait till line is finished 
                    CLR      <VIA_shift_reg               ; switch the light off (for sure) 
                    bra      nextListEntry 

drawdone: 
                    puls     d                            ; correct stack and go back 
                    rts      




;****************************************************************************
;END OF MALBAN FUNCTIONS ***************************************************
;*****************************************************************************


;draw_test_item 
                   ;ldu      #Vpawpaw
			     ;LDA       ObjYpos,u 
                   ;LDB      ObjXpos,u   
                   ;LDA      #20
                   ;LDB      #25                
                   ;TFR      d,x                          ; in x position of list 
                  ; LDA      #$40                         ; scale positioning 
                  ; LDB      #$40                         ; scale move in list 
                  ; JSR      draw_synced_list 
                  ; RTS

;*************************************************************************8
; mountain goat random
;*************************************************************

;Goat_Random	
	;lda	seed
	;asla
	;bcc 	rand_done
	;eora 	#$1d
;rand_done:
	;sta 	seed
	;RTS

;*********************************************************************
;ENd of brandon test draw function - Begin of Malban Shroom Random
;*********************************************************************

RANDOM_A_alt           
                    inc      random_x 
                    lda      random_a 
                    eora     random_b 
                    eora     random_x 
                    sta      random_a 
                    adda     random_b 
                    sta      random_b 
                    lsra     
                    eora     random_a 
                    adda     random_c 
                    sta      random_c 
                    RTS    
*This code Inits the random number generator...
*Input - None
*Output - None
*Used - A, B

InitRandom ldd Random_Word      ;is the 16 bit random word zero?
           bne ExitInitRandom   ;No, then exit the inti code
           inc Random_MSB       ;Yes, than change state to something else that zero
ExitInitRandom rts

;GetRandom 
;Input - None
;Output - a, b (D) as the new random 16-bit word
;Used - A, B - Use to return new random word
;Note - New random word in Rndom_Word

GetRandom
        clr    ,-s               ;Clear holder of LFSB
        lda    Random_MSB        ;get high byte of 16-bit Random word
        anda   #%10110100        ;Get the bits check in shifting
        ldb    #6                ;Use the top 6 bits for xoring

GetRandom1
        lsla                     ;move top bit into the carry flag
        bcc    GetRandom2        ;skip incing the LFSB if no carry
        inc    ,s                ;add one to the LFSB test holder

GetRandom2
        decb                     ;remove one from loop counter
        bne    GetRandom1        ;loop if all bits are not done

        lda    ,s+               ;get LFSB off of stack
        inca                     ;invert lower bit by adding one
        rora                     ;move bit 0 into carry
        rol    Random_LSB        ;shift carry in to the bit 0 of Random_LSB
        rol    Random_MSB        ;one for shift to complete the 16 shifting
        ldd    Random_Word       ;Load up a and b with the new Random word
        rts
