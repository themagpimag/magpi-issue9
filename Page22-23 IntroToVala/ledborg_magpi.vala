// LedBorgSimpleServer.vala

// the namespaces we'll be using
using GLib;
using Soup;

// our main class
public class LedBorgSimpleServer : GLib.Object {
  // define the port number to listen on
  static const int LISTEN_PORT = 9999;

  // define the device file to write to
  static const string DEVICE = "/dev/ledborg";

  // the method executed when run
  public static int main (string[] args) {
    // set up http server
    var server = new Soup.Server(Soup.SERVER_PORT, LISTEN_PORT);
    
    // handle requests from the client
    server.add_handler("/", default_handler);
    
    // get the running http server
    server.run();

    return 0;
  }

  // default http handler
  public static void default_handler(Soup.Server server, Soup.Message msg, string path, GLib.HashTable<string, string>? query, Soup.ClientContext client)
  {
    // action a request
    if(query != null)
    {
      // check the 'action' url parameter just to make sure
      if(query["action"] == "SetColour")
      {
        // get red, green, blue values from url params
        string red = query["red"];
        string green = query["green"];
        string blue = query["blue"];

        /* build our RGB colour string
        Each 0, 1 or 2:
        off, half or full brightnesss */
        string colour = red + green + blue;

        // do colour change
        do_colour_change(colour);
      }
    }

    // build the html for the client
    string html = """
<html>
  <head>
    <title>LedBorgSimpleServer</title>
  </head>
  <body>
    <form method="get" action="/">
     Red:<select name="red">
      <option value="0">Off</option>
      <option value="1">1/2</option>
      <option value="2">Full</option>
     </select>
     Green:<select name="green">
      <option value="0">Off</option>
       <option value="1">1/2</option>
       <option value="2">Full</option>
     </select>
     Blue:<select name="blue">
      <option value="0">Off</option>
      <option value="1">1/2</option>
      <option value="2">Full</option>
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
    /* Here we use posix file handling to write to the file instead of
    vala's gio file handling, as we don't want the safety of
    gio getting in the way when operating in /dev */
    // open the file for writing
    Posix.FILE f = Posix.FILE.open(DEVICE, "w");
      
    // write the colour string to file
    f.puts(colour);
  }
}
