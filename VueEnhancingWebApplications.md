# Enhancing Web Applications with VueJs

Web Frameworks come and go - frequently. [VueJs](https://vuejs.org/) is yet another Web Framework (YAWF), but  I think you'll find that VueJs is a bit different than most other frameworks. Unlike most of its peers VueJs is not specific to building full featured client side SPA (Single Page Applications) which it supports, but it also addresses much simpler scenarios of enhancing existing simple HTML pages.

The focus of this article is on VueJs as a **drop in JavaScript Framework** that you can use in simple function HTML pages (rather than full featured SPAs) or in server generated HTML pages. Specifically I'll use Web Connection for my server side examples since it fits the FoxPro target audience of this paper, but the concepts really can be used with any kind of server framework - I use these concepts frequently with ASP.NET Core for example.

## Framework Overload
So why use Vue? It is after all another framework and there are tons of them out there. 

I've used a number of JavaScript frameworks, and even though I have become a big fan VueJs, I tend to still use [Angular](https://angular.io/) as my primary framework to build full blown SPA applications. Vue also supports full blown SPA development with a full blown CLI and [WebPack](https://webpack.js.org/) based build system for bundling, packagin and support tooling. A framework like Angular or Vue with the full build process in place, works well for complex SPA applications. 

But you see, most of the big Web Frameworks are just that: Big and bulky. They require a large amount of bootstrap code just to load even a hello world application. More so, most require a complex **build process** that pulls in 100's of megabytes of dependencies, just to produce the final HTML output which often is also quite large (in the 100's of Kilobytes) especially for simple things.

If you're building a full featured, large Single Page Application front end for a complex enterprise application, that's perfectly fine. These build processes provide a number of other benefits such as automatically bundling and packing of resources, translating CSS from SCSS, LESS, provide tooling for testing and much more.

But it's **overkill** when you just want to drop a partial component into an existing page or add a small list of items into an existing static or server rendered HTML page. In fact, using a full SPA framework that's next to impossible to do effectively today (although Web Component proposals for many frameworks are aiming to change that some). 

### More Options with Vue
Where Vue really differentiates itself from other frameworks is that it can also easily be dropped into existing HTML pages using a single script reference, which allows Vue to be used more along the lines of how jQuery used to be dropped in to provide **incremental enhancement** to HTML pages.

Vue provides most of the functionality of other big frameworks that require full build processes, with just a single, small (38kb compressed) library. This means that with VueJs **it's very easy to enhance existing static or server rendered HTML pages** with easy JavaScript in much the same way that [jQuery](https://jquery.com/) could be used in the past as a simple drop-in to any page. In fact, VueJs can take over many if not most of the features that jQuery used to provide using declarative programming and model design.

> #### @icon-info-circle jQuery's Fall From Grace
> Even though jQuery has fallen out of favor over the years in favor of bigger frameworks, it is still very useful especially for simple page processing. Many of jQuery's features have been co-opted directly by the HTML DOM, but there are still many, many useful helpers that come in handy as well as built-in AJAX callback functionality that's easy to use. Although there's much less need for jquery in applications that use modern databinding, almost every application I built with client side code still benefits from jQuery. I say out of favor perhaps, but not down for the count just yet.

## Why use a a JavaScript Framework?
VueJs - like many of the other frameworks like Angular, React, Ember, Aurelia etc. - is a Model binding framework, that at it's heart provides an MVC/MVVM (Model Vue Controller, Model View Viewmodel) data binding framewo0rk.

At the highest level all frameworks are based on a simple concept:

* A JavaScript data model that describes the data to be bound
* A template inside of HTML that describes how to render the data
* Some bootstrap code that binds the model to a template
* Code that reacts to events and fires your JavaScript code

The key feature of VueJs and other frameworks is data binding, which actually can affect more than what you traditionally think of as data, such as display attributes and UI state. While you will always want to bind actually data values like a name, date or description, you may also want to bind state data such as wether an item is enabled or disable, whether it's visible or whether it has a specific CSS class or style associated with it. All of this can be handled through the declarative HTML syntax of VueJs.

