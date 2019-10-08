************************************************************************
*PROCEDURE ttRestProcess
****************************
***  Function: Processes incoming Web Requests for ttRestProcess
***            requests. This function is called from the wwServer 
***            process.
***      Pass: loServer -   wwServer object reference
*************************************************************************
LPARAMETER loServer
LOCAL loProcess
PRIVATE Request, Response, Server, Session, Process
STORE NULL TO Request, Response, Server, Session, Process

#INCLUDE WCONNECT.H

loProcess = CREATEOBJECT("ttRestProcess", loServer)
loProcess.lShowRequestData = loServer.lShowRequestData

IF VARTYPE(loProcess)#"O"
   *** All we can do is return...
   RETURN .F.
ENDIF

*** Call the Process Method that handles the request
loProcess.Process()

*** Explicitly force process class to release
loProcess.Dispose()

RETURN

*************************************************************
DEFINE CLASS ttRestProcess AS WWC_RESTPROCESS
*************************************************************

*** Response class used - override as needed
cResponseClass = [WWC_PAGERESPONSE]

*** Default for page script processing if no method exists
*** 1 - MVC Template (ExpandTemplate()) 
*** 2 - Web Control Framework Pages
*** 3 - MVC Script (ExpandScript())
nPageScriptMode = 3

*!* cAuthenticationMode = "UserSecurity"  && `Basic` is default

oRewrite = NULL
cRestMethod = ""

*** Force User Security/Custom mode
cAuthenticationMode = "UserSecurity"
nAuthenticatedUserPk = 0

#IF .F.
* Intellisense for THIS
LOCAL THIS as ttRestProcess OF ttRestProcess.prg
#ENDIF
 
*********************************************************************
* Function ttRestProcess :: OnProcessInit
************************************
*** If you need to hook up generic functionality that occurs on
*** every hit against this process class , implement this method.
*********************************************************************
FUNCTION OnProcessInit

THIS.InitSession("ttw",3600,.T.)

*!*	lcScriptName = LOWER(JUSTFNAME(Request.GetPhysicalPath()))

*!*	llIgnoreLoginRequest = INLIST(lcScriptName,"customers","CustomersRecentEntries")

*!*	*** Ignore all - no auth
*!*	* llIgnoreLoginRequest = .T.  && for testing API calls

*!*	IF !llIgnoreLoginRequest
*!*		*** Set up users in tt_users.dbf
*!*		IF !THIS.Authenticate("any","",llIgnoreLoginRequest) 
*!*		   IF !llIgnoreLoginRequest
*!*			  RETURN .F.
*!*		   ENDIF
*!*		ENDIF
*!*	ENDIF

*** Explicitly specify that pages should encode to UTF-8 
*** Assume all form and query request data is UTF-8
Response.Encoding = "UTF8"
Request.lUtf8Encoding = .T.


*** Add CORS header to allow cross-site access from other domains/mobile devices on Ajax calls
 Response.AppendHeader("Access-Control-Allow-Origin","*")
 Response.AppendHeader("Access-Control-Allow-Methods","POST, GET, DELETE, PUT, OPTIONS")
 Response.AppendHeader("Access-Control-Allow-Headers","Content-Type, *")
 *** Allow cookies and auth headers
 Response.AppendHeader("Access-Control-Allow-Credentials","true")
 
 *** CORS headers are requested with OPTION by XHR clients. OPTIONS returns no content
lcVerb = Request.GetHttpVerb()
IF (lcVerb == "OPTIONS")
   *** Just exit with CORS headers set
   *** Required to make CORS work from Mobile devices
   RETURN .F.
ENDIF   


RETURN .T.
ENDFUNC


************************************************************************
*  OnUrlRewrite
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION OnUrlRewrite(loRewrite, lvParm1)

this.oRewrite = loRewrite

*** Assume first segment is our method name
IF loRewrite.oPathSegments.Count > 0
   this.cRestMethod = loRewrite.oPathSegments.Item(1)      
   IF VARTYPE(lvParm1) = "L"
	   RETURN EVALUATE("THIS." + this.cRestMethod  + "()")   
   ELSE
       RETURN EVALUATE("THIS." + this.cRestMethod  + "(lvParm1)")   
   ENDIF
ENDIF

