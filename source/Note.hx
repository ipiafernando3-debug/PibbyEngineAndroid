package;

import flixel.FlxSprite;
import flixel.util.FlxColor;

class Note extends FlxSprite
{
    public var strumTime:Float = 0;
    public var noteData:Int = 0; // 0: Left, 1: Down, 2: Up, 3: Right
    public var mustPress:Bool = false;
    public var tooLate:Bool = false;
    public var wasGoodHit:Bool = false;
    public var prevNote:Note;

    public var sustainLength:Float = 0;
    public var isSustainPiece:Bool = false;

    public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false)
    {
        super();

        if (prevNote == null)
            prevNote = this;

        this.prevNote = prevNote;
        this.isSustainPiece = sustainNote;
        this.strumTime = strumTime;
        this.noteData = noteData;

        // Gráfico temporal basado en color para cada dirección hasta cargar spritesheets
        var noteColor:FlxColor = FlxColor.WHITE;
        switch (noteData % 4)
        {
            case 0: noteColor = FlxColor.PURPLE; // Left
            case 1: noteColor = FlxColor.BLUE;   // Down
            case 2: noteColor = FlxColor.GREEN;  // Up
            case 3: noteColor = FlxColor.RED;    // Right
        }

        makeGraphic(40, 40, noteColor);
        updateHitbox();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (mustPress)
        {
            // Si la nota pasa del tiempo límite sin ser tocada, se marca como perdida
            if (strumTime < Conductor.songPosition - 166)
            {
                if (!wasGoodHit)
                    tooLate = true;
            }
        }
    }
}
