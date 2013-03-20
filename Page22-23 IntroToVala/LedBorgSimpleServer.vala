// LedBorgSimpleServer.vala

// the namespaces we'll be using
using GLib;
using Soup;

// define exception
errordomain IOError {
	FILE_NOT_FOUND
}

// our main class
public class LedBorgSimpleServer : GLib.Object {

	// define the port number to listen on
	static const int LISTEN_PORT = 9999;

	// define the device file to write to
	static const string DEVICE = "/dev/ledborg";

	// main - this is the method that gets executed when the program is run
	public static int main (string[] args) {
		// set up http server
		var server = new Soup.Server(Soup.SERVER_PORT, LISTEN_PORT);
		
		// any requests from the client will be handled by our default_handler method
		server.add_handler("/", default_handler);
		
		// get the http server running and accepting requests
		server.run();

		return 0;
	}

	// default http handler
	public static void default_handler(Soup.Server server, Soup.Message msg, string path, GLib.HashTable<string, string>? query, Soup.ClientContext client)
	{
		// see if we're being asked to action a request
		if(query != null)
		{
			// check the 'action' url parameter just to make sure
			if(query["action"] == "SetColour")
			{
				// get red, green, blue values from url params
				string red = query["red"];
				string green = query["green"];
				string blue = query["blue"];

				// build our colour string
				/*
				The colour string should be three digits long,
				each digit representing red, green and blue respectively.
				
				Each digit's value should be either 0, 1 or 2
				corresponding to 'off', 'half brightness' or 'full brightness'
				*/
				string colour = red + green + blue;

				// do colour change
				do_colour_change(colour);
			}
		}

		// build the html to send to the client
		string html = """
			<html>
				<head><title>LedBorgSimpleServer</title></head>
				<body>
					<form method="get" action="/">
						Red:
						<select name="red">
							<option value="0">Off</option>
							<option value="1">1/2 brightness</option>
							<option value="2">Full brightness</option>
						</select>
						Green:
						<select name="green">
							<option value="0">Off</option>
							<option value="1">1/2 brightness</option>
							<option value="2">Full brightness</option>
						</select>
						Blue:
						<select name="blue">
							<option value="0">Off</option>
							<option value="1">1/2 brightness</option>
							<option value="2">Full brightness</option>
						</select>
						<input type="submit" name="action" value="SetColour" />
					</form>
				</body>
			</html>	
		""";

		// send the html back to the client
		msg.set_status_full(Soup.KnownStatusCode.OK, "OK");
		msg.set_response("text/html", Soup.MemoryUse.COPY, html.data);
	}

	// do the colour change
	public static void do_colour_change(string colour)
	{
		// check file exists (if not, then either device or driver not present)
		File file = File.new_for_path(DEVICE);
		if(file.query_exists())
		{
			/*
			Here we use posix file handling to write to the file instead of
			vala's gio file handling, as we don't want the safety of
			gio getting in the way when operating in /dev
			*/
			// open the file for writing
			Posix.FILE f = Posix.FILE.open(DEVICE, "w");
			
			// write the colour string to the file
			f.puts(colour);
		}
		else
		{
			throw new IOError.FILE_NOT_FOUND("Device or driver not present. %s not found.".printf(DEVICE));
		}
	}
}

