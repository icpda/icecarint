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
            call    eeprom_conf
    ; Prepare modules
            call    lcd_prepare
    ; Booting..
            call    display_boot_mesg
    ; Start modules
            call    rs232_start
    ; Enable interrupts
            call    int_enable
loop
            goto    loop
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
    ; TODO: Implement command interpreter
            return
    ; Check if we have recived a message
check_for_msg
            movlw   RS232MSG
            subwf   RS232STATUS,W
            btfss   STATUS,Z
            return
            movlw   RS232MSGSIZE
            subwf   RS232RXIND,W
            btfss   STATUS,Z
            call    display_msg
            return
; ------------------------------------------------------------------------------
; Display rs232 message
; ------------------------------------------------------------------------------
display_msg
            movf    RS232RX0,W
            movwf   LCDDAT0
            movf    RS232RX1,W
            movwf   LCDDAT1
            movf    RS232RX2,W
            movwf   LCDDAT2
            movf    RS232RX3,W
            movwf   LCDDAT3
            movf    RS232RX4,W
            movwf   LCDDAT4
            movf    RS232RX5,W
            movwf   LCDDAT5
            movf    RS232RX6,W
            movwf   LCDDAT6
            movf    RS232RX7,W
            movwf   LCDDAT7
    ; Write message to lcd
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
err_ech     de      "ERR:ECHO"
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