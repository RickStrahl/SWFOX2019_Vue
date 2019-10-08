SET PROCEDURE TO wwBusinessObject ADDITIVE
SET PROCEDURE TO wwCollections ADDITIVE
SET PROCEDURE TO ttcustomer.prg ADDITIVE

*************************************************************
DEFINE CLASS ttcustomer AS wwBusinessObject
*************************************************************

cAlias = "tt_customers"
cDataPath = "data\"
cFileName = "tt_customers"

cPkField = "Pk"
cIdTable = "data\tt_id.dbf"

*** Sql Connection String
cConnectString = "driver={sql server};server=.;database=TimeTrakkerWC"

*** 0 - fox 2 - Sql 4-Web
nDataMode = 0


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
* ttCustomer ::  GetCustomerList
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION GetCustomerList(lcCursor, lcFields,lcFilter)

IF EMPTY(lcCursor)
	lcCursor = "TCustomers"
ENDIF
IF EMPTY(lcFields)
   lcFields = "Pk, Company, LastName, FirstName, Country, Entered"
ENDIF   

IF !EMPTY(lcFilter)
   lcFilter = "WHERE " + lcFilter
ELSE
   lcFilter = ""   
ENDIF


RETURN this.Query(;
  "select " + lcFields + ;
  " from " + this.cAlias + ;
  " " + lcFilter + ;
  " order by company", lcCursor)

ENDFUNC
*  ttCustomer ::  GetCustomerList

************************************************************************
*  GetCustomerListWithRecentOrders
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION GetCustomerListWithRecentOrders(lcFields,lcFilter,lnMaxCount)


#IF .F. 
LOCAL Request as wwRequest, Response as wwPageResponse, Server as wwServer, ;
      THIS as wwProcess, Process as wwProcess, Session as wwSession
#ENDIF

*Response.GzipCompression = .T.


IF EMPTY(lnMaxCount)
   lnMaxCount = 5
ENDIF
   
IF this.GetCustomerList("Tcustomers", lcFields,lcFilter) < 1
   RETURN null
ENDIF

LOCAL loBusEntry as ttEntry
loBusEntry = THIS.CreateChildobject("ttEntry")

loCustomerList = CursorToCollection("TCustomers")

FOR EACH loCustomer IN loCustomerList FOXOBJECT   
   loBusEntry.GetrecententriesForUser(lnMaxCount,loCustomer.Pk)
   ADDPROPERTY(loCustomer,"RecentEntries",CursorToCollection("TEntries"))       
ENDFOR

USE IN TEntries
USE IN TCustomers

RETURN loCustomerList
ENDFUNC
*   GetCustomerListWithRecentOrders

************************************************************************
* ttCustomer ::  GetFilteredCustomerList
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION GetFilteredCustomerList
PARAMETERS lcCursor, lcFields, lcCompany, ldEntered

IF EMPTY(lcCursor)
	lcCursor = "TCustomers"
ENDIF
IF EMPTY(lcFields)
   lcFields = "Pk, Company, LastName, FirstName, Country, Entered"
ENDIF   

lcFilter = ""

IF !EMPTY(lcCompany)
   lcFilter = lcFilter + "and company=?lcCompany "
ENDIF
IF !EMPTY(ldEntered)
   lcFilter = lcFilter + "and entered>?ldEntered "
ENDIF

IF !EMPTY(lcFilter)
   *** Strip out the leading and
   lcFilter = SUBSTR(lcFilter,4)
   lcFilter = " where " + lcfilter
ENDIF   


RETURN this.Query(;
  "select " + lcFields + ;
  " from " + this.cAlias + ;
  lcFilter +;
  " order by company", lcCursor)

ENDFUNC
*  ttCustomer ::  GetFilteredCustomerList



************************************************************************
* ttCustomer ::  Validate
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION Validate()

DODEFAULT()

IF EMPTY(this.oData.Company)
   this.AddValidationError("Company can't be left empty.","Company")
ENDIF
IF EMPTY(this.oData.LastName)
   this.AddValidationError("Lastname must be provided.","LastName")
ENDIF
IF EMPTY(this.oData.FirstName)
   this.AddValidationError("Firstname must be provided.","FirstName")
ENDIF


IF EMPTY(this.oData.CountryId)
	this.AddValidationError("Country is a required field","CountryId")
ENDIF

IF THIS.oValidationErrors.Count > 0
	this.SetError( this.oValidationErrors.ToString() )
	RETURN .F.
ENDIF

RETURN .T.
ENDFUNC
*  ttCustomer ::  Validate


************************************************************************
* ttCustomer ::  Load
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

