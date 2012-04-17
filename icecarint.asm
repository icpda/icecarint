; ##############################################################################
;
; Project: ICECARINT V1.0
; File Name: icecarint.asm
; Processor: PIC16F914
; Frequency: 8 MHz
;
; ##############################################################################
            list p=16f914
            #include p16f914.inc
            #include icecarint.inc
            #include rs232.inc
            #include pwm.inc
            #include lcd.inc

; _CP_OFF: Code protection disabled
; _PWRTE_ON: Power time enabled
; _WDT_OFF: Watch dog timer disabled
; _INTOSCIO: Internal oscillator enabled
            __config _CP_OFF & _PWRTE_ON & _WDT_OFF & _INTOSCIO

; ------------------------------------------------------------------------------
; Reset vector
; ------------------------------------------------------------------------------
start       code    H'0000'
            goto    main
; ------------------------------------------------------------------------------
; Interrupt vector
; ------------------------------------------------------------------------------
interrupt   code    H'0004'
    ; Save context
            movwf   TMPW
            movf    STATUS,W
            movwf   TMPSTATUS

            bcf     STATUS,RP0
            bcf     STATUS,RP1
    ; Check for Rx int
            btfsc   PIR1,RCIF
            call    rs232_rx_int
    ; Check for Tx int
            btfsc   PIR1,TXIF
            call    rs232_tx_int

    ; Restore context
            movf    TMPSTATUS,W
            movwf   STATUS
            movf    TMPW,W
            retfie
; ------------------------------------------------------------------------------
; Main program
; ------------------------------------------------------------------------------
main
            bcf     STATUS,RP0
            bcf     STATUS,RP1
    ; Clear all ports
            call    clear_ports
    ; Configure Internal 8 MHz Clock
            bsf     STATUS,RP0
            movlw   H'70'
            iorwf   OSCCON,F
            bcf     STATUS,RP0
    ; Configure modules
            call    rs232_conf
            call    lcd_conf
            call    pwm_conf
    ; Prepare modules
            call    lcd_prepare
    ; Booting..
            call    boot_mesg
    ; Start modules
            call    rs232_start
    ; Enable interrupts
            call    int_enable
loop
            goto    loop
; ------------------------------------------------------------------------------
; Clear ports
; ------------------------------------------------------------------------------
clear_ports
            clrf    PORTA
            clrf    PORTB
            clrf    PORTC
            clrf    PORTD
            clrf    PORTE
            return
; ------------------------------------------------------------------------------
; Interrupts enable
; ------------------------------------------------------------------------------
int_enable
    ; Enable global and peripheral interruptions
            movlw   H'C0'
            movwf   INTCON
            return
; ------------------------------------------------------------------------------
; Load boot message
; ------------------------------------------------------------------------------
boot_mesg
            bcf     STATUS,RP0
            bcf     STATUS,RP1
    ; TODO: Load message from E2PROM
            movlw   "I"
            movwf   LCDDAT0
            movlw   "C"
            movwf   LCDDAT1
            movlw   "E"
            movwf   LCDDAT2
            movlw   "C"
            movwf   LCDDAT3
            movlw   "A"
            movwf   LCDDAT4
            movlw   "R"
            movwf   LCDDAT5
            movlw   "1"
            movwf   LCDDAT6
            movlw   "0"
            movwf   LCDDAT7
            call    lcd_write_msg1
            movlw   "B"
            movwf   LCDDAT8
            movlw   "O"
            movwf   LCDDAT9
            movlw   "O"
            movwf   LCDDATA
            movlw   "T"
            movwf   LCDDATB
            movlw   "I"
            movwf   LCDDATC
            movlw   "N"
            movwf   LCDDATD
            movlw   "G"
            movwf   LCDDATE
            movlw   "*"
            movwf   LCDDATF
            call    lcd_write_msg2
            return
; ------------------------------------------------------------------------------
            end