this.ErrorMsg("Invalid Route",;
   "Route values must at least include 1 segment relative to the virtual or root application")

ENDFUNC
*   OnUrlRewrite

*********************************************************************
FUNCTION TestPage
***********************
LPARAMETERS lvParm
*** Any posted JSON string is automatically deserialized
*** into a FoxPro object or value

#IF .F. 
* Intellisense for intrinsic objects
LOCAL Request as wwRequest, Response as wwPageResponse, Server as wwServer, ;
      Process as wwProcess, Session as wwSession
#ENDIF

*** Simply create objects, collections, values and return them
*** they are automatically serialized to JSON
loObject = CREATEOBJECT("EMPTY")
ADDPROPERTY(loObject,"name","TestPage")
ADDPROPERTY(loObject,"description",;
            "This is a JSON API method that returns an object.")
ADDPROPERTY(loObject,"entered",DATETIME())

*** To get proper case you have to override property names
*** otherwise all properties are serialized as lower case in JSON
Serializer.PropertyNameOverrides = "Name,Description,Entered"


RETURN loObject

*** To return a cursor use this string result:
*!* RETURN "cursor:TCustomers"


*** To return a raw Response result (non JSON) use:
*!*	JsonService.IsRawResponse = .T.   && use Response output
*!*	Response.ExpandScript()
*!*	RETURN                            && ignored

ENDFUNC



************************************************************************
*  Customers
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION Customers(loParm)

#IF .F. 
LOCAL Request as wwRequest, Response as wwPageResponse, Server as wwServer, ;
      THIS as wwProcess, Process as wwProcess, Session as wwSession
#ENDIF

lcFilter = ""
pcSearchFor = ""
IF VARTYPE(loParm) = "O"
    pcSearchFor = loParm.Search
    plActive = loParm.Active  
ELSE 
	PRIVATE pcSearchFor
	pcSearchFor = Request.Params("search")
ENDIF

IF !EMPTY(pcSearchFor)
	pcSearchFor = "%" + LOWER(pcSearchFor) + "%"
    lcFilter = "lower(Company) like ?pcSearchFor OR LOWER(lastname) like ?pcSearchFor"
ENDIF


LOCAL loCustomer as ttCustomer
loCustomer = CREATEOBJECT("ttCustomer")
loCustomer.Getcustomerlist("TCustomers","pk,Company,firstname + ' ' + lastname as Name," + ;
                                        "LastOrder as LastAccess",lcFilter)
                                        
RETURN "cursor:TCustomers"
ENDFUNC
*   Customers

************************************************************************
*  CustomersRecentEntries
****************************************
FUNCTION CustomersRecentEntries(loParm)

#IF .F. 
LOCAL Request as wwRequest, Response as wwPageResponse, Server as wwServer, ;
      THIS as wwProcess, Process as wwProcess, Session as wwSession
#ENDIF

Response.GzipCompression = .T.

lcFilter = ""
lnCount = 5
pcSearchFor = ""
IF VARTYPE(loParm) = "O"
    pcSearchFor = loParm.Search
    lnCount = loParm.maxCount
ELSE 
	PRIVATE pcSearchFor
	pcSearchFor = Request.Params("search")
ENDIF


IF !EMPTY(pcSearchFor)
	pcSearchFor = "%" + LOWER(pcSearchFor) + "%"
    lcFilter = "lower(Company) like ?pcSearchFor OR LOWER(lastname) like ?pcSearchFor"
ENDIF


loCustomer = CREATEOBJECT("ttCustomer")
loCustomerList = loCustomer.GetCustomerListWithRecentOrders(;
					"pk,Company,firstname + ' ' + lastname as Name,LastOrder as LastAccess",;
					lcFilter, lnCount)

Serializer.PropertyNameOverrides = "recentEntries,lastAccess,itemTotal,customerPk,punchedOut,timeIn,timeOut,totalHours,projName,invoicePk,userPk,projectPk"

RETURN loCustomerList
ENDFUNC
*   CustomersRecentEntries


************************************************************************
*  Projects
****************************************
***  Function: Returns projects for a given user
***    Assume:
***      Pass: 
***    Return:
************************************************************************
FUNCTION Projects()

