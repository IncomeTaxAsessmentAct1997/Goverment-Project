extends Label

var selct = 0
var obj = null
var selected_checks = []
var selected_action = -1
var action_just_completed = false
var opinions = {}
var exists = {}
var leniency = 30
var effect = 0
var money = 0

func _ready():
	load_selections()
	load_justice_data()
	update_pos()
	fade_from_black()

func _input(event):
	if Input.is_action_just_pressed("ui_down"):
		match selct:
			16:
				switch_page("Checks/Background Checks #2", 20, "Checks/Background Checks")
				return
			66:
				switch_page("Justices/Page 2", 70, "Justices/Page 1")
				return
		if not selct in [4, 22, 33, 44, 66, 71]:
			selct += 1
			update_pos()

	if Input.is_action_just_pressed("ui_up"):
		match selct:
			20:
				switch_page("Checks/Background Checks", 16, "Checks/Background Checks #2")
				return
			70:
				switch_page("Justices/Page 1", 66, "Justices/Page 2")
				return
		if selct % 10 != 0:
			selct -= 1
			update_pos()

	if Input.is_action_just_pressed("ui_accept"):
		action_just_completed = false
		if selct >= 10 and selct < 30:
			selection()
		elif selct >= 60 and selct <= 71:
			if selected_action == 32:
				var judge_opinion = opinions.get(selct, 100)
				var normalized = judge_opinion / 100.0
				var success_chance = 0.5 + 49.5 * pow(1 - normalized, 3)
				if randf() * 100 < success_chance:
					exists[selct] = false
					var judge_label = get_parent().get_node("Justices/Page 1").get_node_or_null(str(selct))
					if judge_label == null:
						judge_label = get_parent().get_node("Justices/Page 2").get_node(str(selct))
					judge_label.text = "Empty Seat"
					money -= 1000
				save_justice_data()
				selected_action = -1
				action_just_completed = true
				switch_page("Justices/Page 1", 66, "Justices/Page 2")
				switch_menu("Non Profits", 30, "Justices")
			elif selected_action == 33:
				var opinion_decrease = 10 + effect
				opinions[selct] = opinions.get(selct, 100) - opinion_decrease
				money -= 500
				save_justice_data()
				selected_action = -1
				action_just_completed = true
				switch_page("Justices/Page 1", 66, "Justices/Page 2")
				switch_menu("Non Profits", 30, "Justices")

		match selct:
			0: switch_menu("Checks", 10, "Menu")
			1: switch_menu("Non Profits", 30, "Menu")
			2: switch_menu("News", 50, "Menu")
			3: switch_menu("Applications", 40, "Menu")
			4:
				get_parent().visible = false
				fade_to_black()
			30:
				if not action_just_completed:
					if money < 500:
						action_just_completed = true
						return
					leniency += 10 + effect
					money -= 500
					save_justice_data()
					action_just_completed = true
			31:
				if money < 300:
					action_just_completed = true
					return
				effect += 5
				money -= 300
				save_justice_data()
				action_just_completed = true
			32:
				if money < 1000:
					action_just_completed = true
					return
				selected_action = 32
				switch_menu("Justices", 60, "Non Profits")
				action_just_completed = true
			33:
				if money < 500:
					action_just_completed = true
					return
				selected_action = 33
				switch_menu("Justices", 60, "Non Profits")
				action_just_completed = true

	if Input.is_action_just_pressed("ui_cancel"):
		if selct >= 10 and selct < 60:
			close_all_menus()
			selct = 0
			update_pos()
		elif selct >= 60 and selct <= 71:
			switch_page("Justices/Page 1", 66, "Justices/Page 2")
			switch_menu("Non Profits", 30, "Justices")

