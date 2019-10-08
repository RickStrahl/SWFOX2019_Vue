DO AlbumServiceClient

LOCAL loClient as AlbumServiceClient
loClient = CREATEOBJECT("AlbumServiceClient")

*!*	loAlbums = loClient.GetAlbums()
*!*	IF ISNULL(loAlbums)
*!*	   ? "Couldn't retrieve albums: " + loClient.cErrorMsg
*!*	ELSE    
*!*	   ? loAlbums.Count
*!*	ENDIF   

*!*	loArtists = loClient.GetArtists()
*!*	IF ISNULL(loAlbums)
*!*	    ? "Couldn't retrieve artists: " + loClient.cErrorMsg
*!*	ELSE    
*!*		? loArtists.Count   
*!*	ENDIF   


*** Anthrax
loResult = loClient.GetArtist(6)
loArtist = loResult.Artist  && API returns artist and albums 

IF !loClient.Login("test","test")
   ? "Couldn't log in to update artist..."
ENDIF

loArtist.ArtistName = "Anthrax - " + TIME()
loResult = loCLient.UpdateArtist(loArtist)

IF ISNULL(loResult)
   ? "Couldn't update artist: " + loClient.cErrorMsg
ENDIF


? loResult.Artist.ArtistName