#IF .F. 
LOCAL Request as wwRequest, Response as wwPageResponse, Server as wwServer, ;
      THIS as wwProcess, Process as wwProcess, Session as wwSession
#ENDIF

this.CheckAuthentication()

LOCAL loProjBus as ttProject
loProjBus = CREATEOBJECT("ttProject")
lnCount = loProjBus.GetActiveProjectsForCustomer(this.nAuthenticatedUserPk,"TProjects")

IF loProjBus.lError
   ERROR loProjBus.cErrorMsg
ENDIF


SELECT pk,projname,status, ;
       FormatValue(entered,"MMM dd, yyyy") as entered, ;
       FormatValue(startDate,"MMM dd, yyyy") as startDate,;
       FormatValue(endDate,"MMM dd, yyyy") as enddate ;        
       FROM TProjects ;
       into cursor TProjects
       

RETURN "cursor:TProjects"
ENDFUNC
*   Projects




************************************************************************
*  RecentEntries
****************************************
***  Function:
***    Assume:
***      Pass: id query string which is the user pk
***    Return:
************************************************************************
FUNCTION RecentEntries()
LOCAL lcId

*** Check auth and ensure there is a nAuthenticatedUserPk
this.CheckAuthentication()

lcId = Request.Params("id")

LOCAL loEntryBus as ttEntry
loEntryBus = CREATEOBJECT("ttEntry")
lnCount = loEntryBus.GetRecentEntriesForUser(10,VAL(lcId),.f.,"TEntries")
IF loEntryBus.lError
    ERROR loEntryBus.cErrorMsg
ENDIF

RETURN "cursor:TEntries"
ENDFUNC
*   RecentEntries

************************************************************************
*  Project
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION Project(loParm)
LOCAL lcId, lcVerb

*** Check auth and ensure there is a nAuthenticatedUserPk
this.CheckAuthentication()

lcVerb = UPPER(Request.GetHttpVerb())
IF lcVerb == "POST" OR lcVerb == "PUT"
   RETURN this.SaveProject(loParm)
ENDIF
IF lcVerb == "DELETE"
   RETURN this.DeleteProject(loParm)
ENDIF


lcId = Request.Params("id")

LOCAL loProjBus as ttProject
loProjBus = CREATEOBJECT("ttProject")
IF !loProjBus.Load(VAL(lcId))
   ERROR "Invalid Project to retrieve..."
ENDIF   


RETURN loProjBus.oData
ENDFUNC
*   Project


************************************************************************
*  SaveProject
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION SaveProject(loProject)
 
IF ISNULLOREMPTY(loProject)
   ERROR "No project was passed."
ENDIF   

LOCAL loProjBus as ttProject
loProjBus = CREATEOBJECT("ttProject")


IF VARTYPE(loProject.Pk) = "N" AND loProject.Pk > 0
    IF(!loProjBus.Load(loProject.Pk))
       ERROR "Can't find project to update."
    ENDIF
    
    *** Make sure the current user that owns this is updating    
    * this.nAuthenticatedUserPk = loProjBus.oData.UserPk    
ELSE	
	loProjBus.New()
	loProjBus.oData.CustomerPk = loProject.CustomerPk
ENDIF
loProj = loProjBus.oData

loProj.ProjName = loProject.ProjName
loProj.StartDate = CTOT(loProject.StartDate)


IF !loProjBus.Validate()
   ERROR  loProjBus.cErrorMsg   
ENDIF 
IF !loProjBus.Save()
   ERROR "Couldn't save project: " + loProjBus.cErrorMsg
ENDIF

*** Fix up display values
loProj.Entered = FormatValue(entered,"MMM dd, yyyy") 
loProj.startDate = FormatValue(startDate,"MMM dd, yyyy")
loProj.endDate = FormatValue(endDate,"MMM dd, yyyy")

RETURN loProj
ENDFUNC
*   SaveProject



************************************************************************
*  DeleteProject
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION DeleteProject(loParm)
LOCAL lcId

lcId = Request.QueryString("id")

LOCAL loProjBus as ttProject
loProjBus = CREATEOBJECT("ttProject")
IF !loProjBus.Delete(VAL(lcId))
   ERROR "Couldn't delete project."
ENDIF

