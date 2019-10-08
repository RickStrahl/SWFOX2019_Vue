**********************************************************************
*PROCEDURE ttprocess
****************************
***  Function: Processes incoming Web Requests for ttprocess
***            requests. This function is called from the wwServer 
***            process.
***      Pass: loServer -   wwServer object reference
*************************************************************************
LPARAMETER loServer
LOCAL loProcess
PRIVATE Request, Response, Server, Session, Process
STORE NULL TO Request, Response, Server, Session, Process

#INCLUDE WCONNECT.H

loProcess = CREATEOBJECT("ttprocess", loServer)
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
DEFINE CLASS ttprocess AS WWC_PROCESS
*************************************************************

*** Response class used - override as needed
cResponseClass = [WWC_PAGERESPONSE]

*** Scriptmode used for any non-method hits
*** 1 - Templates (evaluated)
*** 3 - Scripts (compiled pages)
nPageScriptMode = 3



*** Force User Security/Custom mode
cAuthenticationMode = "UserSecurity"

*** User Pk we use for foreign keys
*** and if needed for access to user profile (from session)
nAuthenticatedUserPk = 0

*********************************************************************
* Function ttprocess :: OnProcessInit
************************************
*** If you need to hook up generic functionality that occurs on
*** every hit against this process class , implement this method.
*********************************************************************
FUNCTION OnProcessInit
LOCAL lcScriptName, llForceLogin

THIS.InitSession("ttw",1600,.T.)

lcScriptName = LOWER(JUSTFNAME(Request.GetPhysicalPath()))
llIgnoreLoginRequest = INLIST(lcScriptName,"default","login","logout")

*** Ignore all - no auth
* llIgnoreLoginRequest = .T.  && for testing API calls

IF !llIgnoreLoginRequest
	*** Set up users in tt_users.dbf
	IF !THIS.Authenticate("any","",llIgnoreLoginRequest) 
	   IF !llIgnoreLoginRequest
		  RETURN .F.
	   ENDIF
	ENDIF
ENDIF

*** FOR NOW HARDCODE USER ID UNTIL WE ADD AUTHENTICATION
* THIS.nAuthenticatedUserPk = 1

*** Explicitly specify that pages should encode to UTF-8 
*** Assume all form and query request data is UTF-8
Response.Encoding = "UTF8"
Request.lUtf8Encoding = .T.

RETURN .T.
ENDFUNC


************************************************************************
*  Login
****************************************
***  Function: Handles display of the login form if directly accessed
***            and routes postbacks to the Authenticate() method.
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION Login()

pcReturnUrl = Request.Params("ReturnUrl")
pcErrorMessage = ""
pcDisplayMessage = "use test@test.com/test for a test login"

IF Request.IsPostback()
   *pcUsername = Request.Form("WebLogin_txtUsername")
   IF this.Authenticate("ANY",@pcErrorMessage)
	  IF EMPTY(pcReturnUrl)
	     pcReturnUrl = "~/default.ttk"
	  ENDIF
      Response.Redirect(pcReturnUrl)
   ENDIF
   
   *** Authenticate renders the login form if we failed
   RETURN
ENDIF

*** Only render this on a GET operation
*THIS.OnShowAuthenticationForm()

*** EXPLICITLY show the admin page and let OnShowAuthenticationForm
*** just redirect to this link with a ReturnUrl

*** You can also use a custom authentication dialog
Response.ExpandScript(Config.cHtmlPagePath + "views\_login.wcs")
ENDFUNC
*   Login

************************************************************************
*  Logout
****************************************
***  Function: Just a routing mechanism to allow logging out.
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION Logout()
this.Authenticate("Logout")
Response.Redirect("default.ttk")
ENDFUNC
*   Logout

************************************************************************
*  OnShowAuthenticationForm
****************************************
***  Function: Show the authentication form. In this case it's simply
***            showing the application template.
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION OnShowAuthenticationForm(lcUsername, lcErrorMsg)
LOCAL lcUrl 
lcUrl = "~/login.ttk"

