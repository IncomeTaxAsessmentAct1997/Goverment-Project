extends AnimatedSprite2D

@export var target_frame: int = 0
@export var button_group: String = "buttons"
@export var button_type: String = "check"

var original_frame: int
var is_toggled := false

func _ready():
    original_frame = frame
    add_to_group(button_group)

func _input(event):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        var tex := sprite_frames.get_frame_texture(animation, frame)
        if Rect2(-tex.get_size() * 0.5, tex.get_size()).has_point(get_local_mouse_position()):
            _reset_other_buttons()
            is_toggled = !is_toggled
            frame = target_frame if is_toggled else original_frame
            var dialogue = get_tree().get_first_node_in_group("dialogue")
            if dialogue and dialogue.has_method("on_button_pressed"):
                dialogue.on_button_pressed(button_type)

func _reset_other_buttons():
    for b in get_tree().get_nodes_in_group(button_group):
        if b != self: b.reset_to_original()

func reset_to_original():
    frame = original_frame
    is_toggled = false
