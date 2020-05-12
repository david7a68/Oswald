module oswald.window;

// support both per-window input processing and global input processing

import oswald.event: OsEventHandler;
import oswald.platform;

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
    OsEventHandler* event_handler;
    void* client_data;
}

/**
OsWindow provides an API for managing a single operating system window.
*/
struct OsWindow {
    void* platform_data;
    CursorIcon cursor_icon;
    bool has_cursor;
    bool close_requested;

    void* client_data;
    OsEventHandler* event_handler;

    ~this() {
        platform_destroy_window(platform_data);
    }

    void close() {
        platform_close_window(platform_data);
    }

    void retitle(const char[] new_title) {
        platform_retitle_window(platform_data, new_title);
    }

    void resize(short width, short height) {
        platform_resize_window(platform_data, width, height);
    }

    void set_mode(WindowMode new_mode) {
        platform_set_window_mode(platform_data, new_mode);
    }

    void set_cursor(CursorIcon icon) {
        platform_set_window_cursor(platform_data, icon);
        cursor_icon = icon;
    }

    /**
    Poll the operating system for events pertaining to this particular window.
    */
    void poll_events() {
        platform_poll_events(platform_data);
    }

    /**
    Waits until the selected window produces input events, then process input events
    until they have all been processed.
    */
    void wait_events() {
        platform_wait_events(platform_data);
    }
}

/**
Create a new window and store its state in the offered location.
*/
void create_window(OsWindow* window, WindowConfig config) {
    auto hwnd = platform_create_window(config, window);
    window.platform_data = hwnd;
    window.client_data = config.client_data;
    window.event_handler = config.event_handler;
    window.cursor_icon = CursorIcon.Pointer;
}

/**
Poll the operating system for any unprocessed input events and processed all of
them.
*/
void poll_events() {
    platform_poll_events();
}

/**
Wait until any window receives and input event, then process input events until
they have all been processed.
*/
void wait_events() {
    platform_wait_events();
}
