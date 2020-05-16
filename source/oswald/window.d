module oswald.window;

import oswald.types;
import oswald.window_data: windows, event_handlers;
import oswald.platform;

WindowHandle create_window(WindowConfig config) {
    auto handle = windows.alloc();

    if (!windows.is_valid(handle))
        assert(false);

    auto window = windows.get(handle);

    if (config.custom_event_handler) {
        window.event_handler = config.custom_event_handler;
    }
    else {
        event_handlers[handle.id] = *config.event_handler;
        window.event_handler = &event_handlers[handle.id];
    }

    platform_create_window(config, window);

    return handle;
}

void destroy_window(WindowHandle handle) {
    auto window = windows.get(handle);

    if (window is null)
        return;

    platform_destroy_window(window.platform_data);
    windows.free(handle);
}

bool has_cursor(WindowHandle handle) {
    return windows.get(handle).has_cursor;
}

bool is_close_requested(WindowHandle handle) {
    return windows.get(handle).close_requested;
}

void set_client_data(WindowHandle handle, void* data) {
    windows.get(handle).client_data = data;
}

void set_event_handler(WindowHandle handle, OsEventHandler* event_handler) {
    event_handlers[handle.id] = *event_handler;
    windows.get(handle).event_handler = &event_handlers[handle.id];
}

void set_custom_event_handler(WindowHandle handle, OsEventHandler* custom_event_handler) {
    windows.get(handle).event_handler = custom_event_handler;
}

OsEventHandler get_event_handler(WindowHandle handle) {
    if (windows.get(handle).event_handler != &event_handlers[handle.id])
        return OsEventHandler();
    return event_handlers[handle.id];
}

void close(WindowHandle handle) {
    platform_close_window(windows.get(handle).platform_data);
}

void retitle(WindowHandle handle, const char[] new_title) {
    platform_retitle_window(windows.get(handle).platform_data, new_title);
}

void resize(WindowHandle handle, short width, short height) {
    platform_resize_window(windows.get(handle).platform_data, width, height);
}

void set_mode(WindowHandle handle, WindowMode new_mode) {
    platform_set_window_mode(windows.get(handle).platform_data, new_mode);
}

void set_cursor(WindowHandle handle, CursorIcon icon) {
    auto window = windows.get(handle);
    platform_set_window_cursor(window.platform_data, icon);
    window.cursor_icon = icon;
}

/**
Poll the operating system for events pertaining to this particular window.
*/
void poll_events(WindowHandle handle) {
    platform_poll_events(windows.get(handle).platform_data);
}

/**
Poll the operating system for any unprocessed input events and process all of
them.
*/
void poll_events() {
    platform_poll_events();
}

/**
Waits until the selected window produces input events, then process input events
until they have all been processed.
*/
void wait_events(WindowHandle handle) {
    platform_wait_events(windows.get(handle).platform_data);
}

/**
Wait until any window receives and input event, then process input events until
they have all been processed.
*/
void wait_events() {
    platform_wait_events();
}

version (Windows) {
    import core.sys.windows.windows: HWND;

    HWND get_hwnd(WindowHandle handle) {
        if (auto window = windows.get(handle))
            return window.platform_data;
        return null;
    }
}

void set_global_event_handler(OsEventHandler* event_handler) {
    global_event_handler_storage = *event_handler;
    global_event_handler = &global_event_handler_storage;
}

/// Returns the callbacks in the global event handler. If you set a custom event
/// handler, this function will return a copy of the default event handler.
OsEventHandler get_global_event_handler() {
    if (global_event_handler != &global_event_handler_storage)
        return default_handler;
    return global_event_handler_storage;
}

/// Cause all events not handled by a window event handler to be handled by a
/// custom event handler. Make sure that this event handler remains in memory
/// as long as it is in use.
void set_custom_global_event_handler(OsEventHandler* custom_event_handler) {
    global_event_handler = custom_event_handler;
}

/// Reset the global event handler callbacks to their defaults. This will
/// override any custom event handler you have set.
void reset_global_event_handler() {
    global_event_handler_storage = default_handler;
    global_event_handler = &global_event_handler_storage;
}

package:

OsEventHandler* global_event_handler;

static this() {
    global_event_handler = &global_event_handler_storage;
}

OsEventHandler global_event_handler_storage = default_handler;

immutable default_handler = OsEventHandler(
    (window, handler, key, state)          { return true; },
    (window, handler, button, state)       { return true; },
    (window, handler, scroll_amount)       { return true; },
    (window, handler, cursor_x, cursor_y)  { return true; },
    (window, handler)                      { return true; },
    (window, handler, cursor_x, cursor_y)  { return true; },
    (window, handler)                      { return true; },
    (window, handler, width, height)       { return true; },
    (window, handler)                      { return true; },
);
