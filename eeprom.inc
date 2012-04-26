; ##############################################################################
;
; Project: ICECARINT V1.0
; File Name: eeprom.inc
; Processor: PIC16F914
; Frequency: 8 MHz
;
; ##############################################################################

; ------------------------------------------------------------------------------
; Variables declaration
; ------------------------------------------------------------------------------
EEPROMADRL      EQU H'0120'
EEPROMADRH      EQU H'0121'
EEPROMRDL       EQU H'0122'
EEPROMRDH       EQU H'0123'
EEPROMWRL       EQU H'0124'
EEPROMWRH       EQU H'0125'

EEPROMERR       EQU H'FF'