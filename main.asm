

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

.equ    letterF = 0x71
.equ    letterP = 0x73
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
.def    turnTrack = R25
.def    displayCountLow = R26
.def    displayCountHigh = R27

.org $0000 
	jmp RESET
.org %006
    jmp StopTimerInt
.org $0014
 	jmp MsecT0Int


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
clr     displayCountLow
clr     displayCountHigh
ldi     secDigit, $FF ;For start screen delay
ldi     turnTrack, $01   

ldi temp, 1<<INT2
out GICR, temp ; INT2 activation
; INITIALIZE MCUCSR
ldi temp, 1<<ISC2
out MCUCSR, temp ; Rising edge act.

clr     temp

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
    clr     temp  
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

DisplayTurn:            ;print out 'turn' text to sevseg
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
    rjmp    DisplayP2
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
    rcall   Long_Delay5
    ldi     temp, $00
    out     PORTD, temp

    sei 

;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;   MAIN PART   ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

MainLoop:
    rcall   SevSegDrive
    cpi     temp4, $AA      ;to check if showing timer result phase is started
    breq    ShowResultTime
    rjmp    MainLoop



;; Delay subroutine
Delay:	ldi     temp2, $00
	    ldi     temp3, $06
Wait:	subi    temp2, 1
	    sbci    temp3, 0
	    brcc    Wait
	    ret

Long_Delay:	ldi     temp2, $00
	        ldi     temp3, $FF
WaitL:	    subi    temp2, 1
	        sbci    temp3, 0
	        brcc    WaitL
	        ret
Long_Delay5:
    rcall   Long_Delay
    rcall   Long_Delay
    rcall   Long_Delay
    rcall   Long_Delay
    rcall   Long_Delay
    ret

CheckTurn:
    clr     temp4
    cpi     turnTrack, $01
    breq    ChangeTurn
    rcall   CalcRoundWin
    rjmp    ShowP1Points

ChangeTurn:
    ldi     turnTrack, $02
    push    secDigit
    push    msecDigit1
    push    msecDigit2
    push    msecDigit3
    rjmp    DisplayP2           ;maybe just 'jmp'??

CalcRoundWin:
    pop     temp                ;secDigit of P1
    cp      temp, secDigit
    brsh    


ShowResultTime:
    inc     displayCountLow
    brcs    IncreaseHighNibble
    ret
IncreaseHighNibble:
    inc     displayCountHigh
    sbrc    displayCountHigh, 6
    rjmp    CheckTurn
    ret

SevSegDrive:
    ldi     temp, $00
    out     PORTA, temp
    rcall   DriveMsec3
    ldi     temp, $01
    out     PORTA, temp
    rcall   DriveMsec2
    ldi     temp, $02
    out     PORTA, temp
    rcall   DriveMsec1
    ldi     temp, $03
    out     PORTA, temp
    rcall   DriveSec
    ret

DriveMsec3:
    rcall  DisplayMsec3
    rcall  Delay
    ret
DriveMsec2:
    rcall  DisplayMsec2
    rcall  Delay
    ret
DriveMsec1:
    rcall  DisplayMsec1
    rcall  Delay
    ret
DriveSec:
    rcall  DisplaySec
    rcall  Delay
    ret

DisplayMsec3:
    cpi     msecDigit3, $09
    breq    showNine
    cpi     msecDigit3, $08
    breq    showEight
    cpi     msecDigit3, $07
    breq    showSeven
    cpi     msecDigit3, $06
    breq    showSix
    cpi     msecDigit3, $05
    breq    showFive 
    cpi     msecDigit3, $04
    breq    showFour 
    cpi     msecDigit3, $03
    breq    showThree
    cpi     msecDigit3, $02
    breq    showTwo
    cpi     msecDigit3, $01
    breq    showOne
    cpi     msecDigit3, $00
    breq    showZero
    ret 
DisplayMsec2:
    cpi     msecDigit2, $09
    breq    showNine
    cpi     msecDigit2, $08
    breq    showEight
    cpi     msecDigit2, $07
    breq    showSeven
    cpi     msecDigit2, $06
    breq    showSix
    cpi     msecDigit2, $05
    breq    showFive 
    cpi     msecDigit2, $04
    breq    showFour 
    cpi     msecDigit2, $03
    breq    showThree
    cpi     msecDigit2, $02
    breq    showTwo
    cpi     msecDigit2, $01
    breq    showOne
    cpi     msecDigit2, $00
    breq    showZero
    ret 

showNine:
    ldi     temp, num9
    out     PORTC, temp
    ret
showEight:
    ldi     temp, num8
    out     PORTC, temp
    ret
showSeven:
    ldi     temp, num7
    out     PORTC, temp
    ret
showSix:
    ldi     temp, num6
    out     PORTC, temp
    ret
showFive:
    ldi     temp, num5
    out     PORTC, temp
    ret
showFour:
    ldi     temp, num4
    out     PORTC, temp
    ret
showThree:
    ldi     temp, num3
    out     PORTC, temp
    ret
showTwo:
    ldi     temp, num2
    out     PORTC, temp
    ret
showOne:
    ldi     temp, num1
    out     PORTC, temp
    ret
showZero:
    ldi     temp, num0
    out     PORTC, temp
    ret

DisplayMsec1:
    cpi     msecDigit1, $09
    breq    showNine
    cpi     msecDigit1, $08
    breq    showEight
    cpi     msecDigit1, $07
    breq    showSeven
    cpi     msecDigit1, $06
    breq    showSix
    cpi     msecDigit1, $05
    breq    showFive 
    cpi     msecDigit1, $04
    breq    showFour 
    cpi     msecDigit1, $03
    breq    showThree
    cpi     msecDigit1, $02
    breq    showTwo
    cpi     msecDigit1, $01
    breq    showOne
    cpi     msecDigit1, $00
    breq    showZero
    ret
DisplaySec:
    cpi     secDigit, $09
    breq    showNine
    cpi     secDigit, $08
    breq    showEight
    cpi     secDigit, $07
    breq    showSeven
    cpi     secDigit, $06
    breq    showSix
    cpi     secDigit, $05
    breq    showFive 
    cpi     secDigit, $04
    breq    showFour 
    cpi     secDigit, $03
    breq    showThree
    cpi     secDigit, $02
    breq    showTwo
    cpi     secDigit, $01
    breq    showOne
    cpi     secDigit, $00
    breq    showZero
    ret


StopTimer:      ;stop timer and start the timer result display phase
    ;;;;;
    ldi     temp4, $AA
    ret

StopTimerInt:
    push    temp
    in      temp,SREG
    push    temp

    rcall StopTimer 

    pop     temp
    out     SREG, temp
    pop     temp
    reti


MsecT0Int:
    push    temp
    in      temp,SREG
    push    temp

    rcall TimerDrive   

    pop     temp
    out     SREG, temp
    pop     temp
    reti

TimerDrive:
    inc     msecDigit3
    cpi     msecDigit3, $10
    brsh    OverMsec3
    ret

OverMsec3:
    subi    msecDigit3, $0A
    inc     msecDigit2
    cpi     msecDigit2, $10
    brsh    OverMsec2
    ret

OverMsec2:
    subi    msecDigit2, $0A
    inc     msecDigit1
    cpi     msecDigit1, $10
    brsh    OverMsec1
    ret

OverMsec1:
    subi    msecDigit1, $0A
    inc     secDigit
    cpi     secDigit, $9
    brsh    StopTimer
    ret

