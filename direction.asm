; ##############################################################################
;
; Project: ICECARINT V1.0
; File Name: direction.asm
; Processor: PIC16F914
; Frequency: 8 MHz
;
; ##############################################################################
;
; MotorL: PORTD4/5
; MotorR: PORTD6/7
;
; ##############################################################################
            #include p16f914.inc
            #include direction.inc

; ------------------------------------------------------------------------------
; Direction module
; ------------------------------------------------------------------------------
direction   code

; ------------------------------------------------------------------------------
; Config direction
; ------------------------------------------------------------------------------
dir_conf
            bcf     STATUS,RP0
            bcf     STATUS,RP1
     ; Configure pins
            bsf     STATUS,RP0
            movlw   H'0F'
            andwf   TRISD,F
            bcf     STATUS,RP0
            andwf   PORTD,F
            return
; ------------------------------------------------------------------------------
; Set direction
; ------------------------------------------------------------------------------
dir_set
dir_set_s
            movlw   DIRS
            subwf   DIRVALUE,W
            btfss   STATUS,Z
            goto    dir_set_f
            call    motor1_s
            call    motor2_s
            retlw   DIRCMDOK
dir_set_f
            movlw   DIRF
            subwf   DIRVALUE,W
            btfss   STATUS,Z
            goto    dir_set_b
            call    motor1_f
            call    motor2_f
            retlw   DIRCMDOK
dir_set_b
            movlw   DIRB
            subwf   DIRVALUE,W
            btfss   STATUS,Z
            goto    dir_set_l
            call    motor1_b
            call    motor2_b
            retlw   DIRCMDOK
dir_set_l
            movlw   DIRL
            subwf   DIRVALUE,W
            btfss   STATUS,Z
            goto    dir_set_r
            call    motor1_b
            call    motor2_f
            retlw   DIRCMDOK
dir_set_r
            movlw   DIRR
            subwf   DIRVALUE,W
            btfss   STATUS,Z
            goto    dir_set_error
            call    motor1_f
            call    motor2_b
            retlw   DIRCMDOK
dir_set_error
            retlw   DIRCMDERR
; ------------------------------------------------------------------------------
; Motor 1 and 2 direction set
; ------------------------------------------------------------------------------
motor1_s
            bcf     PORTD,RD4
            bcf     PORTD,RD5
            return
motor2_s
            bcf     PORTD,RD6
            bcf     PORTD,RD7
            return
motor1_f
            bsf     PORTD,RD4
            bcf     PORTD,RD5
            return
motor2_f
            bsf     PORTD,RD6
            bcf     PORTD,RD7
            return
motor1_b
            bcf     PORTD,RD4
            bsf     PORTD,RD5
            return
motor2_b
            bcf     PORTD,RD6
            bsf     PORTD,RD7
            return
; ------------------------------------------------------------------------------
; Global functions declaration
; ------------------------------------------------------------------------------
global  dir_conf
global  dir_set
; ------------------------------------------------------------------------------
            end