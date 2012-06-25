-----------------
ICECARINT Project
-----------------

This is the Firmware to be in a PIC 16F914 as the ICECAR Interface to control
motors, 8x2 LCD and lights for the car, to the Beagleboard.

------------
Modules Info
------------

Module	Timer	Registers	Data Memory
-------------------------------------------
MAIN	NA	OSCCON		 0050-007F
RS232	NA	RCSTA TXSTA	 0020-002F
		SPBGR
PWM	TMR2	CCP2CON	CPR2L	 0040-0041
		PR2 TMR2
DIR     NA      NA               0042-0042
LED     NA      NA               0043-0043
LCD	TMR0	ANSEL		 0030-003F
		OPTION_REG
EEPROM  NA      EECON1           0120-0125

------------
Test Cases
------------

Command     Return
-------------------------------------------
XXXXXX      Nothing
@XXXXX      Nothing
@CXXXX      Nothing
@CECHO      @ECH?  ?: Status register value
@CECHX      LCD "ERR:ECH "
@CPWM0      PWM0: Speed 0
@CPWM1      PWM1: Speed 1
@CPWM2      PWM2: Speed 2
@CPWM3      PWM3: Speed 3
@CPWM4      PWM4: Speed 4
@CPWM5      PWM5: Speed 5
@CPWM6      PWM6: Speed 6
@CPWMX      LCD "ERR:PWM "
@CDIRF      Direction Forward
@CDIRB      Direction Back
@CDIRL      Direction Left
@CDIRR      Direction Right
@CDIRS      Direction Stop
@CDIRX      LCD "ERR:DIR "
@MAWESOME!  LCD "AWESOME!"

ICe