; ##############################################################################
;
; Project: ICECARINT V1.0
; File Name: direction.asm
; Processor: PIC16F914
; Frequency: 8 MHz
;
; ##############################################################################
;
; LEDON1: PORTC0
; LEDON2: PORTC1
; LEDRED: PORTC2
; LEDBLUE: PORTC3
;
; ##############################################################################
            #include p16f914.inc
            #include led.inc

; ------------------------------------------------------------------------------
; LED module
; ------------------------------------------------------------------------------
led         code

; ------------------------------------------------------------------------------
; Config led
; ------------------------------------------------------------------------------
led_conf
            bcf     STATUS,RP0
            bcf     STATUS,RP1
     ; Configure pins
            bsf     STATUS,RP0
            movlw   H'F0'
            andwf   TRISC,F
            bcf     STATUS,RP0
            andwf   PORTC,F
            return
; ------------------------------------------------------------------------------
; Set led
; ------------------------------------------------------------------------------
led_set
led_off
            movlw   LEDOFF
            subwf   LEDVALUE,W
            btfss   STATUS,Z
            goto    led_on1
            movlw   H'F0'
            andwf   PORTC,F
            retlw   LEDCMDOK
led_on1
            movlw   LEDON1
            subwf   LEDVALUE,W
            btfss   STATUS,Z
            goto    led_on2
            bsf     PORTC,RC0
            retlw   LEDCMDOK
led_on2
            movlw   LEDON2
            subwf   LEDVALUE,W
            btfss   STATUS,Z
            goto    led_red
            bsf     PORTC,RC1
            retlw   LEDCMDOK
led_red
            movlw   LEDRED
            subwf   LEDVALUE,W
            btfss   STATUS,Z
            goto    led_blue
            bsf     PORTC,RC2
            retlw   LEDCMDOK
led_blue
            movlw   LEDBLU
            subwf   LEDVALUE,W
            btfss   STATUS,Z
            goto    led_set_error
            bsf     PORTC,RC3
            retlw   LEDCMDOK
led_set_error
            retlw   LEDCMDERR
; ------------------------------------------------------------------------------
; Global functions declaration
; ------------------------------------------------------------------------------
global  led_conf
global  led_set
; ------------------------------------------------------------------------------
            end