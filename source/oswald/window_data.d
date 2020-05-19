module oswald.window_data;

package:

import oswald.types;

enum invalid_slot_id = WindowID.max;

WindowAllocator!max_open_windows windows;

struct Window {
    void* platform_data;
    void* client_data;

    WindowHandle handle;
    WindowID next_window = WindowID.max;

    CursorIcon cursor_icon;
    bool has_cursor;
    bool close_requested;
}

/**
Manages the allocation of memory for windows and their associated data.
*/
struct WindowAllocator(size_t num_slots) {
    Window[num_slots] slots;
    OsEventHandler[num_slots] handlers;

    /// The number of slots that are currently in use.
    size_t num_active;
    /// The number of times alloc() has been called.
    size_t num_allocated;
    /// The first entry in the free list.
    size_t first_free_slot = WindowID.max;

    @nogc bool is_valid(WindowHandle handle) {
        if (handle.id > slots.length) return false;
        if (handle.generation != slots[handle.id].handle.generation) return false;
        return true;
    }

    @nogc bool is_live(WindowHandle handle) { return is_valid(handle) && slots[handle.id].platform_data !is null; }

    @nogc WindowHandle alloc() {
        const has_unused_slots = num_allocated < slots.length;
        const has_free_slots = first_free_slot < slots.length;

        scope (exit) num_allocated++;                           // alloc() has been called, record that

        if (has_unused_slots) {
            auto slot = &slots[num_allocated];
            slot.handle.id = cast(WindowID) num_allocated;      // we leave generation = 0
            num_active++;
            return slot.handle;
        }

        if (has_free_slots) {
            auto slot = &slots[first_free_slot];
            first_free_slot = slot.next_window;
            num_active++;
            return slot.handle;                                 // ID is unchanged from prev. alloc(), and generation is handled by free()
        }
        
        return WindowHandle(WindowID.max, WindowID.max);
    }

    @nogc void free(WindowHandle handle) {
        auto window = &slots[handle.id];

        const current_generation = window.handle.generation;
        window.handle.generation = cast(ushort) (current_generation + 1);
        window.next_window = cast(WindowID) first_free_slot;
        first_free_slot = handle.id;

        handlers[handle.id] = OsEventHandler();

        num_active--;
    }

    @nogc Window* get(WindowHandle handle) {
        if (handle.id > slots.length)
            return null;

        auto window = &slots[handle.id];

        if (handle.generation != window.handle.generation)
            return null;

        return window;
    }

    @nogc OsEventHandler* get_handler_for(WindowHandle handle) {
        if (!is_valid(handle)) return null;

        return &handlers[handle.id];
    }
}

unittest {
    WindowAllocator!2 alloc;

    const h1 = alloc.alloc();
    assert(h1 == WindowHandle(0, 0));
    assert(alloc.is_valid(h1));
    assert(alloc.get(h1) == &alloc.slots[0]);

    const h2 = alloc.alloc();
    assert(h2 == WindowHandle(1, 0));
    assert(alloc.is_valid(h2));
    assert(alloc.get(h2) == &alloc.slots[1]);

    alloc.free(h2);

    const h3 = alloc.alloc();
    assert(h3 == WindowHandle(1, 1));
    assert(alloc.is_valid(h3));
    assert(alloc.get(h3) == &alloc.slots[1]);

    const h4 = alloc.alloc();
    assert(h4 == WindowHandle(WindowID.max, WindowID.max));
    assert(!alloc.is_valid(h4));
    assert(alloc.get(h4) is null);
}
