************************************************************************
*PROCEDURE VueProcess
****************************
***  Function: Processes incoming Web Requests for VueProcess
***            requests. This function is called from the wwServer 
***            process.
***      Pass: loServer -   wwServer object reference
*************************************************************************
LPARAMETER loServer
LOCAL loProcess
PRIVATE Request, Response, Server, Session, Process
STORE NULL TO Request, Response, Server, Session, Process

#INCLUDE WCONNECT.H

loProcess = CREATEOBJECT("VueProcess", loServer)
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
DEFINE CLASS VueProcess AS WWC_RESTPROCESS
*************************************************************

*** Response class used - override as needed
cResponseClass = [WWC_PAGERESPONSE]

*** Default for page script processing if no method exists
*** 1 - MVC Template (ExpandTemplate()) 
*** 2 - Web Control Framework Pages
*** 3 - MVC Script (ExpandScript())
nPageScriptMode = 3

*!* cAuthenticationMode = "UserSecurity"  && `Basic` is default


*** ADD PROCESS CLASS EXTENSIONS ABOVE - DO NOT MOVE THIS LINE ***


#IF .F.
* Intellisense for THIS
LOCAL THIS as VueProcess OF VueProcess.prg
#ENDIF
 
*********************************************************************
* Function VueProcess :: OnProcessInit
************************************
*** If you need to hook up generic functionality that occurs on
*** every hit against this process class , implement this method.
*********************************************************************
FUNCTION OnProcessInit

*!* LOCAL lcScriptName, llForceLogin
*!*	THIS.InitSession("MyApp")
*!*
*!*	lcScriptName = LOWER(JUSTFNAME(Request.GetPhysicalPath()))
*!*	llIgnoreLoginRequest = INLIST(lcScriptName,"default","login","logout")
*!*
*!*	IF !THIS.Authenticate("any","",llIgnoreLoginRequest) 
*!*	   IF !llIgnoreLoginRequest
*!*		  RETURN .F.
*!*	   ENDIF
*!*	ENDIF
	
*** Explicitly specify that pages should encode to UTF-8 
*** Assume all form and query request data is UTF-8
Response.Encoding = "UTF8"
Request.lUtf8Encoding = .T.


*** Add CORS header to allow cross-site access from other domains/mobile devices on Ajax calls
 Response.AppendHeader("Access-Control-Allow-Origin","*")
 Response.AppendHeader("Access-Control-Allow-Origin",Request.ServerVariables("HTTP_ORIGIN"))
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



*********************************************************************
FUNCTION TestPage()
************************

*** Produce regular HTML response
JsonService.IsRawResponse = .T.
Response.ContentType = "text/html"

Response.ContentType = "text/html"

THIS.StandardPage("Hello World from the VueProcess process",;
                  "If you got here, everything is working fine.<p>" + ;
                  "Server Time: <b>" + TIME()+ "</b>")
                  
ENDFUNC
* EOF TestPage


*********************************************************************
FUNCTION HelloScript()
************************
PRIVATE poError 

*** Produce regular HTML response
JsonService.IsRawResponse = .T.
Response.ContentType = "text/html"

*** Configure a model and pass it into the script
*** Use this to display an ErrorDisplay object
poError = CREATEOBJECT("HtmlErrorDisplayConfig")
poError.Message = "Welcome from the " + this.Class + " class, using MVC scripting."
poError.Icon = "info"

*** Run a query and pass the data to the script
SELECT TOP 10 * FROM wwRequestLog  ;
INTO CURSOR TRequests ;
ORDER BY Time Desc

*** Render HelloScript page template
Response.ExpandScript()

USE IN TRequests

RETURN ""
ENDFUNC
* EOF HelloScript


*************************************************************
*** PUT YOUR OWN CUSTOM METHODS HERE                      
*** 
*** Any method added to this class becomes accessible
*** as an HTTP endpoint with MethodName.Extension where
*** .Extension is your scriptmap. If your scriptmap is .rs
*** and you have a function called Helloworld your
*** endpoint handler becomes HelloWorld.rs
*************************************************************


************************************************************************
*  Todos
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION ToDos()


