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
    WindowCallbacks[num_slots] callbacks;

    /// The number of slots that are currently in use.
    size_t num_active;
    /// The number of times alloc() has been called.
    size_t num_allocated;
    /// The first entry in the free list.
    size_t first_free_slot = WindowID.max;

    @nogc bool is_valid(WindowHandle handle) {
        if (id_of(handle) > slots.length) return false;
        if (gen_of(handle) != gen_of(slots[id_of(handle)].handle)) return false;
        return true;
    }

    @nogc bool is_live(WindowHandle handle) { return is_valid(handle) && slots[id_of(handle)].platform_data !is null; }

    @nogc WindowHandle alloc() {
        const has_unused_slots = num_allocated < slots.length;
        const has_free_slots = first_free_slot < slots.length;

        scope (exit) num_allocated++;                           // alloc() has been called, record that

        if (has_unused_slots) {
            auto slot = &slots[num_allocated];
            slot.handle = make_handle(num_allocated, 0);
            num_active++;
            return slot.handle;
        }

        if (has_free_slots) {
            auto slot = &slots[first_free_slot];
            first_free_slot = slot.next_window;
            num_active++;
            return slot.handle;                         // ID is unchanged from prev. alloc(), and generation is handled by free()
        }
        
        return make_handle(WindowID.max, WindowID.max);
    }

    @nogc void free(WindowHandle handle) in (is_live(handle)) {
        auto window = &slots[id_of(handle)];

        window.handle = make_handle(id_of(window.handle), gen_of(window.handle) + 1);
        window.next_window = cast(WindowID) first_free_slot;
        first_free_slot = id_of(handle);

        callbacks[id_of(handle)] = WindowCallbacks();

        num_active--;
    }

    @nogc Window* get(WindowHandle handle) in (is_live(handle)) {
        return &slots[id_of(handle)];
    }

    @nogc WindowCallbacks* get_callbacks_for(WindowHandle handle) in (is_live(handle)) {
        return &callbacks[id_of(handle)];
    }
}

/// Extract the top 16-bytes of the value
@nogc WindowID id_of(WindowHandle handle) { return cast(WindowID) (handle.value >> 16); }
@nogc ushort gen_of(WindowHandle handle) { return cast(ushort) (handle.value & 0xFFFF); }

@nogc WindowHandle make_handle(size_t id, size_t gen) in (id <= WindowID.max) {
    auto handle = WindowHandle(cast(uint) id);
    handle.value <<= 16;
    handle.value |= gen;
    return handle;
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
