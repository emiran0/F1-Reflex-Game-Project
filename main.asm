

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
.equ	letterL = 0x38
.equ	letterA = 0x77
.equ	letterY = 0x6E

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
.def	p1SecHolder = R28
.def	p1Msec1Holder = R29
.def	p1Msec2Holder = R30
.def	p1Msec3Holder = R31


.org $0000 
	jmp RESET
.org $006
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
ldi		scoreTrack, $00

clr     temp

;Main Subroutines between actual timing.

StartScreen1:
    inc     temp
    ldi     temp2, (1<<3)
    out     PORTA, temp2
    ldi     temp2, letterP
    out     PORTC, temp2
    rcall   Delay
	rcall   Delay
    ldi     temp2, (1<<2)
    out     PORTA, temp2
    ldi     temp2, letterL
    out     PORTC, temp2
    rcall   Delay
	rcall   Delay
	ldi     temp2, (1<<1)
    out     PORTA, temp2
    ldi     temp2, letterA
    out     PORTC, temp2
    rcall   Delay
	rcall   Delay
	ldi     temp2, (1<<0)
    out     PORTA, temp2
    ldi     temp2, letterY
    out     PORTC, temp2
    rcall   Delay
	rcall   Delay
    cpse    temp, secDigit
    rjmp    StartScreen1
    clr     temp  
	clr		secDigit

StartScreen2:
    inc     temp
    ldi     temp2, (1<<2)
    out     PORTA, temp2
    ldi     temp2, letterF
    out     PORTC, temp2
    rcall   Delay
	rcall   Delay
    ldi     temp2, (1<<1)
    out     PORTA, temp2
    ldi     temp2, num1
    out     PORTC, temp2
    rcall   Delay
	rcall   Delay
    cpse    temp, secDigit
    rjmp    StartScreen2
    clr     temp  
	clr		secDigit
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

BlinkP1Won:
    ldi     temp, (1<<2)
    out     PORTA, temp
    ldi     temp, letterP
    out     PORTC, temp
    rcall   Delay
	rcall   Delay
    ldi     temp, (1<<1)
    out     PORTA, temp
    ldi     temp, num1
    out     PORTC, temp
    rcall   Delay
	rcall   Delay
	ldi		temp, $00
	out		PORTA, temp
	rcall	Long_Delay
    rjmp    BlinkP1Won
BlinkP2Won:
    ldi     temp, (1<<2)
    out     PORTA, temp
    ldi     temp, letterP
    out     PORTC, temp
    rcall   Delay
	rcall   Delay
    ldi     temp, (1<<1)
    out     PORTA, temp
    ldi     temp, num2
    out     PORTC, temp
    rcall   Delay
	rcall   Delay
	ldi		temp, $00
	out		PORTA, temp
	rcall	Long_Delay
    rjmp    BlinkP2Won

CheckForFinish:
	mov     temp, scoreTrack
    andi    temp, $03
	cpi		temp, $03
	breq	P1Won
	clr		temp
	mov     temp, scoreTrack
	swap	temp
    andi    temp, $03
	cpi		temp, $03
	breq	P2Won
	ret
P1Won:
	rjmp	BlinkP1Won
P2Won:
	rjmp	BlinkP2Won

	
    
ShowP1Points:
    inc     temp4
    ldi     temp, (1<<3)
    out     PORTA, temp
    ldi     temp, letterP
    out     PORTC, temp
    rcall   Delay
	rcall   Delay
    ldi     temp, (1<<2)
    out     PORTA, temp
    ldi     temp, num1
    out     PORTC, temp
    rcall   Delay
	rcall   Delay
    ldi     temp, (1<<0)
    out     PORTA, temp
	clr		temp
    mov     temp, scoreTrack
    andi    temp, $03
    rcall   ScoreTransform
    out     PORTC, temp
    rcall   Delay
	rcall   Delay
    sbrs    temp4, 7
    rjmp    ShowP1Points
	clr		p1secHolder
	clr		p1Msec1Holder
	clr		p1Msec2Holder
	clr		p1Msec3Holder
    clr     temp4

