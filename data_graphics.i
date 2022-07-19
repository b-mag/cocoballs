;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  NON-GRAPHIC DATA
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; TEXT DATA
subtitlestring:
 DB     "COCOBALLS port of a basic ball demo for Tandy CoCo"
 DB      $80 
startstring: 
 DB     "not used"
 DB      $80 
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  Cool pictures and things
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

VballSprite0:
 DB $01, +$01, -$17 ; sync and move to y, x
 DB $FF, -$14, +$0C ; draw, y, x
 DB $FF, +$01, +$15 ; draw, y, x
 DB $FF, +$13, +$0C ; draw, y, x
 DB $FF, +$11, -$06 ; draw, y, x
 DB $FF, +$01, -$19 ; draw, y, x
 DB $FF, -$12, -$0E ; draw, y, x
 DB $01, +$01, -$17 ; sync and move to y, x
 DB $FF, +$00, +$00 ; draw, y, x
 DB $FF, -$14, +$0C ; draw, y, x
 DB $02 ; endmarker 


Vpawpaw:
 DB $01, -$1B, -$11 ; sync and move to y, x
 DB $FF, -$02, +$1C ; draw, y, x
 DB $FF, +$0F, +$18 ; draw, y, x
 DB $FF, +$1D, +$09 ; draw, y, x
 DB $FF, +$0C, -$12 ; draw, y, x
 DB $FF, -$11, -$11 ; draw, y, x
 DB $FF, -$0A, -$12 ; draw, y, x
 DB $FF, +$02, -$16 ; draw, y, x
 DB $FF, -$0A, -$0B ; draw, y, x
 DB $FF, -$10, +$0B ; draw, y, x
 DB $FF, -$02, +$10 ; draw, y, x
 DB $01, -$05, -$1A ; sync and move to y, x
 DB $FF, -$0E, +$05 ; draw, y, x
 DB $00, -$01, +$10 ; mode, y, x
 DB $FF, +$10, -$05 ; draw, y, x
 DB $00, +$00, -$10 ; mode, y, x
 DB $01, -$01, +$00 ; sync and move to y, x
 DB $FF, -$0C, +$06 ; draw, y, x
 DB $00, +$06, +$12 ; mode, y, x
 DB $FF, +$0E, -$08 ; draw, y, x
 DB $00, -$09, -$11 ; mode, y, x
 DB $02 ; endmarker 

SpikeBall:
 DB $01, -$04, -$01 ; sync and move to y, x
 DB $FF, -$01, -$04 ; draw, y, x
 DB $FF, +$04, +$03 ; draw, y, x
 DB $FF, +$00, -$08 ; draw, y, x
 DB $FF, +$03, +$08 ; draw, y, x
 DB $FF, +$04, -$01 ; draw, y, x
 DB $FF, -$04, +$05 ; draw, y, x
 DB $FF, +$03, +$04 ; draw, y, x
 DB $FF, -$06, -$02 ; draw, y, x
 DB $FF, -$01, +$06 ; draw, y, x
 DB $FF, -$01, -$07 ; draw, y, x
 DB $FF, -$04, +$01 ; draw, y, x
 DB $FF, +$03, -$05 ; draw, y, x
 DB $02 ; endmarker 
