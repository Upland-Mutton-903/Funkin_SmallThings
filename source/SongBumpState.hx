package;

import Conductor;
import flixel.FlxG;
import flixel.system.FlxSound;
import Song.SwagSong;

class SongBumpState extends MusicBeatState
{
    public static var songToBop:String;

    var song:SwagSong;
    var vocals:FlxSound;

    // CLASS CREATION
    override function create()
    {
        super.create();

        // if a song somehow isnt set, use bopeebo
        if (songToBop == null)
        {
            songToBop = "bopeebo";
        }

        // load the song data
        song = Song.loadFromJson(songToBop, songToBop);

        // set conductor shit
        Conductor.mapBPMChanges(song);
        Conductor.changeBPM(song.bpm);
        persistentUpdate = true;

        // logging
        trace("BOPPING " + songToBop + " AT " + Conductor.bpm + "BPM");

        // define the vocals
        if (song.needsVoices == true)
        {
            vocals = new FlxSound().loadEmbedded(Paths.voices(song.song));
        } else {
            vocals = new FlxSound();
        }

        // start song
        this.startSong();
    }

    // ON FOCUS LOST
    override function onFocusLost()
    {
        // mute vocals
        vocals.volume = 0;

        super.onFocusLost();
    }

    // ON FOCUS
    override function onFocus()
    {
        // unmute vocals
        vocals.volume = 1;

        // resync vocals
        this.resyncVocals();

        super.onFocus();
    }

    // UPDATE
    override function update(elapsed:Float)
    {
        // update beat and step
        Conductor.songPosition = FlxG.sound.music.time;

        super.update(elapsed);
    }

    // BEAT HIT
    override function beatHit()
    {
        // TEST
        trace("BEAT HIT");

        super.beatHit();
    }

    // START SONG
    function startSong():Void
    {
        // play the music
        FlxG.sound.playMusic(Paths.inst(song.song), 1, false);

        // play the vocals
        vocals.play();
    }

    // RESYNC VOCALS
    function resyncVocals():Void
    {
        // pause the vocals
        vocals.pause();

        // replay and reset conductor shit
        FlxG.sound.music.play();
        Conductor.songPosition = FlxG.sound.music.time;
        vocals.time = Conductor.songPosition;
        vocals.play();
    }
}