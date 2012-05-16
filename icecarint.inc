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
ICESTATUS0      EQU H'0050'
ICESTATUS1      EQU H'0051'
; Memory used for operation in main loop
MULTIPLYING     EQU H'0053'
MULTIPLIER      EQU H'0054'
EEPROMADR       EQU H'0055'
; Memory for command arguments
ICECMDECHARG    EQU H'0060'
; Shared memory between banks
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

ICEERRIND       EQU H'08'

; ------------------------------------------------------------------------------
; ICESTATUS0 bit description
; ------------------------------------------------------------------------------
ICEMSG          EQU H'07'
ICECMD          EQU H'06'
ICECMDECH       EQU H'05'
ICECMDLCD       EQU H'04'
ICECMDPWM       EQU H'03'
ICECMDDIR       EQU H'02'
ICECMDLIG       EQU H'01'

; ------------------------------------------------------------------------------
; External functions declaration
; ------------------------------------------------------------------------------
; RS232 Module
extern  rs232_conf
extern  rs232_start
extern  rs232_rx
extern  rs232_rx_int
extern  rs232_tx
extern  rs232_tx_int
; PWM Module
extern  pwm_conf
extern  pwm_start
; LCD Module
extern  lcd_conf
extern  lcd_prepare
extern  lcd_write_msg1
extern  lcd_write_msg2
; EEPROM Module
extern  eeprom_conf
extern  eeprom_read
extern  eeprom_write

; ------------------------------------------------------------------------------
; Commands declaration
; ------------------------------------------------------------------------------
CMDUNKWN        EQU H'00'
CMDKWN          EQU H'01'
CMDECH          EQU H'10'
CMDLCD          EQU H'20'
CMDPWM          EQU H'30'
CMDDIR          EQU H'40'
CMDLIG          EQU H'50'