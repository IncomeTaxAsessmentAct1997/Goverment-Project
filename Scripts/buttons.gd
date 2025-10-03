extends AnimatedSprite2D

@export var target_frame: int = 0
@export var button_group: String = "buttons"

var original_frame: int
var is_toggled: bool = false

func _ready():
	original_frame = frame
	add_to_group(button_group)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var texture = sprite_frames.get_frame_texture(animation, frame)
		var sprite_rect = Rect2(-texture.get_size() * 0.5, texture.get_size())
		if sprite_rect.has_point(get_local_mouse_position()):
			_reset_other_buttons()
			is_toggled = !is_toggled
			frame = target_frame if is_toggled else original_frame

func _reset_other_buttons():
	for button in get_tree().get_nodes_in_group(button_group):
		if button != self:
			button.reset_to_original()

func reset_to_original():
	frame = original_frame
	is_toggled = false
