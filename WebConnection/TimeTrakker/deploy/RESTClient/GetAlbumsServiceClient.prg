DO wwJsonSerializer

loClient = CREATEOBJECT("wwJsonServiceClient")

loAlbums = loClient.CallService("https://albumviewer.west-wind.com/api/albums")

FOR EACH loAlbum IN loAlbums FOXOBJECT
   ? loAlbum.Title + " - "  + loAlbum.Artist.ArtistName + " (" + TRANSFORM(loAlbum.Year) + ")"
   IF !ISNULL(loAlbum.Tracks)
	   FOR EACH loTrack IN loAlbum.Tracks FOXOBJECT
		   ? "  " + loTrack.SongName + " "  + NVL(loTrack.Length,"")
	   ENDFOR
	ENDIF
ENDFOR