IF TYPE("pcReturnUrl") = "C"
   lcUrl = lcUrl + "?returnurl=" + pcReturnUrl
ENDIF  

Response.Redirect(lcUrl)
ENDFUNC
*   OnShowAuthenticationForm

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


*********************************************************************
FUNCTION TestPage()
************************

THIS.StandardPage("Hello World from Vultr VM",;
                  "If you got here, everything is working fine.<p>" + ;
                  "Server Time: <b>" + TIME()+ "</b>")
                  
ENDFUNC
* EOF TestPage


************************************************************************
*  Default
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION Default()

#IF .F. 
LOCAL Request as wwRequest, Response as wwPageResponse, Server as wwServer, ;
      THIS as wwProcess, Process as wwProcess, Session as wwSession
#ENDIF

*** Check for authentication but don't abort if not logged in
*** Doing this so we know who is logged in and we can check for
*** open entries on the default page - otherwise that doesn't work
this.Oncheckforauthentication()

Response.ExpandScript()
ENDFUNC
*   Default

************************************************************************
* EntryBrowser
****************************************
***  Function:
***    Assume:
************************************************************************
FUNCTION  EntryBrowser()

#IF .F. 
LOCAL Request as wwRequest, Response as wwResponse, Process as wwProcess
#ENDIF

pnCustomerPk = VAL(Request.Params("lstCustomer"))
pcView = Request.Params("View")

loCustomerBus = THIS.CreateBusObject("ttCustomer")
loCustomerBus.GetCustomerList("TCustomers","pk,company")

LOCAL loEntryBus as ttEntry
loEntryBus = this.CreateBusObject("ttEntry")
DO CASE
   CASE pcView = "Open"
   	   loEntryBus.Getopenentries(this.nAuthenticatedUserPk,"TEntries",pnCustomerPk)
   CASE pcView = "All"
       	loEntryBus.GetRecentEntriesForUser(2000,Process.nAuthenticatedUserPk,.F.,"TEntries",pnCustomerPk)
   OTHERWISE
	    loEntryBus.GetRecentEntriesForUser(25,Process.nAuthenticatedUserPk,.F.,"TEntries",pnCustomerPk)
ENDCASE

pnEntryCount = RECCOUNT()
Calculate SUM(TotalHours) to pnTotalHours

Response.ExpandScript()
ENDFUNC
*  EntryBrowser

************************************************************************
* Punchin
****************************************
***  Function:
***    Assume:
************************************************************************
FUNCTION  Punchin()

#IF .F. 
LOCAL Request as wwRequest, Response as wwResponse, Process as wwProcess, Server as wwServer
#ENDIF

*** Declare PRIVATE variabls passed to the view
pcErrorMsg = ""
pcErrorIcon = "warning"
pcErrorHeader = ""
poErrors = null
poEntry = null

*** Create a new entry object
loEntryBus = this.CreateBusObject("ttEntry")
loEntryBus.New()
poEntry = loEntryBus.oData


*** Handle Postback
IF (Request.IsPostBack())
   poErrors = Request.UnbindFormVars(poEntry)

   IF !loEntryBus.Validate()
       loValErrors =loEntryBus.oValidationErrors
       poErrors.AddErrors( loValErrors )
   ENDIF
   
   IF poErrors.Count < 1 
       poEntry.UserPk = this.nAuthenticatedUserPk
       
       IF !loEntryBus.Save() 
	      pcErrorMsg = loEntryBus.cErrorMsg      
       ENDIF  
   ENDIF

   IF (poErrors.Count > 0)
   	   pcErrorMsg = poErrors.ToHtml()
   	   pcErrorHeader = "Please fix the following form entry errors"
   ELSE
       pcErrorMsg = "Entry saved."
       pcErrorIcon = "info"
       Response.AppendHeader("Refresh","2;url=entrybrowser.ttk")       
   ENDIF               
