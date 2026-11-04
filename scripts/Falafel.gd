extends RigidBody2D

signal sliced(is_bomb, points) # Updated to send points!
signal missed

@onready var whole_sprite = $WholeSprite
@onready var left_half = $LeftHalf
@onready var right_half = $RightHalf
@onready var collision_shape = $CollisionShape2D
@onready var particles = $GPUParticles2D
@onready var sauce_splash = $SauceSplash 

var is_sliced = false
var is_bomb = false 

func _ready():
	left_half.hide()
	right_half.hide()
	sauce_splash.hide()

# This function turns a normal falafel into our squeeze bottle trap
func convert_to_bomb(bottle_texture: Texture2D):
	is_bomb = true
	whole_sprite.texture = bottle_texture
	whole_sprite.scale = Vector2(1.2, 1.2)
	collision_shape.scale = Vector2(1.2, 1.2)
	sauce_splash.scale = Vector2(1.5, 1.5)

# NEW: Dynamically changes textures for your shop unlocks and handles scaling!
func set_ingredient_type(whole_tex: Texture2D, left_tex: Texture2D, right_tex: Texture2D):
	is_bomb = false
	whole_sprite.texture = whole_tex
	left_half.texture = left_tex
	right_half.texture = right_tex
	
	# Check the name of the file to see what ingredient it is
	var texture_path = whole_tex.resource_path.to_lower()
	
	if "halloumi" in texture_path:
		whole_sprite.scale = Vector2(1.5, 1.5)
		left_half.scale = Vector2(1.5, 1.5)
		right_half.scale = Vector2(1.5, 1.5)
		collision_shape.scale = Vector2(1.5, 1.5)
	elif "pickle" in texture_path:
		whole_sprite.scale = Vector2(1.1, 1.1)
		left_half.scale = Vector2(1.1, 1.1)
		right_half.scale = Vector2(1.1, 1.1)
		collision_shape.scale = Vector2(1.1, 1.1)
	elif "tomato" in texture_path:
		whole_sprite.scale = Vector2(1.2, 1.2)
		left_half.scale = Vector2(1.2, 1.2)
		right_half.scale = Vector2(1.2, 1.2)
		collision_shape.scale = Vector2(1.2, 1.2)
	else:
		# ORIGINAL FALAFEL
		pass

func slice(_impulse_pos: Vector2):
	if is_sliced or not is_inside_tree(): return  
	is_sliced = true
	
	collision_shape.set_deferred("disabled", true)
	whole_sprite.hide()
	
	# Determine points before sending the signal
	var points_reward = 1
	if not is_bomb and whole_sprite.texture:
		var texture_path = whole_sprite.texture.resource_path.to_lower()
		if "halloumi" in texture_path:
			points_reward = 3   # 3 Points for Halloumi!
		elif "pickle" in texture_path:
			points_reward = 6   # 6 Points for Pickle!
		elif "tomato" in texture_path:
			points_reward = 10   # 10 Points for Tomato!

	if is_bomb:
		sauce_splash.show()
		var tween = create_tween()
		tween.tween_property(sauce_splash, "modulate:a", 0.0, 0.8)
	else:
		left_half.show()
		right_half.show()
		var tween = create_tween().set_parallel(true)
		# Splitting movement
		tween.tween_property(left_half, "position", left_half.position + Vector2(-100, 50), 0.5)
		tween.tween_property(right_half, "position", right_half.position + Vector2(100, 50), 0.5)
		tween.tween_property(left_half, "modulate:a", 0.0, 0.5).set_delay(0.5)
		tween.tween_property(right_half, "modulate:a", 0.0, 0.5).set_delay(0.5)
	
	particles.emitting = true
	emit_signal("sliced", is_bomb, points_reward) # Sends both values!
	
	await scene_tree_timer(1.0)
	queue_free()

func scene_tree_timer(delay: float):
	if is_inside_tree():
		await get_tree().create_timer(delay).timeout

func _on_visible_on_screen_notifier_2d_screen_exited():
	if not is_sliced and position.y > 0:
		emit_signal("missed", is_bomb) 
	queue_free()
