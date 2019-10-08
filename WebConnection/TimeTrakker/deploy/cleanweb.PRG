DO WCONNECT

************************************************************************
*  CleanWeb
****************************************
***  Function: Cleans out the Web folder before publishing to remove
***            prg and fxp for script files.
***    Assume: Make sure to run out of the DEPLOY folder
************************************************************************


DeleteTree("..\Web","*.prg",.T.)
DeleteTree("..\Web","*.fxp",.T.)
DeleteTree("..\Web","*.bak",.T.)