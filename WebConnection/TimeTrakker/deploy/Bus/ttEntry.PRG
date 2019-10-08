SET PROCEDURE TO wwBusinessObject ADDITIVE
SET PROCEDURE TO wwCollections ADDITIVE
SET PROCEDURE TO ttentry.prg ADDITIVE

*************************************************************
DEFINE CLASS ttentry AS wwBusinessObject
*************************************************************

cAlias = "tt_entries"
cDataPath = "data\"
cFileName = "tt_entries"

cPkField = "Pk"
cIdTable = "data\tt_id.dbf"

*** Sql Connection String
cConnectString = "driver={sql server};server=.;database=TimeTrakkerWC"

*** 0 - fox 2 - Sql 4-Web
nDataMode = 0

oCustomer = null
oProject = null

************************************************************************
*  Init
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION Init()

IF ttConfig.nDataMode = 2
    TimeTrakkerSqlConnection(THIS)
ENDIF

ENDFUNC
*   Init

************************************************************************
* ttEntry ::  GetOpenEntryCount
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return: Number of records in the cursor TEntries
************************************************************************
FUNCTION GetOpenEntryCount(lcUserPk) as Int
LOCAL lnRes
PRIVATE pcUserPk
pcUserPk = lcUserPk

lnRes = this.Query("select Count(pk) as OEntries " + ;
                  " from " + this.cAlias + ;
		   		  " where !PunchedOut AND UserPk = ?pcUserPk",;
	   		  	  "TQuery")
IF (lnRes == -1)
   RETURN -1
ENDIF

lnRes = TQuery.OEntries

USE IN TQuery
   
RETURN lnRes	   		  	  
ENDFUNC
*  ttEntry ::  GetOpenEntries

************************************************************************
*  GetLastCustomerUsed
****************************************
***  Function: Returns the last customer ID used for this user
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION GetLastCustomerUsed(lnUserPk)
PRIVATE pcUserPk
pnUserPk = lnUserPk

lnRes = this.Query("select TOP 1 CustomerPk " + ;
                  " from " + this.cAlias + ;
		   		  " where UserPk = ?pnUserPk " + ;
		   		  " ORDER BY TimeIn DESC",;
	   		  	  "TQuery")
IF lnRes = -1
   RETURN 0
ENDIF
   	  	  
IF lnRes < 1
   lnResult = 0
ELSE
   lnResult = Tquery.Customerpk
ENDIF
USE IN TQuery
RETURN  lnResult  
ENDFUNC
*   GetLastCustomerUsed


************************************************************************
* ttEntry ::  GetOpenEntries
****************************************
***  Function: 
***    Assume:
***      Pass:
***    Return: Number of records in the cursor TEntries
************************************************************************
FUNCTION GetOpenEntries(lcUserPk, lcCursor, lnCustomerPk) as Int
LOCAL lcCustFilter
PRIVATE pcUserPk, pnCustomerPk

pcUserPk = lcUserPk
pnCustomerPk = lnCustomerPk

IF EMPTY(lcCursor)
  lcCursor = "TEntries"
ENDIF

PRIVATE pnCustomerPk
pnCustomerPk = 0
lcCustFilter = ""
IF !EMPTY(lnCustomerPk)
    pnCustomerPk = lnCustomerPk
    lcCustFilter = " AND e.CustomerPk=pnCustomerPk "
ENDIF

RETURN this.Query("select e.*, p.ProjName as ProjName  " +;
                  "from " + this.cAlias + " as e, tt_Projects as p " + ;
		   		  "where !PunchedOut AND UserPk = ?pcUserPk AND p.pk = e.ProjectPk " +;
		   		  lcCustFilter + ;
		   		  "order by TimeIn DESC",;
	   		  	  lcCursor)
ENDFUNC
*  ttEntry ::  GetOpenEntries

************************************************************************
* ttEntry ::  GetRecentEntriesForUser
****************************************
***  Function: 
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION GetRecentEntriesForUser()
PARAMETERS lnCount,lcUserPk, llClosedOnly, lcCursor, lnCustomerPk

