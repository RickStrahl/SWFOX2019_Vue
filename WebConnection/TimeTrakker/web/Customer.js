/// <reference path="./scripts/ww.jquery.js" />
/// <reference path="lib/toastr/build/toastr.min.js" />

(function () {

    var vm = {}

    vm = {
        baseUrl: "./",
        projects: [],
        entries: [],
        
        newProject: createProject(),
        ready: false,
        addRowVisible: false,

        initialize: function () {
            console.log("customer initialize");
            vm.loadProjects();
        },
        loadProjects: function () {
            ajaxJson(vm.baseUrl + "projects.ttr", null,
                function (projects) {
                    vm.projects = projects;
                    vm.ready = true;
                }, function (error) {
                    console.log(error);
                });
        },
        saveProject: function () {
            
            ajaxJson(vm.baseUrl + "project.ttr", vm.newProject,
                function (project) {                    
                    vm.projects.unshift(project);
                    vm.newProject = createProject();
                    vm.addRowVisible = false;

                    // force setting the id in the 'page'
                    $("#id").val(project.customerpk);

                    toastr.success("New project added.");
                }, function (error) {
                    toastr.error("Couldn't save project." + error.message)
                });
        },
        removeProject: function (project) {         
            if (!confirm("Are you sure you want to remove this project?"))
                return;            
            ajaxJson(vm.baseUrl + "project.ttr?id=" + project.pk,null,
                function (result) {
                    toastr.success("Project removed.");

                    // filter the project list by all projects that don't match
                    var filtered = vm.projects.filter(function (p, i) {
                        return p.pk != project.pk;
                    });                    

                    // Note: Take special care with arrays
                    // Updating individual elements requires special use of Vue.set/delete
                    vm.projects = filtered;
                    //Vue.set(vm, "projects", filtered);
                    //Vue.set(vm.properties,10,newItem);
                },
                function (error) {
                    toastr.error("Couldn't delete project: " + error.message);
                },
                { method: "DELETE" });
        }
    }
    console.log('up and at em');
    vm.initialize();

    // vee-validate for form validation
    // https://baianat.github.io/vee-validate/guide/rules.html#min
    var vv_config = {
        errorBagName: 'errors', // change if property conflicts.
        fieldsBagName: 'fields',
        delay: 1,
        locale: 'en',
        dictionary: null,
        strict: true,
        classes: true,
        classNames: {
            touched: 'touched', // the control has been blurred
            untouched: 'untouched', // the control hasn't been blurred
            valid: 'valid', // model is valid
            invalid: 'invalid', // model is invalid
            pristine: 'pristine', // control has not been interacted with
            dirty: 'dirty' // control has been interacted with
        },
        events: 'input|blur',
        inject: true
    };
    Vue.use(VeeValidate, vv_config); 

    var app = new Vue({
        el: "#CustomerPage",
        data: function () {
            return vm;
        }
    });

    function createProject() {
        var custId = $("#Id").val() * 1;        
        return {
            projname: "",
            startdate: moment(new Date()).format("M/D/Y"),
            status: 0,
            pk: 0,
            customerpk: custId

        };
    }

})();