module oswald.platform.win32;

version (Windows)  : import core.sys.windows.windows;
import std.typecons : Flag;
import oswald.errors : WindowError;
import oswald.window : OsWindow, WindowConfig;
import oswald.platform.win32input : windowProc;
import oswald.platform : platformPageScroll;

@safe @nogc nothrow:

pragma(lib, "user32");

struct Win32WindowData
{
    HWND handle;
    HDC hdc;
}

static immutable wndclassName = "viewport_win32_wndclass_name"w;
static immutable windowHandlePropertyName = "OSWALD_WINDOW"w;
static immutable uint win32ScrollLines;

@trusted static this()
{
    void registerWindowClass()
    {
        WNDCLASSEXW wc;
        wc.cbSize = WNDCLASSEXW.sizeof;
        wc.style = CS_OWNDC | CS_VREDRAW | CS_HREDRAW;
        wc.lpfnWndProc = &windowProc;
        wc.hInstance = GetModuleHandle(null);
        wc.lpszClassName = &wndclassName[0];

        RegisterClassExW(&wc);
    }

    registerWindowClass();

    uint lines;
    SystemParametersInfo(SPI_GETWHEELSCROLLLINES, 0, &lines, 0);

    if (lines == WHEEL_PAGESCROLL)
        win32ScrollLines = platformPageScroll;
    else
        win32ScrollLines = lines;
}

@trusted WindowError win32CreateWindow(in WindowConfig config,
        ref Win32WindowData window, void* statePtr)
{
    auto tmpTitle = getTitleAsNativeString(config.title);

    if (tmpTitle == null)
        return WindowError.TitleTooLong;

    //dfmt off
    HWND hwnd = CreateWindowExW(
        0,                              //Optional window styles
        &wndclassName[0],               //The name of the window class
        tmpTitle,                       //The name of the window
        WS_OVERLAPPEDWINDOW,            //Window Style
        CW_USEDEFAULT, CW_USEDEFAULT,   //(x, y) positions of the window
        config.width, config.height,    //The width and height of the window
        null,                           //Parent window
        null,                           //Menu
        GetModuleHandle(null),          //hInstance handle
        null
    );
    //dfmt on

    if (hwnd == null)
        return WindowError.WindowConstructionFailed;

    window.handle = hwnd;
    window.hdc = GetDC(hwnd);
    SetPropW(hwnd, windowHandlePropertyName.ptr, statePtr);

    if (!config.hidden)
        win32ShowWindow(window);

    return WindowError.NoError;
}

@trusted void win32DestroyWindow(Win32WindowData context)
{
    DestroyWindow(context.handle);
}

alias win32ShowWindow = win32SetWindowMode!SW_SHOW;
alias win32HideWindow = win32SetWindowMode!SW_HIDE;

@trusted void win32SetWindowMode(uint mode)(Win32WindowData context)
{
    ShowWindow(cast(void*) context.handle, mode);
}

@trusted void win32SetStatePointer(OsWindow* context)
{
    SetPropW(context.win32.handle, windowHandlePropertyName.ptr, context);
}

@trusted OsWindow* win32GetStatePointer(HWND hwnd)
{
    return cast(OsWindow*) GetPropW(hwnd, windowHandlePropertyName.ptr);
}

@trusted WindowError win32SetTitle(Win32WindowData context, string title)
{
    auto tmpTitle = getTitleAsNativeString(title);

    if (tmpTitle == null)
        return WindowError.TitleTooLong;

    SetWindowText(context.handle, tmpTitle);

    return WindowError.NoError;
}

@trusted void win32ProcessEvents(Flag!"waitEvents" waitEvents, Win32WindowData context)
{
    MSG msg;

    if (waitEvents)
    {
        const quit = GetMessageW(&msg, context.handle, 0, 0);

        TranslateMessage(&msg);
        DispatchMessage(&msg);

        if (quit == 0)
            return;
    }

    while (PeekMessageW(&msg, context.handle, 0, 0, PM_REMOVE))
    {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }
}

private:

@safe @nogc wchar* getTitleAsNativeString(string title) nothrow
{
    import oswald.platform.cinterop : tempCString;
    import oswald.window : maxTitleLength;

    auto rTempCString = title.tempCString!(maxTitleLength, wchar)();

    return rTempCString;
}
