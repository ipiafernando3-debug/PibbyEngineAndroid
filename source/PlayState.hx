package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxTypedGroup;
import flixel.ui.FlxBar;
import flixel.FlxSprite;

class PlayState extends FlxState
{
    public static var instance:PlayState;
    
    var virtualPad:VirtualPad;
    var scoreText:FlxText;
    var missText:FlxText;
    var accuracyText:FlxText;
    
    var score:Int = 0;
    var misses:Int = 0;
    var totalNotesHit:Int = 0;
    var totalNotesSpawned:Int = 0;

    // Sistema de Barra de Vida FNF
    public var health:Float = 50;
    var healthBarBG:FlxSprite;
    var healthBar:FlxBar;

    // Grupos y variables para las notas cayendo
    public var notes:FlxTypedGroup<Note>;
    public static var strumY:Float = 50;

    override public function create():Void
    {
        super.create();
        instance = this;

        // Color de fondo temporal (Gris oscuro estilo motor)
        FlxG.cameras.bgColor = FlxColor.fromRGB(20, 20, 30);

        // Inicializar grupo de notas
        notes = new FlxTypedGroup<Note>();

        // --- 1. BARRA DE VIDA CLÁSICA ---
        healthBarBG = new FlxSprite(340, 620).makeGraphic(600, 20, FlxColor.BLACK);
        healthBarBG.scrollFactor.set();
        add(healthBarBG);

        healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, HORIZONTAL, 592, 12, this, "health", 0, 100);
        healthBar.createFilledBar(FlxColor.fromRGB(255, 0, 0), FlxColor.fromRGB(0, 255, 0));
        healthBar.scrollFactor.set();
        add(healthBar);

        // --- 2. TEXTOS Y ESTADÍSTICAS ---
        scoreText = new FlxText(20, 20, 400, "SCORE: 0", 24);
        scoreText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        add(scoreText);

        missText = new FlxText(20, 60, 400, "MISSES: 0", 24);
        missText.setFormat("VCR OSD Mono", 24, FlxColor.RED, LEFT, OUTLINE, FlxColor.BLACK);
        add(missText);

        accuracyText = new FlxText(960, 20, 300, "ACCURACY: 100%", 20);
        accuracyText.setFormat("VCR OSD Mono", 20, FlxColor.GREEN, RIGHT, OUTLINE, FlxColor.BLACK);
        accuracyText.scrollFactor.set();
        add(accuracyText);

        // Instrucción en pantalla
        var infoText = new FlxText(0, 300, 1280, "PIBBY ENGINE - EVENTOS Y NOTETYPES ACTIVOS", 20);
        infoText.setFormat("VCR OSD Mono", 20, FlxColor.PURPLE, CENTER);
        add(infoText);

        // Añadir notas
        add(notes);

        // Controles táctiles
        virtualPad = new VirtualPad();
        add(virtualPad);

        // Generar notas de prueba iniciales con tipos especiales y eventos
        spawnTestNotes();
        triggerCustomEvent("PantallaOscura", "0");
    }

    private function spawnTestNotes():Void
    {
        // Nota normal
        notes.add(new Note(1000, 0, null, false, "Normal"));
        // Nota tipo especial (Ej: Nota Dañina / Preparación para Pibby)
        notes.add(new Note(1500, 1, null, false, "DamageNote"));
        notes.add(new Note(2000, 2, null, false, "Normal"));
        notes.add(new Note(2500, 3, null, false, "Normal"));
        totalNotesSpawned += 4;
    }

    // --- SISTEMA DE CUSTOM EVENTS INCLUIDOS ---
    public function triggerCustomEvent(eventName:String, value:String):Void
    {
        switch(eventName)
        {
            case "Cambiar Velocidad":
                trace("Evento ejecutado: Velocidad cambiada a " + value);
            case "PantallaOscura":
                FlxG.camera.flash(FlxColor.BLACK, 0.5);
                trace("Evento ejecutado: Efecto de oscuridad inicializado.");
            case "Activar Glitch":
                FlxG.camera.shake(0.01, 0.2);
                trace("Evento ejecutado: Glitch temporal activado.");
            default:
                trace("Evento desconocido: " + eventName);
        }
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        Conductor.songPosition += elapsed * 1000;

        if (health > 100) health = 100;
        if (health < 0) health = 0;

        if (health <= 0)
        {
            trace("GAME OVER ACTIVADO");
        }

        notes.forEachAlive(function(daNote:Note)
        {
            var speed:Float = 2.0;
            var targetY:Float = strumY;
            var timeDifference:Float = daNote.strumTime - Conductor.songPosition;
            
            var baseX:Float = 350 + (daNote.noteData * 110);
            daNote.x = baseX;
            daNote.y = targetY + (timeDifference * 0.45 * speed);

            // Si la nota pasa de largo sin tocarse
            if (timeDifference < -150 && !daNote.wasGoodHit)
            {
                misses++;
                missText.text = "MISSES: " + misses;
                health -= 10;
                updateAccuracy();
                
                daNote.kill();
                notes.remove(daNote, true);
                daNote.destroy();
            }
        });

        // Detección táctil de botones
        if (virtualPad.buttonLeft.justPressed) { checkHit(0); }
        if (virtualPad.buttonDown.justPressed) { checkHit(1); }
        if (virtualPad.buttonUp.justPressed) { checkHit(2); }
        if (virtualPad.buttonRight.justPressed) { checkHit(3); }
    }

    private function checkHit(direction:Int):Void
    {
        var foundNote:Bool = false;

        notes.forEachAlive(function(daNote:Note)
        {
            if (daNote.noteData == direction && !daNote.wasGoodHit)
            {
                var diff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
                
                if (diff < 166)
                {
                    daNote.wasGoodHit = true;
                    
                    // --- LÓGICA SEGÚN EL NOTE-TYPE ---
                    if (daNote.noteType == "DamageNote")
                    {
                        // Esta nota te quita vida en lugar de darte puntos (Ideal para las notas corruptas de Pibby)
                        health -= 15;
                        score -= 100;
                        FlxG.camera.flash(FlxColor.RED, 0.05);
                        triggerCustomEvent("Activar Glitch", "1");
                    }
                    else
                    {
                        // Nota normal
                        score += 350;
                        health += 2.5;
                        totalNotesHit++;
                        FlxG.camera.flash(FlxColor.WHITE, 0.03);
                    }
                    
                    scoreText.text = "SCORE: " + score;
                    updateAccuracy();
                    
                    daNote.kill();
                    notes.remove(daNote, true);
                    daNote.destroy();
                    foundNote = true;
                }
            }
        });

        if (!foundNote) {
            score += 100;
            scoreText.text = "SCORE: " + score;
            FlxG.camera.flash(FlxColor.WHITE, 0.05);
        }
    }

    private function updateAccuracy():Void
    {
        var totalPresses:Int = totalNotesHit + misses;
        if (totalPresses > 0)
        {
            var acc:Float = (totalNotesHit / totalPresses) * 100;
            accuracyText.text = "ACCURACY: " + Std.int(acc) + "%";
        }
    }
}
