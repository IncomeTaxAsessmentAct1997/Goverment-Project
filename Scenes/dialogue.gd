extends Node2D

@onready var item1 = $"1"
@onready var item2 = $"2"
@onready var item3 = $"3"
@onready var item4 = $"4"
@onready var item5 = $"5"
@onready var item6 = $"6"

var gun_names = [
    "Glock\n17",
    "M4A1\nCarbine",
    "AK-\n47",
    "Desert\nEagle",
    "MP5",
    "Barrett\nM82",
    "\nRemington 870",
    "Sig\nSauer P226",
    "Beretta\n92FS",
	"FN\nSCAR"
]

const ANIMATION_DURATION = 0.5
const DELAY_BETWEEN = 3.0

var animation_started = false
var waiting_for_drop = false
var drop_completed = false
var cycling_started = false
var cycle_timer: Timer
var all_labels_off_screen = false
var spawn_counter = 0
var cycle_start_time = 0.0
var cycle_duration = 5.0
var documents_dropped = false
var current_button_pressed: String = ""
var current_gun: String = ""
var initial_positions = {}
var initial_parent_position = Vector2.ZERO

func _ready():
    initial_parent_position = position
    item1.position = Vector2(-423, 30)
    item2.position = Vector2(1060, 81)
    item3.position = Vector2(-423, 234)
    item4.position = Vector2(1060, 336)
    item5.position = Vector2(-423, 387)
    item6.position = Vector2(1060, 482)
    initial_positions[item1] = item1.position
    initial_positions[item2] = item2.position
    initial_positions[item3] = item3.position
    initial_positions[item4] = item4.position
    initial_positions[item5] = item5.position
    initial_positions[item6] = item6.position
    current_gun = gun_names[randi() % gun_names.size()]
    update_label_texts()
    cycle_timer = Timer.new()
    cycle_timer.wait_time = 3.0
    cycle_timer.one_shot = true
    cycle_timer.timeout.connect(_on_cycle_timer_timeout)
    add_child(cycle_timer)

func update_label_texts():
    var label2 = item2.get_node("Label")
    label2.text = "Here You Go. I'll be\npurchasing a " + current_gun
    var label3 = item3.get_node("Label")
    if current_button_pressed == "check":
        label3.text = "You're all set, have a\nnice day"
    else:
        label3.text = "You need to leave\nnow"
    var label4 = item4.get_node("Label")
    if current_button_pressed == "no":
        item4.visible = false
    else:
        item4.visible = true
        label4.text = "Thank You."

func on_button_pressed(button_type: String):
    current_button_pressed = button_type
    update_label_texts()

func reset_dialogue():
    if cycle_timer:
        cycle_timer.stop()
    for tween in get_tree().get_processed_tweens():
        if tween and tween.is_running():
            tween.stop()
    animation_started = false
    waiting_for_drop = false
    drop_completed = false
    cycling_started = false
    all_labels_off_screen = false
    spawn_counter = 0
    cycle_start_time = 0.0
    documents_dropped = false
    current_button_pressed = ""
    current_gun = gun_names[randi() % gun_names.size()]
    position = initial_parent_position
    for item in initial_positions:
        item.position = initial_positions[item]
        item.visible = true
    update_label_texts()

func _on_cycle_timer_timeout():
    if not cycling_started and not all_labels_off_screen:
        start_cycle_dialogue()

func start_cycle_dialogue():
    if not cycling_started:
        cycling_started = true
        cycle_timer.stop()
        cycle_dialogue()

func reset_cycle_timer():
    if cycle_timer and not cycling_started:
        cycle_timer.stop()
        cycle_timer.start()

