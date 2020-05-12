/**
`Oswald.event` holds the OsEventHandler struct and its associated callbacks as
well as the global window event handler.

By default, every window you create will send events to the global window event
handler. You can override the event callbacks as you like on a per-window basis
or replace the callbacks in the global event handler. This may occur at any time
while the application is running, and will take effect the next time input is
processed with the poll_events() or wait_events() functions are called.

Additional data may be attached to an event handler by creating a struct with
the handler as the first member, followed by other data. Set the event handler,
then reinterpret the event handler passed into the event callbacks as your type.

For example:
```
struct Handler {
    OsEventHandler events;
    alias events this;

    uint num_key_events;
}

global_event_handler.on_key = (window, handler, key, state) {
    (cast(Handler*) handler).num_key_events++;
}
```
*/
module oswald.event;

import oswald.input;
import oswald.window;

/// Window event callback. Return true if the event has been consumed, false to
/// pass the event on to the global event handler.
alias KeyCallback           = bool function(OsWindow*, OsEventHandler*, KeyCode, ButtonState);
/// ditto
alias MouseButtonCallback   = bool function(OsWindow*, OsEventHandler*, MouseButton, ButtonState);
/// ditto
alias ScrollBack            = bool function(OsWindow*, OsEventHandler*, int);
/// ditto
alias CursorMoveCallback    = bool function(OsWindow*, OsEventHandler*, short, short);
/// ditto
alias CursorExitCallback    = bool function(OsWindow*, OsEventHandler*);
/// ditto
alias CursorEnterCallback   = bool function(OsWindow*, OsEventHandler*, short, short);
/// ditto
alias CloseCallback         = bool function(OsWindow*, OsEventHandler*);
/// ditto
alias ResizeCallback        = bool function(OsWindow*, OsEventHandler*, short, short);
/// ditto
alias DestroyCallback       = bool function(OsWindow*, OsEventHandler*);

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

    /// Set this flag to true if left/right distinctions for keys such as
    /// Control and Shift are desired. The undirected KeyCode.Control and
    /// KeyCode.Shift will not be sent.
    bool is_left_right_key_aware;
}

OsEventHandler* global_event_handler;

/// Reset the global event handler callbacks to their defaults.
void reset_global_event_handler() {
    default_global_event_handler = gen_default_event_handler();
    global_event_handler = &default_global_event_handler;
}

private:

static this() {
    global_event_handler = &default_global_event_handler;
}

OsEventHandler default_global_event_handler = gen_default_event_handler();

OsEventHandler gen_default_event_handler() nothrow {
    return OsEventHandler(
        (window, events, key, state)          { return true; },
        (window, events, button, state)       { return true; },
        (window, events, scroll_amount)       { return true; },
        (window, events, cursor_x, cursor_y)  { return true; },
        (window, events)                      { return true; },
        (window, events, cursor_x, cursor_y)  { return true; },
        (window, events)                      { return true; },
        (window, events, width, height)       { return true; },
        (window, events)                      { return true; },
    );
}