Just like you can easily bind data to a `ControlSource` in FoxPro, VueJs allows you to bind data to an HTML element or its attributes. Unlike FoxPro though, the databinding in Vue is much more flexibile as it allows you to bind to any property of each element. You can bind to the most common `innerText`, `innerHTML` and `value` elements of course, but you can also easily bind a `title`, `class`, `style` or  `disabled` attribute. Essentially you can bind to any attribute that an element supports and bind to any event including custom user generated DOM events. 

This is very powerful as it allows the framework to abstract the DOM away almost entirely. Rather than pushing data items individually into the DOM every time a value changes, you can simply set a property value on the model, and the framework takes care of updating the HTML DOM based on the template bindings on the page.

## First look at Vue Syntax
To give you an idea what a Vue 'HTML template' along with the model binding code looks like here's a simple example of a list of items displayed with display and editable fields:

```html
<div id="todoApp">
    
<h1>{{appName}}</h1>

<div class="todo-item"
     v-bind:class="{completed: todo.completed}"
     v-for="todo in todos" >
     
    <div class="todo-content" 
         v-on:click="toggleCompleted(todo)">

        <div class="todo-header">
            <div v-if="!todo.isEditing" >
                {{todo.title}}
            </div>
            <div v-else>
                <input type="text"  ref="todoTitle" 
                        v-model="todo.title"
                        class="todo-header inline-editor" />
            </div>
        </div>                            
        <div v-if="!todo.isEditing" style="min-height: 25px;" >
            {{todo.description}}
        </div>
        <div v-else>
            <textarea v-model="todo.description"
                      class="inline-editor"></textarea>
        </div>
    </div>
</div>
</div>

<script>
// create the view model separately - more options this way
var vm = {
    appName: "Vue Todo List",
    todos: [ 
        { 
          title: "todo 1",
          description: "description",
          completed: false,
          isEditing: false
        },
        { ... },
        { ... }
    ],
    toggleEditMode: function(todo) { todo.isEditing = !todo.isEditing },
    toggleCompleted: (todo)=> todo.completed = !todo.completed
 }
 
// initialize the model
var app = new Vue({
    el: '#todoApp',
    data: function() {
       return vm;  // bind the model to the view
    }
});
<script>
```

Looking at the HTML and the Vue template syntax it should be pretty easy to discern what this page does, and that's part of the appeal of using a databinding framework. The templates look pretty much like normal HTML with some additional attributes and some binding expressions.

If you run this page here's what it looks like (with some added edit and remove buttons that I get to later):

![](FirstVueExample.png)

It's a pretty simple page, yet there's a lot going on in this example actually. There's literally no code to update the DOM as all the rendering is taken care of by rendering data from the model (the `vm` instance). Even operations like changing the edit state of an item and displaying a completely separate view, or toggling the completed state are simply updating a model value (`todo.completed = !todo.completed` for example) that is then immediately reflected in the UI.

The Vue specific tags are those that start with `v-` like `v-bind`, `v-model`, `v-if`, `v-else` and so on. There are also special directives like the binding a `v-bind:class` or `v-bind:style`, where you can provide a class value to describe behavior like class names or styles.

The code to hook this up is also very simple - you create a model of data which typically is an object with properties and potentially nested properties/arrays that contains the data that is to be rendered into the View. Each simple value can be bound to `v-text` or via `{{ property }}` or - for nested objects - `{{ property.childproperty }}` bindings.

Because data binding in VueJs is **reactive**, any change you make to the model is immediately reflected in the HTML view, so when you change the `vm.todos` array or any of the Todo items inside of it, the template is immediately refreshed and the data updated.

The important point is this:

> VueJs, not your own JavaScript code is responsible for updating the HTML DOM. Your code can just update the model data to update the HTML displayed on the screen. Note that you **still** can update HTML via the DOM, but generally your aim is to let the model do the work whenever possible.

