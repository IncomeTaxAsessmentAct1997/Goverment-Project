extends Node2D
@onready var backdrop = $Backdrop
@onready var characters = $Characters
var is_animating = false

func _ready():
	backdrop.modulate.a = 1.0
	characters.modulate.a = 0.0
	backdrop.position.x = 0
	await get_tree().create_timer(1.0).timeout
	play_animation(true)

func play_animation(forward: bool):
	is_animating = true
	var tween = create_tween()
	tween.finished.connect(func(): is_animating = false)
	
	if forward:
		backdrop.position.x = 0
		tween.tween_property(backdrop, "position:x", 713, 1.0)
		tween.chain().tween_property(backdrop, "modulate:a", 0.0, 1.0)
		tween.parallel().tween_property(characters, "modulate:a", 1.0, 0.571)
	else:
		tween.tween_property(characters, "modulate:a", 0.0, 1.0)
		tween.parallel().tween_property(backdrop, "modulate:a", 1.0, 1.0)
		backdrop.position.x = 713
		tween.chain().tween_property(backdrop, "position:x", 0, 1.0)