func switch_menu(menu_name: String, new_selct: int, current_menu: String):
	get_parent().get_node(current_menu).visible = false
	var menu = get_parent().get_node(menu_name)
	menu.visible = true
	if menu_name == "Checks":
		get_parent().get_node("Checks/Background Checks").visible = true
		get_parent().get_node("Checks/Background Checks #2").visible = false
	if menu_name == "Justices":
		get_parent().get_node("Justices/Page 1").visible = true
		get_parent().get_node("Justices/Page 2").visible = false
	if menu_name == "Non Profits":
		get_parent().get_node("Non Profits/34").text = "Current Funds: " + str(money) + "$"
	selct = new_selct
	update_pos()

func switch_page(page_name: String, new_selct: int, current_page: String):
	get_parent().get_node(current_page).visible = false
	get_parent().get_node(page_name).visible = true
	selct = new_selct
	update_pos()

func selection():
	var obj = get_parent().get_node("Checks/Background Checks").get_node(str(selct)) if selct < 20 else get_parent().get_node("Checks/Background Checks #2").get_node(str(selct))
	if obj.get_theme_color("font_color", "Label") == Color("#00ff00"):
		obj.add_theme_color_override("font_color", Color("#009900"))
		selected_checks.erase(selct)
	else:
		obj.add_theme_color_override("font_color", Color("#00FF00"))
		selected_checks.append(selct)
	save_selections()

func save_var(path: String, data):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_var(data)
	file.close()

func load_var(path: String, default):
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var val = file.get_var()
		file.close()
		return val
	return default

func save_selections():
	save_var("user://select.dat", selected_checks)

func load_selections():
	selected_checks = load_var("user://select.dat", [])
	apply_selections()

func apply_selections():
	for check_id in selected_checks:
		var obj = get_parent().get_node("Checks/Background Checks").get_node_or_null(str(check_id)) if check_id < 20 else get_parent().get_node("Checks/Background Checks #2").get_node_or_null(str(check_id))
		obj.add_theme_color_override("font_color", Color("#00FF00"))

func save_justice_data():
	save_var("user://opinions.dat", opinions)
	save_var("user://exists.dat", exists)
	save_var("user://leniency.dat", leniency)
	save_var("user://effect.dat", effect)
	save_var("user://money.dat", money)

func load_justice_data():
	for i in range(60, 72):
		opinions[i] = 100
		exists[i] = true
	opinions = load_var("user://opinions.dat", opinions)
	exists = load_var("user://exists.dat", exists)
	leniency = load_var("user://leniency.dat", 30)
	effect = load_var("user://effect.dat", 0)
	money = load_var("user://money.dat", 500)

func close_all_menus():
	for menu_name in ["Checks", "Non Profits", "News", "Applications", "Justices"]:
		var menu = get_parent().get_node_or_null(menu_name)
		menu.visible = false
	get_parent().get_node("Menu").visible = true

func update_pos():
	if selct < 10:
		obj = get_parent().get_node("Menu").get_node(str(selct))
	elif selct < 20:
		obj = get_parent().get_node("Checks/Background Checks").get_node(str(selct))
	elif selct < 30:
		obj = get_parent().get_node("Checks/Background Checks #2").get_node(str(selct))
	elif selct < 40:
		obj = get_parent().get_node("Non Profits").get_node(str(selct))
	elif selct < 50:
		obj = get_parent().get_node("Applications").get_node(str(selct))
	elif selct < 60:
		obj = get_parent().get_node("News").get_node(str(selct))
	elif selct < 70:
		obj = get_parent().get_node("Justices/Page 1").get_node(str(selct))
	elif selct < 80:
		obj = get_parent().get_node("Justices/Page 2").get_node(str(selct))

	var right_center = Vector2(obj.global_position.x + obj.size.x, obj.global_position.y + obj.size.y / 2)
	global_position = Vector2(right_center.x + 20, right_center.y - 19)

func fade_to_black():
	var fade_rect = get_parent().get_parent().get_node("ColorRect")
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 1.0).from(fade_rect.modulate.a)
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://Scenes/shop.tscn"))

func fade_from_black():
	var fade_rect = get_parent().get_parent().get_node("ColorRect")
	fade_rect.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 1.0).from(1.0)
