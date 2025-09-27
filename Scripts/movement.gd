extends Label

var selct = 0
var obj = null

func _ready():
	update_pos()	

func _input(event):
	if Input.is_action_just_pressed("ui_down"):
		if selct == 16:
			switch_menu("Background Checks #2", 20, "Background Checks")
		elif selct !=4 and selct !=22 and selct !=33 and selct !=44:
			selct += 1
			update_pos()
	if Input.is_action_just_pressed("ui_up"):
		if selct % 10 != 0:
			selct -= 1
			update_pos()
		elif selct == 20:
			switch_menu("Background Checks", 16, "Background Checks #2")
	if Input.is_action_just_pressed("ui_accept"):
		if selct >= 10 and selct < 30:
			selection()
		match selct:
			0:
				switch_menu("Background Checks", 10, "Menu")
			1:
				switch_menu("Non Profits", 30, "Menu")
			3:
				switch_menu("Applications", 40, "Menu")
			
	if Input.is_action_just_pressed("ui_cancel"):
		if selct >= 10:
			close_all_menus()
			selct = 0
			update_pos()


func switch_menu(menu_name: String, new_selct: int, current_menu: String):
	get_parent().get_node(current_menu).visible = false
	var menu = get_parent().get_node(menu_name)
	if menu:
		menu.visible = true
	selct = new_selct
	update_pos()

func selection():
	print("selection is called")
	if selct < 20:
		var obj = get_parent().get_node("Background Checks").get_node(str(selct))
	else: 
		var obj = get_parent().get_node("Background Checks #2").get_node(str(selct))
	
	if obj.get_theme_color("font_color", "Label") == Color("#00ff00"):
		obj.add_theme_color_override("font_color", Color("#009900"))
	else:
		obj.add_theme_color_override("font_color", Color("#00FF00"))

func close_all_menus():
	for menu_name in ["Background Checks", "Background Checks #2", "Non Profits", "Applications"]:
		var menu = get_parent().get_node_or_null(menu_name)
		if menu:
			menu.visible = false
	get_parent().get_node("Menu").visible = true


func update_pos():
	if selct < 10:
		obj = get_parent().get_node("Menu").get_node_or_null(str(selct))
	elif selct >= 10 and selct < 20:
		obj = get_parent().get_node("Background Checks").get_node_or_null(str(selct))
	elif selct >= 20 and selct < 30:
		obj = get_parent().get_node("Background Checks #2").get_node_or_null(str(selct))
	elif selct >= 30 and selct < 40:
		obj = get_parent().get_node("Non Profits").get_node_or_null(str(selct))
	else:
		obj = get_parent().get_node("Applications").get_node_or_null(str(selct))
	
	var right_center = Vector2(obj.global_position.x + obj.size.x, obj.global_position.y + obj.size.y / 2)
	global_position = Vector2(right_center.x + 20, right_center.y - 19)
	print(selct)
