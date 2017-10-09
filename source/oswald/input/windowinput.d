module oswald.input.windowinput;

import std.typecons : Flag;

import oswald.window : OsWindow;
import oswald.input : Cursor, MouseButton, Key, Keycodes, Mouse;
import oswald.input : numSupportedMouseButtons;

alias KeyCallback = void function(OsWindow* window, Key key);
alias ScrollCallback = void function(OsWindow* window, float scroll);
alias CursorMoveCallback = void function(OsWindow* window, Cursor cursor);
alias MouseButtonCallback = void function(OsWindow* window, MouseButton mouse);
alias CursorExitCallback = void function(OsWindow*, Cursor);
alias CursorEnterCallback = void function(OsWindow*, Cursor);

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
    
    package(oswald)
    void dispatch(string callback, Args...)(Args args) nothrow
    {
        import std.exception: assumeWontThrow;

        mixin("if (" ~ callback ~ ") assumeWontThrow(" ~ callback ~ " (args));");
    }

@safe @nogc nothrow:

    void process(Flag!"waitForEvents" waitForEvents)
    {
        platformProcessEvents(waitForEvents, _window.platformData);
    }

    nothrow @property
    {
        Key[] keys()
        {
            return _keys;
        }

        Mouse* mouse()
        {
            return &_mouse;
        }

        Cursor* cursor()
        {
            return &_cursor;
        }
    }

    KeyCallback keyCallback;

    CursorMoveCallback cursorMoveCallback;

    CursorExitCallback cursorExitCallback;

    CursorEnterCallback cursorEnterCallback;

    MouseButtonCallback mouseButtonCallback;

    ScrollCallback scrollCallback;

package(oswald):
    this(OsWindow* window)
    {
        _window = window;
    }

private:
    OsWindow* _window;

    Cursor _cursor;
    Mouse _mouse;
    Key[256] _keys;
}
