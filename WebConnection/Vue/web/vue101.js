//import Vue from './lib/vue/dist/vue.esm.browser.js';
//import { ValidationProvider, extend } from './lib/vee-validate/dist/vee-validate.full.esm.js';

// // Add a rule.
// VeeValidate.extend('secret', {
//     validate: value => value === 'example',
//     message: 'This is not the magic word'
//     });

// custom validator
VeeValidate.extend('xrequired', {
    validate: (value) => value,
    message: 'BOGUS MESSAGE: This field is required', // the error message
    computesRequired: true
  });
Vue.component('ValidationProvider', VeeValidate.ValidationProvider);


// Add a rule - ES2015+
// extend('secret', {
//     validate: value => value === 'example',
//     message: 'This is not the magic word'
//   });
  
// // Register it globally
// Vue.component('ValidationProvider', ValidationProvider);


// create the view model separately - more options this way
var vm = {
    appName: "Vue 101",
    name: "Rick",
    lastName: "Strahl",
    time: new Date(),
    message: "",
    fullName: ()=> {
        return vm.name + " " + vm.lastName;
    },
    initialize: ()=>{
        setInterval(()=> {
            vm.time = new Date();
        },1000)
    },
    sayHello: (name)=>{
        if (!name)
			name = vm.name;

        var timeString = vm.time.toLocaleDateString() + " " + vm.time.toLocaleTimeString();
        
        // note this is a JavaScript interpolated string, not a template!
		return `Hello ${name}. Time is ${timeString}`;
	},
	clickHello: ()=> {
		alert(vm.sayHello(vm.name));
    },
    errors: []
};


// initialize the model
var app = new Vue({
    el: '#app101',
    data: function() {
       vm.initialize();
       return vm;
    },
    filters: {
        'formatDateTime': function (value, format) {
            if (value) {
                if (format)
                    return value.formatDate(format);
                else
                    return value.toLocaleDateString() + " " + value.toLocaleTimeString();
            }
        }, 
        'formatTime': function (value) {
            if (value) {
                return value.toLocaleDateString() + " " + value.toLocaleTimeString();
            }
        }
    }
});



debugger;
