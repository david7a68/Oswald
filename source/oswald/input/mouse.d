module oswald.input.mouse;

import std.traits: EnumMembers;

/**
 * The mouse buttons supported by Oswald
 */
enum MouseButtons: ubyte
{
    Button_1    = 0,
    Button_2    = 1,
    Button_3    = 2,
    Button_4    = 3,
    Button_5    = 4,
    Button_6    = 5,
    Button_7    = 6,
    Button_8    = 7,

    Left        = Button_1,
    Right       = Button_2,
    Middle      = Button_3,
}

///The number of mouse buttons supported by Oswald
enum numSupportedMouseButtons = EnumMembers!(MouseButtons).length - 3;

enum MouseButtonState: ubyte
{
    Pressed,
    Held,
    Dragged,
    Released,
}

struct ClickModifiers
{
    import std.bitmanip: bitfields;

    mixin(bitfields!(
        bool, "control", 1,
        bool, "shift", 1,
        byte, "reserved", 6
    ));
}

struct MouseButton
{
    MouseButtonState state;
    MouseButtons button;
    ClickModifiers modifiers;

    bool isPressed() nothrow
    {
        return state == MouseButtonState.Pressed;
    }
}

struct Mouse
{
    short x, y;
    short lastX, lastY;
    MouseButton[numSupportedMouseButtons] buttons;

    //dfmt off
    const @property leftMouseButton() { return buttons[MouseButtons.Left]; }
    const @property rightMouseButton() { return buttons[MouseButtons.Right]; }
    const @property middleMouseButton() { return buttons[MouseButtons.Middle]; }
    //dfmt on
}

struct Cursor
{
    short x, y;
    short oldX, oldY;
}