RETURN .T.   
ENDFUNC
*   DeleteProject
************************************************************************
*  Login
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION Login(loParm)
LOCAL loUser

loUser =  CREATEOBJECT("ttUser")

*** This is not actually derived from user security but basic structure
*** is similar. Save/Load methods.
THIS.oUserSecurity = loUser


IF !loUser.AuthenticateAndLoad(loParm.userName, loParm.passWord)
   this.cAuthenticatedUser = ""
   this.cAuthenticatedName = ""

   *** Custom var we track
   this.nAuthenticatedUserPk = -1
   
   lcErrorMsg = this.oUserSecurity.cErrorMsg 
   
   Response.Status = "401 Not Authorized"
   ERROR "Invalid credentials: " + lcErrorMsg
   RETURN .F.
ENDIF

*** Stock variables - auto assigned to session vars
this.cAuthenticatedUser = loParm.userName
this.cAuthenticatedName = loUser.oData.UserName

*** Custom variables we need to track ourselves
this.nAuthenticatedUserPk = loUser.oData.Pk

Session.SetSessionVar("AuthenticatedUserPk", loUser.oData.Pk)
Session.SetSessionVar(this.cAuthenticationUserSecurityKey,this.cAuthenticatedUser)
Session.SetSessionVar(this.cAuthenticationUserSecurityKey + "Name",this.cAuthenticatedName)

ENDFUNC
*   Login

************************************************************************
*  OnAuthenticated
****************************************
***  Function: Called after a user has authenticated so we can read
***            values out of the session.
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION OnAuthenticated()

*** Read custom Session var we added in OnAuthenitcateUser
this.nAuthenticatedUserPk = VAL(Session.GetSessionVar("AuthenticatedUserPk"))

RETURN .T.   
ENDFUNC
*   OnAuthenticated

************************************************************************
*  OnAuthenticateUser
****************************************
***  Function: Customize the Authentication logic - instead of User
***            Security we validate against the ttUser business object
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION OnAuthenticateUser(lcUsername, lcPassword, lcErrorMsg)
LOCAL loUser

loUser =  CREATEOBJECT("ttUser")

*** This is not actually derived from user security but basic structure
*** is similar. Save/Load methods.
THIS.oUserSecurity = loUser

IF !loUser.AuthenticateAndLoad(lcUserName, lcPassword)
   this.cAuthenticatedUser = ""
   this.cAuthenticatedName = ""

   *** Custom var we track
   this.nAuthenticatedUserPk = -1
   
   lcErrorMsg = this.oUserSecurity.cErrorMsg 
   RETURN .F.
ENDIF

*** Stock variables - auto assigned to session vars
this.cAuthenticatedUser = lcUsername
this.cAuthenticatedName = loUser.oData.UserName

*** Custom variables we need to track ourselves
this.nAuthenticatedUserPk = loUser.oData.Pk
Session.SetSessionVar("AuthenticatedUserPk", this.nAuthenticatedUserPk)

RETURN .T.
ENDFUNC
*   OnAuthenticateUser

************************************************************************
*  IsAuthenticated()
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
**********************************************************************
FUNCTION CheckAuthentication

IF this.oUserSecurity.IsEmpty()
   this.AUTHENTICATE("ANY")
   RESPONSE.Clear()  && clear out auth request
ENDIF

IF !this.lIsAUTHENTICATED
    Response.Status = "401 Not Authorized"
    ERROR "You're not authorized to access this request. Please log in first..."
ENDIF

RETURN .T.
ENDFUNC
*   IsAuthenticated()


************************************************************************
*  CreateBusObject
****************************************
***  Function: Factory method to load a business object so we 
***            can easily change the data access mechanism
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION CreateBusObject(lcClass)
loObject = CREATEOBJECT(lcClass)

*** Put logic here for configuring objects
*** such as putting connection strings

RETURN loObject
ENDFUNC
*   CreateBusObject

*************************************************************
*** PUT YOUR OWN CUSTOM METHODS HERE                      
*** 
*** Any method added to this class becomes accessible
*** as an HTTP endpoint with MethodName.Extension where
*** .Extension is your scriptmap. If your scriptmap is .rs
*** and you have a function called Helloworld your
*** endpoint handler becomes HelloWorld.rs
*************************************************************


ENDDEFINE