ELSE
   *** New Entry - use last used Customer Pk
   poEntry.CustomerPk = loEntryBus.GetLastCustomerUsed(this.nAuthenticatedUserPk)
ENDIF

*** Handle view display
lnCustomerPk = 0
lnProjPk = 0

loCustomerBus = THIS.CreateBusObject("ttCustomer")
loCustomerBus.GetCustomerList("TCustomers","pk,company")

loProjectBus = THIS.CreateBusObject("ttProject")
loProjectBus.GetProjectList("TProjects")

Response.ExpandScript()
ENDFUNC
*  Punchin

************************************************************************
*  PunchOut
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION PunchOut()

#IF .F. 
LOCAL Request as wwRequest, Response as wwResponse, Process as wwProcess, Server as wwServer
#ENDIF

*** Declare PRIVATE variabls passed to the view
poError = CREATEOBJECT("HtmlErrorDisplayConfig")
poError.Dismissable = .t.
poEntry = null

*** Create a new entry object
LOCAL loEntryBus as ttEntry
loEntryBus = this.CreateBusObject("ttEntry")

pnId = Request.QueryString("id")
IF EMPTY(pnID)
   pnId = Request.Form("pk")
ENDIF   

*** Check for multiple open entries and if so 
*** display a selection
IF EMPTY(pnId)
   lnEntryCount = loEntryBus.GetOpenentrycount(this.nAuthenticatedUserPk)
   IF  lnEntryCount > 1
      *** Show open entries
      Response.Redirect("EntryBrowser.ttk?View=Open")
   ENDIF   
   IF lnEntryCount = 1
       lnEntryCount = loEntryBus.GetOpenentries(this.nAuthenticatedUserPk,"TEntries")
       IF lnEntryCount >0
       	   pnId = TRANSFORM(TEntries.Pk)
       ELSE
	      this.ErrorMsg("There are no open entries","Please create a new time entries first before trying to punch out.")
    	  RETURN       
       ENDIF
   ENDIF
   IF lnEntryCount < 1
      this.ErrorMsg("There are no open entries","Please create a new time entries first before trying to punch out.")
      RETURN
   ENDIF
ENDIF
IF !IsNumber(pnId) 
   Response.Redirect("EntryBrowser.ttk?View=Open")
   RETURN
ENDIF


pnId = VAL(pnId)

IF !loEntryBus.Load(pnID)
   this.ErrorMsg("Invalid entry for Punch Out","Please enter a valid entry Id")
   RETURN
ENDIF

poEntry = loEntryBus.oData

IF (Request.IsPostBack())
   IF Request.IsFormVar("btnDelete")
      IF loEntryBus.Delete(pnId) 
	      Response.Redirect("entrybrowser.ttk")
	      RETURN
	  ENDIF
   ENDIF
 
   poError.Errors = Request.UnbindFormVars(poEntry)
   
   IF !loEntryBus.Validate()
       loValErrors =loEntryBus.oValidationErrors
       poError.Errors.AddErrors( loValErrors )
   ENDIF
   
   IF poError.Errors.Count < 1 
       poEntry.UserPk = this.nAuthenticatedUserPk
       
       IF Request.IsFormVar("btnPunchOut")
       		IF !loEntryBus.PunchOut() 
		      poError.Message = loEntryBus.cErrorMsg      		      
    	   ENDIF  
       ENDIF
       IF Request.IsFormVar("btnSave")
       		IF !loEntryBus.LeaveOpen() 
		      poError.Message = loEntryBus.cErrorMsg      
    	   ENDIF  
       ENDIF
   ENDIF

   IF poError.Errors.Count > 0
   	   poError.Message = poError.Errors.ToHtml()
   	   poError.Header = "Please fix the following form entry errors"
   ELSE
       poError.Message = "Entry saved."
       poError.Icon = "success"
       Response.AppendHeader("Refresh","1;url=EntryBrowser.ttk")
   ENDIF               
