module oswald.platform;

enum platformPageScroll = uint.max;

//dfmt off
static immutable platformFunctions = [
    "CreateWindow",
    "DestroyWindow",
    "CloseWindow",

    "ShowWindow",
    "HideWindow",

    "SetTitle",

    "ResizeWindow"
];

static immutable platformConstants = [
    "ScrollLines"
];

static immutable platformTypes = [
    "WindowData",
];
//dfmt on

version (Windows)
{
    public import oswald.platform.win32;

    enum functionPrefix = "win32";
    enum typePrefix = "Win32";

    //Wierd alias issue. Compiler error without this when building external projects
    alias platformProcessEvents = win32ProcessEvents;

    alias PlatformWindowData = Win32WindowData;
}

mixin(genPlatformAlias!("platform", functionPrefix)(platformFunctions));
mixin(genPlatformAlias!("platform", functionPrefix)(platformConstants));

private:

string genPlatformAlias(string aliasPrefix, string platformPrefix)(in string[] names)
{
    string result;

    foreach(name; names)
        result ~= "alias " ~ aliasPrefix ~ name ~ " = " ~ platformPrefix ~ name ~ ";";

    return result;
}
