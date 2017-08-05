module oswald.examples.emptywindow;

import std.stdio;

void main()
{
	import oswald;
	import std.typecons: Yes, No;

	auto config = WindowConfig("Hello world!", 1280, 720, false);
	OsWindow window;
	OsWindow.createNew(config, &window);
	
	while (!window.isCloseRequested)
	{
		window.input.process(Yes.waitEvents);
	}

	window.destroy();
}
