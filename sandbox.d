/+ dub.sdl:
    name "Sandbox"
    dependency "oswald" path="./"
+/
module sandbox;

import std.stdio;
import oswald.window;
import oswald.input;
import oswald.event;

void main() {
    auto event_handler = create_event_handler();

    OsWindow window;
    create_window(&window, WindowConfig("Hello", 1280, 720, true, cast(OsEventHandler*) &event_handler));

    while (!window.close_requested)
        window.wait_events();

    writeln(event_handler.num_keys_pressed, " key events occured while the window was open.");

    destroy(window);
}

auto create_event_handler() {
    struct Handler {
        OsEventHandler event_handler;
        alias event_handler this;

        uint num_keys_pressed;
    }

    Handler event_handler;
    event_handler.is_left_right_key_aware = true;

    event_handler.on_key = (window, handler, key, state) {
        writeln(key, ":", state);

        if (key == KeyCode.Escape)
            window.close();
        
        (cast(Handler*) handler).num_keys_pressed++;

        return true;
    };

    return event_handler;
}
