; ##############################################################################
;
; Project: ICECARINT V1.0
; File Name: eeprom.asm
; Processor: PIC16F914
; Frequency: 8 MHz
;
; ##############################################################################
;
; EEPROM
;
; ##############################################################################
            list p=16f914
            #include p16f914.inc
            #include eeprom.inc

; ------------------------------------------------------------------------------
; EEPROM module
; ------------------------------------------------------------------------------
eeprom      code

; ------------------------------------------------------------------------------
; Config eeprom
; ------------------------------------------------------------------------------
eeprom_conf
            bsf     STATUS,RP0
            bsf     STATUS,RP1
    ; Point to eeprom memory
            bcf     EECON1,EEPGD

            bcf     STATUS,RP0
            bcf     STATUS,RP1
            return
; ------------------------------------------------------------------------------
; Read eeprom
; ------------------------------------------------------------------------------
eeprom_read
            bsf     STATUS,RP0
            bsf     STATUS,RP1
    ; Check there is not read operation
            btfsc   EECON1,RD
            goto    eeprom_error
    ; Read value in address
            bcf     STATUS,RP0
            movf    EEPROMADRH,W
            movwf   EEADRH
            movf    EEPROMADRL,W
            movwf   EEADRL
            bsf     STATUS,RP0
            bsf     EECON1,RD
    ; Give some time
            nop
    ; Check there is not read operation
            btfsc   EECON1,RD
            goto    eeprom_error
    ; Load value to variable
            bcf     STATUS,RP0
            movf    EEDATL,W
            movwf   EEPROMRDL
            movf    EEDATH,W
            movwf   EEPROMRDH
            return
; ------------------------------------------------------------------------------
; Write eeprom
; ------------------------------------------------------------------------------
eeprom_write
            bsf     STATUS,RP0
            bsf     STATUS,RP1
            ; TODO: Implement for future versions
            return
; ------------------------------------------------------------------------------
; Error on eeprom
; ------------------------------------------------------------------------------
eeprom_error
            bsf     STATUS,RP0
            bsf     STATUS,RP1
    ; Load error value
            movlw   EEPROMERR
            movwf   EEPROMRDL
            movwf   EEPROMRDH

            bcf     STATUS,RP1
            bcf     STATUS,RP0
            return
; ------------------------------------------------------------------------------
; Global functions declaration
; ------------------------------------------------------------------------------
global  eeprom_conf
global  eeprom_read
global  eeprom_write
;-------------------------------------------------------------------------------
            end