IF EMPTY(lnCount)
   lnCount = 25
ENDIF
IF EMPTY(lcCursor)
   lcCursor = "TEntries"   
ENDIF

lcBaseSql = "select TOP " + TRANSFORM(lnCount) + " e.*, p.ProjName as ProjName  " +;
            "from " + this.cAlias + " as e, tt_Projects as p " 

IF llClosedOnly
	lcFilter = 	"where PunchedOut AND UserPk = ?lcUserPk AND p.pk = e.ProjectPk "
ELSE
	lcFilter = 	"where UserPk = ?lcUserPk AND p.pk = e.ProjectPk "
ENDIF	

pnCustomerPk = lnCustomerPk
IF !Empty(lnCustomerPk)
    lcFilter = lcfilter + " AND e.CustomerPk=lnCustomerPk "
ENDIF

lcBaseSql = lcBaseSql + lcFilter

lcBaseSql = lcBaseSql + "order by timein desc"

RETURN this.Query( lcBaseSql , lcCursor)
ENDFUNC
*  ttEntry ::  GetRecentEntriesForUser



************************************************************************
*  GetEntriesForProject
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION GetEntriesForProject
PARAMETERS lnProjectId, lcCursor

IF EMPTY(lcCursor)
  lcCursor = "TChildEntries"
ENDIF  

lcBaseSql = "select TOP 10 e.*, p.ProjName as ProjName  " +;
            "from " + this.cAlias + " as e, tt_Projects as p "  +;
            "where p.pk = ?lnProjectId and e.projectPk == p.pk " +;
            "order by TimeIn DESC"

RETURN this.Query(lcBaseSql,lcCursor)
ENDFUNC
*   GetEntriesForProject

************************************************************************
* ttEntry ::  GetTimeSheetData
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION GetTimeSheetData()
PARAMETERS loParms, lcCursor

LOCAL lcFilter

IF EMPTY(lcCursor)
   lcCursor = "TEntries"
ENDIF   

lcFilter = "UserPk = ?loParms.UserPk AND "

*** Add a day so we include the day
loParms.DateEnd = loParms.DateEnd + 1

lcFilter = lcFilter + "TimeIn >= ?loParms.DateStart AND TimeIn <= ?loParms.DateEnd AND "

IF loParms.BillStatus = "Unbilled"
   lcFilter = lcFilter + "!billed AND "
ENDIF
IF loParms.BillStatus = "Billed"
   lcFilter = lcFilter + "billed AND "
ENDIF   

IF !loParms.AllCustomers
   lnCount=loParms.CustomerPks.Count
   IF lnCount > 0 
  	  lcFilter = lcFilter + "("
   ENDIF
   FOR lnX = 1 TO lnCount
   	  lcFilter = lcFilter + "p.CustomerPk = " + loParms.CustomerPks[lnx]
   	  IF lnX < lnCount
   	     lcFilter = lcFilter + " OR "
	  ELSE
	  	 lcFilter = lcFilter + ") AND "
   	  ENDIF
   ENDFOR  
ENDIF

lcFilter = lcFilter  + " 1=1 "

lcSQL = "select e.*, p.projname, c.Company, c.LastName, c.FirstName from " + this.cAlias + " as e " + ;
        "join tt_Projects as p on e.ProjectPk = p.Pk " +;
        "join tt_customers as c on p.CustomerPk = c.Pk " + ;
        "where " + lcFilter + ;
        "order by p.projname, e.timein "     

*!*	ACTIVATE SCREEN
*!*	? lcSql        

lnResult = this.Query(lcSQL,lcCursor)

RETURN lnResult
ENDFUNC
*  ttEntry ::  GetTimeSheetData


************************************************************************
* ttEntry ::  Load
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION Load(lnPk)

IF !DODEFAULT(lnPk)
   RETURN .F.
ENDIF   


