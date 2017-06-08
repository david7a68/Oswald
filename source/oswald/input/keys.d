module oswald.input.keys;

import std.traits: EnumMembers;

/**
 * The platform-independent keycodes used by oswald.
 *
 * The delineation of the keycodes is largely for organization
 * purposes only, and to make any changes more bearable.
 *
 * The keys are organized according to the following rules:
 *     - Keys are assigned using the QWERTY keyboard layout
 *     - The first 100 keycodes are mapped to standard characters
 *         - Non-letter keys start at 50
 *     - Control keys and function keys follow in the 100+ key range
 *         - Function keys at 150+
 *     - Position-dependent keys are in the 200+ character range
 *         - These include numpad keys, as well as LCTRL/RCTRL
 *     - Numerical keys, are num_1, num_2, ...
 *     - Keys with positional information, such as LSHIFT/RSHIFT
 *       may be sent as Keycodes.SHIFT, or as Keycodes.LSHIFT.
 *       This option is selectable from the WindowInput struct.
 */
enum Keycodes: short
{
    Invalid         = -1,

    //Standard Digits
    Num_0           = 0,
    Num_1           = 1,
    Num_2           = 2,
    Num_3           = 3,
    Num_4           = 4,
    Num_5           = 5,
    Num_6           = 6,
    Num_7           = 7,
    Num_8           = 8,
    Num_9           = 9,

    //26 Letters
    A               = 10,
    B               = 11,
    C               = 12,
    D               = 13,
    E               = 14,
    F               = 15,
    G               = 16,
    H               = 17,
    I               = 18,
    J               = 19,
    K               = 20,
    L               = 21,
    M               = 22,
    N               = 23,
    O               = 24,
    P               = 25,
    Q               = 26,
    R               = 27,
    S               = 28,
    T               = 29,
    U               = 30,
    V               = 31,
    W               = 32,
    X               = 33,
    Y               = 34,
    Z               = 35,

    //Math
    Minus           = 50,
    Equal           = 51,

    //Brackets
    LeftBracket     = 52,
    RightBracket    = 53,

    //Grammatical Characters
    BackSlash       = 54,
    Semicolon       = 55,
    Apostrophe      = 56,
    Comma           = 57,
    Period          = 58,
    Slash           = 59,
    GraveAccent     = 60,
    Space           = 61,

    //Text Control Keys
    Backspace       = 100,
    Delete          = 101,
    Insert          = 102,
    Tab             = 103,
    Enter           = 104,
    Shift           = 105,

    //Arrows
    Left            = 106,
    Right           = 107,
    Up              = 108,
    Down            = 109,

    //Locks
    CapsLock        = 110,
    ScrollLock      = 111,
    NumLock         = 112,

    //Auxiliary
    PrintScreen     = 113,
    Menu            = 114,

    PageUp          = 115,
    PageDown        = 116,
    End             = 117,
    Home            = 118,

    Escape          = 119,
    Control         = 120,
    Alt             = 121,
    Super           = 122,

    //Function Keys
    F1              = 150,
    F2              = 151,
    F3              = 152,
    F4              = 153,
    F5              = 154,
    F6              = 155,
    F7              = 156,
    F8              = 157,
    F9              = 158,
    F10             = 159,
    F11             = 160,
    F12             = 161,
    F13             = 162,
    F14             = 163,
    F15             = 164,
    F16             = 165,
    F17             = 166,
    F18             = 167,
    F19             = 168,
    F20             = 169,
    F21             = 170,
    F22             = 171,
    F23             = 172,
    F24             = 173,
    F25             = 174,

    //Keypad
    Keypad_0        = 200,
    Keypad_1        = 201,
    Keypad_2        = 202,
    Keypad_3        = 203,
    Keypad_4        = 204,
    Keypad_5        = 205,
    Keypad_6        = 206,
    Keypad_7        = 207,
    Keypad_8        = 208,
    Keypad_9        = 209,

    Keypad_Add      = 210,
    Keypad_Subtract = 211,
    Keypad_Multiply = 212,
    Keypad_Divide   = 213,
    Keypad_Decimal  = 214,

    Keypad_Enter    = 215,

    //Positional Keys
    LeftShift       = 215,
    LeftControl     = 216,
    LeftAlt         = 217,
    LeftSuper       = 218,
    
    RightShift      = 219,
    RightControl    = 220,
    RightAlt        = 221,
    RightSuper      = 222,
}

///The number of keys supported by Oswald
enum numSupportedKeys = EnumMembers!(Keycodes).length;

enum KeyState: ubyte
{
    Pressed,
    Held,
    Released
}

struct Key
{
    Keycodes keycode;
    KeyState state;
    size_t platformKeycode;
    int scancode;

    @safe @nogc @property bool isPressed() const pure nothrow
    {
        return state == KeyState.Pressed;
    }
}