ShowP2Points:   
    inc     temp4
    ldi     temp, (1<<3)
    out     PORTA, temp
    ldi     temp, letterP
    out     PORTC, temp
    rcall   Delay
	rcall   Delay
    ldi     temp, (1<<2)
    out     PORTA, temp
    ldi     temp, num2
    out     PORTC, temp
    rcall   Delay
	rcall   Delay
    ldi     temp, (1<<0)
    out     PORTA, temp
    mov     temp, scoreTrack
    swap    temp
    andi    temp, $03
    rcall   ScoreTransform
    out     PORTC, temp
    rcall   Delay
	rcall   Delay
    sbrs    temp4, 7
    rjmp    ShowP2Points
	rcall	CheckForFinish
    clr     temp4

DisplayP1:  
    inc     temp4
    ldi     temp, (1<<2)
    out     PORTA, temp
    ldi     temp, letterP
    out     PORTC, temp
    rcall   Delay
	rcall   Delay
    ldi     temp, (1<<1)
    out     PORTA, temp
    ldi     temp, num1
    out     PORTC, temp
    rcall   Delay
	rcall   Delay
    sbrs    temp4, 7
    rjmp    DisplayP1
	ldi		turnTrack, $01

    clr     temp4

DisplayTurn:            ;print out 'turn' text to sevseg
    inc     temp4
    ldi     temp, (1<<3)
    out     PORTA, temp
    ldi     temp, letterT
    out     PORTC, temp
    rcall   Delay
	rcall   Delay
    ldi     temp, (1<<2)
    out     PORTA, temp
    ldi     temp, letterU
    out     PORTC, temp
	rcall	Delay
	rcall   Delay
    ldi     temp, (1<<1)
    out     PORTA, temp
    ldi     temp, letterR
    out     PORTC, temp
    rcall   Delay
	rcall   Delay
    ldi     temp, (1<<0)
    out     PORTA, temp
    ldi     temp, letterN
    out     PORTC, temp
    rcall   Delay
	rcall   Delay
	ldi		temp, $00
	out		PORTC, temp
    sbrs    temp4, 7
    rjmp	DisplayTurn

    clr     temp4
    rjmp     RedLightDrive

DisplayP2:
    inc     temp4
    ldi     temp, (1<<2)
    out     PORTA, temp
    ldi     temp, letterP
    out     PORTC, temp
    rcall   Delay
	rcall   Delay
    ldi     temp, (1<<1)
    out     PORTA, temp
    ldi     temp, num2
    out     PORTC, temp
    rcall   Delay
	rcall   Delay
    sbrs    temp4, 7
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
    rcall   DiffDelay
	rcall	InitInterrupts
	sei
	ldi     temp, $00
    out     PORTD, temp
	clr		secDigit
	clr		msecDigit1
	clr		msecDigit2
	clr		msecDigit3
	clr		temp
	clr		temp4
	
	rjmp	MainLoop

InitInterrupts:
	; INITIALIZE Timer0 CTC interrupt
	ldi temp, (1<<WGM01)|(1<<CS01)|(1<<CS00)		; prescale 64 and CTC mode
	out TCCR0, temp
	ldi temp, $0E		; to get 0.001 sec timer0 interrupt
	out OCR0, temp
	ldi temp, 1<<OCIE0
	out TIMSK, temp

	ldi temp, 1<<INT2
	out GICR, temp ; INT2 activation
	; INITIALIZE MCUCSR
	ldi temp, 1<<ISC2
	out MCUCSR, temp ; Rising edge act.
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;       MAIN PART      ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MainLoop:

    rcall   SevSegDrive
	rcall	CheckForTurn
	sbrc	displayCountHigh, 5		;check for result display time over
	rcall	CheckTurn
    
    rjmp    MainLoop

;; Delay subroutines
Delay:	ldi     temp2, $00
	    ldi     temp3, $02
Wait:	subi    temp2, 1
	    sbci    temp3, 0
	    brcc    Wait
	    ret

