/+ dub.sdl:
    name "Sandbox"
    dependency "oswald" path="./"
+/
module sandbox;

import std.stdio;
import oswald;

size_t num_keys_pressed;

void main() {
    auto event_handler = create_custom_event_handler();

    auto config = WindowConfig("Hello", 1280, 720, true);
    config.event_handler = cast(OsEventHandler*) &event_handler;
    config.client_data = &num_keys_pressed;

    auto handle = create_window(config);

    while (!is_close_requested(handle))
        wait_events();

    writeln(num_keys_pressed, " key events occured while the window was open.");

    destroy_window(handle);
}

auto create_custom_event_handler() {
    OsEventHandler event_handler;

    event_handler.on_key = (window, handler, key, state) {
        writeln(key, ":", state);

        if (key == KeyCode.Escape)
            window.close();

        (*(cast(size_t*) get_client_data(window)))++;

        return true;
    };

    event_handler.on_cursor_move = (window, handler, x, y) {
        writeln(x, ":", y);
        
        return true;
    };

    return event_handler;
}
