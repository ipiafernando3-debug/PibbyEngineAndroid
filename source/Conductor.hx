package;

class SwagSection
{
    public var sectionNotes:Array<Dynamic> = [];
    public var lengthInSteps:Int = 16;
    public var typeOfSection:Int = 0;
    public var mustHitSection:Bool = true;
}

class BPMChangeEvent
{
    public var stepTime:Int;
    public var songTime:Float;
    public var bpm:Float;

    public function new(step:Int, time:Float, newBpm:Float)
    {
        stepTime = step;
        songTime = time;
        bpm = newBpm;
    }
}

class Conductor
{
    public static var bpm:Float = 100;
    public static var crochet:Float = ((60 / bpm) * 1000); // Milisegundos por beat
    public static var stepCrochet:Float = crochet / 4; // Milisegundos por step
    public static var songPosition:Float = 0;
    public static var lastSongPos:Float = 0;
    public static var offset:Float = 0;

    public static var curBeat:Int = 0;
    public static var curStep:Int = 0;

    public static var bpmChangeMap:Array<BPMChangeEvent> = [];

    public static function mapBPMChanges(song:SwagSong)
    {
        bpmChangeMap = [];

        var curBPM:Float = song.bpm;
        var totalSteps:Int = 0;
        var totalTime:Float = 0;
        var curCrochet:Float = ((60 / curBPM) * 1000);

        if (song.notes != null)
        {
            for (i in 0...song.notes.length)
            {
                if (song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
                {
                    curBPM = song.notes[i].bpm;
                    curCrochet = ((60 / curBPM) * 1000);
                    bpmChangeMap.push(new BPMChangeEvent(totalSteps, totalTime, curBPM));
                }

                var deltaSteps:Int = song.notes[i].lengthInSteps;
                totalSteps += deltaSteps;
                totalTime += curCrochet * (deltaSteps / 4);
            }
        }
    }

    public static function changeBPM(newBpm:Float)
    {
        bpm = newBpm;
        crochet = ((60 / bpm) * 1000);
        stepCrochet = crochet / 4;
    }
}

typedef SwagSong = {
    var song:String;
    var notes:Array<SwagSection>;
    var bpm:Float;
    var needsVoices:Bool;
    var speed:Float;
    var player1:String;
    var player2:String;
}
  
