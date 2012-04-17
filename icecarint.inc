; ##############################################################################
;
; Project: ICECARINT V1.0
; File Name: icecarint.inc
; Processor: PIC16F914
; Frequency: 8 MHz
;
; ##############################################################################

; ------------------------------------------------------------------------------
; Variables declaration
; ------------------------------------------------------------------------------
DATA0           EQU H'0070'
DATA1           EQU H'0071'
DATA2           EQU H'0072'
DATA3           EQU H'0073'
DATA4           EQU H'0074'
DATA5           EQU H'0075'
DATA6           EQU H'0076'
DATA7           EQU H'0077'
DATAIND         EQU H'0078'
CMD0            EQU H'007A'
CMD1            EQU H'007B'
CMD2            EQU H'007C'
CMDIND          EQU H'007D'
TMPSTATUS       EQU H'007E'
TMPW            EQU H'007F'

; ------------------------------------------------------------------------------
; External functions declaration
; ------------------------------------------------------------------------------
; RS232 Module
extern  rs232_conf
extern  rs232_start
extern  rs232_rx_int
extern  rs232_tx_int
; PWM Module
extern  pwm_conf
extern  pwm_start