import { Todo } from "./todo.js";

const newTodoText = "*** New Todo";


// create the view model separately - more options this way
var vm = {
    appName: "Vue Todo List",
    todos: Todo.loadTodos(),  // [] array    
    
    
    toggleCompleted: (todo)=> {
        todo.completed = !todo.completed;
    },
    toggleEditMode: (todo)=>{        
        if(todo.isEditing && ( !todo.title || todo.title.startsWith(newTodoText) ))        
            vm.removeTodo(todo);        

        todo.isEditing = !todo.isEditing;        
    },
    removeTodo: (todo)=> {
        vm.todos = vm.todos.filter((td) => td != todo);        
    },
    addTodo(){
        var todo = new Todo({ title: newTodoText, isEditing: true });        
        vm.todos.unshift(todo);
        
        setTimeout(()=> {
            // console.log(app.$refs.todoTitle);
            // console.log(app.$refs.todoTitle.$el);
            var ref = app.$refs.todoTitle[0];
            ref.select();
            ref.focus();
        })        
    }
};


// initialize the model
var app = new Vue({
    el: '#todoApp',
    data: function() {
       return vm;
    }
});




