export class Todo {
    constructor(initial = {}) {
        this.id = null;
        this.title = "Todo";
        this.description = "";
        this.completed = false;
        this.entered = new Date();
        this.isEditing = false;
        
        if (initial)
             // this allows mapping an object passed for initial values
             Object.assign(this,initial);
    }


    static loadTodos(){
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

        return todos;
    }
}

export class Todo2 extends Todo {
    constructor(){
        this.notes = "";
    } 
}