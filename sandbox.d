/+ dub.sdl:
    name "Sandbox"
    dependency "oswald" path="./"
+/
module sandbox;

import std.stdio;
import oswald;

void main() {
    auto event_handler = create_custom_event_handler();

    auto config = WindowConfig("Hello", 1280, 720, true);
    config.custom_event_handler = cast(OsEventHandler*) &event_handler;

    auto handle = create_window(config);

    while (!is_close_requested(handle))
        wait_events();

    writeln(event_handler.num_keys_pressed, " key events occured while the window was open.");

    destroy_window(handle);
}

auto create_custom_event_handler() {
    struct Handler {
        OsEventHandler event_handler;
        alias event_handler this;

        uint num_keys_pressed;
    }

    Handler event_handler;

    event_handler.on_key = (window, handler, key, state) {
        writeln(key, ":", state);

        if (key == KeyCode.Escape)
            window.close();

        (cast(Handler*) handler).num_keys_pressed++;

        return true;
    };

    return event_handler;
}
