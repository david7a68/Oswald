module oswald;

public:

import oswald.errors: WindowError;

import oswald.window: OsWindow;
import oswald.window: Window;
import oswald.window: WindowConfig;
import oswald.window: maxTitleLength;

import oswald.input: Key, Keycodes, KeyState;
import oswald.input: numSupportedKeys;

import oswald.input: Cursor;
import oswald.input: Mouse, MouseButton, MouseButtons, MouseButtonState;
import oswald.input: numSupportedMouseButtons;

import oswald.input: WindowInput;

import oswald.input: CursorMoveCallback;
import oswald.input: KeyCallback;
import oswald.input: MouseButtonCallback;
import oswald.input: ScrollCallback;
