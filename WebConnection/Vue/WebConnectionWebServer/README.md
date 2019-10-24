# Web Connection Web Server
The Web Connection Web Server is a .NET Core based local Web Server that allows you to run Web Connection application locally without IIS or another Web server. The executable is self contained and includes everything you need to run a Web Connection application locally.

The idea of this server is that you can install it without other dependencies except for a dependency on the .NET Core SDK. There's no IIS configuration or other setup required - the server is preconfigured and ready to go to serve requests locally.

The server can also be used as a standalone static file server - it can serve plain HTML and image resources from any folder on the local machine. 

The server includes the ability for Live Reloading content if changes are made to any of the static and script resources configured for the application.

### Requires .NET Core 3.0 Runtime or SDK
In order to run this Web Server **you need to install .NET Core 3.0 or later**. 

To see if you need to install the SDK or runtime you can run `install.ps1` from a Powershell command prompt. If the runtimes are not installed it will prompt you to download the runtime or SDK.

If you have to install .NET Core you can install either:

* **The [.NET Core SDK](https://dotnet.microsoft.com/download)**  
(recommended for a local development box) 

* **The [.NET Core Runtime](https://dotnet.microsoft.com/download)**    
* (minimal install for a production server)

Either of these will allow you to run this Web server.

### Install.ps1
The install script performs two tasks:

* Checks to see if the .NET Core runtime is installed
* Adds this folder to the User's global path

By having the tool in your path `WebConnectionWebServer` is available from any folder on your machine.

### Running WebConnectionWebServer
You can launch the Web Server by running `WebConnectionWebServer` from anywhere on your machine. This executable is a console application that runs from the Command Line in PowerShell or the Windows Command Prompt.

> ##### @icon-warning Run from the Command Line
> Note: WebConnectionWebServer is a **Console Application** and it has to be launched from a Terminal window in order to run and keep running. You can't start it from Explorer by double clicking, as the application will start and immediately exit. Make sure to run from a Terminal.

There are two ways to launch the Web Server in a given folder:

#### Explicitly specify a Path
You can explicitly launch the Web Server and specify a path that becomes the Web root folder:

```ps
WebConnectionWebServer --WebRoot c:\webconnectionProjects\wwthreads\web
```

#### Launch in the Web Root folder
Alternately you can launch the application in the folder you want to host as a Web site:

```ps
cd c:\webconnectionProjects\wwthreads\web
WebConnectionWebServer
```
#### Shut down the Web Connection Web Server
The application is a Console application and displays status information as it runs by default (you can disable this via options). The server runs in the Terminal window, until you shut it down explicitly via `Ctrl-C` or `Ctrl-Break`, or you close the Terminal window.

### Command Line Options
The `WebConnectionWebServer` application has a number of command line options that allow you to customize how the server runs. You can look up the options are available via the `--help` flag.

Here are the options available:

```text
----------------------------------------------
Web Connection Web Server
---------------------------------------------
(c) Rick Strahl, West Wind Technologies, 2019

Static and Razor File Service with Live Reload for changed content.

Syntax:
-------
WebConnectionWebServer  <options>

Commandline options (optional):

--WebRoot            <path>  (current Path if not provided)
--Port               5200*
--UseSsl             True|False*
--UseLiveReload      True*|False{razorFlag}
--ShowUrls           True|False*
--OpenBrowser        True*|False
--DefaultFiles       ""index.html,default.htm,default.html""

Live Reload options:

--LiveReload.ClientFileExtensions   "".cshtml,.css,.js,.htm,.html,.ts""
--LiveReload ServerRefreshTimeout   3000,
--LiveReload.WebSocketUrl           ""/__livereload""

Configuration options can be specified in:

* Environment Variables with a `WEBCONNECTION_` prefix. Example: 'WEBCONNECTION_WEBROOT'
* Command Line options as shown above

Examples:
---------
WebConnectionWebServer --WebRoot ""c:\temp\My Site"" --port 5500 --useSsl false

$env:LiveReload_Port 5500
WebConnectionWebServer
```

## Hosting in IIS
It's also possible to host this Web Connection Web Server inside of IIS providing the exact same functionality of the standalone using .NET Core hosting. In order for this to work you need the following on your production server:


* Make sure that .NET Core 3.x is installed as a shared runime  
(Install .NET Core Hosting Bundle for Windows (x64 is OK))
* `\wconnect\VisualStudio\WebConnectionWebServer` into `\yourproject\WebConnectionWebServer`
* Create your Web Site (has to be a Root Web Site - no virtuals!)
* Set up a new Application Pool and set **No .NET Managed Code**
* Set up Application Pool Identity to SYSTEM to start - then dial back when it all works
* Make sure you deploy `WebConectionSettings.xml`
* Check settings in WebConnectionSettings.xml

Then set up web.config as follows:

```xml
<configuration>
    <system.webServer>
        <!-- <handlers> ...comment old ASP.NET handler maps... </handlers> -->
        
        <handlers>
          <add name="aspNetCore" path="*" verb="*" modules="AspNetCoreModuleV2" resourceType="Unspecified" />
        </handlers>
        <aspNetCore processPath="dotnet.exe" 
            <!-- Locally installed Web Server binaries make for a portable app -->
            arguments="..\WebConnectionWebServer\WebConnectionWebServer.dll" 
            stdoutLogEnabled="true" 
            stdoutLogFile=".\logs\stdout"
            hostingModel="OutOfProcess">
            <environmentVariables>
                <environmentVariable name="ASPNETCORE_ENVIRONMENT" value="Production" />
                <environmentVariable name="WEBCONNECTION_USELIVERELOAD" value="False" />
                <environmentVariable name="WEBCONNECTION_OPENBROWSER" value="False" />
                <environmentVariable name="WEBCONNECTION_SHOWURLS" value="False" />
              </environmentVariables>
        </aspNetCore>
    </system.webServer>
</configuration>
```

This setup:

* Enables the ASP.NET Core Hosting Module 
* Launches `dotnet.exe` with the `WebConnectionWebServer.dll`
* Uses InProcess hosting (you can also use OutOfProcess)
* Sets up the startup environment:
    * Turn off Live Reload, Open Browser and Show Urls
    * These are not useful in hosted mode
* Code also enables logging in the `/logs` folder

Notice that the path to the WebConnectionWebServer.dll is a relative path, meaning that this web.config configuration is portable. If you move this to a new folder the server link will continue to work.

## Do you need IIS Hosting? 
For production sites you definitely do. For local development running the standalone Web Server with `WebConnectionWebServer` is easy and convenient and doesn't require you to run IIS. It's easy to start and stop and it has no dependencies other than .NET Core Runtimes.
  
### Port Sharing for Port 80
For production however, the standalone server is not ideal because Kestrel natively doesn't have all the features of a full featured IIS Web server. The most pressing problem is that you can't share ports with multiple server instances - one server maps to one port. If you're running only a single site then this might be doable, but it's still not ideal.

### Application Lifetime Management
IIS also provides lifetime management services to ensure that the .NET Core application is up and running and responding. If the application dies IIS quietly shuts it down and starts up a new instance, so IIS (actually the IIS Hosting Service) acts as a lifetime manager.

### Static File Services
IIS can also provide serving of static file content as opposed to letting .NET Core perform that task. On Windows IIS and IIS's Kernel caching are by far the fastest way to serve content that can be cached and compressed and IIS makes this easy and transparent. By default Kestrel serves all static resources and while it can do this capably it's much less efficient at doing so and without caching as IIS does.

In order to do this some extra IIS setup is required however to map handlers explicitly to the Static File handler in IIS **prior** to the .NET Core module. Not that the Core module maps `path="*"` which is **every file**. 

By adding specific handlers for specific extensions you can have IIS take over the most common file types:

```xml
<handlers>
      <add name="StaticFileModuleHtml" path="*.htm*" verb="*" modules="StaticFileModule" resourceType="File" requireAccess="Read" />
      <add name="StaticFileModuleText" path="*.txt" verb="*" modules="StaticFileModule" resourceType="File" requireAccess="Read" />
      <add name="StaticFileModuleSvg" path="*.svg" verb="*" modules="StaticFileModule" resourceType="File" requireAccess="Read" />
      <add name="StaticFileModuleJs" path="*.js" verb="*" modules="StaticFileModule" resourceType="File" requireAccess="Read" />
      <add name="StaticFileModuleCss" path="*.css" verb="*" modules="StaticFileModule" resourceType="File" requireAccess="Read" />
      <add name="StaticFileModuleJpeg" path="*.jpeg" verb="*" modules="StaticFileModule" resourceType="File" requireAccess="Read" />
      <add name="StaticFileModuleJpg" path="*.jpg" verb="*" modules="StaticFileModule" resourceType="File" requireAccess="Read" />
      <add name="StaticFileModulePng" path="*.png" verb="*" modules="StaticFileModule" resourceType="File" requireAccess="Read" />
      <add name="StaticFileModuleGif" path="*.gif" verb="*" modules="StaticFileModule" resourceType="File" requireAccess="Read" />
      <add name="StaticFileModuleWoff" path="*.woff*" verb="*" modules="StaticFileModule" resourceType="File" requireAccess="Read" />
      <add name="StaticFileModuleTxt" path="*.txt" verb="*" modules="StaticFileModule" resourceType="File" requireAccess="Read" />
      
      <add name="aspNetCore" path="*" verb="*" modules="AspNetCoreModuleV2" resourceType="Unspecified" />
    </handlers>
```

