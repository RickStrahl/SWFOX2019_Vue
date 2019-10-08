************************************************************************
*  Load_TimeTrakker
****************************************
***  Function: Sets up Time Trakker by loading libraries and initializing
***            Configuration object
***            Also loads up PUBLIC ttConfig object
***            with global Time Trakker Configuration Settings
************************************************************************

IF ATC("wwutils.",SET("PROCEDURE")) <1
	DO WCONNECT
ENDIF

SET PROCEDURE TO ttUtils ADDITIVE

SET PROCEDURE TO ttEntry ADDITIVE
SET PROCEDURE TO ttCustomer ADDITIVE
SET PROCEDURE TO ttProject ADDITIVE
SET PROCEDURE TO ttUser Additive
SET PROCEDURE TO ttLookups Additive

DO MarkdownParser

*** Load global configuration settings
PUBLIC ttConfig 
ttConfig = CREATEOBJECT("ttConfig")
ttConfig.Load()

RETURN