ENDIF


*** Handle view display
lnCustomerPk = 0
lnProjPk = 0

loCustomerBus = THIS.CreateBusObject("ttCustomer")
loCustomerBus.GetCustomerList("TCustomers","pk,company")

loProjectBus = THIS.CreateBusObject("ttProject")
loProjectBus.GetActiveProjectsForCustomer(loEntryBus.oData.CustomerPk,"TProjects")

Response.ExpandScript()
ENDFUNC
*   PunchOut

************************************************************************
* Entry
****************************************
***  Function:
***    Assume:
************************************************************************
FUNCTION  Entry()

#IF .F. 
LOCAL Request as wwRequest, Response as wwResponse, Process as wwProcess, ;
      THIS as Process, Server as wwServer
#ENDIF

PRIVATE poError
poError = CREATEOBJECT("HtmlErrorDisplayConfig")

lnId = VAL(Request.Params("id"))

IF lnId = 0
   Response.Redirect("~/EntryBrowser.ttk")
ENDIF

loEntry = CREATEOBJECT("ttEntry")

*** doesn't exist - leave
if(!loEntry.Load(lnid))
   Response.Redirect("~/EntryBrowser.ttk")
ENDIF

PRIVATE poEntry
poEntry = loEntry.oData

IF !poEntry.PunchedOut
   Response.Redirect(FormatString("~/punchout.ttk?id={0}",poEntry.Pk))
   RETURN   
ENDIF

Response.ExpandScript()
ENDFUNC
*  Entry


************************************************************************
*  Customers
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION Customers()
LOCAL lcFilter

#IF .F. 
LOCAL Request as wwRequest, Response as wwResponse, Process as wwProcess, Server as wwServer
#ENDIF


PRIVATE pcSearchFor
pcSearchFor = Request.Form("SearchFor")
lcFilter = ""
IF !EMPTY(pcSearchFor)
	pcSearchFor = "%" + LOWER(pcSearchFor) + "%"
    lcFilter = "lower(Company) like ?pcSearchFor"
ENDIF


LOCAL loCustomer as ttCustomer
loCustomer = CREATEOBJECT("ttCustomer")

loCustomer.Getcustomerlist("TCustomers","pk,Company,firstname + ' ' + lastname as Name," + ;
                                        "LastOrder as LastAccess",lcFilter)


_ClipText = lcFilter + "  " + pcSearchFor + "    "  + loCustomer.cSql

LOCAL loConfig
loConfig = CREATEOBJECT("HtmlDataGridConfig")
*loGridConfig.Width = "800"
loConfig.PageSize = 7

LOCAL loColumn as HtmlDataGridColumn
loColumn = CREATEOBJECT("HtmlDataGridColumn")
loColumn.Expression = [HREF("customer.ttk?id=" + TRANSFORM(Pk),Company)]
loColumn.HeaderText = "Company"
loColumn.SortExpression = "UPPER(Company)"
loConfig.AddColumn(loColumn)

loColumn = CREATEOBJECT("HtmlDataGridColumn")
loColumn.Expression = "Name"
loConfig.AddColumn(loColumn)

loColumn = CREATEOBJECT("HtmlDataGridColumn")
loColumn.Expression = "ShortDate(LastAccess,2)"
loColumn.HeaderText = "Last Access"
loColumn.FieldType = "C"
loColumn.SortExpression = "LastAccess"
loConfig.AddColumn(loColumn)

pcCustomerGrid = HtmlDataGrid("TCustomers",loConfig)

Response.ExpandScript()
ENDFUNC
*   Customers

************************************************************************
*  Customer
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION Customer()

*** Setup Code
pnId = Request.QueryString("id")

IF !IsNumber(pnId)
   pnId = 0
ENDIF   
pnId = VAL(pnId)

LOCAL loProject as ttProject
loProject = CREATEOBJECT("ttProject")

