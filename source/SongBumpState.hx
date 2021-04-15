package;

import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import Conductor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import Song.SwagSong;

class SongBumpState extends MusicBeatState
{
    public static var songToBop:String;

    var logo:FlxSprite;

    var scalar:Float;

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

        logo = new FlxSprite();
        logo.frames = Paths.getSparrowAtlas('logoBumpin');
        logo.antialiasing = true;
        logo.animation.addByPrefix('bump', 'logo bumpin', 24);
        logo.updateHitbox();
        logo.screenCenter();
        logo.scale.x = 1.25;
        logo.scale.y = 1.25;
        logo.visible = false;

        add(logo);

        FlxG.drawFramerate = 24;

        // start song
        new FlxTimer().start(2.5, function(tmr:FlxTimer)
        {
            this.startSong();
        });
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

        // ENTER KEY
        if (FlxG.keys.justPressed.ENTER) {
            this.endSong();
        }

        super.update(elapsed);
    }

    // BEAT HIT
    override function beatHit()
    {
        super.beatHit();

        FlxTween.tween(logo.scale, {x: 1.35, y: 1.35,}, 0.125, {
            ease: FlxEase.quartInOut,
            onComplete: function(tween:FlxTween)
            {
                FlxTween.tween(logo.scale, {x: 1.25, y: 1.25}, 0.125, {ease: FlxEase.quartInOut});
            }
        });

        if (song.notes[Math.floor(curStep / 16)] != null)
        {
            if (song.notes[Math.floor(curStep / 16)].changeBPM)
            {
                Conductor.changeBPM(song.notes[Math.floor(curStep / 16)].bpm);
                // trace('CHANGED BPM!');
            }
        }
    }

    // START SONG
    function startSong():Void
    {
        // set logo visible
        logo.visible = true;

        // play the music
        FlxG.sound.playMusic(Paths.inst(song.song), 1, false);
        FlxG.sound.music.onComplete = this.endSong;

        // play the vocals
        vocals.play();
    }

    // END SONG
    function endSong():Void
    {
        FlxG.sound.music.volume = 0;
        vocals.volume = 0;
        logo.visible = false;
        FlxG.drawFramerate = 60;

        new FlxTimer().start(2.5, function(tmr:FlxTimer)
        {
            FlxG.switchState(new FreeplayState());
        });
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