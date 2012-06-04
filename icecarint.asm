; ##############################################################################
;
; Project: ICECARINT V1.0
; File Name: icecarint.asm
; Processor: PIC16F914
; Frequency: 8 MHz
;
; ##############################################################################
            list p=16f914

; _CP_OFF: Code protection disabled
; _PWRTE_ON: Power time enabled
; _WDT_OFF: Watch dog timer disabled
; _INTOSCIO: Internal oscillator enabled
            __config _CP_OFF & _PWRTE_ON & _WDT_OFF & _INTOSCIO

; ------------------------------------------------------------------------------
; Headers
; ------------------------------------------------------------------------------
            #include p16f914.inc
            #include icecarint.inc
            #include rs232.inc
            #include pwm.inc
            #include direction.inc
            #include lcd.inc
            #include eeprom.inc

; ------------------------------------------------------------------------------
; Reset vector
; ------------------------------------------------------------------------------
start       code    H'0000'
            goto    main
; ------------------------------------------------------------------------------
; Interrupt vector
; ------------------------------------------------------------------------------
interrupt   code    H'0004'
    ; Save context
            movwf   TMPW
            movf    STATUS,W
            movwf   TMPSTATUS

            bcf     STATUS,RP0
            bcf     STATUS,RP1
    ; Check for Rx int
            btfsc   PIR1,RCIF
            call    read_rs232
    ; Check for Tx int
            btfsc   PIR1,TXIF
            call    rs232_tx_int

    ; Restore context
            movf    TMPSTATUS,W
            movwf   STATUS
            movf    TMPW,W
            retfie
; ------------------------------------------------------------------------------
; Main program
; ------------------------------------------------------------------------------
main
            bcf     STATUS,RP0
            bcf     STATUS,RP1
    ; Clear all ports
            call    clear_ports
    ; Configure Internal 8 MHz Clock
            bsf     STATUS,RP0
            movlw   H'70'
            iorwf   OSCCON,F
            bcf     STATUS,RP0
    ; Configure modules
            call    rs232_conf
            call    lcd_conf
            call    pwm_conf
            call    dir_conf
            call    eeprom_conf
    ; Prepare modules
            call    lcd_prepare
    ; Booting..
            call    display_boot_mesg
    ; Start modules
            call    rs232_start
    ; Enable interrupts
            call    int_enable
    ; Clear status registers
            clrf    ICESTATUS0
            clrf    ICESTATUS1
main_loop
    ; Check command available
loop_cmd
            btfss   ICESTATUS0,ICECMD
            goto    loop_msg
            call    translate_cmd
            bcf     ICESTATUS0,ICECMD
loop_cmd_pwm
    ; Check if was PWM command
            btfss   ICESTATUS0,ICECMDPWM
            goto    loop_cmd_dir
            call    pwm_stop
            movf    ICESTATUS1,W
            xorlw   H'30'
            movwf   PWMCYCLE
            call    pwm_start
            sublw   PWMCMDOK
            btfss   STATUS,Z
            call    err_pwm_cmd
            bcf     ICESTATUS0,ICECMDPWM
loop_cmd_dir
    ; Check if was Direction command
            btfss   ICESTATUS0,ICECMDDIR
            goto    loop_msg
            movf    ICESTATUS1,W
            movwf   DIRVALUE
            call    dir_set
            sublw   DIRCMDOK
            btfss   STATUS,Z
            call    err_dir_cmd
            bcf     ICESTATUS0,ICECMDDIR
    ; Check message available
loop_msg
            btfss   ICESTATUS0,ICEMSG
            goto    loop_end
            call    display_msg
            bcf     ICESTATUS0,ICEMSG
    ; Restart loop
loop_end
            goto    main_loop
; ------------------------------------------------------------------------------
; Clear ports
; ------------------------------------------------------------------------------
clear_ports
            clrf    PORTA
            clrf    PORTB
            clrf    PORTC
            clrf    PORTD
            clrf    PORTE
            return
; ------------------------------------------------------------------------------
; Interrupts enable
; ------------------------------------------------------------------------------
int_enable
    ; Enable global and peripheral interruptions
            movlw   H'C0'
            movwf   INTCON
            return
; ------------------------------------------------------------------------------
; Read byte from rs232
; ------------------------------------------------------------------------------
read_rs232
            call    rs232_rx_int
    ; Check if we have recived a command