LOCAL loCustomer as ttCustomer
loCustomer = CREATEOBJECT("ttCustomer")

IF (pnId =  0)
    llResult = loCustomer.New()
ELSE
    llResult = loCustomer.Load(pnId)       
ENDIF    

IF (!llResult)
   this.ErrorMsg("Couldn't load Customer","Please make sure you selected a valid customer","",3,"customers.ttk")
   RETURN
ENDIF

loProject.GetProjectsForCustomer(pnId,"TProjects")
SELECT TOP 15 * FROM TProjects INTO CURSOR TProjects ;
   ORDER BY ENTERED DESC 

*** Binding Values
PRIVATE poError, poCustomer
poError = CREATEOBJECT("HtmlErrorDisplayConfig")
poError.Dismissable = .T.

poCustomer = loCustomer.oData

*** Postback Code
IF (Request.IsPostBack())
   poError.Errors = Request.UnbindFormVars(loCustomer.oData)

   IF !loCustomer.Validate()
       poError.Errors.AddErrors( loCustomer.oValidationErrors )
   ENDIF
   
   *** Save
   IF poError.Errors.Count < 1 
       IF !loCustomer.Save() 
	      poError.Message = loCustomer.cErrorMsg      
       ENDIF  
   ENDIF

   *** Handle  display of confirmations and errors
   IF (poError.Errors.Count > 0)
   	   poError.Message = poError.Errors.ToHtml()
   	   poError.Header = "Please fix the following form entry errors"
   ELSE
       poError.Message = "Entry saved."
       poError.Icon = "info"
       Response.AppendHeader("Refresh","2;url=customers.ttk")
   ENDIF               
ENDIF

LOCAL loEntry as TTEntry
loEntry = CREATEOBJECT("ttEntry")
loEntry.Getrecententriesforuser(6,this.nAuthenticatedUserPk, .f., "TEntries", poCustomer.pk)

*** View Preparation Code
Response.ExpandScript(Config.cHtmlPagePath + "Customer.ttk")
ENDFUNC
*   Customer

************************************************************************
*  TimeReport
****************************************
***  Function: Handles the TimeReport form. Passes on reporting to 
***            TimeReportOutput
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION TimeReport()

poError = CREATEOBJECT("HtmlErrorDisplayConfig")
poError.Dismissable = .T.

poReportParms = CREATEOBJECT("EMPTY")
ADDPROPERTY(poReportParms,"CustomerPks",CREATEOBJECT("Collection"))
ADDPROPERTY(poReportParms,"UserPk", Process.nAuthenticatedUserPk)
ADDPROPERTY(poReportParms,"AllCustomers",.T.)
ADDPROPERTY(poReportParms,"DateStart",DATE() - 30)
ADDPROPERTY(poReportParms,"DateEnd",DATE())
ADDPROPERTY(poReportParms,"BillStatus","All")
ADDPROPERTY(poReportParms,"OutputType","Html")  && PDF, JSON, XML

IF (Request.IsPostBack())
   poError.Errors = Request.UnbindFormVars(poReportParms)
   
   poReportParms.CustomerPks = Request.GetFormMultipleCollection("CustomerPk")

   IF (poError.Errors.Count > 0)
   	   poError.Message = poError.Errors.ToHtml()
   	   poError.Header = "Please fix the following form entry errors"
   ELSE
       *** Generate report output
       THIS.TimeReportOutput(poReportParms)
       RETURN
   ENDIF               
ENDIF

loCustomerBus = THIS.CreateBusObject("ttCustomer")
loCustomerBus.GetCustomerList("TCustomers","pk,company")

Response.ExpandScript(Config.cHtmlPagePath + "TimeReport.ttk")
ENDFUNC
*   TimeReports

************************************************************************
*  TimeReportOutput
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION TimeReportOutput(poReportParms)

pcReportTitle = "Time Trakker Report"

loEntryBus = CREATEOBJECT("ttEntry")
loEntryBus.GetTimeSheetData(poReportParms,"TEntries")

