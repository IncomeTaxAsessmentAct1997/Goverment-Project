extends Sprite2D

var is_dragging = false
var drag_offset = Vector2.ZERO

@export var drag_bounds := Rect2(Vector2(0, 0), Vector2(800, 600))

func _input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if event.pressed:
                if is_mouse_over_sprite():
                    start_drag(get_global_mouse_position())
            else:
                stop_drag()
    elif event is InputEventMouseMotion:
        if is_dragging:
            drag_sprite(get_global_mouse_position())

func is_mouse_over_sprite() -> bool:
    if texture == null:
        return false
    var scaled_size = texture.get_size() * scale
    var sprite_rect = Rect2(global_position - scaled_size * 0.5, scaled_size)
    var mouse_pos = get_global_mouse_position()
    return sprite_rect.has_point(mouse_pos)

func start_drag(mouse_pos: Vector2):
    is_dragging = true
    drag_offset = global_position - mouse_pos

func drag_sprite(mouse_pos: Vector2):
    var new_pos = mouse_pos + drag_offset

    var half_size = (texture.get_size() * scale) * 0.5
    new_pos.x = clamp(new_pos.x, drag_bounds.position.x + half_size.x, drag_bounds.position.x + drag_bounds.size.x - half_size.x)
    new_pos.y = clamp(new_pos.y, drag_bounds.position.y + half_size.y, drag_bounds.position.y + drag_bounds.size.y - half_size.y)

    global_position = new_pos

func stop_drag():
    is_dragging = false
    drag_offset = Vector2.ZERO