All the tedious DOM update logic of poking values into the UI via code (ie. `$("#appname").text(vm.appname)`) and more importantly the more complex scenario of updating a list of data via code, is not necessary . Instead you simply assign a value to a model (`vm.todos[0].title = "Updated Todo Item"`) and that value immediately displays.

### Imperative vs. Declarative
If you come from classic style of JavaScript programming using raw JavaScript or jQuery, you likely have used manual updates via code, where you **imperatively** write each change into the HTML document. 

With VueJs on the other hand, you only **declaratively** make changes to the model data, which in turn triggers VueJs to update the HTML template with the newly updated model data. The framework is smart enough to detect which specific properties have changed and updates only those HTML elements that effectively have changes.

To demonstrate here are a couple of examples:

#### Using an imperative approach with jQuery:

```js
// Imperative using jQuery
var total = 200, subtotal = 100;

// throughout the page life cycle
$("#invoiceSubTotal",subtotal);
$("#invoiceTotal",total);
```

#### Using a Declarative approach with VueJs:

```js
// One binding time setup at start of page
var vm = {
    total: 0,
    subtotal: 0
};

// bind the model to the view
var app = new Vue({
    el: '#myApp',
    data: function() {
       return vm;
    }
});

...

// throughout the page life cycle

// updates the HTML view that are bound to these values
vm.total = 200;
vm.subtotal = 100;
```

In theory a VueJs (or any other framework) page/application should never (or at least very rarely) access the HTML DOM directly and instead update the model that drives the HTML display. Using the model to update is preferred because:

* It's much easier to write that code
* Performance is better for bulk DOM updates
* Less error prone (ie. if you rename an HTML element code still works)
* No dependencies on specific DOM features (or even browser/mobile features)

## Vue Basics 
At a high level Vue is not very different from other frameworks. There are a handful of key features that Vue provides.

* Inline HTML Templates
* Declarative directives (`v-for`, `v-if`, `v-show` etc.)
* Model -> Template Binding (`v-text`, `v-html`, `{{ }}`, `v-bind:attr`)
* Two-way Model Binding (`v-model`)
* Event Binding (`v-on:event`)

The idea is pretty simple and similar to other frameworks. During the page's startup you do the following:

* You create a data model
* You add properties to your model for data
* You can nest objects or use arrays
* You add method for event handlers
* You create a Vue instance
* You attach the Vue instance to a DOM element
* You attach your model to the Vue instance

Let's break all that down step by step.


Before I dive in let's create a simple HTML page first that'll hold the example. I'm using the sample folder here and am pulling in the Bootstrap CSS library, FontAwesome and VueJs from a local store. They just make things look nicer, but don't affect any of the operations here.

```html
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
    <title>Vue 100</title>

    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />
    <meta name="description" content="" />

    <link rel="shortcut icon" href="./favicon.ico" type="image/x-icon" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <link rel="apple-touch-icon" href="./touch-icon.png" />

    <link rel="icon" href="./touch-icon.png" />
    <meta name="msapplication-TileImage" content="./touch-icon.png" />

    <link href="./lib/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="./lib/fontawesome/css/all.min.css" rel="stylesheet" />
    <link href="todo.css" rel="stylesheet" />

    <!-- <script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script> -->
    <script src="./lib/vue/dist/vue.js"></script>
</head>
<body>
    <div id="todoApp">

      <!-- page content here -->        
        
    </div>
</body>
</html>
```

The key item specifically relevant here is the inclusion of VueJs:

```html
<!-- <script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script> -->
<script src="./lib/vue/dist/vue.js"></script>
```

### Start with a Model
Generally it's best to start with a model of data that you want to bind. It's not required of course, but I find it helps to think about the data you are going to render first. Let's start with the simplest thing possible.

