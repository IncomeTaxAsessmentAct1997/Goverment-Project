extends ColorRect

func _ready():
    fade_from_black()

func fade_from_black():
    modulate.a = 1.0
    var tween = create_tween()
    tween.tween_property(self, "modulate:a", 0.0, 1.0).from(1.0)
