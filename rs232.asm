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
            #include rs232.inc

; ------------------------------------------------------------------------------
; RS232 module
; ------------------------------------------------------------------------------
rs232       code

; ------------------------------------------------------------------------------
; Config rs232
; ------------------------------------------------------------------------------
rs232_conf
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
            clrf    RS232RXIND
            clrf    RS232TXIND
            return
; ------------------------------------------------------------------------------
; Tx rs232 interruption
; ------------------------------------------------------------------------------
rs232_tx_int
            ; First check if still missing bytes to transfer
            movf    RS232TXIND,W
            btfss   STATUS,Z
            call    rs232_tx
            bcf     PIR1,TXIF
            return
; ------------------------------------------------------------------------------
; Tx rs232
; ------------------------------------------------------------------------------
rs232_tx
            bcf     STATUS,RP0
            bcf     STATUS,RP1
            ; Start a transmission if not in progress
            movf    RS232TXIND,W
            btfsc   STATUS,Z
            goto    rs232_tx_new
rs232_tx1   movlw   H'04'
            subwf   RS232TXIND,W
            btfss   STATUS,Z
            goto    rs232_tx2
            movf    RS232TX1,W
            goto    rs232_tx_end
rs232_tx2   movlw   H'03'
            subwf   RS232TXIND,W
            btfss   STATUS,Z
            goto    rs232_tx3
            movf    RS232TX2,W
            goto    rs232_tx_end
rs232_tx3   movlw   H'02'
            subwf   RS232TXIND,W
            btfss   STATUS,Z
            goto    rs232_tx4
            movf    RS232TX3,W
            goto    rs232_tx_end
rs232_tx4   movf    RS232TX4,W
            goto    rs232_tx_end
rs232_tx_new
            movlw   H'05'
            movwf   RS232TXIND
            movf    RS232TX0,W
rs232_tx_end
            movwf   TXREG
            bsf     STATUS,RP0
            bsf     TXSTA,TXEN
            bcf     STATUS,RP0
            decf    RS232TXIND,F
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
            ; Echo all characters received
            movf    RCREG,W
            movwf   TXREG
            bsf     STATUS,RP0
            bsf     TXSTA,TXEN
            bcf     STATUS,RP0
            ; Check if it is a start of transmission
            movlw   "@"
            subwf   RCREG,W
            btfss   STATUS,Z
            goto    rs232_rx_notstart
rs232_rx_start
            ; Check if transmission status is idle
            movlw   RS232IDLE
            subwf   RS232STATUS,W
            btfss   STATUS,Z
            goto    rs232_rx_conf
            ; Transmission start
            movlw   RS232TRANS
            movwf   RS232STATUS
            return
rs232_rx_conf
            call    rs232_rx_reset
            movlw   RS232TRANS
            movwf   RS232STATUS
            ; TODO: Send WARNING message
            return
rs232_rx_notstart
            ; Check if transmission status is started
            movlw   RS232TRANS
            subwf   RS232STATUS,W
            btfsc   STATUS,Z
            goto    rs232_rx_command
            call    rs232_rx_buffer
            return
rs232_rx_command
            movlw   RS232CMD
            movwf   RS232STATUS
            ; Check if it is a command transmission
            movlw   "C"
            subwf   RCREG,W
            btfss   STATUS,Z
            goto    rs232_rx_message
            ; Command started
            return
rs232_rx_message
            movlw   RS232MSG
            movwf   RS232STATUS
            ; Check if it is a message transmission
            movlw   "M"
            subwf   RCREG,W
            btfss   STATUS,Z
            goto    rs232_rx_err
            ; Message started
            return
rs232_rx_err
            movlw   RS232ERR
            movwf   RS232STATUS
            call    rs232_rx_reset
            return
; ------------------------------------------------------------------------------
; Rx rs232 buffer
; ------------------------------------------------------------------------------
rs232_rx_buffer
            ; Save value to the buffer
            incf    RS232RXIND,F
rs232_rx_buffer0
            movlw   H'01'
            subwf   RS232RXIND,W
            btfss   STATUS,Z
            goto    rs232_rx_buffer1
            movf    RCREG,W
            movwf   RS232RX0
            return
rs232_rx_buffer1
            movlw   H'02'
            subwf   RS232RXIND,W
            btfss   STATUS,Z
            goto    rs232_rx_buffer2
            movf    RCREG,W
            movwf   RS232RX1
            return
rs232_rx_buffer2
            movlw   H'03'
            subwf   RS232RXIND,W
            btfss   STATUS,Z
            goto    rs232_rx_buffer3
            movf    RCREG,W
            movwf   RS232RX2
            return
rs232_rx_buffer3
            movlw   H'04'
            subwf   RS232RXIND,W
            btfss   STATUS,Z
            goto    rs232_rx_buffer4
            movf    RCREG,W
            movwf   RS232RX3
            return
rs232_rx_buffer4
            movlw   H'05'
            subwf   RS232RXIND,W
            btfss   STATUS,Z
            goto    rs232_rx_buffer5
            movf    RCREG,W
            movwf   RS232RX4
            return
rs232_rx_buffer5
            movlw   H'06'
            subwf   RS232RXIND,W
            btfss   STATUS,Z
            goto    rs232_rx_buffer6
            movf    RCREG,W
            movwf   RS232RX5
            return
rs232_rx_buffer6
            movlw   H'07'
            subwf   RS232RXIND,W
            btfss   STATUS,Z
            goto    rs232_rx_buffer7
            movf    RCREG,W
            movwf   RS232RX6
            return
rs232_rx_buffer7
            movlw   H'08'
            subwf   RS232RXIND,W
            btfss   STATUS,Z
            goto    rs232_rx_buffer_throw
            movf    RCREG,W
            movwf   RS232RX7
            return
rs232_rx_buffer_throw
            decf    RS232RXIND,F
            return
; ------------------------------------------------------------------------------
; Rx rs232 reset
; ------------------------------------------------------------------------------
rs232_rx_reset
            clrf    RS232RXIND
            movlw   RS232IDLE
            movwf   RS232STATUS
            return
; ------------------------------------------------------------------------------
; Global functions declaration
; ------------------------------------------------------------------------------
global  rs232_conf
global  rs232_start
global  rs232_rx
global  rs232_rx_int
global  rs232_tx
global  rs232_tx_int
;-------------------------------------------------------------------------------
            end