Personally I like to create my model separately from the View object and then pass that to Vue rather than defining the model directly on the Vue object as the document shows. The reason for this is that I like to create a locally scoped variable that I can access for my model so that I can **always reference** the model and not have to rely on the sometimes unpredictable nature of the `this` reference in JavaScript. 

So I start with a model, which is just a JavaScript object map. You can create a class or function closure which in JavaScript also behavior like objects. for the following I use a Object Map.

> Ideally you'll want to put script code into a separate JavaScript file, but for this first example I'll use a `<script>` tag in the HTML page.

At the bottom of the HTML page before the `</body>` tag add the following:

```js
<script>
// create this first for a script wide reference
var vm = {}; 
vm = {
    appName: "Todo Application"
}

// bind the model to the todoApp Id/Element in the HTML
var app = new Vue({
    el: '#todoApp',
    data: function() {
       return vm;  // bind the model to the view
    }
});
```

So I  create the model first, followed by creating an instance of the Vue object.

The Vue instance is created and the two key items that are set on the passed in object map are:

* **el**: The DOM Element to bind the model to  using CSS syntax    
(`#` means *Id of todoApp*)
* **data**: A JavaScript function that returns the model

The `data` object can either be an object instance or a function. The Vue docs recommend a function because it allows initialization code to be added **just before the model is loaded** which is after the DOM has loaded. In this method I simply return my Vue model.


The object you pass can contain many other options, including a list of filters, locally used components, and much more. For now all we want is the model.


### Add the HTML Template
The term HTML template may be confusing, because in reality you are not creating a seperate 'template' but rather writing the Vue template syntax directly into your existing HTML document. So in the area where above it says `<!-- page content here -->` you can now add the following:

```html
<h1>{{ appName }}</h1>
```

If you open the HTML page in the browser now you should see the "Todo Application" displayed as a big header string. If you change your code and change `appName` to a different value you can see the value updated.

### Dynamic Updates
The first binding works but it's not very dynamic. Let's do something slightly more interesting by adding a value that will dynamically change. Let's go back to the model and add a new property and an initialization function:

Let's add a couple a new property to the model and initialize the model. What I'll do is add a little time update mechanism that shows the current time updating every second by adding a `time` property and an `initialize()` function:

```javascript
// create the view model separately - more options this way
var vm = {
    appName: "Vue Todo List",
    time: new Date(),
    initialize: function() {
        setInterval(function() { vm.time = new Date() },1000);            
    }        
 }
 
// initialize the model
var app = new Vue({
    el: '#todoApp',
    data: function() {
        vm.initialize();
        return vm;  // bind the model to the view
    }
});
```

`time` holds a JavaScript data, and when the model is initialized I explicitly create a timer (`setInterval`) that refreshes every second and creates a new date. IOW, every second the `vm.time` property is updated and should update the HTML with the new time.

To make this work we'll need to update the template:

```html
<h1>{{ appName }}</h1>
<hr>
<p>Current time is: <b>{{time.toLocaleTimeString()}}</b></p>
```

When you run this now you'll see the time updating every second:

![](UpdatingTimer.png)

While maybe not impressive to look at, it's pretty powerful. It demonstrates neatly how you can update just the model data - `vm.time` in this case, and see that change reflected immediately in the HTML. Every second when the interval timer fires, it updates the model and that change updates the HTML in the browser. 

**You don't write code to update the HTML DOM, you write code to simply change values on the model.**

Vue checks the model for changes and when a change is detected fires a DOM update cycle that renders the affected parts of the template. Cool, right?

Note that you can bind data in a few different ways. The **mustache syntax** used above is very descriptive, but it won't work for all controls because it requires a control that can 

```html
<p>Current time is: 
<b v-text="time.toLocaleTimeString()"></b>
```

If you need to bind raw HTML instead you can use `v-html` instead of `v-text`:

```html
<div v-html="getRenderedMarkdown()"></div>
```

### DataBinding in Vue
`v-text` and `v-html` binding are **content** bindings meaning they bind the content that are directly rendered into the HTML between the brackets.