check_for_cmd
            movlw   RS232CMD
            subwf   RS232STATUS,W
            btfss   STATUS,Z
            goto    check_for_msg
            movlw   RS232CMDSIZE
            subwf   RS232RXIND,W
            btfss   STATUS,Z
            return
    ; TODO: Remove debug
            bcf     PORTD,RD3
            bsf     ICESTATUS0,ICECMD
            call    translate_cmd_echo
            btfss   ICESTATUS0,ICECMDECH
            return
            movf    RS232RX3,W
            movwf   ICECMDECHARG
    ; There was an echo command
            call    reply2_echo_cmd
            sublw   CMDECH
            btfss   STATUS,Z
            call    err_echo_cmd
            bcf     ICESTATUS0,ICECMDECH
            bcf     ICESTATUS0,ICECMD
            return
    ; Check if we have recived a message
check_for_msg
            movlw   RS232MSG
            subwf   RS232STATUS,W
            btfss   STATUS,Z
            return
            movlw   RS232MSGSIZE
            subwf   RS232RXIND,W
            btfsc   STATUS,Z
            bsf     ICESTATUS0,ICEMSG
            return
; ------------------------------------------------------------------------------
; Translates rs232 command
; ------------------------------------------------------------------------------
translate_cmd
    ; Check if is lcd command
            movlw   CMDLCD
            call    validate_cmd
            sublw   CMDKWN
            btfsc   STATUS,Z
            bsf     ICESTATUS0,ICECMDLCD
    ; Check if is pwm command
            movlw   CMDPWM
            call    validate_cmd
            sublw   CMDKWN
            btfsc   STATUS,Z
            bsf     ICESTATUS0,ICECMDPWM
    ; Check if is dir command
            movlw   CMDDIR
            call    validate_cmd
            sublw   CMDKWN
            btfsc   STATUS,Z
            bsf     ICESTATUS0,ICECMDDIR
    ; Check if is lig command
            movlw   CMDLIG
            call    validate_cmd
            sublw   CMDKWN
            btfsc   STATUS,Z
            bsf     ICESTATUS0,ICECMDLIG
            goto    translate_cmd_end
translate_cmd_echo
    ; Check if is echo command
            movlw   CMDECH
            call    validate_cmd
            sublw   CMDKWN
            btfsc   STATUS,Z
            bsf     ICESTATUS0,ICECMDECH
translate_cmd_end
            movf    RS232RX3,W
            movwf   ICESTATUS1
            return
; ------------------------------------------------------------------------------
; Validate is known command
; ------------------------------------------------------------------------------
validate_cmd
validate_cmd1
            movwf   EEPROMADR
            call    read_eeprom
            subwf   RS232RX0,W
            btfsc   STATUS,Z
            goto    validate_cmd2
            retlw   CMDUNKWN
validate_cmd2
            incf    EEPROMADR,F
            call    read_eeprom
            subwf   RS232RX1,W
            btfsc   STATUS,Z
            goto    validate_cmd3
            retlw   CMDUNKWN
validate_cmd3
            incf    EEPROMADR,F
            call    read_eeprom
            subwf   RS232RX2,W
            btfsc   STATUS,Z
            retlw   CMDKWN
            retlw   CMDUNKWN
; ------------------------------------------------------------------------------
; Reply to echo command
; ------------------------------------------------------------------------------
reply2_echo_cmd
            movlw   'O'
            subwf   ICECMDECHARG,W
            btfss   STATUS,Z
            retlw   CMDERR
    ; Command echo correct
            movlw   CMDECH
            movwf   EEPROMADR
            call    read_eeprom
            movwf   RS232TX0
            incf    EEPROMADR,F
            call    read_eeprom
            movwf   RS232TX1
            incf    EEPROMADR,F
            call    read_eeprom
            movwf   RS232TX2
            movf    ICESTATUS0,W
            movwf   RS232TX3
            call    rs232_tx
            retlw   CMDECH
; ------------------------------------------------------------------------------
; Display echo command error
; ------------------------------------------------------------------------------
err_echo_cmd
            movlw   CMDECH
            call    display_cmd_err
            return
; ------------------------------------------------------------------------------
; Display pwm command error
; ------------------------------------------------------------------------------
err_pwm_cmd
            movlw   CMDPWM
            call    display_cmd_err
            return
; ------------------------------------------------------------------------------
; Display dir command error
; ------------------------------------------------------------------------------
err_dir_cmd
            movlw   CMDDIR
            call    display_cmd_err
            return
; ------------------------------------------------------------------------------
; Display command error
; ------------------------------------------------------------------------------
display_cmd_err
            movwf   EEPROMADR
            movlw   ICEERRIND
            addwf   EEPROMADR,F
            call    load_eeprom_msg2
            call    lcd_write_msg2
            return
; ------------------------------------------------------------------------------
; Display boot message
; ------------------------------------------------------------------------------
display_boot_mesg
            call    load_boot_msg
            call    lcd_write_msg1
            call    lcd_write_msg2
            return
