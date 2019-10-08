SET PROCEDURE TO ttUtils ADDITIVE


************************************************************************
*  RoundDateToMinuteInterval
****************************************
***  Function:
***    Assume:
***      Pass: lnMode = 0 - Round  1 - Round Down 2 - Round up
***    Return:
************************************************************************
FUNCTION RoundDateToMinuteInterval(ltTime, lnMinuteInterval, lnMode)
LOCAL lnNewTime

IF lnMinuteInterval = 0
   RETURN ltTime
ENDIF   

IF EMPTY(lnMode)
  lnMode = 0
ENDIF  

lnMinutes = MINUTE(ltTime)
IF lnMinutes = 0
   RETURN ltTime
ENDIF
   
*** Round the minutes
DO CASE
	CASE lnMode = 0
		lnMinutes = ROUND(lnMinutes / lnMinuteInterval,0) * lnMinuteInterval
	CASE lnMode = 1
		lnMinutes = FLOOR(lnMinutes / lnMinuteInterval) * lnMinuteInterval
	CASE lnMode = 2
		lnMinutes = CEILING(lnMinutes / lnMinuteInterval) * lnMinuteInterval
ENDCASE	    

ltNewTime = DTOT(TTOD(ltTime))
ltNewTime = ltNewTime + 3600 * Hour(ltTime) +  lnMinutes * 60

RETURN ltNewTime
ENDFUNC
*   RoundDateToMinuteInterval

************************************************************************
*  ToHoursAndMinutes
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION ToHoursAndMinutes(lnHours)
LOCAL lcOutput

IF lnHours < 0.0001
   RETURN ""
ENDIF   

lnWhole = INT(lnHours)
lnFrac = lnHours - lnWhole
IF lnFrac = 0
   RETURN TRANSFORM(lnWhole) + "h:00min"
ENDIF   

lnMins = 60 * lnFrac

RETURN  IIF(lnWhole > 0, TRANSFORM(lnWhole) + "h ","") +;
        PADL(TRANSFORM(ROUND(lnMins,0)),2,"0") + "min"
ENDFUNC
*   ToHoursAndMinutes


************************************************************************
*  TimeTrakkerSqlConnection
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION TimeTrakkerSqlConnection(loBus)

IF VARTYPE(TT_SQLCONNECTION) # "O"
	PUBLIC TT_SQL_CONNECTION
	TT_SQLCONNECTION  = CREATEOBJECT("wwSQL")
	TT_SQLCONNECTION.Connect( ttConfig.cSqlConnectString )
ENDIF

loBus.SetSqlObject(TT_SQLCONNECTION)
ENDFUNC
*   TimeTrakkerSqlConnection


*************************************************************
DEFINE CLASS ReportParms AS Custom
*************************************************************

UserPk  = 0

DateStart = DATE() - 90
DateEnd = DATE()
BillStatus = "Unbilled"

MarkAsBilled = .f.
OutputType = "HTML"
SummaryReport = .f.

ReportToRun = "TimeSheetClient"

DIMENSION CustomerPks[1]
AllCustomers = .t.

ENDDEFINE
*EOC ReportParms 


*************************************************************
DEFINE CLASS ttConfig AS wwConfig
*************************************************************
*: Author: Rick Strahl
*:         (c) West Wind Technologies, 2007
*:Contact: http://www.west-wind.com
*:Created: 10/11/2007
*************************************************************

cFileName = "ttConfig.ini"
cMode = "INI"
cSubName = "TimeTrakker"

cApplicationName = "Time Trakker"
cCompanyName = "West Wind Technologies"
cReportFooter = "www.west-wind.com  *  (503) 914-6335  * sales@west-wind.com"
nDefaultBillRate = 150

nMinuteRounding = 5   && Round to 5 minutes
nMinuteRoundingMode = 0     && Round    1 - Round down 2- Round up

*** The data connection mode
cSqlConnectString = "driver={sql server};server=.;database=TimeTrakkerWC"
nDataMode = 0

************************************************************************
*  Destrory
****************************************
FUNCTION Destroy()
this.Save()
ENDFUNC
*   Destrory

ENDDEFINE
*EOC ttConfig 