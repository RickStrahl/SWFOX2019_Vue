SET PROCEDURE TO wwBusinessObject ADDITIVE
SET PROCEDURE TO wwCollections ADDITIVE
SET PROCEDURE TO ttlookups.prg ADDITIVE

*************************************************************
DEFINE CLASS ttlookups AS wwBusinessObject
*************************************************************

cAlias = "tt_lookups"
cDataPath = "timetrakker\data\"
cFileName = "tt_lookups"

cPkField = "Pk"
cIdTable = "timetrakker\data\tt_id.dbf"

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
this.nDatamode = ttConfig.nDataMode
this.cConnectString = ttConfig.cSqlConnectString
ENDFUNC
*   Init


************************************************************************
* ttLookups ::  GetCountries
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION GetCountries(lcCursor)

IF EMPTY(lcCursor)
  lcCursor = "TCountries"
ENDIF

lcSql = ;
"select cData as CountryCode, cData1 as Country FROM " + this.cAlias +;
" where type = 'COUNTRY' "

RETURN this.Query(lcSql, lcCursor)
ENDFUNC
*  ttLookups ::  GetCountries

************************************************************************
* ttLookups ::  GetStates
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION GetStates(lcCursor)

IF EMPTY(lcCursor)
  lcCursor = "TStates"
ENDIF

RETURN this.Query("select cData as StateCode, cData1 as State FROM " + this.cAlias +;
                  " where type='STATE'",lcCursor)
ENDFUNC
*  ttLookups ::  GetStates


*************************************************************
FUNCTION CreateTable(lcFileName)
*************************************************************
LOCAL lxFields

IF EMPTY(lcFileName)
   lcFileName = THIS.cDataPath + THIS.cFileName
ENDIF

IF THIS.nDataMode = 0

*** Generated on: 09/28/2007
DIMENSION lxFields[  7,4]

lxFields[  1,1]='PK'
lxFields[  1,2]='I'
lxFields[  1,3]=  4
lxFields[  1,4]=  0
lxFields[  2,1]='TYPE'
lxFields[  2,2]='C'
lxFields[  2,3]= 50
lxFields[  2,4]=  0
lxFields[  3,1]='CDATA'
lxFields[  3,2]='C'
lxFields[  3,3]= 50
lxFields[  3,4]=  0
lxFields[  4,1]='CDATA1'
lxFields[  4,2]='C'
lxFields[  4,3]= 50
lxFields[  4,4]=  0
lxFields[  5,1]='CDATA2'
lxFields[  5,2]='M'
lxFields[  5,3]=  4
lxFields[  5,4]=  0
lxFields[  6,1]='IDATA'
lxFields[  6,2]='I'
lxFields[  6,3]=  4
lxFields[  6,4]=  0
lxFields[  7,1]='TVERSION'
lxFields[  7,2]='Q'
lxFields[  7,3]=  8
lxFields[  7,4]=  0

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



   USE
ENDIF
ENDFUNC
* Reindex

ENDDEFINE
* ttlookups
