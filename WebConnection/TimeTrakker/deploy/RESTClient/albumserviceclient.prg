DO wwJsonSerializer
DO wwHttp
SET PROCEDURE TO AlbumServiceClient ADDITIVE


*************************************************************
DEFINE CLASS AlbumServiceClient AS wwJsonServiceClient
*************************************************************
*: Author: Rick Strahl
*:         (c) West Wind Technologies, 2018
*:Contact: http://www.west-wind.com
*:Created: 10/12/18
*************************************************************
#IF .F.
*:Help Documentation
*:Topic:
Class AlbumServiceClient

*:Description:

*:Example:

*:Remarks:

*:SeeAlso:


*:ENDHELP
#ENDIF

cServiceUrl = "https://albumviewer.west-wind.com/api/"

cUserName = "test"
cPassword = "test"


************************************************************************
*  GetAlbums
****************************************
***  Function: Retrieves a list of albums
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION GetAlbums()
LOCAL loAlbums

loAlbums = this.CallService(this.cServiceUrl + "albums")

IF (this.lError)
   RETURN null
ENDIF

RETURN loAlbums   
ENDFUNC
*   GetAlbums

************************************************************************
*  GetArtists
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION GetArtists()
LOCAL loAlbums

loAlbums = this.CallService(this.cServiceUrl + "artists")

IF (this.lError)
   RETURN null
ENDIF

RETURN loAlbums   
ENDFUNC
*   GetArtists


************************************************************************
*  Login
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION Login(lcUser, lcPassword)

loLogin = CREATEOBJECT("EMPTY")
ADDPROPERTY(loLogin,"username",lcUser)
ADDPROPERTY(loLogin,"password",lcPassword)

llResult = this.CallService(this.cServiceUrl + "login",loLogin,"POST")

IF this.lError
   RETURN .F.
ENDIF


RETURN .T.
ENDFUNC
*   Login

************************************************************************
*  GetArtist
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION GetArtist(lnId)

loArtist = this.CallService(this.cServiceUrl + "artist/" + TRANSFORM(lnId))

IF this.lError
   RETURN null
ENDIF   


RETURN loArtist
ENDFUNC
*   GetArtist


************************************************************************
*  UpdateArtist
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION UpdateArtist(loArtist)

loArtist = this.CallService(this.cServiceUrl + "artist", loArtist, "POST")

IF this.lError
   RETURN null
ENDIF   

RETURN loArtist
ENDFUNC
*   UpdateArtist


ENDDEFINE
*EOC AlbumServiceClient 