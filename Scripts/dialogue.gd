extends Node2D

@onready var item1 = $"1"
@onready var item2 = $"2"
@onready var item3 = $"3"
@onready var item4 = $"4"
@onready var item5 = $"5"
@onready var item6 = $"6"

# List of gun names
var gun_names = [
    "Glock\n17",
    "M4A1\nCarbine",
    "AK-\n47",
    "Desert\nEagle",
    "MP5",
    "Barrett\nM82",
    "Remington\n870",
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

# Spawn counter system
var spawn_counter = 0  # 0 = initial, 1 = after first pair off-screen, 2 = after second pair
var cycle_start_time = 0.0  # Track when cycling started
var cycle_duration = 5.0  # Duration for 2 cycles: (2 second wait + 0.5 second animation) * 2 movements per cycle * 2 cycles = 10 seconds, but we'll use 5 for 2 movements

# Store initial positions
var initial_positions = {}
var initial_parent_position = Vector2.ZERO

func _ready():
    # Store initial parent position
    initial_parent_position = position
    
    # Set initial positions (off-screen)
    item1.position = Vector2(-423, 30)
    item2.position = Vector2(1060, 81)
    item3.position = Vector2(-423, 234)
    item4.position = Vector2(1060, 336)
    item5.position = Vector2(-423, 387)
    item6.position = Vector2(1060, 482)
    
    # Store initial positions for reset
    initial_positions[item1] = item1.position
    initial_positions[item2] = item2.position
    initial_positions[item3] = item3.position
    initial_positions[item4] = item4.position
    initial_positions[item5] = item5.position
    initial_positions[item6] = item6.position
    
    # Set label 2 text with random gun
    var random_gun = gun_names[randi() % gun_names.size()]
    var label2 = item2.get_node("Label")
    label2.text = "Here You Go. I'll be\npurchasing a " + random_gun
    
    # Set label 3 text for approval
    var label3 = item3.get_node("Label")
    label3.text = "You're all set, have a\nnice day"
    
    # Set label 4 text for thank you
    var label4 = item4.get_node("Label")
    label4.text = "Thank You."
    
    # Create cycle timer
    cycle_timer = Timer.new()
    cycle_timer.wait_time = 3.0
    cycle_timer.one_shot = true
    cycle_timer.timeout.connect(_on_cycle_timer_timeout)
    add_child(cycle_timer)

func reset_dialogue():
    """Reset all dialogue state for a new client"""
    print("=== RESETTING DIALOGUE SYSTEM ===")
    
    # Stop all timers and tweens
    if cycle_timer:
        cycle_timer.stop()
    
    # Kill all active tweens on this node and children
    for tween in get_tree().get_processed_tweens():
        if tween.is_valid():
            tween.kill()
    
    # Reset all state variables
    animation_started = false
    waiting_for_drop = false
    drop_completed = false
    cycling_started = false
    all_labels_off_screen = false
    spawn_counter = 0
    cycle_start_time = 0.0
    
    # Reset parent position
    position = initial_parent_position
    
    # Reset all item positions to initial off-screen positions
    for item in initial_positions:
        item.position = initial_positions[item]
        item.visible = true  # Make sure items are visible again
    
    # Regenerate random gun text for label 2
    var random_gun = gun_names[randi() % gun_names.size()]
    var label2 = item2.get_node("Label")
    label2.text = "Here You Go. I'll be\npurchasing a " + random_gun
    
    print("Dialogue reset complete - ready for new client")

func _on_cycle_timer_timeout():
    if not cycling_started and not all_labels_off_screen:
        print("Cycle timer expired - starting cycle dialogue")
        start_cycle_dialogue()

func start_cycle_dialogue():
    if not cycling_started:
        print("=== STARTING CYCLE DIALOGUE ===")
        cycling_started = true
        cycle_timer.stop()
        cycle_dialogue()

func reset_cycle_timer():
    if cycle_timer and not cycling_started:
        cycle_timer.stop()
        cycle_timer.start()
        print("Cycle timer reset")

func check_and_update_spawn_counter():
    # Check if labels have moved off-screen using LOCAL coordinates (y < -20)
    # Since the parent node moves, we need to check local positions
    var global_threshold = global_position.y - 20
    
    if spawn_counter == 0:
        # Check if item1 or item2 are off-screen (using local coordinates)
        var item1_global_y = global_position.y + item1.position.y
        var item2_global_y = global_position.y + item2.position.y
        
        if item1.position.y < -20 or item2.position.y < -20:
            spawn_counter = 1
            print("=== SPAWN COUNTER INCREASED TO 1 ===")
            print("Current spawn_counter: ", spawn_counter)
            print("Item1 local Y: ", item1.position.y, " Item2 local Y: ", item2.position.y)
    elif spawn_counter == 1:
        # Check if item3 or item4 are off-screen (using local coordinates)
        if item3.position.y < -20 or item4.position.y < -20:
            spawn_counter = 2
            print("=== SPAWN COUNTER INCREASED TO 2 ===")
            print("Current spawn_counter: ", spawn_counter)
            print("Item3 local Y: ", item3.position.y, " Item4 local Y: ", item4.position.y)
            # Decrease all y coordinates by 153
            adjust_all_positions(-153)

func adjust_all_positions(offset: float):
    # Adjust all visible items by the offset
    item1.position.y += offset
    item2.position.y += offset
    item3.position.y += offset
    item4.position.y += offset
    item5.position.y += offset
    item6.position.y += offset
    print("All positions adjusted by: ", offset)

func update_label_visibility():
    # Make labels invisible when their y coordinate is less than -20
    item1.visible = item1.position.y >= -20
    item2.visible = item2.position.y >= -20
    item3.visible = item3.position.y >= -20
    item4.visible = item4.position.y >= -20
    item5.visible = item5.position.y >= -20
    item6.visible = item6.position.y >= -20

func start_dialogue_animation():
    if not animation_started:
        animation_started = true
        animate_initial_items()

func animate_initial_items():
    # First labels always spawn at their original positions (spawn_counter = 0)
    var tween1 = create_tween()
    tween1.tween_property(item1, "position", Vector2(20, 30), ANIMATION_DURATION)
    tween1.finished.connect(reset_cycle_timer)
    
    # Animate item 2 after delay
    await get_tree().create_timer(DELAY_BETWEEN).timeout
    var tween2 = create_tween()
    tween2.tween_property(item2, "position", Vector2(594, 81), ANIMATION_DURATION)
    tween2.finished.connect(reset_cycle_timer)
    
    # Wait for animation to finish, then wait for document drop
    await tween2.finished
    waiting_for_drop = true
    reset_cycle_timer()
    print("Waiting for document drop to continue dialogue...")

func on_documents_dropped():
    if waiting_for_drop and not drop_completed:
        drop_completed = true
        waiting_for_drop = false
        print("Documents dropped - continuing dialogue and starting cycle timer")
        continue_dialogue()
        
        # Start cycle timer - it will trigger auto-scroll after 3 seconds
        cycle_timer.stop()
        cycle_timer.start()
        print("Cycle timer started - auto-scroll will begin in 3 seconds")

func continue_dialogue():
    # Don't stop the cycle timer here - let it run
    
    # Check spawn counter to determine where to spawn (using local coordinates)
    if spawn_counter == 1:
        # Spawn item 3 at local y=234, item 4 at local y=336
        print("Spawning with counter=1: item3 at 234, item4 at 336")
        
        var tween3 = create_tween()
        tween3.tween_property(item3, "position", Vector2(20, 234), ANIMATION_DURATION)
        # Don't reset cycle timer here
        
        await get_tree().create_timer(DELAY_BETWEEN).timeout
        
        var tween4 = create_tween()
        tween4.tween_property(item4, "position", Vector2(594, 336), ANIMATION_DURATION)
        # Don't reset cycle timer here
        
        await tween4.finished
        # Don't reset cycle timer here
    else:
        # Default spawning for counter=0 (using local coordinates)
        print("Spawning with counter=0")
        var tween3 = create_tween()
        tween3.tween_property(item3, "position", Vector2(20, 234), ANIMATION_DURATION)
        # Don't reset cycle timer here
        
        await get_tree().create_timer(DELAY_BETWEEN).timeout
        
        var tween4 = create_tween()
        tween4.tween_property(item4, "position", Vector2(594, 336), ANIMATION_DURATION)
        # Don't reset cycle timer here
        
        await tween4.finished
        # Don't reset cycle timer here

func cycle_dialogue():
    # Movement pattern: 51, 153, 102, 51, 102, 51 
    var move_pattern = [51, 153, 102, 51, 102, 51]
    var pattern_index = 0
    
    # Track visible items
    var visible_items = [item1, item2, item3, item4, item5, item6]
    
    # Start the timer for 2 cycles
    # Each movement takes: 2.0 seconds (wait) + 0.5 seconds (animation) = 2.5 seconds
    # 2 movements (1 cycle) = 5 seconds
    # 2 cycles = 10 seconds total, cut in half = 5 seconds
    cycle_start_time = Time.get_ticks_msec() / 1000.0
    var total_cycle_time = 5.0  # 2 cycles in 5 seconds (half of 10)
    
    print("=== STARTING CYCLE DIALOGUE ===")
    print("Will stop after ", total_cycle_time, " seconds (2 cycles)")
    
    while true:
        await get_tree().create_timer(2.0).timeout
        
        # Check if we've exceeded the time limit for 2 cycles
        var current_time = Time.get_ticks_msec() / 1000.0
        var elapsed_time = current_time - cycle_start_time
        
        print("--- Cycle Update ---")
        print("Current spawn_counter: ", spawn_counter)
        print("Elapsed time: ", elapsed_time, " / ", total_cycle_time)
        
        if elapsed_time >= total_cycle_time:
            print("=== STOPPING SCROLL: Completed 2 cycles (", elapsed_time, " seconds) ===")
            all_labels_off_screen = true
            break
        
        # Update visibility before checking
        update_label_visibility()
        
        # Check and update spawn counter
        check_and_update_spawn_counter()
        
        # Check if all items are off screen
        var any_visible = false
        for item in visible_items:
            if item.visible:
                any_visible = true
                break
        
        if not any_visible:
            all_labels_off_screen = true
            print("All labels moved off screen - stopping cycle")
            break
        
        # Get the movement amount from the pattern
        var move_amount = move_pattern[pattern_index]
        
        # Move the entire Dialogue node up
        var tween = create_tween()
        tween.tween_property(self, "position", position + Vector2(0, -move_amount), ANIMATION_DURATION)
        
        # Update visibility and spawn counter after moving
        await tween.finished
        update_label_visibility()
        check_and_update_spawn_counter()
        
        print("After move - spawn_counter: ", spawn_counter)
        print("Item2 local Y: ", item2.position.y)
        
        # Move to next in pattern (loop back to start after last)
        pattern_index = (pattern_index + 1) % move_pattern.size()
