module oswald.event;

import oswald.input;
import oswald.window;

alias KeyCallback           = bool function(OsWindow*, KeyCode, ButtonState);
alias MouseButtonCallback   = bool function(OsWindow*, MouseButton, ButtonState);

alias ScrollBack            = bool function(OsWindow*, int);
alias CursorMoveCallback    = bool function(OsWindow*, short, short);
alias CursorExitCallback    = bool function(OsWindow*);
alias CursorEnterCallback   = bool function(OsWindow*, short, short);

alias CloseCallback         = bool function(OsWindow*);
alias ResizeCallback        = bool function(OsWindow*, short, short);
alias DestroyCallback       = bool function(OsWindow*);

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

OsEventHandler global_event_handler = default_global_event_handler;

immutable default_global_event_handler = OsEventHandler(
    (window, key, state)          { return true; },
    (window, button, state)       { return true; },
    (window, scroll_amount)       { return true; },
    (window, cursor_x, cursor_y)  { return true; },
    (window)                      { return true; },
    (window, cursor_x, cursor_y)  { return true; },
    (window)                      { return true; },
    (window, width, height)       { return true; },
    (window)                      { return true; },
);
