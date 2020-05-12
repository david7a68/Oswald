/+ dub.sdl:
    name "Sandbox"
    dependency "oswald" path="./"
+/
module sandbox;

import std.stdio;
import oswald.window;
import oswald.input;

void main() {
    auto event_handler = create_event_handler();

    OsWindow window;
    create_window(&window, WindowConfig("Hello", 1280, 720, true, &event_handler));

    while (!window.close_requested)
        window.wait_events();
    
    destroy(window);
}

OsEventHandler create_event_handler() {
    OsEventHandler event_handler;
    event_handler.on_key = (window, key, state) {
        writeln(key, ":", state);

        if (key == KeyCode.Escape)
            window.close();
        
        return true;
    };

    return event_handler;
}
