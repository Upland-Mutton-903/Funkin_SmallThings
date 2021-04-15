package;

import Song.SwagSong;

class SongBumpState extends MusicBeatState
{
    public static var songToBop:String;

    var song:SwagSong;

    override function create()
    {
        // if a song somehow isnt set, use bopeebo
        if (songToBop == null)
        {
            songToBop = "bopeebo";
        }

        // load the song data
        song = Song.loadFromJson(songToBop, songToBop);

        trace("BOPPING " + songToBop);
    }
}