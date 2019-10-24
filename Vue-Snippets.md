# Vue 100

### Define a base View
```js
<div id="vue101" class="container">
    <h1>
        <i class="fa fa-info-circle text-primary"></i>
        {{title}}</h1>
    <hr>
    <b>Time is: </b> {{ time }}
</div>       
```

### Initial View and Vue

```javascript
<script>
vm = {};
vm = {
    title: "Vue 101",
    time: new Date(),
    name: "Rick",
    message: "",
    sayHello: function() { 
     alert("Hello " + vm.name);
    }
}

// initialize the model
var app = new Vue({
     el: '#vue101',
     data: function() {
        return vm;  // bind the model to the view
     }
 });
</script>
```

### Add an Input Field

```html
<div class="form-group mt-4">
  <label for="">What's your name</label>
  <input type="text" 
        v-model="name" 
        class="form-control" name="" id="" aria-describedby="helpId" placeholder="">
  <small id="helpId" class="form-text text-muted">you typed {{name}}</small>
</div>
```

### Add a button and Message Display

```html
<button type="button" class="btn btn-primary" 
    v-on:click="sayHello()">
    <i class="fa fa-bullhorn"></i>
    Say Hello
</button>


```

### Turn Message() into  Method for dynamic updates

```html
<strong>{{message()}}</strong>
```


```javascript
message: function() {
    if (!vm.name)
          return "";
    
    return "Hello " + vm.name;
},
```


### Todo List Example

### Todo List of Items

```javascript
// create a class
function Todo(initial) {
        this.id = null;
        this.title = "Todo";
        this.description = "";
        this.completed = false;
        this.entered = new Date();
        this.isEditing = false;
        
        if (initial)
             // this allows mapping an object passed for initial values
             Object.assign(this,initial);
};

// create instances
var todos = [
    new Todo ({ 
        title: "Make SW Fox travel arrangements",
        description: "Compare fares and use travel site to book flights."
    }),
    new Todo( { 
        title: "Prepare for SW Fox",
        description: "Work on Vue Demo and get it done" 
    }),
    new Todo( {
        title:"Go windsurfing",
        description: "After work make time to go!"
    }),
    new Todo({
        title: "Drop Everything - It's Windy!", 
        description: "It's nuking, let's get in the car and go!"
    })
];
```

### Display Todo Items

```html
<div class="todo todo-item" 
      v-for="todo in todos">

    <div class="todo-header">{{todo.title}}</div>   
    <div class="todo-content">
        {{todo.description}}
    </div>    
</div>
```

### Add Checkbox

```html
      :class="{completed: todo.completed}">

       <input type="checkbox" 
             class="float-left"
            v-model="todo.completed"  />
```

### Remove Button

above todo item: 

```html
<i class="fa fa-times text-danger float-right"
   @click="removeTodo(todo)"></i>
```

```javascript
removeTodo: function(todo) {
    vm.todos = vm.todos.filter((td) => td != todo);
},
```
