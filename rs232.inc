; ##############################################################################
;
; Project: ICECARINT V1.0
; File Name: rs232.inc
; Processor: PIC16F914
; Frequency: 8 MHz
;
; ##############################################################################

; ------------------------------------------------------------------------------
; Variables declaration
; ------------------------------------------------------------------------------
RS232RX0        EQU H'0020'
RS232RX1        EQU H'0021'
RS232RX2        EQU H'0022'
RS232RX3        EQU H'0023'
RS232RX4        EQU H'0024'
RS232RX5        EQU H'0025'
RS232RX6        EQU H'0026'
RS232RX7        EQU H'0027'
RS232RXIND      EQU H'0028'
RS232TX0        EQU H'002A'
RS232TX1        EQU H'002B'
RS232TX2        EQU H'002C'
RS232TX3        EQU H'002D'
RS232TXIND      EQU H'002E'

; -----RS232STATUS--------------------------------------------------------------
; 0: Idle
; 1: Transmission started
; 2: Command
; 3: Message
; X: Unknown
; ------------------------------------------------------------------------------
RS232STATUS     EQU H'002F'

; RS232STATUS values
RS232IDLE       EQU H'00'
RS232TRANS      EQU H'01'
RS232CMD        EQU H'02'
RS232MSG        EQU H'03'
RS232ERR        EQU H'FF'

; -----PROTOCOL-----------------------------------------------------------------
; @: Init of transmission (1 Byte)
; C: Command M: Message (1 Byte)
; B: Body of command/message (4 Bytes C, 8 Bytes message)
; ------------------------------------------------------------------------------
RS232CMDSIZE    EQU H'04'
RS232MSGSIZE    EQU H'08'