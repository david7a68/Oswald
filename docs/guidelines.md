# Raison d'etre (Why a new window library?)
- D does not have a low-level windowing library currently available.
- Oswald avoid dynamically allocating memory, unlike many other libraries.
- This was (and continues to be) a learning opportunity.

# Library Structure
- The library is split into two sections
    - Platform agnostic code is kept in the main `oswald` package.
    - The platform dependent code is kept in the `platform` subpackage.
- The `input` package holds everything input related. It was split from just a single module because of its size.

# Safety
- The public interface should be entirely @safe, @nogc, and nothrow.
- Destroying a platform window should also destroy the window object.
- A pointer to the window may be passed to the platform
    - [Conclusion]: Window state will be stored in the `OsWindow` structure, with a factory function to instantiate it.
    - [Reasoning]: Using a struct is the least common denomimnator, and would allow a user to create a class wrapper trivially. Oswald does not throw exceptions, but it would be trivial to create a wrapper class (or struct) that does. With the simplicity of the library's API, it is extremely easy to create a wrapper with custom functionality.

# Errors
- The entire library is nothrow
- Leaves two options for errors; global error values, and returning errors
    - Returning errors makes more sense
- Functions that can error out must return a Result.
    - This includes creating windows.

# Memory
- All memory allocations are managed by the window objects themselves.
- Wherever possible, static allocations are used.

# Input
Input in Oswald is handled through the use of an event loop, and a small set of callbacks. Each window is responsible for processing its own events.

The callbacks are divided into two categories:
 - Window callbacks
    - Window callbacks relate to the function and state of a window, such as hiding, resizing, etc.
 - Dynamic callbacks
    - Dynamic callbacks relate to user input, such as a key event, or mouse movement

Dynamic callbacks are things like keyboard and mouse input, which change rapidly and continuously throughout the window's lifetime.

# Concurrency and Thread Safety
Oswald is designed entirely as a serial program (not threaded), and makes no guarantees about its thread safety.