Long_Delay:	ldi     temp2, $00
	        ldi     temp3, $AA
WaitL:	    subi    temp2, 1
	        sbci    temp3, 0
	        brcc    WaitL
	        ret
DiffDelay:
	cpi		turnTrack, $01
	breq	P2Delay
	cpi		turnTrack, $0F
	breq	P1Delay
    ret

P2Delay:
	ldi		temp, $00
	rcall	Long_Delay
	rcall	Long_Delay
	cpse	msecDigit2, temp
	dec		msecDigit2
	cpse	msecDigit2, temp
	rjmp	P2Delay
	ret
P1Delay:
	rcall	Long_Delay
	rcall	Long_Delay
	ldi		temp, $00
	cpse	p1Msec2Holder, temp
	dec		p1Msec2Holder
	cpse	p1Msec2Holder, temp
	rjmp	P1Delay
	ret

CheckTurn:
    clr     temp4
	clr		displayCountHigh
	ldi		temp, $01
    cpse    turnTrack, temp
	rcall   CalcRoundWinSec
    rcall   ChangeTurn
    ret

ChangeTurn:
    ldi     turnTrack, $0F
	mov		p1SecHolder, secDigit
	mov		p1Msec1Holder, msecDigit1
	mov		p1Msec2Holder, msecDigit2
	mov		p1Msec3Holder, msecDigit3
    rjmp    DisplayP2           

AddPointsToP2Sec:
	ldi		temp, $10
	add		scoreTrack, temp
	rjmp	ShowP1Points
AddPointsToP1Sec:
	ldi		temp, $01
	add		scoreTrack, temp
	rjmp	ShowP1Points 
CalcRoundWinSec:               ;secDigit of P1
    cp      secDigit, p1SecHolder
    brsh    CheckP1WinSec
	cp		secDigit, p1SecHolder
	brlo	AddPointsToP2Sec	;;
	ret
CheckP1WinSec:
	cp		secDigit, p1SecHolder
	breq	CalcP1WinMsec1
	cp		secDigit, p1SecHolder
	brne	AddPointsToP1Sec	;;
	ret
AddPointsToP2Msec1:
	ldi		temp, $10
	add		scoreTrack, temp
	rjmp	ShowP1Points
AddPointsToP1Msec1:
	ldi		temp, $01
	add		scoreTrack, temp
	rjmp	ShowP1Points 
CalcP1WinMsec1:				;msecDigit1
	cp		msecDigit1, p1Msec1Holder
	brsh	CheckP1WinMsec1
	cp		msecDigit1, p1Msec1Holder
	brlo	AddPointsToP2Msec1	;;
	ret
CheckP1WinMsec1:
	cp		msecDigit1, p1Msec1Holder
	breq	CalcP1WinMsec2
	cp		msecDigit1, p1Msec1Holder
	brne	AddPointsToP1Msec1	;;
	ret
AddPointsToP2Msec2:
	ldi		temp, $10
	add		scoreTrack, temp
	rjmp	ShowP1Points
AddPointsToP1Msec2:
	ldi		temp, $01
	add		scoreTrack, temp
	rjmp	ShowP1Points 
CalcP1WinMsec2:			;msecDigit2
	cp		msecDigit2, p1Msec2Holder
	brsh	CheckP1WinMsec2
	cp		msecDigit2, p1Msec2Holder
	brlo	AddPointsToP2Msec2	;;
	ret
CheckP1WinMsec2:
	cp		msecDigit2, p1Msec2Holder
	breq	CalcP1WinMsec3
	cp		msecDigit2, p1Msec2Holder
	brne	AddPointsToP1Msec2
	ret
CalcP1WinMsec3:			;msecDigit3
	cp		msecDigit3, p1Msec3Holder
	brsh	CheckP1WinMsec3
	cp		msecDigit3, p1Msec3Holder
	brlo	AddPointsToP2Msec3	;;
	ret
