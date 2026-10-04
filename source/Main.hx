package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
    var gameWidth:Int = 1280; // Ancho de pantalla base optimizado
    var gameHeight:Int = 720; // Alto de pantalla base
    var initialState:Class<flixel.FlxState> = PlayState; // Estado inicial del juego
    var zoom:Float = -1;
    var framerate:Int = 60; // 60 FPS estables para celular
    var skipSplash:Bool = true;
    var startFullscreen:Bool = false;

    public function new()
    {
        super();
        addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));
    }
}
