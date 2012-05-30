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
LCD	TMR0	ANSEL		 0030-003F
		OPTION_REG
EEPROM  NA      EECON1           0120-0125


ICe