func check_and_update_spawn_counter():
    var item1_screen_y = (global_position + item1.position).y
    var item2_screen_y = (global_position + item2.position).y
    var item3_screen_y = (global_position + item3.position).y
    var item4_screen_y = (global_position + item4.position).y
    if spawn_counter == 0:
        if item1_screen_y < -20 or item2_screen_y < -20:
            spawn_counter = 1
    elif spawn_counter == 1:
        if item3_screen_y < -20 or item4_screen_y < -20:
            spawn_counter = 2
            adjust_all_positions(-153)

func adjust_all_positions(offset: float):
    item1.position.y += offset
    item2.position.y += offset
    item3.position.y += offset
    item4.position.y += offset
    item5.position.y += offset
    item6.position.y += offset

func update_label_visibility():
    item1.visible = (global_position + item1.position).y >= -20
    item2.visible = (global_position + item2.position).y >= -20
    item3.visible = (global_position + item3.position).y >= -20
    item4.visible = (global_position + item4.position).y >= -20
    item5.visible = (global_position + item5.position).y >= -20
    item6.visible = (global_position + item6.position).y >= -20

func start_dialogue_animation():
    if not animation_started:
        animation_started = true
        animate_initial_items()

func animate_initial_items():
    var tween1 = create_tween()
    tween1.tween_property(item1, "position", Vector2(20, 30), ANIMATION_DURATION)
    tween1.finished.connect(reset_cycle_timer)
    await get_tree().create_timer(DELAY_BETWEEN).timeout
    var tween2 = create_tween()
    tween2.tween_property(item2, "position", Vector2(594, 81), ANIMATION_DURATION)
    tween2.finished.connect(reset_cycle_timer)
    await tween2.finished
    waiting_for_drop = true
    reset_cycle_timer()

func on_documents_dropped():
    if waiting_for_drop and not drop_completed:
        drop_completed = true
        waiting_for_drop = false
        documents_dropped = true
        continue_dialogue()
        cycle_timer.stop()
        cycle_timer.start()

func continue_dialogue():
    if spawn_counter == 1:
        var tween3 = create_tween()
        tween3.tween_property(item3, "position", Vector2(20, 234), ANIMATION_DURATION)
        await get_tree().create_timer(DELAY_BETWEEN).timeout
        if item4.visible:
            var tween4 = create_tween()
            tween4.tween_property(item4, "position", Vector2(594, 336), ANIMATION_DURATION)
            await tween4.finished
        else:
            await get_tree().create_timer(DELAY_BETWEEN).timeout
    else:
        var tween3 = create_tween()
        tween3.tween_property(item3, "position", Vector2(20, 234), ANIMATION_DURATION)
        await get_tree().create_timer(DELAY_BETWEEN).timeout
        if item4.visible:
            var tween4 = create_tween()
            tween4.tween_property(item4, "position", Vector2(594, 336), ANIMATION_DURATION)
            await tween4.finished
        else:
            await get_tree().create_timer(DELAY_BETWEEN).timeout

func cycle_dialogue():
    var move_pattern = [51, 153, 102, 51, 102, 51]
    var pattern_index = 0
    var visible_items = [item1, item2, item3, item4, item5, item6]
    cycle_start_time = Time.get_ticks_msec() / 1000.0
    var total_cycle_time = 5.0
    while cycling_started and is_inside_tree():
        await get_tree().create_timer(2.0).timeout
        var current_time = Time.get_ticks_msec() / 1000.0
        var elapsed_time = current_time - cycle_start_time
        if not documents_dropped and elapsed_time >= total_cycle_time:
            all_labels_off_screen = true
            break
        update_label_visibility()
        check_and_update_spawn_counter()
        var any_visible = false
        for item in visible_items:
            if item.visible:
                any_visible = true
                break
        if not any_visible:
            all_labels_off_screen = true
            break
        var move_amount = move_pattern[pattern_index]
        var tween = create_tween()
        tween.tween_property(self, "position", position + Vector2(0, -move_amount), ANIMATION_DURATION)
        await tween.finished
        update_label_visibility()
        check_and_update_spawn_counter()
        pattern_index = (pattern_index + 1) % move_pattern.size()
