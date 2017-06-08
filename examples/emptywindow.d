import std.stdio;

void main()
{
	import oswald;
	import std.typecons: Yes, No;

	auto config = WindowConfig("Hello world!", 1280, 720, false);
	auto window = new Window(config);

	while (!window.isCloseRequested)
	{
		window.input.process(Yes.waitEvents);
	}

	window.destroy();
}
