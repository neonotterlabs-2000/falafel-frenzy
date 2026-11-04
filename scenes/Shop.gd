extends Control

@onready var coin_label = $CoinLabel
@onready var halloumi_button = $HalloumiButton
@onready var pickle_button = $PickleButton
@onready var tomato_button = $TomatoButton

func _ready():
	update_shop_ui()

func update_shop_ui():
	# 1. Show the player's current cash balance
	coin_label.text = "$" + str(Global.total_coins)
	
	# 2. Update button texts based on what is already unlocked
	if Global.unlocked_ingredients["halloumi"]:
		halloumi_button.text = "UNLOCKED"
		halloumi_button.disabled = true
	
	if Global.unlocked_ingredients["pickle"]:
		pickle_button.text = "UNLOCKED"
		pickle_button.disabled = true
		
	if Global.unlocked_ingredients["tomato"]:
		tomato_button.text = "UNLOCKED"
		tomato_button.disabled = true

func _on_halloumi_button_pressed():
	if Global.total_coins >= 20 and not Global.unlocked_ingredients["halloumi"]:
		Global.total_coins -= 20
		Global.unlocked_ingredients["halloumi"] = true
		Global.save_game()
		update_shop_ui()

func _on_pickle_button_pressed():
	if Global.total_coins >= 40 and not Global.unlocked_ingredients["pickle"]:
		Global.total_coins -= 40
		Global.unlocked_ingredients["pickle"] = true
		Global.save_game()
		update_shop_ui()

func _on_tomato_button_pressed():
	if Global.total_coins >= 80 and not Global.unlocked_ingredients["tomato"]:
		Global.total_coins -= 80
		Global.unlocked_ingredients["tomato"] = true
		Global.save_game()
		update_shop_ui()

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/StartMenu.tscn")
