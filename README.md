# OS Window Abstraction Library in D (OSWALD)

Oswald is a simple window abstraction library that is intended for cross-platform use. It is designed as a relatively low-level library, that other graphics or UI libraries can build off of.

Oswald does not (and will not) support the creationg of graphics contexts, or other similar tasks. For a library that creates and manages graphics contexts, please direct yourself to GLFW (glfw.org), SDL (libsdl.org), or SFML (sfml-dev.org).

Please see the `examples` directory for how to use the library.

Unfortunately, source documentation in Oswald is a bit scarce, but is being actively improved.

# Platform Support
Currently, only windows is supported (and then, only to a limited degree). However, more platforms are planned.

 [x] Windows
 [ ] Linux
 [ ] macOS (OSX)
 [ ] Android
