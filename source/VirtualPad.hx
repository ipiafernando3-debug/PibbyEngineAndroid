package;

import flixel.FlxG;
import flixel.group.FlxTypedGroup;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class VirtualPad extends FlxTypedGroup<FlxButton>
{
    public var buttonLeft:FlxButton;
    public var buttonDown:FlxButton;
    public var buttonUp:FlxButton;
    public var buttonRight:FlxButton;

    public function new()
    {
        super();

        // Distribución horizontal de los 4 botones en la parte inferior de la pantalla (1280x720)
        // Izquierda
        buttonLeft = createButton(150, 500, "LEFT");
        // Abajo
        buttonDown = createButton(380, 500, "DOWN");
        // Arriba
        buttonUp = createButton(740, 500, "UP");
        // Derecha
        buttonRight = createButton(970, 500, "RIGHT");

        add(buttonLeft);
        add(buttonDown);
        add(buttonUp);
        add(buttonRight);
    }

    private function createButton(X:Float, Y:Float, Label:String):FlxButton
    {
        // Creamos un botón táctil con gráfico generado por código para evitar errores si falta la imagen
        var button = new FlxButton(X, Y);
        button.makeGraphic(160, 160, FlxColor.WHITE);
        button.alpha = 0.35; // Semitransparente para ver el juego detrás
        button.scrollFactor.set();
        return button;
    }
}
