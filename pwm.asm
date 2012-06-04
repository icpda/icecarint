; ##############################################################################
;
; Project: ICECARINT V1.0
; File Name: pwm.asm
; Processor: PIC16F914
; Frequency: 8 MHz
;
; ##############################################################################
;
; Frequency: 1.22KHz
; Pin: PORTD2
;
; ##############################################################################
            #include p16f914.inc
            #include pwm.inc

; ------------------------------------------------------------------------------
; PWM module
; ------------------------------------------------------------------------------
pwm         code

; ------------------------------------------------------------------------------
; Config pwm
; ------------------------------------------------------------------------------
pwm_conf
            bcf     STATUS,RP0
            bcf     STATUS,RP1
            bcf     PORTD,RD2
    ; Disable PWM pin
            bsf     STATUS,RP0
            bsf     TRISD,RD2
    ; Configure PWM period
            movlw   H'65'
            movwf   PR2
    ; Configure PWM module
            bcf     STATUS,RP0
            movlw   H'0F'
            movwf   CCP2CON
    ; Set PWM0
            clrf    PWMSTATUS
            clrf    PWMCYCLE
            clrf    CCPR2L
            movlw   H'0F'
            andwf   CCP2CON,F
    ; Configure Timer2
            bcf     PIR1,TMR2IF
            bsf     T2CON,T2CKPS0
            bcf     T2CON,T2CKPS1
            clrf    TMR2
     ; Enable PWM pin
            bsf     STATUS,RP0
            bcf     TRISD,RD2
            bsf     STATUS,RP0
            return
; ------------------------------------------------------------------------------
; Start pwm
; ------------------------------------------------------------------------------
pwm_start
            bcf     STATUS,RP0
            bcf     STATUS,RP1
            movlw   PWMCMDOK
            movwf   PWMSTATUS
     ; Set PWM based on PWMCYCLE
            movf    PWMCYCLE,W
            btfss   STATUS,Z
            call    pwm_set_duty_cycle
     ; Enable Timer2
            clrf    TMR2
            bsf     T2CON,TMR2ON
            movlw   PWMCMDOK
            subwf   PWMSTATUS,W
            btfss   STATUS,Z
            retlw   PWMCMDERR
            retlw   PWMCMDOK
; ------------------------------------------------------------------------------
; Stop pwm
; ------------------------------------------------------------------------------
pwm_stop
            bcf     STATUS,RP0
            bcf     STATUS,RP1
    ; Set PWM0
            clrf    PWMCYCLE
            clrf    CCPR2L
            movlw   H'0F'
            andwf   CCP2CON,F
    ; Disable Timer2
            bcf     T2CON,TMR2ON
    ; Clear PWM pin
            bcf     PORTD,RD2
            return
; ------------------------------------------------------------------------------
; Set pwm duty cycle
; ------------------------------------------------------------------------------
pwm_set_duty_cycle
            decfsz  PWMCYCLE,F
            goto    pwm_set2
            movlw   PWM1L
            iorwf   CCP2CON,F
            movlw   PWM1H
            movwf   CCPR2L
            return
pwm_set2
            decfsz  PWMCYCLE,F
            goto    pwm_set3
            movlw   PWM2L
            iorwf   CCP2CON,F
            movlw   PWM2H
            movwf   CCPR2L
            return
pwm_set3
            decfsz  PWMCYCLE,F
            goto    pwm_set4
            movlw   PWM3L
            iorwf   CCP2CON,F
            movlw   PWM3H
            movwf   CCPR2L
            return
pwm_set4
            decfsz  PWMCYCLE,F
            goto    pwm_set5
            movlw   PWM4L
            iorwf   CCP2CON,F
            movlw   PWM4H
            movwf   CCPR2L
            return
pwm_set5
            decfsz  PWMCYCLE,F
            goto    pwm_set6
            movlw   PWM5L
            iorwf   CCP2CON,F
            movlw   PWM5H
            movwf   CCPR2L
            return
pwm_set6
            decfsz  PWMCYCLE,F
            goto    pwm_set_error
            movlw   PWM6L
            iorwf   CCP2CON,F
            movlw   PWM6H
            movwf   CCPR2L
            return
pwm_set_error
            movlw   PWMCMDERR
            movwf   PWMSTATUS
            clrf    PWMCYCLE
            return
; ------------------------------------------------------------------------------
; Global functions declaration
; ------------------------------------------------------------------------------
global  pwm_conf
global  pwm_start
global  pwm_stop
global  pwm_set_duty_cycle
; ------------------------------------------------------------------------------
            end