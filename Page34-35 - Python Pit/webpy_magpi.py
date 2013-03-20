# web.py: controlling your Pi from a smartphone
# using LedBorg (www.piborg.com) as an example
# ColinD 27/12/2012 (www.rasptut.co.uk)
# This article appeared in Issue 9 of The MagPi (www.themagpi.com)
# This code is released without any warranty as to fitness of purpose. You use it at your own risk only.
# This code is released as freeware, you may use it as you want providing the above header remains in tact.

import web
from web import form

# Define the pages (index) for the site
urls = ('/', 'index')
render = web.template.render('templates')

app = web.application(urls, globals())

# Define the buttons that should be shown on the form
my_form = form.Form(
 form.Button("btn", id="btnR", value="R", html="Red", class_="btnRed"),
 form.Button("btn", id="btnG", value="G", html="Green", class_="btnGreen"),
 form.Button("btn", id="btnO", value="0", html="-Off-", class_="btnOff")
)

# define what happens when the index page is called
class index:
    # GET is used when the page is first requested
    def GET(self):
        form = my_form()
        return render.index(form, "Raspberry Pi Python Remote Control")
        
    # POST is called when a web form is submitted
    def POST(self):
        # get the data submitted from the web form
        userData = web.input()

        # Determine which colour LedBorg should display
        if userData.btn == "R":
            print "RED"
            lbColour = "200" #Rgb
        elif userData.btn == "G":
            print "GREEN"
            lbColour = "020" # rGb
        elif userData.btn == "0":
            lbColour = "000"
            print "Turn LedBorg Off"
        else:
            print "Do nothing else - assume something fishy is going on..."

        # write the colour value to LedBorg (see www.piborg.com)
        LedBorg = open('/dev/ledborg', 'w')
        LedBorg.write(lbColour)
        print lbColour
        del LedBorg

        # reload the web form ready for the next user input
        raise web.seeother('/')
# run
if __name__ == '__main__':
    app.run()

