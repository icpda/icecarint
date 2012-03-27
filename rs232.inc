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
RXDAT0          EQU H'0020'
RXDAT1          EQU H'0021'
RXDAT2          EQU H'0022'
RXDAT3          EQU H'0023'
RXDAT4          EQU H'0024'
RXDAT5          EQU H'0025'
RXDAT6          EQU H'0026'
RXDAT7          EQU H'0027'
RXDATIND        EQU H'0028'
TXDAT0          EQU H'002A'
TXDAT1          EQU H'002B'
TXDAT2          EQU H'002C'
TXDAT3          EQU H'002D'
TXDATIND        EQU H'002E'

; -----RS232STATUS--------------------------------------------------------------
; 0: Idle
; 1: Transmission started
; 2: Command
; 3: Message
; X: Unknown
; ------------------------------------------------------------------------------

RS232STATUS     EQU H'002F'

; -----PROTOCOL-----------------------------------------------------------------
; @: Init of transmission (1 Byte)
; C: Command M: Message (1 Byte)
; B: Body of command/message (4 Bytes C, 8 Bytes message)
; ------------------------------------------------------------------------------