For binding element attributes you use `v-bind:attribute`. For example to bind the title attribute in the header you might use:

```html
<h1 v-bind:title="appName + ' ' + time.toLocaleTimeString()">{{appName}}</h1>
```

An alternate slightly simpler syntax is:

```html
<h1 :title="appName + ' ' + time.toLocaleTimeString()">{{appName}}</h1>
```

The `:` is a shortcut for `vbind:`. Although shorter I often find `v-bind` more descriptive.

Now when you hover over the document title you should see the title in a tool tip and the tool tip text will change every second to reflect the time as well.

The expression above brings up an important point: 

> Vue 'expressions' are **raw JavaScript** and you can pretty much use any valid JavaScript expression inside of a `v-bind` directive or a `{{ }}` expression. Unlike other frameworks that use pseudo JavaScript that uses special parsing, in Vue you can simply use raw JavaScript for native functions or your own code as long as you can reference it through your model.

### Editing Data
Displaying data is nice, but you also need to update data in your model from input created in the user interface. Vue supports two-way databinding via the `v-model` directive which allows you to bind a model value to a control in much the same way as `v-bind` does, but also supports **binding back** to the data source. You can use `v-model` with any of the HTML input elements.

Here's what this looks like:

```html
<p>
    <label for="">Update the App Name: </label>

    <input type="text" 
            class="form-control"
            v-model="appName"
            />
</p>
```

Notice the `v-model="appName"` attribute which binds the app name to the input box. When you now run this, you can type into the edit box and as you type you can immediately the title update:

![](VModelInputAppName.png)

What's nice about this is that you can update your model values and immediately see the changes reflected without any sort of update mechanism. If you update a value that triggers changes to another value (like say you add an order item and recalculate a total) those new values are immediately updated.

This functionality makes it very easy to create very interactive applications.

### Event Handling
Data binding on its own is powerful but it's not all that useful if you can't fire off actions as well. To do this you can bind DOM events to functions in your model.

Let's add a button to the page that allows resetting the value of the `appName` to its default value after it's been changed, or to an updated value if it hasn't.

```html
<button class="btn btn-primary mt-2" 
         v-on:click="resetAppName()">
    <i class="fas fa-recycle" style="color: lightgreen"></i> 
    Reset to Default                
</button>
```

This hooks the `click` event of the button to an `resetAppName` function in the model:

```javascript
resetAppName: function() { 
    if (vm.appName != defaultAppName)
        vm.appName = defaultAppName;
    else
        vm.appName = defaultAppName + " RESET";   
}
```

When you click the button the above code fires and you have access to the current model. You can also pass parameters to the function from script, including in scope variables, which is an important and powerful feature we'll look at when look at list binding.

### Computed bindings
Vue is also smart enough to do what are basically computed bindings, if you bind to a method in your model:

```javascript
var vm = {};
vm = {
  firstName: "Rick",
  lastName: "Strahl",
  fullName: ()=> vm.firstName + " " + vm.lastName
};
```

You can then embed can then print out the full name like this:

```html
<div>{{ fullName() }</div>
```
What's nice is that because this is a model function that is bound into the HTML template, if you change `firstName` or `lastName` the name in the UI is still updated.

### Conditional Binding
One important thing that UI needs to do is conditionally bind things based on a truthy state. For example, you might want to only and error message display if there's an error message to display.

To create a conditional binding you can use `v-if` which doesn't render an item, or `v-show`/`v-hide` which make the element hidden but still in the document.

I'll use `v-if` here to create the error box:

```javascript
<div class="alert alert-warning" v-if="errorMessage">
    <i class="fas fa-exclamation-triangle" style="color: firebrick"></i>                
    {{errorMessage}}
</div>
...
<button class="btn btn-primary " v-on:click="setError()">
    Toggle Error
</button>

```

The idea is if `errorMessage` is empty it doesn't disply.


### List Binding
