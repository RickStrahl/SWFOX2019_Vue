SET PROCEDURE TO wwBusinessObject ADDITIVE
SET PROCEDURE TO wwCollections ADDITIVE
SET PROCEDURE TO ttproject.prg ADDITIVE

*************************************************************
DEFINE CLASS ttproject AS wwBusinessObject
*************************************************************

cAlias = "tt_projects"
cDataPath = "data\"
cFileName = "tt_projects"

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
this.nDatamode = ttConfig.nDataMode
this.cConnectString = ttConfig.cSqlConnectString
ENDFUNC
*   Init


************************************************************************
* ttProject ::  GetProjectList
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION GetProjectList(lcCursor)

IF EMPTY(lcCursor)
   lcCursor = "TProjects"
ENDIF
   
RETURN this.Query("select p.Pk, ProjName, CustomerPk, Status, p.Entered, c.Company " + ;
				  " from tt_Projects as p , tt_Customers as c " +;
				  " where p.CustomerPk = c.Pk " +;
                  " order by p.Entered DESC", lcCursor )   
ENDFUNC
*  ttProject ::  GetProjectList

************************************************************************
* ttProject ::  GetProjectsForCustomer
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION GetProjectsForCustomer
PARAMETERS lnCustPk, lnMaxCount, lcCursor
IF EMPTY(lcCursor)
  lcCursor = "TProjects"
  
ENDIF  
RETURN this.Query("select p.Pk, ProjName, CustomerPk, Status, p.Entered, c.Company " + ;
				  " from tt_Projects as p , tt_Customers as c " +;
				  " where p.CustomerPk = ?lnCustPk AND p.CustomerPk = c.Pk " +;
                  " order by p.Entered DESC", lcCursor )   
ENDFUNC
*  ttProject ::  GetProjectsForCustomer


************************************************************************
* ttProject ::  GetProjectsForCustomer
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION GetActiveProjectsForCustomer
PARAMETERS lnCustPk, lcCursor
IF EMPTY(lcCursor)
  lcCursor = "TProjects"
ENDIF  
RETURN this.Query("select Pk, ProjName, Status, Entered, StartDate,EndDate " +;
                  "from " + this.cAlias + ;
                  " where CustomerPk = ?lnCustPk and status < 2 " + ;
                  " order by Entered DESC",lcCursor)
ENDFUNC
*  ttProject ::  GetProjectsForCustomer


************************************************************************
*  New
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

THIS.oData.Entered = DATETIME()

ENDFUNC
*   New


************************************************************************
*  Delete
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION Delete(lnPk)

IF EMPTY(lnPk)
   this.SetError("Can't delete: invalid id.")
   RETURN .F.
ENDIF   

IF !DODEFAULT(lnPk)
   RETURN .F.
ENDIF
   
PRIVATE pnPk 
pnPk = lnPk


this.Execute("delete from TT_Entries where projectPk = pnPk")

RETURN !this.lError
ENDFUNC
*   Delete

************************************************************************
*  Validate
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION Validate()

IF !DODEFAULT()
   RETURN .F.
ENDIF

IF EMPTY(THIS.oData.ProjName)
   this.AddValidationError("Please provide a project name","ProjectName")
ENDIF

IF this.oValidationErrors.Count > 0
   this.SetError(this.oValidationErrors.ToString())
   RETURN .F.
ENDIF

RETURN .T.
ENDFUNC
*   Validate


*************************************************************
FUNCTION CreateTable(lcFileName)
*************************************************************
LOCAL lxFields

IF EMPTY(lcFileName)
   lcFileName = THIS.cDataPath + THIS.cFileName
ENDIF

IF THIS.nDataMode = 0

*** Generated on: 10/16/2007
DIMENSION lxFields[  7,4]

lxFields[  1,1]='PK'
lxFields[  1,2]='I'
lxFields[  1,3]=  4
lxFields[  1,4]=  0
lxFields[  2,1]='CUSTOMERPK'
lxFields[  2,2]='I'
lxFields[  2,3]=  4
lxFields[  2,4]=  0
lxFields[  3,1]='PROJNAME'
lxFields[  3,2]='V'
lxFields[  3,3]= 80
lxFields[  3,4]=  0
lxFields[  4,1]='ENTERED'
lxFields[  4,2]='T'
lxFields[  4,3]=  8
lxFields[  4,4]=  0
lxFields[  5,1]='STARTDATE'
lxFields[  5,2]='T'
lxFields[  5,3]=  8
lxFields[  5,4]=  0
lxFields[  6,1]='ENDDATE'
lxFields[  6,2]='T'
lxFields[  6,3]=  8
lxFields[  6,4]=  0
lxFields[  7,1]='STATUS'
lxFields[  7,2]='I'
lxFields[  7,3]=  4
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
   
   INDEX ON pk TAG pk
	INDEX ON status TAG status
	INDEX ON customerpk TAG customerpk

   USE
ENDIF
ENDFUNC
* Reindex

ENDDEFINE
* ttproject