DO CASE
    CASE poReportParms.OutputType = "Html"
		Response.ExpandScript(Config.cHtmlPagePath + "TimeReportOutput.ttk")
	CASE poReportParms.OutputType = "PDF"
		loPDF=CREATEOBJECT([WWC_WWPDF])     
		loPDF.cPrinterDriver = FindPostScriptPrinter()
	    lcPDF = loPDF.PrintReportToString("timesheetreport.frx")
	    Response.ContentType = "application/pdf"
 	    Response.Write(lcPDF)
	CASE poReportParms.OutputType = "JSON"
	   LOCAL loJson as wwJsonSerializer
	   loJson = CREATEOBJECT("wwJsonSerializer")
	   lcOutput = loJson.Serialize("cursor_rawarray:TEntries")
	   
	   Response.ContentType = "application/json"
	   Response.Write(lcOutput)	
	CASE poReportParms.OutputType = "XML"
	   lcXML = ""
	   CURSORTOXML("TEntries","lcXml",1,48)
   	   Response.ContentType = "text/xml"
	   Response.Write(lcXML)	
ENDCASE



ENDFUNC
*   TimeReportOutput

************************************************************************
*  Projects
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION Projects()

PRIVATE pnCustomerPk
pnCustomerPk = 0

LOCAL loCust as ttCustomer
loCust = this.CreateBusObject("ttCustomer")

IF loCust.Getcustomerlist("TCustomers") < 0
   THIS.ErrorDisplay("Customer retrieval failed.","We were unable to retrieve customers:" + loCust.cErrorMsg)   
   RETURN		
ENDIF

LOCAL loProj as ttProject
loProj = CREATEOBJECT("ttProject")

IF loProj.Getprojectlist("TProjects") < 0
   THIS.ErrorDisplay("Project retrieval failed.","We were unable to retrieve projects:" + loProj.cErrorMsg)   
   RETURN		
ENDIF



Response.ExpandScript()
ENDFUNC
*   Projects

************************************************************************
* Project
****************************************
***  Function:
***    Assume:
************************************************************************
FUNCTION  Project()

#IF .F. 
LOCAL Request as wwRequest, Response as wwResponse, Process as wwProcess, Server as wwServer,;
      poErrors as ErrorDisplayConfig, poProject as ttProject
#ENDIF

poError = CREATEOBJECT("HtmlErrorDisplayConfig")

lnId = VAL(Request.QueryString("id"))

LOCAL loCust as ttCustomer
loCust = THIS.CreateBusObject("ttCustomer")
loCust.Getcustomerlist("TCustomers","pk,company,lastname,firstname")

LOCAL loProj as ttProject
loProj = this.CreateBusObject("ttProject")
IF !loProj.Load(lnId)
	IF (lnId = 0)
	   loProj.New()
	ELSE
	   poError.Message = "Invalid project id"
	ENDIF
ENDIF
poProject = loProj.oData

LOCAL loEntryBus as ttEntry
loEntryBus = this.CreateBusObject("ttEntry")
loEntryBus.GetEntriesForProject(lnId,"TEntries")


IF (Request.IsPostBack())
   poError.Errors = Request.UnbindFormVars(loProj.oData)

   IF !loProj.Validate()
       poError.Errors.AddErrors( loProj.oValidationErrors )
   ENDIF
   
   IF poError.Errors.Count < 1 
       IF !loProj.Save() 
	      poError.Message = loProj.cErrorMsg      
       ENDIF  
   ENDIF

   IF (poError.Errors.Count > 0)
   	  poError.Message = poError.Errors.ToHtml()
   	   poError.Header = "Please fix the following form entry errors"
   ELSE
       poError.Message = "Entry saved."
       poError.Icon = "info"
       Response.Redirect("~/projects.ttk")
   ENDIF               
ENDIF
 

Response.ExpandScript()
ENDFUNC
*  Project


