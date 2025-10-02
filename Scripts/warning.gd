extends AnimatedSprite2D
# Or use: extends Sprite2D or extends Label

@export var tooltip_text: String = "Tooltip text here"

@onready var warning_label: Label = get_parent().get_parent().get_node("Warning")
var is_hovering: bool = false

func _ready():
	# Set the tooltip text
	if warning_label:
		warning_label.text = tooltip_text
		warning_label.visible = false

func _process(_delta):
	if is_hovering and warning_label:
		# Position tooltip at top-right of mouse
		var mouse_pos = get_global_mouse_position()
		warning_label.global_position = mouse_pos + Vector2(10, -20)

func _on_mouse_entered():
	is_hovering = true
	if warning_label:
		warning_label.visible = true
		warning_label.text = tooltip_text

func _on_mouse_exited():
	is_hovering = false
	if warning_label:
		warning_label.visible = false
		warning_label.global_position = Vector2(0, 0)

# For AnimatedSprite2D, we need to handle mouse detection manually
func _input(event):
	if event is InputEventMouseMotion:
		var local_pos = to_local(event.position)
		var rect = Rect2(-sprite_frames.get_frame_texture(animation, frame).get_size() / 2 if sprite_frames else Vector2.ZERO, 
						 sprite_frames.get_frame_texture(animation, frame).get_size() if sprite_frames else Vector2.ZERO)
		
		if rect.has_point(local_pos):
			if not is_hovering:
				_on_mouse_entered()
		else:
			if is_hovering:
				_on_mouse_exited()
