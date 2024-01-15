

;|~~~~~~~~~~~~~~~~~~~~~~~~~~~~|;
;|   -   F1 REFLEX GAME   -   |;  
;|~~~~~~~~~~~~~~~~~~~~~~~~~~~~|;

;SEV-SEG Numbers
.equ    num9= 0x6F
.equ    num8= 0x7F
.equ    num7= 0x07
.equ    num6= 0x7D
.equ    num5= 0x6D
.equ    num4= 0x66
.equ    num3= 0x4F
.equ    num2= 0x5B
.equ    num1= 0x06
.equ    num0= 0x3F
.equ    letterP = 0x73
.equ    letterF = 0x71
.equ    letterT = 0x78
.equ    letterU = 0x1C
.equ    letterR = 0x50
.equ    letterN = 0x54
.equ    LightSequance1 = 0x18 ;For the Red Lights in PORTD
.equ    LightSequance2 = 0x3C
.equ    LightSequance3 = 0x7E
.equ    LightSequance4 = 0xFF


;REGISTERS
.def    temp = R16
.def    temp2 = R17
.def    temp3 = R18
.def    temp4 = R19
.def    secDigit = R20
.def    msecDigit1 = R21
.def    msecDigit2 = R22
.def    msecDigit3 = R23
.def    scoreTrack = R24

.org $0000
	jmp RESET
.org $0016
 	jmp MsecOVFT0


RESET:
;INITIALIZE
ldi     temp, low(RAMEND) 
out     spl, temp
ldi     temp, high(RAMEND) 
out     sph, temp

ldi     secDigit, $00
ldi     msecDigit1, $00
ldi     msecDigit2, $00

ldi     temp, $00
out     DDRB, temp
ldi     temp, $FF
out     DDRD, temp ;F1 Red Light Sequance Output
out     DDRC, temp ; SEVSEG o/p
out     DDRA, temp
clr     temp
clr     temp4
ldi     secDigit, $F0   

;Main Subroutines between actual timing.

StartScreen:
    inc     temp
    ldi     temp2, (1<<2)
    out     PORTA, temp2
    ldi     temp2, letterF
    out     PORTC, temp2
    rcall   Delay
    ldi     temp2, (1<<1)
    out     PORTA, temp2
    ldi     temp2, num1
    out     PORTC, temp2
    rcall   Delay
    cpse    temp, secDigit
    rjmp    StartScreen
    ldi     secDigit, $C0  
	rjmp	ShowP1Points

ScoreTransform:
    cpi     temp, $00
    breq    ScoreToSevsegZero
    cpi     temp, $01
    breq    ScoreToSevsegOne
    cpi     temp, $02
    breq    ScoreToSevsegTwo
    cpi     temp, $03
    breq    ScoreToSevsegThree
    ret

ScoreToSevsegZero:
    ldi     temp, num0
    ret
ScoreToSevsegOne:
    ldi     temp, num1
    ret
ScoreToSevsegTwo:
    ldi     temp, num2
    ret
ScoreToSevsegThree:
    ldi     temp, num3
    ret
    
ShowP1Points:
    inc     temp4
    ldi     temp, (1<<3)
    out     PORTA, temp
    ldi     temp, letterP
    out     PORTC, temp
    rcall   Delay
    ldi     temp, (1<<2)
    out     PORTA, temp
    ldi     temp, num1
    out     PORTC, temp
    rcall   Delay
    ldi     temp, (1<<0)
    out     PORTA, temp
    mov     temp, scoreTrack
    andi    temp, $03
    rcall   ScoreTransform
    out     PORTC, temp
    rcall   Delay
    cpse    temp4, secDigit
    rjmp    ShowP1Points
    clr     temp4

ShowP2Points:   
    inc     temp4
    ldi     temp, (1<<3)
    out     PORTA, temp
    ldi     temp, letterP
    out     PORTC, temp
    rcall   Delay
    ldi     temp, (1<<2)
    out     PORTA, temp
    ldi     temp, num2
    out     PORTC, temp
    rcall   Delay
    ldi     temp, (1<<0)
    out     PORTA, temp
    mov     temp, scoreTrack
    swap    temp
    andi    temp, $03
    rcall   ScoreTransform
    out     PORTC, temp
    rcall   Delay
    cpse    temp4, secDigit
    rjmp    ShowP2Points
    clr     temp4

DisplayP1:  
    inc     temp4
    ldi     temp, (1<<2)
    out     PORTA, temp
    ldi     temp, letterP
    out     PORTC, temp
    rcall   Delay
    ldi     temp, (1<<1)
    out     PORTA, temp
    ldi     temp, num1
    out     PORTC, temp
    rcall   Delay
    cpse    temp4, secDigit
    rjmp    DisplayP1
    clr     temp4

DisplayTurn:
    inc     temp4
    ldi     temp, (1<<3)
    out     PORTA, temp
    ldi     temp, letterT
    out     PORTC, temp
    rcall   Delay
    ldi     temp, (1<<2)
    out     PORTA, temp
    ldi     temp, letterU
    out     PORTC, temp
    ldi     temp, (1<<1)
    out     PORTA, temp
    ldi     temp, letterR
    out     PORTC, temp
    rcall   Delay
    ldi     temp, (1<<0)
    out     PORTA, temp
    ldi     temp, letterN
    out     PORTC, temp
    rcall   Delay
    cpse    temp4, secDigit
    rcall   DisplayTurn
    clr     temp4
    rjmp    RedLightDrive

DisplayP2:
    inc     temp4
    ldi     temp, (1<<2)
    out     PORTA, temp
    ldi     temp, letterP
    out     PORTC, temp
    rcall   Delay
    ldi     temp, (1<<1)
    out     PORTA, temp
    ldi     temp, num2
    out     PORTC, temp
    rcall   Delay
    cpse    temp4, secDigit
    rjmp    DisplayP1
    clr     temp4
    rjmp    DisplayTurn

RedLightDrive:
    ldi     temp, LightSequance1
    out     PORTD, temp
    rcall   Long_Delay
    rcall   Long_Delay
    rcall   Long_Delay
    ldi     temp, LightSequance2
    out     PORTD, temp
    rcall   Long_Delay
    rcall   Long_Delay
    rcall   Long_Delay
    ldi     temp, LightSequance3
    out     PORTD, temp
    rcall   Long_Delay
    rcall   Long_Delay
    rcall   Long_Delay
    ldi     temp, LightSequance4
    out     PORTD, temp
    rcall   Long_Delay
    rcall   Long_Delay
    rcall   Long_Delay
    ldi     temp, $00
    out     PORTD, temp
    rcall   DiffDelay

;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;   MAIN PART   ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

MainLoop:
    







;; Delay subroutine
Delay:	ldi     temp2, $00
	    ldi     temp3, $06
Wait:	subi    temp2, 1
	    sbci    temp3, 0
	    brcc    Wait
	    ret

Long_Delay:	ldi     temp2, $00
	    ldi     temp3, $FF
WaitL:	subi    temp2, 1
	    sbci    temp3, 0
	    brcc    WaitL
	    ret

MsecOVFT0:
    push    temp
    in      temp,SREG
    push    temp

    rcall   