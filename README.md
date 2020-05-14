# OS Window Abstraction Library in D (OSWALD)

Oswald is a simple window abstraction library that is intended for cross-platform use. It is designed as a relatively low-level library, that other graphics or UI libraries can build off of. Oswald does not dynamically allocate memory, and returns error codes instead of throwing exceptions.

Oswald does not (and will not) support the creationg of graphics contexts, or other similar tasks. For a library that creates and manages graphics contexts, please direct yourself to GLFW (glfw.org), SDL (libsdl.org), or SFML (sfml-dev.org). Note that none of these libraries are compatible with Oswald. If you would like to use Oswald, you'll have to roll your own graphics initialization code. It remains a possibility that a companion library will be created, but there are no guarantees.

Unfortunately, source documentation in Oswald is a bit scarce, but is being actively improved.

**This library is being improved as I see the need for my own projects. If there is any feature that you would like to see, please do let me know!**

## Usage

For a quick rundown of what you can do, `sandbox.d` is a good place to get started. You can also clone the repository yourself and play around with sandbox.d. Run it with `dub sandbox.d`.

If you want to use Oswald in your own project, the directions are as follows:

1. Add Oswald to your project. If you're using dub, type `dub add oswald` into a console pointed at your project directory to do so automatically.
2. Import Oswald into a module in your project with `import oswald`.
3. Call `create_window(config)` to create a window. It will return a handle to a window to use for all subsequent calls.
   - You can set up your event handler callbacks by instantiating a copy of OsEventHandler and filling it in. Any callbacks left empty will be directed to the global event handler (it does nothing by default).
4. When you are ready to process input call `poll_input()` or `wait_input()`. Per-window variants of these functions also exist.
5. Once you are done with a window, call `close_window(handle)` to send out a close request to be handled by your callbacks, or `destroy_window(handle)` to destroy a window directly.

## Handling Events

Oswald provides a 2-tiered method for handling events, a global event handler, and a select event handler. When you create a window, or at any time while it is active, you can change its event handler or one of its callbacks. To do so, call `get_event_handler(handle)`, make any changes you need, then call `set_event_handler(handle, event_handler)`.

Optionally, if you want to keep track of per-handler data, you can create a struct with an `OsEventHandler` as the first member. Set `WindowConfig.custom_event_handler` before you create the window or call `set_custom_event_handler(handle, event_handler)` after the fact. Note that **you are responsible for ensuring that this memory remains valid for as long as windows are using it**.

A similar process exists for the global event handler. The `set_global_event_handler(handler)`, `get_global_event_handler()`, and `set_custom_global_event_handler(handler*)` functions are defined to operate the same way that the per-window functions do.

## Known Issues

- There is currently no error handling of any kind except to crash.

## Platform Support

Currently, only windows is supported (and then, only to a limited degree). However, more platforms are planned.

- [x] Windows
- [ ] Linux
- [ ] macOS (OSX)
- [ ] Android