; ------------------------------------------------------------------------------
; Load boot message
; ------------------------------------------------------------------------------
load_boot_msg
            bcf     STATUS,RP0
            bcf     STATUS,RP1
            clrf    EEPROMADR
            call    load_eeprom_msg1
            call    load_eeprom_msg2
            return
; ------------------------------------------------------------------------------
; Load eeprom messages
; ------------------------------------------------------------------------------
load_eeprom_msg1
            call    read_eeprom
            movwf   LCDDAT0
            incf    EEPROMADR,F
            call    read_eeprom
            movwf   LCDDAT1
            incf    EEPROMADR,F
            call    read_eeprom
            movwf   LCDDAT2
            incf    EEPROMADR,F
            call    read_eeprom
            movwf   LCDDAT3
            incf    EEPROMADR,F
            call    read_eeprom
            movwf   LCDDAT4
            incf    EEPROMADR,F
            call    read_eeprom
            movwf   LCDDAT5
            incf    EEPROMADR,F
            call    read_eeprom
            movwf   LCDDAT6
            incf    EEPROMADR,F
            call    read_eeprom
            movwf   LCDDAT7
            incf    EEPROMADR,F
            return
load_eeprom_msg2
            call    read_eeprom
            movwf   LCDDAT8
            incf    EEPROMADR,F
            call    read_eeprom
            movwf   LCDDAT9
            incf    EEPROMADR,F
            call    read_eeprom
            movwf   LCDDATA
            incf    EEPROMADR,F
            call    read_eeprom
            movwf   LCDDATB
            incf    EEPROMADR,F
            call    read_eeprom
            movwf   LCDDATC
            incf    EEPROMADR,F
            call    read_eeprom
            movwf   LCDDATD
            incf    EEPROMADR,F
            call    read_eeprom
            movwf   LCDDATE
            incf    EEPROMADR,F
            call    read_eeprom
            movwf   LCDDATF
            return
; ------------------------------------------------------------------------------
; Read eeprom data
; ------------------------------------------------------------------------------
read_eeprom
            bcf     STATUS,RP0
            bcf     STATUS,RP1
            movf    EEPROMADR,W
            bsf     STATUS,RP1
            clrf    EEPROMADRH
            movwf   EEPROMADRL
            call    eeprom_read
            movlw   EEPROMERR
            xorwf   EEPROMRDL,W
            btfsc   STATUS,Z
            goto    read_eeprom_err
            movf    EEPROMRDL,W
            goto    read_eeprom_end
read_eeprom_err
            movlw   "?"
read_eeprom_end
            bcf     STATUS,RP1
            return
; ------------------------------------------------------------------------------
; Display rs232 message
; ------------------------------------------------------------------------------
display_msg
            movf    RS232RX0,W
            movwf   LCDDAT8
            movf    RS232RX1,W
            movwf   LCDDAT9
            movf    RS232RX2,W
            movwf   LCDDATA
            movf    RS232RX3,W
            movwf   LCDDATB
            movf    RS232RX4,W
            movwf   LCDDATC
            movf    RS232RX5,W
            movwf   LCDDATD
            movf    RS232RX6,W
            movwf   LCDDATE
            movf    RS232RX7,W
            movwf   LCDDATF
    ; Write message to lcd
            call    lcd_write_msg2
            return
; ------------------------------------------------------------------------------
; Boot message
; ------------------------------------------------------------------------------
boot_msg    code    H'2100'
            de      "ICECAR10"
            de      "BOOTING*"
; ------------------------------------------------------------------------------
; Echo command
; ------------------------------------------------------------------------------
cmd_ech     de      "ECH", CMDECH
            de      "RESV"
err_ech     de      "ERR:ECH "
; ------------------------------------------------------------------------------
; LCD command
; ------------------------------------------------------------------------------
cmd_lcd     de      "LCD", CMDLCD
            de      "RESV"
err_lcd     de      "ERR:LCD "
; ------------------------------------------------------------------------------
; PWM command
; ------------------------------------------------------------------------------
cmd_pwm     de      "PWM", CMDPWM
            de      "RESV"
err_pwm     de      "ERR:PWM "
; ------------------------------------------------------------------------------
; Direction command
; ------------------------------------------------------------------------------
cmd_dir     de      "DIR", CMDDIR
            de      "RESV"
err_dir     de      "ERR:DIR "
; ------------------------------------------------------------------------------
; Lights command
; ------------------------------------------------------------------------------
cmd_lig     de      "LIG", CMDLIG
            de      "RESV"
err_lig     de      "ERR:LIG "
; ------------------------------------------------------------------------------
            end