CheckP1WinMsec3:
	cp		msecDigit3, p1Msec3Holder
	breq	TieRoundNoPoints
	cp		msecDigit3, p1Msec3Holder
	brne	AddPointsToP1Msec3
	ret
AddPointsToP2Msec3:
	ldi		temp, $10
	add		scoreTrack, temp
	rjmp	ShowP1Points
AddPointsToP1Msec3:
	ldi		temp, $01
	add		scoreTrack, temp
	rjmp	ShowP1Points 
TieRoundNoPoints:
	rjmp	ShowP1Points
			
CheckForTurn:
	ldi		temp, $AA
	cpse    temp4, temp
	ret						     ;to check if showing reflex result phase is started
	rcall	ShowResultTime
	ret

ShowResultTime:
	cli
    inc     displayCountLow
    sbrs    displayCountLow, 4
    ret
	rcall	IncreaseHighNibble
	ret

IncreaseHighNibble:
	clr		displayCountLow
    inc     displayCountHigh
    ret

SevSegDrive:
    ldi     temp, (1<<0)
    out     PORTA, temp
    rcall   DriveMsec3
    ldi     temp, (1<<1)
    out     PORTA, temp
    rcall   DriveMsec2
    ldi     temp, (1<<2)
    out     PORTA, temp
    rcall   DriveMsec1
    ldi     temp, (1<<3)
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
    breq    showNineSec
    cpi     secDigit, $08
    breq    showEightSec
    cpi     secDigit, $07
    breq    showSevenSec
    cpi     secDigit, $06
    breq    showSixSec
    cpi     secDigit, $05
    breq    showFiveSec
    cpi     secDigit, $04
    breq    showFourSec 
    cpi     secDigit, $03
    breq    showThreeSec
    cpi     secDigit, $02
    breq    showTwoSec
    cpi     secDigit, $01
    breq    showOneSec
    cpi     secDigit, $00
    breq    showZeroSec
    ret

showNineSec:
    ldi     temp, num9
	ori		temp, $80
    out     PORTC, temp
    ret
showEightSec:
    ldi     temp, num8
	ori		temp, $80
    out     PORTC, temp
    ret
showSevenSec:
    ldi     temp, num7
	ori		temp, $80
    out     PORTC, temp
    ret
showSixSec:
    ldi     temp, num6
	ori		temp, $80
    out     PORTC, temp
    ret
showFiveSec:
    ldi     temp, num5
	ori		temp, $80
    out     PORTC, temp
    ret
showFourSec:
    ldi     temp, num4
	ori		temp, $80
    out     PORTC, temp
    ret
showThreeSec:
    ldi     temp, num3
	ori		temp, $80
    out     PORTC, temp
    ret
showTwoSec:
    ldi     temp, num2
	ori		temp, $80
    out     PORTC, temp
    ret
showOneSec:
    ldi     temp, num1
	ori		temp, $80
    out     PORTC, temp
    ret
showZeroSec:
    ldi     temp, num0
	ori		temp, $80
    out     PORTC, temp
    ret

StopTimerInt:
    push    temp
    in      temp,SREG
    push    temp

	ldi     temp4, $AA

    pop     temp
    out     SREG, temp
    pop     temp
    reti

MsecT0Int:
    push    temp
    in      temp,SREG
    push    temp

	ldi		temp, $AA
	cpse	temp4, temp
    rcall	TimerDrive   

    pop     temp
    out     SREG, temp
    pop     temp
    reti

TimerDrive:
    inc     msecDigit3
    cpi     msecDigit3, $0A
    brsh    OverMsec3
    ret

OverMsec3:
    clr		msecDigit3
    inc     msecDigit2
    cpi     msecDigit2, $0A
    brsh    OverMsec2
    ret

OverMsec2:
    clr		msecDigit2
    inc     msecDigit1
    cpi     msecDigit1, $0A
    brsh    OverMsec1
    ret

OverMsec1:
    subi    msecDigit1, $0A
    inc     secDigit
    cpi     secDigit, $09
    brsh    LimitSecNine
    ret
LimitSecNine:
	ldi		secDigit, $09
	ret

