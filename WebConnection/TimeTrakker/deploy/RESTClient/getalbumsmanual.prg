DO wwHttp
DO wwJsonSerializer

loHttp = CREATEOBJECT("wwHttp")
lcAlbumsJson = loHttp.HttpGet("https://albumviewer.west-wind.com/api/albums")

loSer = CREATEOBJECT("wwJsonSerializer")

*** This should return a collection of Albums
loAlbums = loSer.DeSerializeJson(lcAlbumsJson)

SET STEP ON 

FOR EACH loAlbum IN loAlbums FOXOBJECT
   ? loAlbum.Title + " - "  + loAlbum.Artist.ArtistName + " (" + TRANSFORM(loAlbum.Year) + ")"
   IF !ISNULL(loAlbum.Tracks)
	   FOR EACH loTrack IN loAlbum.Tracks FOXOBJECT
		   ? "  " + loTrack.SongName + " "  + NVL(loTrack.Length,"")
	   ENDFOR
	ENDIF
ENDFOR






