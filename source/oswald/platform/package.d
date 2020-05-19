module oswald.platform;

version (Windows) {
    import oswald.platform.win32;

    alias platform_create_window = win32_create_window;
    alias platform_destroy_window = win32_destroy_window;
    alias platform_close_window = win32_close_window;
    alias platform_set_window_mode = win32_set_window_mode;
    alias platform_resize_window = win32_resize_window;
    alias platform_retitle_window = win32_retitle_window;
    alias platform_set_window_cursor = win32_set_window_cursor;
    alias platform_poll_events = win32_poll_events;
    alias platform_wait_events = win32_wait_events;
}
