module oswald.input.windowinput;

import std.typecons : Flag;

import oswald.window : OsWindow;
import oswald.input : Cursor, MouseButton, Key, Keycodes;
import oswald.input : numSupportedMouseButtons;

alias KeyCallback = void function(OsWindow* window, Key key);
alias ScrollCallback = void function(OsWindow* window, float scroll);
alias CursorMoveCallback = void function(OsWindow* window, Cursor cursor);
alias MouseButtonCallback = void function(OsWindow* window, MouseButton mouse);

/**
 * `WindowInput` handles the processing of window-specific input.
 *
 * To update a window, call the `process` function of its
 * `WindowInput`.
 *
 * Input is handled through the use of event callbacks, which may be
 * set at any time through the `onEvent` members. If the callback is
 * `null`, the event will be ignored.
 */
struct WindowInput
{
    import oswald.window : OsWindow;
    import oswald.platform : platformProcessEvents;

@safe @nogc nothrow:

    void process(Flag!"waitEvents" waitEvents)
    {
        platformProcessEvents(waitEvents, _window.platformData);
    }

    @property Key[] keys()
    {
        return _keys;
    }

    KeyCallback keyCallback;

    CursorMoveCallback cursorCallback;

    MouseButtonCallback mouseButtonCallback;

    ScrollCallback scrollCallback;

package(oswald):
    this(OsWindow* window)
    {
        _window = window;
    }

    @property
    {
        ref Cursor cursor()
        {
            return _cursor;
        }

        MouseButton[] mouseButtons()
        {
            return _mouseButtons;
        }
    }
private:
    OsWindow* _window;

    Cursor _cursor;
    MouseButton[numSupportedMouseButtons] _mouseButtons;
    Key[256] _keys;
}
