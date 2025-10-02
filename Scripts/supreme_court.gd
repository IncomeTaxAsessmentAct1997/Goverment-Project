extends Node

var lastnames = ["Anderson","Johnson","Thompson","Martinez","Clark","Robinson","Walker","Hall","Young","Allen","Wright","King","Scott","Green","Adams","Baker","Nelson","Carter","Mitchell","Perez"]

func _ready():
    var selected_names = []
    
    if FileAccess.file_exists("user://justice.dat"):
        var file = FileAccess.open("user://justice.dat", FileAccess.READ)
        selected_names = file.get_var()
        file.close()
    else:
        while selected_names.size() < 9:
            var name = lastnames[randi() % lastnames.size()]
            if not selected_names.has(name):
                selected_names.append(name)
        
        var file = FileAccess.open("user://justice.dat", FileAccess.WRITE)
        if file:
            file.store_var(selected_names)
            file.close()
    
    for i in range(7):
        get_node("Page 1/" + str(60 + i)).text = "Justice " + selected_names[i]
    
    for i in range(2):
        get_node("Page 2/" + str(70 + i)).text = "Justice " + selected_names[7 + i]
