module oswald.window;

import oswald.errors : WindowError;

enum maxTitleLength = 1024;

alias WindowResizeCallback = void function(OsWindow*, short, short);
alias WindowDrawCallback = void function(OsWindow*);

struct WindowConfig
{
    string title;

    ushort width;
    ushort height;
    bool hidden;
    bool resizeable = true;
}

struct OsWindow
{
    import oswald.platform;
    import oswald.input : WindowInput;

    package(oswald)
    void dispatch(string callback, Args...)(Args args) nothrow
    {
        import std.exception: assumeWontThrow;

        mixin("if (" ~ callback ~ ") assumeWontThrow(" ~ callback ~ " (args));");
    }

@safe @nogc nothrow:
    static WindowError createNew(WindowConfig config, OsWindow* destination)
    {
        auto error = platformCreateWindow(config, destination._platformData, destination);
        destination.input = WindowInput(destination);
        return error;
    }

    ~this()
    {
        platformDestroyWindow(_platformData);
    }

    //dfmt off
    @property
    {
        /**
        * `true` if a request to close the window was made, `false`
        * otherwise.
        */
        bool isCloseRequested() const { return _isCloseRequested; }

        bool cursorIsInWindow() const { return _cursorIsInWindow; }

        ///Platform specific information about the window
        inout(PlatformWindowData) platformData() inout { return _platformData; }

        ///The input processor
        ref WindowInput input() { return _input; }

        ///Sets the title to `newTitle`
        void title(string newTitle) { platformSetTitle(_platformData, newTitle); }

        ///User defined information that will be available
        ///to any callbacks originating from the window.
        void* userData() { return _userData; }

        ///Ditto
        void userData(void* userData) { _userData = userData; }

        ///Ditto
        @trusted void userData(T)(T t) if (is(T == class)) { _userData = cast(void*) t; }

        ///The width of the window
        const ushort width() { return _width; }

        ///The height of the window
        const ushort height() { return _height; }
    }

    version (Windows) alias win32 = platformData;

    void close()
    {
        platformCloseWindow(_platformData);
    }

    void show()
    {
        platformShowWindow(_platformData);
    }

    void hide()
    {
        platformHideWindow(_platformData);
    }

    void resize(ushort newWidth, ushort newHeight)
    {
        platformResizeWindow(_platformData, newWidth, newHeight);
    }

    WindowResizeCallback resizeCallback;
    WindowDrawCallback drawCallback;

package(oswald):

    @property void isCloseRequested(bool icr)
    {
        _isCloseRequested = icr;
    }

    @property void cursorIsInWindow(bool ciin)
    {
        _cursorIsInWindow = ciin;
    }

    ushort _width;
    ushort _height;

private:
    PlatformWindowData _platformData;
    WindowInput _input;

    void* _userData;
    bool _isCloseRequested;
    bool _cursorIsInWindow;
}

class Window
{
    import oswald.platform: PlatformWindowData;
    import oswald.input: WindowInput;

public:
    this(WindowConfig cfg)
    {
        const err = OsWindow.createNew(cfg, &_window);

        if (err)
            assert(false, "Oswald was unable to create a window.");
    }

    //dfmt off
    @property
    {
        /**
        * `true` if a request to close the window was made, `false`
        * otherwise.
        */
        bool isCloseRequested() const { return _window.isCloseRequested; }

        PlatformWindowData platformData() { return _window.platformData; }

        ref WindowInput input() { return _window.input; }

        void title(string newTitle) { _window.title = newTitle; }

        void* userData() { return _window.userData; }

        void userData(void* userData) { _window.userData = userData; }

        @trusted void userData(T)(T t) if (is(T == class))
            { _window.userData = t; }

        ushort width() { return _window.width; }

        ushort height() { return _window.height; }

        version(Windows) alias win32 = platformData;
    }

    void close() { _window.close(); }

    void show() { _window.show(); }

    void hide() { _window.hide(); }
    //dfmt on

    WindowResizeCallback resizeCallback;

private:
    OsWindow _window;
}
