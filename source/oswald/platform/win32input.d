module oswald.platform.win32input;

import core.sys.windows.windows;
import oswald.input : Cursor;
import oswald.input : MouseButton, MouseButtons, MouseButtonState;
import oswald.input : Key, Keycodes, KeyState;
import oswald.input : WindowInput;
import oswald.window : OsWindow;
import oswald.platform.win32 : win32GetStatePointer;

/**
 * Processes window events.
 *
 * The windowProc is solely responsible for delegating events to their
 * appropriate handlers, and does minimal processing itself.
 */
extern (Windows) LRESULT windowProc(HWND hwnd, uint msg, WPARAM wp, LPARAM lp) nothrow
{
    import std.exception : assumeWontThrow;

    auto window = win32GetStatePointer(hwnd);

    if (window is null)
        return DefWindowProc(hwnd, msg, wp, lp);

    switch (msg)
    {
    case WM_KEYDOWN:
    case WM_SYSKEYDOWN:
    case WM_KEYUP:
    case WM_SYSKEYUP:
        Key key = win32ProcessKeyEvent(wp, lp);
        const isInvalidKey = key.keycode == Keycodes.Invalid;

        if (!isInvalidKey && window.input.keyCallback)
            assumeWontThrow(window.input.keyCallback(window, key));
        return 0;

    case WM_LBUTTONDOWN:
    case WM_LBUTTONUP:
    case WM_MBUTTONDOWN:
    case WM_MBUTTONUP:
    case WM_RBUTTONDOWN:
    case WM_RBUTTONUP:
    case WM_XBUTTONDOWN:
    case WM_XBUTTONUP:
        MouseButton button = win32ProcessMouseButton(msg, wp, lp);
        window.input.dispatch!"mouseButtonCallback"(window, button);
        return 0;

    case WM_MOUSELEAVE:
        window.cursorIsInWindow = false;
        window.input.dispatch!"cursorExitCallback"(window, *window.input.cursor);
        return 0;

    case WM_MOUSEMOVE:
        auto cursor = win32ProcessCursorMove(window.input, wp, lp);

        if (!window.cursorIsInWindow)
        {
            window.cursorIsInWindow = true;
            requestMouseTracking(hwnd);
            window.input.dispatch!"cursorEnterCallback"(window, cursor);
        }

        window.input.dispatch!"cursorMoveCallback"(window, cursor);
        return 0;

    case WM_MOUSEWHEEL:
        auto lines = win32ProcessScrollLines(window.input, wp, lp);
        window.input.dispatch!"scrollCallback"(window, lines);
        return 0;
    
    case WM_SIZE:
        win32ProcessSizeChange(window, wp, lp);
        window.dispatch!"resizeCallback"(window, window.width, window.height);
        return 0;

    case WM_CLOSE:
        window.isCloseRequested = true;
        return 0;

    case WM_DESTROY:
        assert(hwnd !is null);

        PostQuitMessage(0);
        return 0;

    default:
        return DefWindowProc(hwnd, msg, wp, lp);
    }
}

private:

static immutable keyTranslationTable = win32GenKeytranslationTable();

auto extractCursorPos(LPARAM lp) nothrow
{
    import std.typecons : tuple;

    union Splitter
    {
        LPARAM lp;
        struct
        {
            short x, y;
        }
    }

    const splitter = Splitter(lp);

    return tuple(splitter.x, splitter.y);
}

void requestMouseTracking(HWND hwnd) nothrow
{
    TRACKMOUSEEVENT tme;
    tme.cbSize = tme.sizeof;
    tme.dwFlags = TME_LEAVE | TME_HOVER;
    tme.hwndTrack = hwnd;
    tme.dwHoverTime = HOVER_DEFAULT;

    TrackMouseEvent(&tme);
}

Key win32ProcessKeyEvent(WPARAM wp, LPARAM lp) nothrow
{
    Keycodes getKeycode(WPARAM wp, LPARAM lp)
    {
        const isExtendedKey = (lp & 0x01000000);

        if (wp == VK_CONTROL)
            return isExtendedKey ? Keycodes.RightControl : Keycodes.LeftControl;
        return keyTranslationTable[wp];
    }

    Key key;
    key.keycode = getKeycode(wp, lp);
    key.state = ((lp >> 31) & 1) ? KeyState.Released : KeyState.Pressed;
    key.platformKeycode = wp;
    key.scancode = (lp >> 16) & 0x1ff;

    const wasPressed = (lp >> 30) & 1;
    const wasHeld = wasPressed && key.state == KeyState.Pressed;

    if (wasHeld)
        key.state = KeyState.Held;

    return key;
}