*** Try to load the Customer's Billing Rate
IF EMPTY(this.oData.Rate) AND !EMPTY(this.oData.CustomerPk)
   loCustomer = CREATEOBJECT("ttCustomer")
   IF loCustomer.Load(this.oData.CustomerPk)
   	  this.oData.Rate = loCustomer.oData.BillRate
   ENDIF
   
ENDIF

IF EMPTY(this.oData.Timeout) OR this.oData.TimeOut < {^2000/01/01}
	this.oData.TimeOut = this.RoundDate( DATETIME()) 
	this.CalculateTotals()
ENDIF

*** Load customer record
loCustomer = CREATEOBJECT("ttCustomer")
IF loCustomer.Load(this.oData.CustomerPk)
   ADDPROPERTY(this.oData,"Customer",loCustomer.oData)
ENDIF

loProject = CREATEOBJECT("ttProject")
IF loProject.Load(this.oData.ProjectPk)
   ADDPROPERTY(this.oData,"Project",loProject.oData)
ENDIF

RETURN .T.
ENDFUNC
*  ttEntry ::  Load



************************************************************************
* ttEntry ::  New
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION New()

IF !DODEFAULT()
   RETURN .F.
ENDIF

this.oData.Timein = this.RoundDate( DATETIME() )
ENDFUNC
*  ttEntry ::  New


************************************************************************
* ttEntry ::  Punchin
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION Punchin()

this.oData.PunchedOut = .F.
this.oData.Timeout = {}
this.oData.Totalhours = 0
this.oData.ItemTotal = 0

IF EMPTY(this.oData.Timein)
   this.oData.Timein = DATETIME()
ENDIF   

*** Apply rounding to input date
this.oData.Timein = this.RoundDate(this.oData.TimeIn)

RETURN this.Save()
ENDFUNC
*  ttEntry ::  Punchin

************************************************************************
* ttEntry ::  PunchOut
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION PunchOut()

this.oData.PunchedOut = .T.

IF EMPTY(this.oData.TimeOut)
   this.oData.Timeout = this.RoundDate( DATETIME(),5, 2)
ENDIF
this.CalculateTotals()

RETURN this.Save()
ENDFUNC
*  ttEntry ::  PunchOut

************************************************************************
* ttEntry ::  LeaveOpen
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION LeaveOpen()

this.oData.PunchedOut = .F.
this.oData.Timeout = {}
this.oData.Totalhours = 0
this.oData.ItemTotal = 0

RETURN this.Save()
ENDFUNC
*  ttEntry ::  LeaveOpen


************************************************************************
* ttEntry ::  Validate
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION Validate()

DODEFAULT()

IF EMPTY(this.oData.Title)
   this.AddValidationError("Title cannot be left blank","Title")
ENDIF

IF EMPTY(this.oData.CustomerPk)
	THIS.AddValidationError("An entry must be associated with a customer","CustomerPk")
ENDIF
IF EMPTY(this.oData.ProjectPk)
   THIS.AddValidationError("An entry must be associated with a project","ProjectPk")
ENDIF

IF EMPTY(this.oData.TimeIn)
   THIS.AddValidationError("An entry must have a punch in date","TimeIn")
ENDIF

IF this.oValidationErrors.Count > 0
   this.SetError(this.oValidationErrors.ToString())
   RETURN .F.
ENDIF

RETURN .T.   
ENDFUNC
*  ttEntry ::  Validate


************************************************************************
* ttEntry ::  CalculateTotals
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION CalculateTotals()

this.oData.TotalHours = (this.oData.Timeout - this.oData.Timein) / 3600
this.oData.ItemTotal = this.oData.TotalHours * this.oData.Rate

ENDFUNC
*  ttEntry ::  CalculateTotals


************************************************************************
* ttEntry ::  RoundDate
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION RoundDate(ltDate)

*** Round the value
IF !EMPTY(ltDate)
	RETURN RoundDateToMinuteInterval( ltDate, ttConfig.nMinuteRounding, ttConfig.nMinuteRoundingMode)
ENDIF