IF !FILE(".\todos.dbf") 
   ReloadData()	
ENDIF

SELECT id, title, descript as Description, entered, completed, isEditing ;
     FROM TODOS ;
	 ORDER BY entered DESC ;
	 INTO CURSOR Tquery

Serializer.PropertyNameOverrides = "isEditing"

RETURN "cursor:TQuery"
ENDFUNC
*   Todos


FUNCTION ReloadData()

if (FILE("todos.dbf"))
   ERASE FILE Todos.dbf
endif  

CREATE TABLE TODOS (id v(20), title v(100), descript M, entered T,completed L, isEditing L)

INSERT INTO TODOS VALUES ("1","Load up sailing gear","Load up the car, stock up on food.",DATETIME(),.f.,.f.)
INSERT INTO TODOS VALUES ("2","Get on the road out East","Get in the car and drive until you find wind",DATETIME(),.f.,.f.)
INSERT INTO TODOS VALUES ("3","Wait for wind","Arrive on the scene only to find no wind",DATETIME(),.f.,.f.)
INSERT INTO TODOS VALUES ("4","Pray for wind","Still waiting!",DATETIME(),.F.,.F.)
INSERT INTO TODOS VALUES ("5","Sail!","Score by hitting surprise frontal band and hit it big!",DATETIME(),.F.,.f.)

RETURN .T.
ENDFUNC
* Todos


************************************************************************
*  TodoStatus
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION toggleTodo(loTodo)
LOCAL lcID

IF ISNULLOREMPTY(loTodo)
   ERROR "No Todo item passed."
ENDIF

lcId = loTodo.Id

SELECT * FROM TODOS ;
       WHERE id = lcId ;
       INTO CURSOR TTodo
   IF _Tally = 0
  	   ERROR "Invalid Todo to update."
   ENDIF

UPDATE Todos SET completed= loTodo.completed WHERE id = lcId

RETURN .T.
ENDFUNC
*   TodoStatus

************************************************************************
*  Todo
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION ToDo(loToDo)

*ERROR "We're not ready to accept your ToDo's just yet..."



IF !USED("ToDos")
   USE ToDos IN 0
ENDIF
SELECT ToDos

lcVerb = Request.GetHttpverb()

IF lcVerb = "GET" 
   lcId = Request.Params("id")
   IF IsNullOrEmpty(lcId)
   	   ERROR "No Id provided to load a Todo item"
   ENDIF  
   
   SELECT * FROM TODOS ;
       WHERE id = lcId ;
       INTO CURSOR TTodo
   IF _Tally = 0
  	   ERROR "No Id provided to load a Todo item"
   ENDIF

   SCATTER NAME loTodo MEMO
   Serializer.PropertyNameOverrides = "isEditing"
   RETURN loTodo       
ENDIF

IF lcVerb = "PUT" OR lcVerb = "POST"
	IF VARTYPE(loTodo) # "O"
	   ERROR "Invalid operation: No To Do Item passed."
	ENDIF

   loTodo.IsEditing = .F.

	 llNew = .F.
    LOCATE FOR id == loToDo.id
    IF empty(loTodo.Id) OR !FOUND()
		APPEND BLANK
		loTodo.id = GetUniqueId(8)
      loTodo.entered = DATETIME()
		llNew = .T.
	ENDIF
	GATHER NAME loTodo MEMO
	
	*** Fix for differing field name
	REPLACE descript WITH loTodo.description
	SCATTER NAME loTodo Memo
   Serializer.PropertyNameOverrides = "isEditing"
   return loTodo
ENDIF

IF lcVerb = "DELETE"

   lcid =  Request.QueryString("id")
   LOCATE FOR id == lcId 
   IF !FOUND() OR EMPTY(lcId)
      Response.Status = "404 Not found"
      ERROR "Invalid Todo - can't delete."      
   ENDIF
   
   DELETE FOR id == lcId
   RETURN .t.
ENDIF

RETURN loTodo
ENDFUNC
*   Todo

************************************************************************
*  DeleteTodo
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION DeleteTodo()


ENDFUNC
*   DeleteTodo


ENDDEFINE