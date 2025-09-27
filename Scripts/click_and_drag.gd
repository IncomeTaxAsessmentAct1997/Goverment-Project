extends Sprite2D

var is_dragging = false
var drag_offset = Vector2.ZERO

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if is_mouse_over_sprite():
					start_drag(event.position)
			else:
				stop_drag()
	elif event is InputEventMouseMotion:
		if is_dragging:
			drag_sprite(event.position)

func is_mouse_over_sprite() -> bool:
	if texture == null:
		return false
	var texture_size = texture.get_size()
	var sprite_rect = Rect2(global_position - texture_size * 0.5, texture_size)
	var mouse_pos = get_global_mouse_position()
	return sprite_rect.has_point(mouse_pos)

func start_drag(mouse_pos: Vector2):
	is_dragging = true
	drag_offset = global_position - mouse_pos

func drag_sprite(mouse_pos: Vector2):
	global_position = mouse_pos + drag_offset

func stop_drag():
	is_dragging = false
	drag_offset = Vector2.ZERO
