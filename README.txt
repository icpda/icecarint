-----------------
ICECARINT Project
-----------------

This is the Firmware to be in a PIC 16F914 as the ICECAR Interface to control motors, 8x2 LCD and lights for the car, to the Beagleboard.

------------
Modules Info
------------

Module	Timer	Registers	Memory
-----------------------------------------
MAIN	NA	OSCCON		????-????
R232	NA	RCSTA TXSTA	????-????
		SPBGR
PWM	TMR2	CCP2CON	CPR2L	????-????
		PR2 TMR2
LCD	TMR0	ANSEL		0030-003F
		OPTION_REG

ICe