# OS Window Abstraction Library in D (OSWALD)

Oswald is a simple window abstraction library that is intended for cross-platform use. It is designed as a relatively low-level library, that other graphics or UI libraries can build off of. Oswald does not dynamically allocate memory, and returns error codes instead of throwing exceptions.

Oswald does not (and will not) support the creationg of graphics contexts, or other similar tasks. For a library that creates and manages graphics contexts, please direct yourself to GLFW (glfw.org), SDL (libsdl.org), or SFML (sfml-dev.org). Note that none of these libraries are compatible with Oswald. If you would like to use Oswald, you'll have to roll your own graphics initialization code. It remains a possibility that a companion library will be created, but there are no guarantees.

Please see the `examples` directory for how to use the library.

Unfortunately, source documentation in Oswald is a bit scarce, but is being actively improved.

###Note:

This library is being improved as I see the need for my own projects. If there is any feature that you would like to see, please do let me know!

##Features under consideration:

- [x] Object interface for windows
- [ ] Statically configurable error handling behavior

# Platform Support
Currently, only windows is supported (and then, only to a limited degree). However, more platforms are planned.

- [x] Windows
- [ ] Linux
- [ ] macOS (OSX)
- [ ] Android
