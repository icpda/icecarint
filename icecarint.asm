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

; _CP_OFF: Code protection disabled
; _PWRTE_ON: Power time enabled
; _WDT_OFF: Watch dog timer disabled
; _INTOSCIO: Internal oscillator enabled
            __config _CP_OFF & _PWRTE_ON & _WDT_OFF & _INTOSCIO

; ------------------------------------------------------------------------------
; Assemblies included (Features)
; ------------------------------------------------------------------------------
            #include rs232.asm
            #include pwm.asm

; ------------------------------------------------------------------------------
; Variables declaration
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Reset vector
; ------------------------------------------------------------------------------
start       org     H'0000'
            goto    main
; ------------------------------------------------------------------------------
; Interrupt vector
; ------------------------------------------------------------------------------
interrupt   org     H'0004'
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
            movf    TEMPW,W
            retfie
; ------------------------------------------------------------------------------
; Main program
; ------------------------------------------------------------------------------
main
            bcf     STATUS,RP0
            bcf     STATUS,RP1
    ; Configure Internal 8 MHz Clock
            bsf     STATUS,RP0
            movlw   H'70'
            iorwf   OSCCON,F
            bcf     STATUS,RP0
    ; Clear all ports
            call    clear_ports
    ; Configure necesary modules
            call    rs232_conf
            call    pwm_conf
    ; Start necesary modules
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
            end