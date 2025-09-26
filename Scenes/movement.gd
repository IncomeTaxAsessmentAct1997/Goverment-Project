extends Label 
var selct = 0

func _ready():
	update_pos()	

func _input(event):
	if Input.is_action_just_pressed("ui_down"):
		if selct != 3:
			selct += 1
			update_pos()
	if Input.is_action_just_pressed("ui_up"):
		if selct != 0:
			selct -= 1
			update_pos()


func update_pos():
	var obj = get_parent().get_node(str(selct))
	var right_center = Vector2(obj.position.x + obj.size.x, obj.position.y + obj.size.y / 2)
	global_position = Vector2(right_center.x + 20, right_center.y - 19)
