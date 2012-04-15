; ##############################################################################
;
; Project: ICECARINT V1.0
; File Name: rs232.asm
; Processor: PIC16F914
; Frequency: 8 MHz
;
; ##############################################################################
;
; USART: 9600 8n1
; TX: PORTC6
; RX: PORTC7
;
; ##############################################################################
            list p=16f914
            #include p16f914.inc
            #include icecarint.inc
            #include rs232.inc

; ------------------------------------------------------------------------------
; Variables declaration
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; RS232 module
; ------------------------------------------------------------------------------
rs232       code

; ------------------------------------------------------------------------------
; Config rs232
; ------------------------------------------------------------------------------
rs232_config
            bcf     STATUS,RP0
            bcf     STATUS,RP1
    ; Configure pins direction
            bsf     STATUS,RP0
            bcf     TRISC,RC6
            bsf     TRISC,RC7
    ; Configure transmission
            movlw   H'04'
            movwf   TXSTA
    ; Configure baudrate
            movlw   H'33'
            movwf   SPBRG
            bcf     STATUS,RP0
    ; Configure reception
            movlw   H'10'
            movwf   RCSTA
            return
; ------------------------------------------------------------------------------
; Start/Restart rs232
; ------------------------------------------------------------------------------
rs232_start
            call    rs232_stop
    ; Clear interruption flags
            bcf     PIR1,RCIF
            bcf     PIR1,TXIF
    ; Enable interruptions
            bsf     STATUS,RP0
            bsf     PIE1,RCIE
            bsf     PIE1,TXIE
            bcf     STATUS,RP0
    ; Enable reception
            bsf     RCSTA,SPEN
            return
; ------------------------------------------------------------------------------
; Stop rs232
; ------------------------------------------------------------------------------
rs232_stop
            bcf     STATUS,RP0
            bcf     STATUS,RP1
    ; Disable reception
            bcf     RCSTA,SPEN
    ; Disable interruptions
            bsf     STATUS,RP0
            bcf     PIE1,RCIE
            bcf     PIE1,TXIE
            bcf     STATUS,RP0
    ; Clear previous data
            clrf    RS232STATUS
            clrf    RXDATIND
            clrf    TXDATIND
            return
; ------------------------------------------------------------------------------
; Tx rs232 interruption
; ------------------------------------------------------------------------------
rs232_tx_int
            call    rs232_tx
            bcf     PIR1,TXIF
            return
; ------------------------------------------------------------------------------
; Tx rs232
; ------------------------------------------------------------------------------
rs232_tx
            return
; ------------------------------------------------------------------------------
; Rx rs232 interruption
; ------------------------------------------------------------------------------
rs232_rx_int
            call    rs232_rx
            bcf     PIR1,RCIF
            return
; ------------------------------------------------------------------------------
; Rx rs232
; ------------------------------------------------------------------------------
rs232_rx
            bcf     STATUS,RP0
            bcf     STATUS,RP1
            ; Check if it is a start of transmission
            movlw   "@"
            subwf   RCREG,W
            btfss   STATUS,Z
            goto    rs232_rx_notstart
rs232_rx_start
            ; Check if transmission status is idle
            movf    RS232STATUS,F
            btfss   STATUS,Z
            goto    rs232_rx_conf
            ; Transmission start
            incf    RS232STATUS,F
            return
rs232_rx_conf
            call    rs232_rx_reset
            incf   RS232STATUS,F
            ; TODO: Send WARNING message
            return
rs232_rx_notstart
            ; Check if transmission status is started
            decf    RS232STATUS,W
            btfsc   STATUS,Z
            goto    rs232_rx_command
            call    rs232_rx_buffer
            return
rs232_rx_command
            incf    RS232STATUS,F
            ; Check if it is a command transmission
            movlw   "C"
            subwf   RCREG,W
            btfss   STATUS,Z
            goto    rs232_rx_message
            ; Command started
            return
rs232_rx_message
            incf    RS232STATUS,F
            ; Check if it is a message transmission
            movlw   "M"
            subwf   RCREG,W
            btfss   STATUS,Z
            goto    rs232_rx_err
            ; Message started
            return
rs232_rx_err
            call    rs232_rx_reset
            ; TODO: Send ERROR message
            return
; ------------------------------------------------------------------------------
; Rx rs232 buffer
; ------------------------------------------------------------------------------
rs232_rx_buffer
            ; Try save value to the buffer
            incf    RXDATIND,F
rs232_rx_buffer0
            movlw   H'01'
            subwf   RXDATIND,W
            btfss   STATUS,Z
            goto    rs232_rx_buffer1
            movf    RCREG,W
            movwf   RXDAT0
            return
rs232_rx_buffer1
            movlw   H'02'
            subwf   RXDATIND,W
            btfss   STATUS,Z
            goto    rs232_rx_buffer2
            movf    RCREG,W
            movwf   RXDAT1
            return
rs232_rx_buffer2
            movlw   H'03'
            subwf   RXDATIND,W
            btfss   STATUS,Z
            goto    rs232_rx_buffer3
            movf    RCREG,W
            movwf   RXDAT2
            return
rs232_rx_buffer3
            movlw   H'04'
            subwf   RXDATIND,W
            btfss   STATUS,Z
            goto    rs232_rx_buffer4
            movf    RCREG,W
            movwf   RXDAT3
            return
rs232_rx_buffer4
            movlw   H'05'
            subwf   RXDATIND,W
            btfss   STATUS,Z
            goto    rs232_rx_buffer5
            movf    RCREG,W
            movwf   RXDAT4
            return
rs232_rx_buffer5
            movlw   H'06'
            subwf   RXDATIND,W
            btfss   STATUS,Z
            goto    rs232_rx_buffer6
            movf    RCREG,W
            movwf   RXDAT5
            return
rs232_rx_buffer6
            movlw   H'07'
            subwf   RXDATIND,W
            btfss   STATUS,Z
            goto    rs232_rx_buffer7
            movf    RCREG,W
            movwf   RXDAT6
            return
rs232_rx_buffer7
            movlw   H'08'
            subwf   RXDATIND,W
            btfss   STATUS,Z
            goto    rs232_rx_buffer_throw
            movf    RCREG,W
            movwf   RXDAT7
            return
rs232_rx_buffer_throw
            decf    RXDATIND,F
            return
; ------------------------------------------------------------------------------
; Rx rs232 reset
; ------------------------------------------------------------------------------
rs232_rx_reset
            clrf    RXDATIND
            clrf    RS232STATUS
            return
;-------------------------------------------------------------------------------
            end