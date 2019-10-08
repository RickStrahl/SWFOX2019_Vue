//import Vue from './lib/vue/dist/vue.esm.browser.js';

import { Todo } from "./todo.js";

import './scripts/ww.jquery.js';
import './lib/toastr/build/toastr.min.js';


const newTodoText = "*** New Todo";

// * Register Global Components */

// Add Validation Provider
Vue.component('ValidationProvider', VeeValidate.ValidationProvider);




// create the view model separately - more options this way
var vm = {
    appName: "Vue Todo List",
    todos: [],        
    errorMessage: "",

    loadTodos: ()=>{
        vm.errorMessage = null;
        vm.todos = null;
        return ajaxJson("todos.wcvue",null,
            (todos) => vm.todos = todos;                                            
            (error)=> vm.setError(error));
    },
    toggleCompleted: (todo)=> {
        vm.errorMessage = null;
        var newStatus = !todo.completed;
        ajaxJson("toggleTodo.wcvue",
                { id: todo.id, completed: newStatus },
                (status)=>{
                    todo.completed = newStatus;                    
                },
                (error)=> vm.setError(error));
    },
    toggleEditMode: (todo)=>{        
        if(todo.isEditing && ( !todo.title || todo.title.startsWith(newTodoText) ))        
        {
            vm.removeTodo(todo);                    
            return;            
        }
        
        if(todo.isEditing)
            vm.saveTodo(todo);        
        else
            todo.isEditing = !todo.isEditing; 
    },
    removeTodo: (todo)=> {        
        ajaxJson("todo.wcvue?id=" + todo.id,null,
            ()=> {
                vm.todos = vm.todos.filter((td) => td != todo);    
                toastr.success("Todo removed.");
            },
            vm.setError,
            { method: "DELETE" });
        
    },
    addTodo: ()=> {
        var todo = new Todo({ title: newTodoText, isEditing: true });        
        vm.todos.unshift(todo);
        
        setTimeout(()=> {
            // access DOM element
            var ref = app.$refs.todoTitle[0];
            ref.select();
            ref.focus();
        },10)        
    },
    saveTodo: (todo)=>{
        vm.errorMessage = null;
        ajaxJson("todo.wcvue",todo,
        (td) => {
            // update id from server
            todo.id = td.id;
            todo.completed = td.completed;
            todo.entered = td.entered;
            todo.isEditing = !todo.isEditing;        

            toastr.success("Todo updated.");
        },
        vm.setError);
    },
    reloadData: ()=>{
        ajaxJson("reloadData.wcVue",null,
        () => {
            vm.loadTodos();
            toastr.success("Todo list reloaded.");
        },vm.setError);
    },
    setError: (error)=>{
        vm.errorMessage = error.message;
        toastr.error(error.message)
    }

};



// initialize the model
var app = new Vue({
    el: '#todoApp',
    data: function() {
       vm.loadTodos();
       return vm;
    }
});

console.log(app);