this.oData.Entered = DATETIME()
this.oData.BillRate = ttConfig.nDefaultBillRate

ENDFUNC
*  ttCustomer ::  Load

************************************************************************
* ttCustomer ::  Save
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION Save()

IF EMPTY(THIS.oData.Company)
  this.oData.Company = "N/A"
ENDIF
this.oData.Updated = DATETIME()

RETURN DODEFAULT()
ENDFUNC
*  ttCustomer ::  Save


************************************************************************
* ttCustomer ::  New
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

this.oData.Entered = DATETIME()

ENDFUNC
*  ttCustomer ::  New


*************************************************************
FUNCTION CreateTable(lcFileName)
*************************************************************
LOCAL lxFields

IF EMPTY(lcFileName)
   lcFileName = THIS.cDataPath + THIS.cFileName
ENDIF

IF THIS.nDataMode = 0

*** Generated on: 10/16/2007
DIMENSION lxFields[ 19,4]

lxFields[  1,1]='PK'
lxFields[  1,2]='I'
lxFields[  1,3]=  4
lxFields[  1,4]=  0
lxFields[  2,1]='LASTNAME'
lxFields[  2,2]='V'
lxFields[  2,3]= 50
lxFields[  2,4]=  0
lxFields[  3,1]='FIRSTNAME'
lxFields[  3,2]='V'
lxFields[  3,3]= 50
lxFields[  3,4]=  0
lxFields[  4,1]='COMPANY'
lxFields[  4,2]='V'
lxFields[  4,3]= 80
lxFields[  4,4]=  0
lxFields[  5,1]='ADDRESS'
lxFields[  5,2]='M'
lxFields[  5,3]=  4
lxFields[  5,4]=  0
lxFields[  6,1]='CITY'
lxFields[  6,2]='V'
lxFields[  6,3]= 50
lxFields[  6,4]=  0
lxFields[  7,1]='STATE'
lxFields[  7,2]='V'
lxFields[  7,3]= 10
lxFields[  7,4]=  0
lxFields[  8,1]='ZIP'
lxFields[  8,2]='V'
lxFields[  8,3]= 12
lxFields[  8,4]=  0
lxFields[  9,1]='COUNTRY'
lxFields[  9,2]='V'
lxFields[  9,3]= 50
lxFields[  9,4]=  0
lxFields[ 10,1]='COUNTRYID'
lxFields[ 10,2]='V'
lxFields[ 10,3]= 10
lxFields[ 10,4]=  0
lxFields[ 11,1]='PHONE'
lxFields[ 11,2]='V'
lxFields[ 11,3]=128
lxFields[ 11,4]=  0
lxFields[ 12,1]='EMAIL'
lxFields[ 12,2]='M'
lxFields[ 12,3]=  4
lxFields[ 12,4]=  0
lxFields[ 13,1]='FAX'
lxFields[ 13,2]='M'
lxFields[ 13,3]=  4
lxFields[ 13,4]=  0
lxFields[ 14,1]='NOTES'
lxFields[ 14,2]='M'
lxFields[ 14,3]=  4
lxFields[ 14,4]=  0
lxFields[ 15,1]='ENTERED'
lxFields[ 15,2]='T'
lxFields[ 15,3]=  8
lxFields[ 15,4]=  0
lxFields[ 16,1]='UPDATED'
lxFields[ 16,2]='T'
lxFields[ 16,3]=  8
lxFields[ 16,4]=  0
lxFields[ 17,1]='LASTORDER'
lxFields[ 17,2]='T'
lxFields[ 17,3]=  8
lxFields[ 17,4]=  0
lxFields[ 18,1]='BILLRATE'
lxFields[ 18,2]='N'
lxFields[ 18,3]= 10
lxFields[ 18,4]=  2
lxFields[ 19,1]='XML'
lxFields[ 19,2]='M'
lxFields[ 19,3]=  4
lxFields[ 19,4]=  0

CREATE TABLE (lcFileName) FROM ARRAY lxFields


  USE
ENDIF

ENDFUNC
* CreateTable

*************************************************************
FUNCTION Reindex
*************************************************************

IF THIS.nDataMode = 0
   IF !OpenExclusive(THIS.cDataPath + THIS.cFileName,THIS.cAlias)
      THIS.SetError("Unable to open Customer file due to exclusive use.")
      RETURN .F.
   ENDIF

   DELETE TAG ALL
   PACK

   INDEX on PK TAG pk
   INDEX on UPPER(Company) TAG Company
   INDEX ON updated TAG updated

   USE
ENDIF
ENDFUNC
* Reindex

ENDDEFINE
* ttcustomer