RETURN ltDate
ENDFUNC
*  ttEntry ::  RoundDate


*************************************************************
FUNCTION CreateTable(lcFileName)
*************************************************************
LOCAL lxFields

IF EMPTY(lcFileName)
   lcFileName = THIS.cDataPath + THIS.cFileName
ENDIF

IF THIS.nDataMode = 0

*** Generated on: 10/16/2007
DIMENSION lxFields[ 18,4]

lxFields[  1,1]='PK'
lxFields[  1,2]='I'
lxFields[  1,3]=  4
lxFields[  1,4]=  0
lxFields[  2,1]='CUSTOMERPK'
lxFields[  2,2]='I'
lxFields[  2,3]=  4
lxFields[  2,4]=  0
lxFields[  3,1]='PROJECTPK'
lxFields[  3,2]='I'
lxFields[  3,3]=  4
lxFields[  3,4]=  0
lxFields[  4,1]='INVOICEPK'
lxFields[  4,2]='I'
lxFields[  4,3]=  4
lxFields[  4,4]=  0
lxFields[  5,1]='USERPK'
lxFields[  5,2]='I'
lxFields[  5,3]=  4
lxFields[  5,4]=  0
lxFields[  6,1]='TITLE'
lxFields[  6,2]='C'
lxFields[  6,3]=128
lxFields[  6,4]=  0
lxFields[  7,1]='DESCRIPT'
lxFields[  7,2]='M'
lxFields[  7,3]=  4
lxFields[  7,4]=  0
lxFields[  8,1]='TIMEIN'
lxFields[  8,2]='T'
lxFields[  8,3]=  8
lxFields[  8,4]=  0
lxFields[  9,1]='TIMEOUT'
lxFields[  9,2]='T'
lxFields[  9,3]=  8
lxFields[  9,4]=  0
lxFields[ 10,1]='PUNCHEDOUT'
lxFields[ 10,2]='L'
lxFields[ 10,3]=  1
lxFields[ 10,4]=  0
lxFields[ 11,1]='QTY'
lxFields[ 11,2]='N'
lxFields[ 11,3]= 20
lxFields[ 11,4]=  2
lxFields[ 12,1]='RATE'
lxFields[ 12,2]='N'
lxFields[ 12,3]= 20
lxFields[ 12,4]=  2
lxFields[ 13,1]='TOTALHOURS'
lxFields[ 13,2]='N'
lxFields[ 13,3]= 20
lxFields[ 13,4]=  2
lxFields[ 14,1]='ITEMTOTAL'
lxFields[ 14,2]='N'
lxFields[ 14,3]= 20
lxFields[ 14,4]=  2
lxFields[ 15,1]='TAXABLE'
lxFields[ 15,2]='L'
lxFields[ 15,3]=  1
lxFields[ 15,4]=  0
lxFields[ 16,1]='BILLED'
lxFields[ 16,2]='L'
lxFields[ 16,3]=  1
lxFields[ 16,4]=  0
lxFields[ 17,1]='IMPORTED'
lxFields[ 17,2]='L'
lxFields[ 17,3]=  1
lxFields[ 17,4]=  0
lxFields[ 18,1]='XML'
lxFields[ 18,2]='M'
lxFields[ 18,3]=  4
lxFields[ 18,4]=  0

CREATE TABLE (lcFileName) FROM ARRAY lxFields

  USE
ENDIF

ENDFUNC
* CreateTable

*************************************************************
FUNCTION Reindex()
*************************************************************

IF THIS.nDataMode = 0
   IF !OpenExclusive(THIS.cDataPath + THIS.cFileName,THIS.cAlias)
      THIS.SetError("Unable to open Customer file due to exclusive use.")
      RETURN .F.
   ENDIF

   DELETE TAG ALL
   PACK

	INDEX ON pk TAG pk
	INDEX ON punchedout TAG punchedout
	INDEX ON timein TAG timein

   USE
ENDIF
ENDFUNC
* Reindex

ENDDEFINE
* ttentry
