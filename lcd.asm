; ##############################################################################
;
; Project: ICECARINT V1.0
; File Name: lcd.asm
; Processor: PIC16F914
; Frequency: 8 MHz
;
; ##############################################################################
;
; Display Message to LCD 8x2
; LCD Data: PORTB
; LCD RS: PORTE0
; LCD RW: PORTE1
; LCD E: PORTE2
;
; ##############################################################################
            #include p16f914.inc
            #include lcd.inc

; ------------------------------------------------------------------------------
; LCD module
; ------------------------------------------------------------------------------
lcd         code

; ------------------------------------------------------------------------------
; Config lcd
; ------------------------------------------------------------------------------
lcd_conf
            bcf     STATUS,RP0
            bcf     STATUS,RP1
    ; Configure pins direction
            bsf     STATUS,RP0
            movlw   H'18'
            andwf   TRISE,F
            clrf    TRISB
    ; Disable analog input pins
            movlw   H'1F'
            andwf   ANSEL,F
    ; Config Timer0 and disable pull-ups on port b
            movlw   H'C2'
            movwf   OPTION_REG
            bcf     STATUS,RP0
            return
; ------------------------------------------------------------------------------
; Prepare lcd
; ------------------------------------------------------------------------------
lcd_prepare
            bcf     STATUS,RP0
            bcf     STATUS,RP1
    ; Clear Display
            movlw   H'01'
            call    lcd_ctrl
    ; Function Set
            movlw   H'38'
            call    lcd_ctrl
    ; Return Home
            movlw   H'02'
            call    lcd_ctrl
    ; Display ON
            movlw   H'0E'
            call    lcd_ctrl
    ; Entry Display Set
            movlw   H'06'
            call    lcd_ctrl
    ; Cursor Shift
    ;        movlw   H'1C'
    ;        call   lcd_ctrl
            return
; ------------------------------------------------------------------------------
; Write message row1
; ------------------------------------------------------------------------------
lcd_write_msg1
            bcf     STATUS,RP0
            bcf     STATUS,RP1

    ; Goto row1
            call    lcd_to_row1

            movf    LCDDAT0,W
            call    lcd_char
            movf    LCDDAT1,W
            call    lcd_char
            movf    LCDDAT2,W
            call    lcd_char
            movf    LCDDAT3,W
            call    lcd_char
            movf    LCDDAT4,W
            call    lcd_char
            movf    LCDDAT5,W
            call    lcd_char
            movf    LCDDAT6,W
            call    lcd_char
            movf    LCDDAT7,W
            call    lcd_char
            return
; ------------------------------------------------------------------------------
; Write message row2
; ------------------------------------------------------------------------------
lcd_write_msg2
            bcf     STATUS,RP0
            bcf     STATUS,RP1

    ; Goto row2
            call    lcd_to_row2

            movf    LCDDAT8,W
            call    lcd_char
            movf    LCDDAT9,W
            call    lcd_char
            movf    LCDDATA,W
            call    lcd_char
            movf    LCDDATB,W
            call    lcd_char
            movf    LCDDATC,W
            call    lcd_char
            movf    LCDDATD,W
            call    lcd_char
            movf    LCDDATE,W
            call    lcd_char
            movf    LCDDATF,W
            call    lcd_char
            return
; ------------------------------------------------------------------------------
; Go to lcd row1
; ------------------------------------------------------------------------------
lcd_to_row1
            movlw   H'02'
            call    lcd_ctrl
            return
; ------------------------------------------------------------------------------
; Go to lcd row2
; ------------------------------------------------------------------------------
lcd_to_row2
            movlw   H'C0'
            call    lcd_ctrl
            return
; ------------------------------------------------------------------------------
; Control command lcd
; ------------------------------------------------------------------------------
lcd_ctrl
            movwf   PORTB
            bcf     PORTE,RE0
            bcf     PORTE,RE1
            bsf     PORTE,RE2
            nop
            bcf     PORTE,RE2
            call    delay_1ms
            call    delay_1ms
            return
; ------------------------------------------------------------------------------
; Character command lcd
; ------------------------------------------------------------------------------
lcd_char
            movwf   PORTB
            bsf     PORTE,RE0
            bcf     PORTE,RE1
            bsf     PORTE,RE2
            nop
            bcf     PORTE,RE2
            call    wait_lcd_bf
            return
; ------------------------------------------------------------------------------
; 1ms delay
; ------------------------------------------------------------------------------
delay_1ms
            movlw   H'06'
            movwf   TMR0
            bcf     INTCON,T0IF
wait_1ms
            btfss   INTCON,T0IF
            goto    wait_1ms
            return
; ------------------------------------------------------------------------------
; Wait lcds busy flag
; ------------------------------------------------------------------------------
wait_lcd_bf
            bsf     STATUS,RP0
            movlw   H'FF'
            movwf   TRISB
            bcf     STATUS,RP0
            bcf     PORTE,0
            bsf     PORTE,1
wait_bf
            bsf     PORTE,2
            nop
            bcf     PORTE,2
            btfsc   PORTB,7
            goto    wait_bf
            bsf     STATUS,RP0
            clrf    TRISB
            bcf     STATUS,RP0
            return
; ------------------------------------------------------------------------------
; Variables declaration
; ------------------------------------------------------------------------------
global  lcd_conf
global  lcd_prepare
global  lcd_write_msg1
global  lcd_write_msg2
; ------------------------------------------------------------------------------
            end