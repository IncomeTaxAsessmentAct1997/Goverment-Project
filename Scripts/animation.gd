extends Node2D

@onready var backdrop = $Backdrop
@onready var characters = $Characters
@onready var documents = get_parent().get_node("Documents")
@onready var dialogue = get_parent().get_node_or_null("Dialogue")

var is_animating = false
var money = 0
var sprite_paths = [
    "res://Sprites/char1.png",
    "res://Sprites/char2.png",
    "res://Sprites/char3.png",
    "res://Sprites/char4.png"
]
var sprite_index = 0
var sprite_queue = []
var last_sprite_index = -1
var current_sprite: Sprite2D = null
var sprites_shown = []

func _ready():
    money = load_var("user://money.dat", 0)
    backdrop.modulate.a = 1.0
    characters.modulate.a = 0.0
    backdrop.position.x = 0
    documents.position.y = 0
    reset_all_documents()
    if dialogue: dialogue.add_to_group("dialogue")
    await get_tree().create_timer(1.0).timeout
    play_animation(true)

func initialize_sprite_queue():
    sprite_queue.clear()
    for i in sprite_paths.size():
        sprite_queue.append(i)
    sprite_queue.shuffle()
    if last_sprite_index != -1 and sprite_queue.size() > 1 and sprite_queue[0] == last_sprite_index:
        var swap_index = randi_range(1, sprite_queue.size() - 1)
        var temp = sprite_queue[0]
        sprite_queue[0] = sprite_queue[swap_index]
        sprite_queue[swap_index] = temp
    sprites_shown.clear()

func spawn_new_sprite():
    if current_sprite and current_sprite.is_inside_tree():
        current_sprite.queue_free()
    if sprite_queue.is_empty():
        initialize_sprite_queue()
    sprite_index = sprite_queue.pop_front()
    last_sprite_index = sprite_index
    sprites_shown.append(sprite_index)
    current_sprite = Sprite2D.new()
    current_sprite.texture = load(sprite_paths[sprite_index])
    current_sprite.position = Vector2(300, 400)
    add_child(current_sprite)

func get_current_sprite_index() -> int:
    return sprite_index

func play_animation(forward: bool):
    is_animating = true
    var tween = create_tween()
    tween.finished.connect(func():
        is_animating = false
        if forward:
            if dialogue and dialogue.has_method("start_dialogue_animation"):
                dialogue.start_dialogue_animation()
                await get_tree().create_timer(3.5).timeout
                animate_documents()
            else:
                animate_documents()
        else:
            if dialogue and dialogue.has_method("reset_dialogue"):
                dialogue.reset_dialogue()
            await get_tree().create_timer(3.0).timeout
            play_animation(true)
    )
    if forward:
        generate_new_documents()
        spawn_new_sprite()
        documents.position.y = 0
        reset_all_documents()
        backdrop.position.x = 0
        tween.tween_property(backdrop, "position:x", 713, 1.0)
        tween.chain().tween_property(backdrop, "modulate:a", 0.0, 1.0)
        tween.parallel().tween_property(characters, "modulate:a", 1.0, 0.571)
    else:
        reset_all_buttons()
        add_money(50)
        documents.position.y = 0
        reset_all_documents()
        tween.tween_property(characters, "modulate:a", 0.0, 1.0)
        tween.parallel().tween_property(backdrop, "modulate:a", 1.0, 1.0)
        backdrop.position.x = 713
        tween.chain().tween_property(backdrop, "position:x", 0, 1.0)

func animate_documents():
    var doc_tween = create_tween()
    doc_tween.set_trans(Tween.TRANS_CUBIC)
    doc_tween.set_ease(Tween.EASE_OUT)
    doc_tween.tween_property(documents, "position:y", -634, 0.5)
    await doc_tween.finished
    regenerate_documents()

func reset_all_buttons():
    for button in get_tree().get_nodes_in_group("buttons"):
        button.reset_to_original()

func reset_all_documents():
    for droppable in get_tree().get_nodes_in_group("droppables"):
        droppable.drop_in_progress = false
        droppable.dropped = false
        droppable.is_dragging = false
        droppable._hovering = false
        droppable.drag_offset = Vector2.ZERO
        droppable.visible = true
        droppable.scale = Vector2(1.25, 1.25)
        if not droppable.has_meta("original_local_position"):
            droppable.set_meta("original_local_position", droppable.position)
        droppable.position = droppable.get_meta("original_local_position")

func add_money(amount: int):
    if money == null: money = 0
    money += amount
    save_var("user://money.dat", money)

func generate_new_documents():
    var doc_generator = get_tree().get_first_node_in_group("document_generator")
    if doc_generator and doc_generator.has_method("generate"):
        doc_generator.generate()

func regenerate_documents():
    pass

func save_var(path: String, data):
    var file = FileAccess.open(path, FileAccess.WRITE)
    if file:
        file.store_var(data)
        file.close()

func load_var(path: String, default):
    if FileAccess.file_exists(path):
        var file = FileAccess.open(path, FileAccess.READ)
        if file:
            var val = file.get_var()
            file.close()
            return val
    return default
