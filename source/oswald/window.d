module oswald.window;

import oswald.errors : WindowError;

enum maxTitleLength = 1024;

alias WindowResizeCallback = void function(OsWindow*, short, short);

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
@safe @nogc nothrow:

    import oswald.platform;
    import oswald.input : WindowInput;

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

    @property
    {

        /**
        * `true` if a request to close the window was made, `false`
        * otherwise.
        */
        bool isCloseRequested() const
        {
            return _isCloseRequested;
        }

        PlatformWindowData platformData()
        {
            return _platformData;
        }

        ref WindowInput input()
        {
            return _input;
        }

        void title(string newTitle)
        {
            platformSetTitle(_platformData, newTitle);
        }

        void* userData()
        {
            return _userData;
        }

        void userData(void* userData)
        {
            _userData = userData;
        }

        @trusted void userData(T)(T t) if (is(T == class))
        {
            _userData = cast(void*) t;
        }

        ushort width()
        {
            return _width;
        }

        ushort height()
        {
            return _height;
        }
    }

    version (Windows) alias win32 = platformData;

    void close()
    {
        isCloseRequested = true;
    }

    void show()
    {
        platformShowWindow(_platformData);
    }

    void hide()
    {
        platformHideWindow(_platformData);
    }

    WindowResizeCallback resizeCallback;

package(oswald):

    @property void isCloseRequested(bool icr)
    {
        _isCloseRequested = icr;
    }

    ushort _width;
    ushort _height;

private:
    PlatformWindowData _platformData;
    WindowInput _input;

    void* _userData;
    bool _isCloseRequested;
}