float win32ProcessScrollLines(ref WindowInput input, WPARAM wp, LPARAM lp) nothrow
{
    import oswald.platform : platformScrollLines;

    auto lines = GET_WHEEL_DELTA_WPARAM(wp);

    lines *= platformScrollLines;

    return lines / WHEEL_DELTA;
}

Cursor win32ProcessCursorMove(ref WindowInput input, WPARAM wp, LPARAM lp) nothrow
{
    void updateMouseButtons(ref WindowInput input, short x, short y)
    {
        auto mouse = input.mouse;
        foreach (ref button; mouse.buttons)
        {
            if (button.state == MouseButtonState.Pressed)
            {
                const cursorMoved = (mouse.x == x) && (mouse.y == y);
                if (cursorMoved)
                    button.state = MouseButtonState.Dragged;
                else
                    button.state = MouseButtonState.Held;
            }
        }
    }

    auto cursor = input.cursor;

    cursor.oldX = cursor.x;
    cursor.oldY = cursor.y;

    auto pos = lp.extractCursorPos();
    cursor.x = pos[0];
    cursor.y = pos[1];

    updateMouseButtons(input, cursor.x, cursor.y);
    input.mouse.lastX = cursor.oldX;
    input.mouse.lastY = cursor.oldY;

    return *cursor;
}

MouseButton win32ProcessMouseButton(uint msg, WPARAM wp, LPARAM lp) nothrow
{
    bool isButtonDown(uint msg)
    {
        switch (msg)
        {
        case WM_LBUTTONDOWN:
        case WM_RBUTTONDOWN:
        case WM_MBUTTONDOWN:
        case WM_XBUTTONDOWN:
            return true;
        default:
            return false;
        }
    }

    MouseButtons getButton(uint msg, WPARAM wp)
    {
        switch (msg)
        {
        case WM_LBUTTONDOWN:
        case WM_LBUTTONUP:
            return MouseButtons.Left;
        case WM_RBUTTONDOWN:
        case WM_RBUTTONUP:
            return MouseButtons.Right;
        case WM_MBUTTONDOWN:
        case WM_MBUTTONUP:
            return MouseButtons.Middle;
        default:
            return (LOWORD(wp) == XBUTTON1) ? MouseButtons.Button_4 : MouseButtons.Button_5;
        }
    }

    MouseButton button;
    button.button = getButton(msg, wp);

    button.state = isButtonDown(msg) ? MouseButtonState.Pressed : MouseButtonState.Released;

    return button;
}

void win32ProcessSizeChange(OsWindow* window, WPARAM wp, LPARAM lp) nothrow
{
    window._height = HIWORD(lp);
    window._width = LOWORD(lp);
}

/**
 Creates a translation table between win32 key messages and oswald keycodes.

 Keycodes are generated such that the index of the win32 key holds the
 oswald key code.
 */
