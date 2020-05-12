
import std.stdio;
import oswald.window;
import oswald.input;
import oswald.event;

void main() {
    OsEventHandler event_handler;
    event_handler.on_key = (window, key, state) {
        writeln(key, ":", state);

        if (key == KeyCode.Escape)
            window.close();
        
        return true;
    };

    event_handler.is_left_right_key_aware = true;

    OsWindow window;
    create_window(&window, WindowConfig("Hello", 1280, 720, true, &event_handler));

    window.set_cursor(CursorIcon.Pointer);

    while (!window.close_requested)
        window.wait_events();
    
    destroy(window);
}
