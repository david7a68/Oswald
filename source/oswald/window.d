module oswald.window;

import oswald.types;
import oswald.window_data: windows;
import oswald.platform;

WindowHandle create_window(WindowConfig config) {
    auto handle = windows.alloc();

    if (!windows.is_valid(handle))
        assert(false);

    auto handler_slot = windows.get_callbacks_for(handle);
    *handler_slot = *config.callbacks;

    auto window = windows.get(handle);
    window.client_data = config.client_data;
    platform_create_window(config, window);

    return handle;
}

void destroy_window(WindowHandle handle) in (is_live(handle)) {
    auto window = windows.get(handle);

    if (window is null)
        return;

    platform_destroy_window(window.platform_data);
    windows.free(handle);
}

@nogc bool has_cursor         (WindowHandle handle) { return windows.get(handle).has_cursor; }
@nogc bool is_close_requested (WindowHandle handle) { return windows.get(handle).close_requested; }
@nogc bool is_live            (WindowHandle handle) { return windows.is_live(handle); }

void set_client_data(WindowHandle handle, void* data) in (is_live(handle)) {
    windows.get(handle).client_data = data;
}

void* get_client_data(WindowHandle handle) in (is_live(handle)) {
    if (auto window = windows.get(handle))
        return window.client_data;
    return null;
}

void set_callbacks(WindowHandle handle, WindowCallbacks* callbacks) in (is_live(handle)) {
    *windows.get_callbacks_for(handle) = *callbacks;
}

WindowCallbacks get_callbacks(WindowHandle handle) in (is_live(handle)) {
    return *windows.get_callbacks_for(handle);
}

void request_close(WindowHandle handle) in (is_live(handle)) {
    platform_close_window(windows.get(handle).platform_data);
}

void reset_close_request(WindowHandle handle) in (is_live(handle)) {
    windows.get(handle).close_requested = false;
}

void retitle(WindowHandle handle, const char[] new_title) in (is_live(handle)) {
    platform_retitle_window(windows.get(handle).platform_data, new_title);
}

void resize(WindowHandle handle, short width, short height) in (is_live(handle)) {
    platform_resize_window(windows.get(handle).platform_data, width, height);
}

void set_mode(WindowHandle handle, WindowMode new_mode) in (is_live(handle)) {
    platform_set_window_mode(windows.get(handle).platform_data, new_mode);
}

void set_cursor(WindowHandle handle, CursorIcon icon) in (is_live(handle)) {
    auto window = windows.get(handle);
    platform_set_window_cursor(window.platform_data, icon);
    window.cursor_icon = icon;
}

/**
Poll the operating system for events pertaining to this particular window.
*/
void poll_events(WindowHandle handle) in (is_live(handle)) {
    platform_poll_events(windows.get(handle).platform_data);
}

/**
Poll the operating system for any unprocessed input events and process all of
them.
*/
void poll_events() { platform_poll_events(); }

/**
Waits until the selected window produces input events, then process input events
until they have all been processed.
*/
void wait_events(WindowHandle handle) in (is_live(handle)) {
    platform_wait_events(windows.get(handle).platform_data);
}

/**
Wait until any window receives and input event, then process input events until
they have all been processed.
*/
void wait_events() { platform_wait_events(); }

version (Windows) {
    import core.sys.windows.windows: HWND;

    @nogc HWND get_hwnd(WindowHandle handle) in (is_live(handle)) {
        if (auto window = windows.get(handle))
            return window.platform_data;
        return null;
    }
}