*** AJAX CALLBACKS ***

************************************************************************
*  Callbacks
****************************************
***  Function: Generic endpoint for callbacks
***    Assume: Callbacks.ttk?method=UpdateEntryTotals
***            POST JSON to be passed as input parameter (if any)
***      Pass:
***    Return:
************************************************************************
FUNCTION Callbacks()

*** Instantiate or reference the class that will will handle the method call
*** Here I just use the Process class itself which will lhandle the call
loTarget= this  && Class that handles callback

*** Instanantiate the service
loService = CREATEOBJECT("wwJsonService")

*** Return a JSON Response
Response.ContentType = "application/json"

*** Write out the result from CallMethod which returns the JSON for the method
*** or a JSON Error object if the call failed
lcResult = loService.CallMethod(Request,loTarget) 

*** Return an error response so jQuery's error handler kicks in
*** Note: Result is still a JSON response
IF loService.ErrorOccurred
   Response.Status = "500 Server Error"
ENDIF

Response.Write(lcResult)
RETURN
ENDFUNC
*   Callbacks


************************************************************************
*  GetActiveProjectsForCustomer
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION GetActiveProjectsForCustomer(lnCustomerPk)

loProject = CREATEOBJECT("ttProject")
loProject.GetActiveProjectsForCustomer(lnCustomerPk,"TProjects")

IF loProject.lError
   ERROR "Failed to get projects: " + loProject.cErrorMsg
ENDIF

RETURN "cursor:TProjects"
ENDFUNC
*   GetActiveProjectsForCustomer


************************************************************************
*  UpdateEntryTotals
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION UpdateEntryTotals(loParms)

loEntry = CREATEOBJECT("ttEntry")
IF !loEntry.Load( loParms.Pk )
	ERROR "Unable to load customer"
ENDIF

loEntry.oData.Timein = loParms.TimeIn
loEntry.oData.Timeout = loParms.TimeOut

IF EMPTY(loEntry.oData.Timein) OR EMPTY(loEntry.oData.Timeout)
  ERROR "Invalid date value detected."
ENDIF

loEntry.oData.Timein = loEntry.RoundDate(loEntry.oData.TimeIn)
loEntry.oData.Timeout = loEntry.RoundDate(loEntry.oData.Timeout)
  
loEntry.oData.Rate = loParms.BillRate
loEntry.CalculateTotals()

*** Create a result object with just the values we want
*** This is mainly to provide proper client formatting
loResult = CREATEOBJECT("EMPTY")
ADDPROPERTY(loResult,"Message","")

ADDPROPERTY(loResult,"Timein",TRANSFORM(TTOD(loEntry.oData.Timein)) + " " + ShortTime(loEntry.oData.TimeIn))
ADDPROPERTY(loResult,"Timeout",TRANSFORM(TTOD(loEntry.oData.Timeout)) + " " + ShortTime(loEntry.oData.TimeOut))
ADDPROPERTY(loResult,"BillRate",ALLTRIM(TRANSFORM(loEntry.oData.Rate,"9,999.99")) )

ADDPROPERTY(loResult,"TotalHours",ToHoursAndMinutes(loEntry.oData.TotalHours))
ADDPROPERTY(loResult,"ItemTotal",ALLTRIM(TRANSFORM(loEntry.oData.ItemTotal,"$$$,$$$.99")) )


DO CASE
CASE loEntry.oData.Timeout < loEntry.oData.Timein
   loResult.Message = "Time in is earlier than time out."
   loResult.Timeout = TRANSFORM(TTOD(DATETIME()) ) + " " + ShortTime(DATETIME()) 
CASE loEntry.oData.TotalHours > 10
   loResult.Message = "Large number of hours detected. Are you sure this correct?"
ENDCASE

RETURN loResult
ENDFUNC


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


************************************************************************
*  Browser
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION Browser()
Response.ExpandScript()
ENDFUNC
*   Browser

ENDDEFINE