SET PROCEDURE TO wwBusinessObject ADDITIVE
SET PROCEDURE TO wwCollections ADDITIVE
SET PROCEDURE TO ttuser.prg ADDITIVE

*************************************************************
DEFINE CLASS ttuser AS wwBusinessObject
*************************************************************

cAlias = "tt_users"
cDataPath = "data\"
cFileName = "tt_users"

cPkField = "Pk"
cIdTable = "tt_id.dbf"

*** Sql Connection String
cConnectString = ""

*** 0 - fox 2 - Sql 4-Web
nDataMode = 0

************************************************************************
* ttUser ::  AuthenticateAndLoad
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION AuthenticateAndLoad
PARAMETERS lcUsername, lcPassword

IF EMPTY(lcUserName) OR EMPTY(lcPassword)
	this.SetError("Empty username or password is not supported")
	RETURN .F.
ENDIF

lcUsername = LOWER(lcUsername)
lcPassword = LOWER(lcPassword)

IF !this.LoadBase("Userid == ?lcUsername AND Password == ?lcPassword")
  this.SetError("Invalid username or password")
  RETURN .F.
ENDIF 

RETURN .T.
ENDFUNC
*  ttUser ::  AuthenticateAndLoad

************************************************************************
* ttUser ::  Save
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION Save()

*** Force to lower case
this.oData.userid = LOWER(this.oData.userId)
this.oData.password = LOWER(this.oData.password)

RETURN DODEFAULT()
ENDFUNC
*  ttUser ::  Save


************************************************************************
* ttUser ::  Validate
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION Validate()

DODEFAULT()

IF EMPTY(this.oData.UserId)
	this.AddValidationerror("UserId must be specified","txtUserId")
ENDIF
IF EMPTY(this.oData.Password)
	this.AddValidationError("Password cannot be omitted","txtPassword")	
ENDIF	    

IF this.ValidationErrors.Count > 0
   this.SetError(this.ValidationErrors.ToString())
   RETURN .F.
ENDIF   

RETURN .T.
ENDFUNC
*  ttUser ::  Validate


*************************************************************
FUNCTION CreateTable(lcFileName)
*************************************************************
LOCAL lxFields

IF EMPTY(lcFileName)
   lcFileName = THIS.cDataPath + THIS.cFileName
ENDIF

IF THIS.nDataMode = 0
	*** Generated on: 09/07/2015
	DIMENSION lxFields[  8,4]

	lxFields[  1,1]='PK'
	lxFields[  1,2]='I'
	lxFields[  1,3]=  4
	lxFields[  1,4]=  0
	lxFields[  2,1]='USERID'
	lxFields[  2,2]='V'
	lxFields[  2,3]=128
	lxFields[  2,4]=  0
	lxFields[  3,1]='PASSWORD'
	lxFields[  3,2]='V'
	lxFields[  3,3]= 40
	lxFields[  3,4]=  0
	lxFields[  4,1]='USERNAME'
	lxFields[  4,2]='V'
	lxFields[  4,3]= 50
	lxFields[  4,4]=  0
	lxFields[  5,1]='COMPANY'
	lxFields[  5,2]='V'
	lxFields[  5,3]= 50
	lxFields[  5,4]=  0
	lxFields[  6,1]='LASTCUSTPK'
	lxFields[  6,2]='I'
	lxFields[  6,3]=  4
	lxFields[  6,4]=  0
	lxFields[  7,1]='LASTPROJPK'
	lxFields[  7,2]='I'
	lxFields[  7,3]=  4
	lxFields[  7,4]=  0
	lxFields[  8,1]='FULLNAME'
	lxFields[  8,2]='V'
	lxFields[  8,3]= 50
	lxFields[  8,4]=  0

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
* ttuser
