module oswald.input;

public:

import oswald.input.keys: Key, Keycodes, KeyState;
import oswald.input.keys: numSupportedKeys;

import oswald.input.mouse: Cursor;
import oswald.input.mouse: MouseButton, MouseButtons, MouseButtonState;
import oswald.input.mouse: numSupportedMouseButtons;

import oswald.input.windowinput: WindowInput;
import oswald.input.windowinput: CursorMoveCallback, MouseButtonCallback, ScrollCallback;
import oswald.input.windowinput: KeyCallback;
