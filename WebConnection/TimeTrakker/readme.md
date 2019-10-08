# TimeTrakker Server Side Web Connection Sample Application Sample
from Southwest Fox 2016 

### What it is
This is a server side sample application for Web Connection that uses:

* The new Web Connection 6.0 project layout
* wwBusiness Objects for all Business Logic
* Use MVC style development with Controller code and Script pages 
* Utilizes new Web Connection 6.0 Layout Pages, Sections and Partials
* Implements custom application security using wwUserSecurity
* Demonstrates Responsive Design for mobile ready display
* Demonstrates output generation to PDF

The application uses Mobile first design and is designed to run on devices from phones all the way up to desktop class displays and be usable and attractive on all of these device sizes.

### Online Sample
You can check out this application online at:  

* [http://timetrakkerswf.west-wind.com](http://timetrakkerswf.west-wind.com)

You can use the following login:  
* Email: **guest@swfox.com**                                                         
* Password: **test**


### Updates
I will be updating this example **before, during and after** the conference, so it's probably a good idea to use Git to clone this repository. 
## Installation
Once you have the files cloned from BitBucket do the following.

### FoxPro Configuration
Start Visual FoxPro in the `deploy` folder to ensure the paths get set properly.

> #### Modify config.fpw Paths
> Make sure you adjust the paths in config.fpw (or `SetPaths.prg`) to reflect the Web Connection installation folder on your machine. For most of you the base paths should point to:
> ```
> PATH=.\data;.\bus;C:\WCONNECT\FOX\classes;C:\WCONNECT\FOX\;
> ```

The easiest way to do this is to use the generated **TimeTrakker - Start FoxPro IDE with Web Connection** shortcut and change the FoxPro and startup path to match the path of your `deploy` folder. I also recommend you set the **Run As Administrator** flag on the shortcut to allow IIS configuration and COM Server compilation support. 

Once the paths are set up start the application from the Fox command window.

```foxpro
do TimeTrakkerMain.prg
```
### Unzip the data
Go to the `deploy\data` folder and unzip the file contained in the folder into the same folder to expand the TimeTrakker Sample data.


### IIS or IIS Express Configuration
Next, we need to configure IIS to make sure the service API backend is available. You can use IIS Express or IIS but I recommend you use IIS just so the application is always ready to run as IIS Express has to be started explicitly.

If you have IIS installed you can run:

```foxpro
DO TimeTrakker_ServerConfig.prg
```

to configure the IIS virtual called `TimeTrakker`. After this is done you should be able to navigate to:

* [http://localhost/TimeTrakker](http://localhost/TimeTrakker)

to verify the server works and:

* [http://localhost/TimeTrakker/EntryBrowser.ttk](http://localhost/TimeTrakker/EntryBrowser.ttk)

to verify the Web Connection server can be contacted.

If you want to use IIS Express and Visual Studio:

* Open Visual Studio
* Open Web Site at `<installFolder>\web`

Then to start IIS Express right click on `index.html` and choose **View in Web Browser**. This will start IIS Express on a custom port. You should then be able to navigate to:

* [http://localhost:3343](http://localhost:3343)
* [http://localhost:3343/EntryBrowser.ttk](http://localhost:3343/EntryBrowser.ttk)

That's it. Happy exploring...