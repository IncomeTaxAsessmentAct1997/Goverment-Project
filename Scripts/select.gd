extends Node

var leniency_cost = 30
var selected_checks = []
var supreme_court_leniency
var news
var action
var lastnames = ["Anderson","Johnson","Thompson","Martinez","Clark","Robinson","Walker","Hall","Young","Allen","Wright","King","Scott","Green","Adams","Baker","Nelson","Carter","Mitchell","Perez"]


func _ready():
	load_selected_checks()
	calculate_cost()

func load_selected_checks():
	if FileAccess.file_exists("user://select.dat"):
		var file = FileAccess.open("user://select.dat", FileAccess.READ)
		selected_checks = file.get_var()
		file.close()

func calculate_cost():
	leniency_cost = 0
	
	for check_id in selected_checks:
		match check_id:
			10, 11, 12:
				leniency_cost += 10
			13, 14:
				leniency_cost += 15
			15, 16:
				leniency_cost += 20
			20, 21, 22:
				leniency_cost += 25
		
func supreme_court():
	var article = get_parent().get_node("News/Article").text
	match action:
		1:
			article = "Supreme Court strikes down\nrecently passed gun control in\nBurlingame, calling it gross\noverreach by a radical left\ngovernment."
		2:
			article = "Justice Brown has been\n successfully impeached after\n immense backlash following\n recent revelations.\n"
		3:
			article = "Congress voted to impeach\nJustice Brown today\nbut were ultimately unsuccessful\ndespite calls from several\nnon-profit organizations."
		4:
			article = "Tragedy struck as 0 mass\nshooting incidents occured	\nthe police are still\ninvestigating but it's been\nuncovered that at least 5 people\nwere killed."
		5: 
			article = "Scathing evidence has been\nreleased to the public today\nfollowing an investigation into\nJustice Brown which has led to\nmore calls to resign from\nmembers of Congress."
		6:
			article = "Public opinion has reached an all\ntime low following recent\nincriminating evidence against\nJustice Brown with some members\nof Congress calling for an\nimpeachment hearing."
		7:
			article = "Public opinion of Justice Brown\nhas been rapidly dropping\nfollowing recent allegations."
		8:
			article = "Following recent allegations\npublic opinion of Justice Brown\nhas slowly been decreasing but\npolls show that public opinion\nis still generally positive."
