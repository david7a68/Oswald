module oswald.platform.win32;

//dfmt off
version (Windows) :
//dfmt on

import core.sys.windows.windows;
import std.typecons : Flag;
import oswald.errors : WindowError;
import oswald.window : OsWindow, WindowConfig;
import oswald.platform.win32input : windowProc;
import oswald.platform : platformPageScroll;

@safe @nogc nothrow:

pragma(lib, "user32");

static immutable uint win32ScrollLines;

struct Win32WindowData
{
    HWND handle;
}

@trusted static this()
{
    WNDCLASSEXW wc;
    wc.cbSize = WNDCLASSEXW.sizeof;
    wc.style = CS_OWNDC | CS_VREDRAW | CS_HREDRAW;
    wc.lpfnWndProc = &windowProc;
    wc.hInstance = GetModuleHandle(null);
    wc.lpszClassName = &wndclassName[0];
    RegisterClassExW(&wc);

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

    DWORD style = WS_OVERLAPPEDWINDOW;
    
    if (!config.resizeable)
        style ^= WS_SIZEBOX;

    //dfmt off
    HWND hwnd = CreateWindowExW(
        0,                              //Optional window styles
        &wndclassName[0],               //The name of the window class
        tmpTitle,                       //The name of the window
        style,                          //Window Style
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
    SetPropW(hwnd, windowHandlePropertyName.ptr, statePtr);

    if (!config.hidden)
        win32ShowWindow(window);

    return WindowError.NoError;
}

@trusted void win32DestroyWindow(Win32WindowData context)
{
    DestroyWindow(context.handle);
}

@trusted void win32CloseWindow(Win32WindowData context)
{
    auto err = PostMessage(context.handle, WM_CLOSE, 0, 0);

    assert(err != 0, "PostMessage(WM_CLOSE) failed");
}

alias win32ShowWindow = win32SetWindowMode!SW_SHOW;
alias win32HideWindow = win32SetWindowMode!SW_HIDE;

@trusted void win32SetWindowMode(uint mode)(Win32WindowData context)
{
    ShowWindow(cast(void*) context.handle, mode);
}

@trusted WindowError win32SetTitle(Win32WindowData context, string title)
{
    auto tmpTitle = getTitleAsNativeString(title);

    if (tmpTitle == null)
        return WindowError.TitleTooLong;

    SetWindowText(context.handle, tmpTitle);

    return WindowError.NoError;
}

@trusted WindowError win32ResizeWindow(Win32WindowData context, ushort newWidth, ushort newHeight)
{
    RECT rect;
    GetWindowRect(context.handle, &rect);

    auto err = MoveWindow(context.handle, rect.left, rect.top, newWidth, newHeight, TRUE);

    return WindowError.NoError;
}

@trusted void win32ProcessEvents(Flag!"waitForEvents" waitForEvents, Win32WindowData context)
{
    MSG msg;

    if (waitForEvents)
    {
        const quit = GetMessageW(&msg, context.handle, 0, 0);
        assert(quit != -1, "GetMessage returned -1");

        TranslateMessage(&msg);
        DispatchMessage(&msg);

        if (quit == 0)
            return;
    }

    while (PeekMessage(&msg, context.handle, 0, 0, PM_REMOVE) != 0)
    {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }
}

@trusted void win32ProcessEvents(Flag!"waitForEvents" waitForEvents)
{ //Global process events
    MSG msg;

    if (waitForEvents)
    {
        const quit = GetMessageW(&msg, null, 0, 0);
        TranslateMessage(&msg);
        DispatchMessage(&msg);

        if (quit == 0)
            return;
    }

    while (PeekMessageW(&msg, null, 0, 0, PM_REMOVE))
    {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }
}

package:

@trusted OsWindow* win32GetStatePointer(HWND hwnd)
{
    return cast(OsWindow*) GetPropW(hwnd, windowHandlePropertyName.ptr);
}

private:

static immutable wndclassName = "viewport_win32_wndclass_name"w;
static immutable windowHandlePropertyName = "OSWALD_WINDOW"w;

@safe @nogc wchar* getTitleAsNativeString(string title) nothrow
{
    import oswald.platform.cinterop : tempCString;
    import oswald.window : maxTitleLength;

    auto rTempCString = title.tempCString!(maxTitleLength, wchar)();

    return rTempCString;
}
