extends Node2D

@export var falafel_scene: PackedScene
@export var bottle_texture: Texture2D # Slot to load your bottle image

# --- PAUSE BUTTON SETTINGS: Drag your Play icon PNG into this new slot! ---
@export_group("Pause Settings")
@export var play_icon: Texture2D
@onready var pause_button = $CanvasLayer/UI/PauseButton
var pause_icon: Texture2D # Will automatically store your default pause texture
# --------------------------------------------------------------------------

# --- NEW: Drag and drop your asset images into these Inspector slots! ---
@export_group("Ingredient Textures")
@export var falafel_whole: Texture2D
@export var falafel_left: Texture2D
@export var falafel_right: Texture2D

@export var halloumi_whole: Texture2D
@export var halloumi_left: Texture2D
@export var halloumi_right: Texture2D

@export var pickle_whole: Texture2D
@export var pickle_left: Texture2D
@export var pickle_right: Texture2D

@export var tomato_whole: Texture2D
@export var tomato_left: Texture2D
@export var tomato_right: Texture2D
# ---------------------------------------------------------------------

@onready var spawn_timer = $SpawnTimer
@onready var score_label = $CanvasLayer/UI/ScoreLabel
@onready var lives_label = $CanvasLayer/UI/LivesLabel

var swipe_start = Vector2.ZERO
var swiping = false
var bomb_chance = 0.2 # 20% chance a flying item will be a bottle trap

func _ready():
	Global.reset_game()
	update_ui()
	spawn_timer.start()
	
	# --- PAUSE BUTTON SETUP ---
	if pause_button:
		# Save the original pause icon texture so we can swap back to it later
		pause_icon = pause_button.texture_normal 
		# Ensures the button works even when the tree is paused!
		pause_button.process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	# Don't track swipes or slices if the game is paused
	if get_tree().paused:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				swiping = true
				swipe_start = event.position
			else:
				swiping = false
	
	if event is InputEventMouseMotion and swiping:
		check_slice(event.position)

func check_slice(pos: Vector2):
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collide_with_bodies = true
	
	var results = space_state.intersect_point(query)
	for result in results:
		var body = result.collider
		if body.has_method("slice"):
			body.slice(pos)

func _on_spawn_timer_timeout():
	var difficulty_factor = min(1.0 + (Global.score / 250.0), 1.8)
	spawn_timer.wait_time = max(1.2 / difficulty_factor, 0.35) 
	
	var item = falafel_scene.instantiate()
	add_child(item)
	
	# 1. COUNT EXISTING BOTTLES: Look at all flying items currently on screen
	var current_bottle_count = 0
	for active_item in get_children():
		if "is_bomb" in active_item and active_item.is_bomb == true:
			current_bottle_count += 1
	
	# 2. CAP THE TRAPS: Only roll for a bottle if there are fewer than 2 on screen
	if randf() < bomb_chance and bottle_texture and current_bottle_count < 2:
		item.convert_to_bomb(bottle_texture)
	else:
		# --- NEW: Build a pool of all unlocked options from Global.gd ---
		var available_ingredients = []
		for key in Global.unlocked_ingredients.keys():
			if Global.unlocked_ingredients[key] == true:
				available_ingredients.append(key)
				
		# Pick a random ingredient name from your unlocked list
		var chosen = available_ingredients.pick_random()
		
		# Give the flying scene its correct textures dynamically
		match chosen:
			"falafel":
				item.set_ingredient_type(falafel_whole, falafel_left, falafel_right)
			"halloumi":
				item.set_ingredient_type(halloumi_whole, halloumi_left, halloumi_right)
			"pickle":
				item.set_ingredient_type(pickle_whole, pickle_left, pickle_right)
			"tomato":
				item.set_ingredient_type(tomato_whole, tomato_left, tomato_right)
		# -----------------------------------------------------------------
	
	# Random spawn position at bottom
	var screen_size = get_viewport_rect().size
	item.position = Vector2(randf_range(100, screen_size.x - 100), screen_size.y + 50)
	
	# Launch upward
	var base_y_velocity = randf_range(-700, -950) * difficulty_factor
	var capped_y_velocity = clamp(base_y_velocity, -1150.0, -600.0)
	
	var launch_velocity = Vector2(
		randf_range(-120, 120) * difficulty_factor, 
		capped_y_velocity
	)
	item.linear_velocity = launch_velocity
	item.angular_velocity = randf_range(-5, 5) * difficulty_factor
	
	item.connect("sliced", _on_item_sliced)
	item.connect("missed", _on_item_missed)

# FIXED: Now accepts the points argument from Falafel.gd!
func _on_item_sliced(was_bomb: bool, points: int = 1):
	if was_bomb:
		Global.lives -= 1
	else:
		Global.score += points # Custom points added smoothly here!
		
	update_ui()
	check_game_over()

func _on_item_missed(was_bomb: bool):
	if not was_bomb:
		Global.lives -= 1
		update_ui()
		check_game_over()

func check_game_over():
	if Global.lives <= 0:
		Global.total_points += Global.score # Keeps history intact
		
		# --- NEW: Convert round score into wallet fortune matching your shop mockup! ---
		Global.total_coins += Global.score
		
		Global.save_game()                  # Save it safely to the system!
		
		get_tree().change_scene_to_file("res://scenes/GameOver.tscn")

func update_ui():
	score_label.text = "Score: " + str(Global.score)
	lives_label.text = "Lives: " + str(Global.lives)

# Connected to your PauseButton pressed() signal
func _on_pause_button_pressed():
	var is_pausing = !get_tree().paused
	get_tree().paused = is_pausing
	
	if is_pausing:
		if play_icon:
			pause_button.texture_normal = play_icon
	else:
		if pause_icon:
			pause_button.texture_normal = pause_icon