Keycodes[] win32GenKeytranslationTable()
{
    auto result = new Keycodes[](256);
    result[] = Keycodes.Invalid;

    result[0x30] = Keycodes.Num_0;
    result[0x31] = Keycodes.Num_1;
    result[0x32] = Keycodes.Num_2;
    result[0x33] = Keycodes.Num_3;
    result[0x34] = Keycodes.Num_4;
    result[0x35] = Keycodes.Num_5;
    result[0x36] = Keycodes.Num_6;
    result[0x37] = Keycodes.Num_7;
    result[0x38] = Keycodes.Num_8;
    result[0x39] = Keycodes.Num_9;

    result[0x41] = Keycodes.A;
    result[0x42] = Keycodes.B;
    result[0x43] = Keycodes.C;
    result[0x44] = Keycodes.D;
    result[0x45] = Keycodes.E;
    result[0x46] = Keycodes.F;
    result[0x47] = Keycodes.G;
    result[0x48] = Keycodes.H;
    result[0x49] = Keycodes.I;
    result[0x4A] = Keycodes.J;
    result[0x4B] = Keycodes.K;
    result[0x4C] = Keycodes.L;
    result[0x4D] = Keycodes.M;
    result[0x4E] = Keycodes.N;
    result[0x4F] = Keycodes.O;
    result[0x50] = Keycodes.P;
    result[0x51] = Keycodes.Q;
    result[0x52] = Keycodes.R;
    result[0x53] = Keycodes.S;
    result[0x54] = Keycodes.T;
    result[0x55] = Keycodes.U;
    result[0x56] = Keycodes.V;
    result[0x57] = Keycodes.W;
    result[0x58] = Keycodes.X;
    result[0x59] = Keycodes.Y;
    result[0x5A] = Keycodes.Z;

    //Math
    result[VK_OEM_MINUS] = Keycodes.Minus;
    result[VK_OEM_PLUS] = Keycodes.Equal;

    //Brackets
    result[VK_OEM_4] = Keycodes.LeftBracket;
    result[VK_OEM_6] = Keycodes.RightBracket;

    //Grammatical Characters
    result[VK_OEM_5] = Keycodes.BackSlash;
    result[VK_OEM_1] = Keycodes.Semicolon;
    result[VK_OEM_7] = Keycodes.Apostrophe;
    result[VK_OEM_COMMA] = Keycodes.Comma;
    result[VK_OEM_PERIOD] = Keycodes.Period;
    result[VK_OEM_2] = Keycodes.Slash;
    result[VK_OEM_3] = Keycodes.GraveAccent;
    result[VK_SPACE] = Keycodes.Space;
    result[VK_SHIFT] = Keycodes.Shift;

    //Text Control Keys
    result[VK_BACK] = Keycodes.Backspace;
    result[VK_DELETE] = Keycodes.Delete;
    result[VK_INSERT] = Keycodes.Insert;
    result[VK_TAB] = Keycodes.Tab;
    result[VK_RETURN] = Keycodes.Enter;

    //Arrows
    result[VK_LEFT] = Keycodes.Left;
    result[VK_RIGHT] = Keycodes.Right;
    result[VK_UP] = Keycodes.Up;
    result[VK_DOWN] = Keycodes.Down;

    //Locks
    result[VK_CAPITAL] = Keycodes.CapsLock;
    result[VK_SCROLL] = Keycodes.ScrollLock;
    result[VK_NUMLOCK] = Keycodes.NumLock;

    //Auxiliary
    result[VK_SNAPSHOT] = Keycodes.PrintScreen;
    result[VK_MENU] = Keycodes.Menu;

    result[VK_PRIOR] = Keycodes.PageUp;
    result[VK_NEXT] = Keycodes.PageDown;
    result[VK_END] = Keycodes.End;
    result[VK_HOME] = Keycodes.Home;

    result[VK_ESCAPE] = Keycodes.Escape;
    result[VK_CONTROL] = Keycodes.Control;

    //Function Keys
    result[VK_F1] = Keycodes.F1;
    result[VK_F2] = Keycodes.F2;
    result[VK_F3] = Keycodes.F3;
    result[VK_F4] = Keycodes.F4;
    result[VK_F5] = Keycodes.F5;
    result[VK_F6] = Keycodes.F6;
    result[VK_F7] = Keycodes.F7;
    result[VK_F8] = Keycodes.F8;
    result[VK_F9] = Keycodes.F9;
    result[VK_F10] = Keycodes.F10;
    result[VK_F11] = Keycodes.F11;
    result[VK_F12] = Keycodes.F12;
    result[VK_F13] = Keycodes.F13;
    result[VK_F14] = Keycodes.F14;
    result[VK_F15] = Keycodes.F15;
    result[VK_F16] = Keycodes.F16;
    result[VK_F17] = Keycodes.F17;
    result[VK_F18] = Keycodes.F18;
    result[VK_F19] = Keycodes.F19;
    result[VK_F20] = Keycodes.F20;
    result[VK_F21] = Keycodes.F21;
    result[VK_F22] = Keycodes.F22;
    result[VK_F23] = Keycodes.F23;
    result[VK_F24] = Keycodes.F24;

    //Keypad
    result[VK_NUMPAD0] = Keycodes.Keypad_0;
    result[VK_NUMPAD1] = Keycodes.Keypad_1;
    result[VK_NUMPAD2] = Keycodes.Keypad_2;
    result[VK_NUMPAD3] = Keycodes.Keypad_3;
    result[VK_NUMPAD4] = Keycodes.Keypad_4;
    result[VK_NUMPAD5] = Keycodes.Keypad_5;
    result[VK_NUMPAD6] = Keycodes.Keypad_6;
    result[VK_NUMPAD7] = Keycodes.Keypad_7;
    result[VK_NUMPAD8] = Keycodes.Keypad_8;
    result[VK_NUMPAD9] = Keycodes.Keypad_9;

    result[VK_ADD] = Keycodes.Keypad_Add;
    result[VK_SUBTRACT] = Keycodes.Keypad_Subtract;
    result[VK_MULTIPLY] = Keycodes.Keypad_Multiply;
    result[VK_DIVIDE] = Keycodes.Keypad_Divide;
    result[VK_SEPARATOR] = Keycodes.Keypad_Enter;

    //Positional Keys
    result[VK_LSHIFT] = Keycodes.LeftShift;
    result[VK_LCONTROL] = Keycodes.LeftControl;
    result[VK_LMENU] = Keycodes.LeftAlt;
    result[VK_LWIN] = Keycodes.LeftSuper;

    result[VK_RSHIFT] = Keycodes.RightShift;
    result[VK_RCONTROL] = Keycodes.RightControl;
    result[VK_RMENU] = Keycodes.RightAlt;
    result[VK_RWIN] = Keycodes.RightSuper;

    return result;
}
