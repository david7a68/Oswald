module oswald.platform.cinterop;

import std.traits: isSomeChar;

/**
 * A utility function for temporarily creating C-like strings.
 * 
 * It will convert the string from one character width to another, and add a 
 * null-terminating character at the end of the string.
 *
 * This function returns a pointer to its internal buffer. Do not escape this
 * pointer out of the calling function, or undefined behavior may result.
 *
 * Params:
 *      str = The string to convert
 *
 * Returns: null if the buffer is not large enough for the string, else a
 *          pointer to the buffer;
 */
Char* tempCString(size_t buffSize, Char)(string str) if (isSomeChar!Char)
{
    import std.utf : byUTF;

    static Char[buffSize] buffer;

    size_t index;
    auto range = str.byUTF!Char();

    while (!range.empty && index < buffer.length)
    {
        buffer[index] = range.front;
        range.popFront();
        index++;
    }

    if (index == buffer.length)
        return null;

    buffer[index] = '\0';

    return &buffer[0];
}