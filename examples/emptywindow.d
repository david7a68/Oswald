/++ dub.sdl:
	name "emptywindow"
	dependency "oswald" path="../"
+/
module oswald.examples.emptywindow;

import std.stdio;

void main()
{
	import oswald;
	import std.typecons: Yes, No;

	auto config = WindowConfig("Hello world!", 1280, 720, false);
	OsWindow window;
	auto error = OsWindow.createNew(config, &window);
	
	if (error != WindowError.NoError)
	{
		writeln(error);
	}

	while (!window.isCloseRequested)
	{
		window.input.process(Yes.waitForEvents);
	}

	window.destroy();
}
