module oswald.types;

alias WindowID = ushort;

enum max_open_windows = 64;

///
enum CursorIcon : ubyte {
    /// ⭦
    Pointer,
    /// ⌛
    Wait,
    /// Ꮖ
    IBeam,
    /// ⭤
    ResizeHorizontal,
    /// ⭥
    ResizeVertical,
    /// ⤡
    ResizeNorthwestSoutheast,
    /// ⤢
    ResizeCornerNortheastSouthwest,
    /// 
    UserDefined1 = 128,
    /// 
    UserDefined2,
    /// 
    UserDefined3,
    /// 
    UserDefined4
}

enum WindowMode : ubyte {
    Windowed,
    Maximized,
    Minimized,
    Hidden
}

struct WindowConfig {
    const char[] title;
    short width, height;
    bool resizable;

    /// User-specific data. Set this to whatever you want. It will be accessible
    /// from within an event callback through the get_client_data(handle)
    /// function.
    void* client_data;
    
    /// The event handler to be used by this window. If you don't want to handle
    /// any event, leave the callback null. If you don't want to handle any
    /// events at all leave the handler auto initialized. They will be forwarded
    /// to the global event handler.
    OsEventHandler* event_handler;
}

struct WindowHandle {
    WindowID id;
    ushort generation;
}

/// Window event callback. Return true if the event has been consumed, false to
/// pass the event on to the global event handler.
alias KeyCallback           = bool function(WindowHandle, KeyCode, ButtonState);
/// ditto
alias MouseButtonCallback   = bool function(WindowHandle, MouseButton, ButtonState);
/// ditto
alias ScrollBack            = bool function(WindowHandle, int);
/// ditto
alias CursorMoveCallback    = bool function(WindowHandle, short, short);
/// ditto
alias CursorExitCallback    = bool function(WindowHandle);
/// ditto
alias CursorEnterCallback   = bool function(WindowHandle, short, short);
/// ditto
alias CloseCallback         = bool function(WindowHandle);
/// ditto
alias ResizeCallback        = bool function(WindowHandle, short, short);
/// ditto
alias DestroyCallback       = bool function(WindowHandle);

struct OsEventHandler {
    KeyCallback             on_key;
    MouseButtonCallback     on_mouse_button;

    ScrollBack              on_scroll;
    CursorMoveCallback      on_cursor_move;
    CursorExitCallback      on_cursor_exit;
    CursorEnterCallback     on_cursor_enter;

    CloseCallback           on_close_request;
    ResizeCallback          on_window_resize;
    DestroyCallback         on_window_close;
}

enum ButtonState : ubyte {
    Released,
    Pressed,
    Held
}

enum MouseButton : ubyte {
    Left,
    Right,
    Middle,
    Button_4,
    Button_5
}

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
 */
enum KeyCode : ubyte {
    Invalid         = 0,

    //Standard Digits
    Num_0           = 10,
    Num_1           = 11,
    Num_2           = 12,
    Num_3           = 13,
    Num_4           = 14,
    Num_5           = 15,
    Num_6           = 16,
    Num_7           = 17,
    Num_8           = 18,
    Num_9           = 19,

    //26 Letters
    A               = 20,
    B               = 21,
    C               = 22,
    D               = 23,
    E               = 24,
    F               = 25,
    G               = 26,
    H               = 27,
    I               = 28,
    J               = 29,
    K               = 30,
    L               = 31,
    M               = 32,
    N               = 33,
    O               = 34,
    P               = 35,
    Q               = 36,
    R               = 37,
    S               = 38,
    T               = 39,
    U               = 40,
    V               = 41,
    W               = 42,
    X               = 43,
    Y               = 44,
    Z               = 45,

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
    Backspace       = 62,
    Delete          = 63,
    Insert          = 64,
    Tab             = 65,
    Enter           = 66,
    Shift           = 67,

    //Arrows
    Left            = 71,
    Right           = 72,
    Up              = 73,
    Down            = 74,

    //Locks
    CapsLock        = 75,
    ScrollLock      = 76,
    NumLock         = 77,

    //Auxiliary
    PrintScreen     = 80,
    Alt             = 81,

    PageUp          = 82,
    PageDown        = 83,
    End             = 84,
    Home            = 85,

    Escape          = 86,
    Control         = 87,
    Super           = 88,

    //Function Keys
    F1              = 90,
    F2              = 91,
    F3              = 92,
    F4              = 93,
    F5              = 94,
    F6              = 95,
    F7              = 96,
    F8              = 97,
    F9              = 98,
    F10             = 99,
    F11             = 100,
    F12             = 101,
    F13             = 102,
    F14             = 103,
    F15             = 104,
    F16             = 105,
    F17             = 106,
    F18             = 107,
    F19             = 108,
    F20             = 109,
    F21             = 110,
    F22             = 111,
    F23             = 112,
    F24             = 113,
    F25             = 114,

    //Keypad
    Keypad_0        = 120,
    Keypad_1        = 121,
    Keypad_2        = 122,
    Keypad_3        = 123,
    Keypad_4        = 124,
    Keypad_5        = 125,
    Keypad_6        = 126,
    Keypad_7        = 127,
    Keypad_8        = 128,
    Keypad_9        = 129,

    Keypad_Add      = 130,
    Keypad_Subtract = 131,
    Keypad_Multiply = 132,
    Keypad_Divide   = 133,
    Keypad_Decimal  = 134,
    Keypad_Enter    = 135,

    //Positional Keys
    LeftShift       = 140,
    LeftControl     = 141,
    LeftAlt         = 142,
    LeftSuper       = 143,

    RightShift      = 144,
    RightControl    = 145,
    RightAlt        = 146,
    RightSuper      = 147,

    KeyCodeTableSize
}
