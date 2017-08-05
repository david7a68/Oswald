module oswald.examples.callbacks;

import std.stdio;

void main()
{
	import oswald;
	import std.typecons: Yes, No;

	auto config = WindowConfig("Hello world!", 1280, 720, false, true);
	OsWindow window;
	OsWindow.createNew(config, &window);

	window.resizeCallback = (window, width, height) {
		writeln("Window resized: ", width, ":", height);
	};

	window.input.keyCallback = (window, key) {
		writeln(key);
	};	

	while (!window.isCloseRequested)
	{
		window.input.process(Yes.waitForEvents);
	}

	window.destroy();
}
