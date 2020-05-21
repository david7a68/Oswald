/+ dub.sdl:
    name "Sandbox"
    dependency "oswald" path="./"
+/
module sandbox;

import std.stdio;
import oswald;

size_t num_keys_pressed;

void main() {
    auto callbacks = create_custom_callbacks();

    auto config = WindowConfig("Hello", 1280, 720, true);
    config.callbacks = &callbacks;
    config.client_data = &num_keys_pressed;

    auto handle = create_window(config);

    while (!is_close_requested(handle))
        wait_events();

    writeln(num_keys_pressed, " key events occured while the window was open.");

    destroy_window(handle);
}

auto create_custom_callbacks() {
    WindowCallbacks callbacks;

    callbacks.on_key = (window, key, state) {
        writeln(key, ":", state);

        if (key == KeyCode.Escape)
            window.close();

        (*(cast(size_t*) get_client_data(window)))++;
    };

    callbacks.on_cursor_move = (window, x, y) {
        writeln(x, ":", y);
    };

    return callbacks;
}
