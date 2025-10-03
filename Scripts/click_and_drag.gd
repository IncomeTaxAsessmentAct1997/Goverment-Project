extends Sprite2D
var is_dragging := false
var drag_offset: Vector2 = Vector2.ZERO
var drop_in_progress := false
var dropped := false
@export var drag_bounds_normal: Rect2 = Rect2(Vector2(0, 0), Vector2(800, 600))
@export var drag_bounds_button_pressed: Rect2 = Rect2(Vector2(0, 0), Vector2(800, 600))
@export var drop_zone: Rect2 = Rect2(Vector2(100, 100), Vector2(300, 200))
@export var button_group: String = "buttons"
@export var droppable_group: String = "droppables"
@export var char_node_path: NodePath = "../../Char"
enum HoverMode { ONCE, EVERY_FRAME }
@export var hover_mode: HoverMode = HoverMode.ONCE
var _hovering := false
var last_click_position: Vector2 = Vector2.ZERO
var first_click_done := false

func _ready():
	add_to_group(droppable_group)
	drop_checker()

func _process(delta):
	if drop_in_progress:
		var distance: float = abs(1600.0 - global_position.y)
		if distance > 0.0:
			global_position.y = lerp(global_position.y, 1600.0, (1500.0 * delta) / distance)
			if distance < 1.0:
				global_position.y = 1600.0
				drop_in_progress = false
				visible = false

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos: Vector2 = get_global_mouse_position()
		if event.pressed:
			if not first_click_done:
				first_click_done = true
			last_click_position = mouse_pos
			var half_size: Vector2 = texture.get_size() * scale * 0.5
			if Rect2(global_position - half_size, half_size * 2).has_point(mouse_pos):
				is_dragging = true
				_hovering = false
				drag_offset = global_position - mouse_pos
		elif is_dragging:
			is_dragging = false
			drag_offset = Vector2.ZERO
			_hovering = false
			scale = Vector2(1.25, 1.25)
			var any_toggled: bool = false
			for button in get_tree().get_nodes_in_group(button_group):
				if button.is_toggled:
					any_toggled = true
					break
			if any_toggled and drop_zone.has_point(mouse_pos):
				drop_in_progress = true
				scale = Vector2(1, 1)
				start_drop_timer()
	elif event is InputEventMouseMotion and is_dragging:
		var mouse_pos: Vector2 = get_global_mouse_position()
		var any_toggled: bool = false
		for button in get_tree().get_nodes_in_group(button_group):
			if button.is_toggled:
				any_toggled = true
				break
		var bounds: Rect2 = drag_bounds_button_pressed if any_toggled else drag_bounds_normal
		var half_size: Vector2 = texture.get_size() * scale * 0.5
		var new_pos: Vector2 = mouse_pos + drag_offset
		new_pos.x = clamp(new_pos.x, bounds.position.x + half_size.x, bounds.position.x + bounds.size.x - half_size.x)
		new_pos.y = clamp(new_pos.y, bounds.position.y + half_size.y, bounds.position.y + bounds.size.y - half_size.y)
		global_position = new_pos
		if any_toggled and drop_zone.has_point(mouse_pos):
			if not _hovering or hover_mode == HoverMode.EVERY_FRAME:
				_hovering = true
				scale = Vector2(1, 1)
		elif _hovering:
			_hovering = false
			scale = Vector2(1.25, 1.25)

func start_drop_timer():
	await get_tree().create_timer(2.0).timeout
	dropped = true
	check_all_dropped()

func check_all_dropped():
	for droppable in get_tree().get_nodes_in_group(droppable_group):
		if not droppable.dropped:
			return
	get_node(char_node_path).play_animation(false) 

func drop_checker():
	while true:
		await get_tree().create_timer(1.0).timeout
		var all_dropped: bool = true
		for droppable in get_tree().get_nodes_in_group(droppable_group):
			if not droppable.dropped:
				all_dropped = false
				break
		if all_dropped:
			pass
