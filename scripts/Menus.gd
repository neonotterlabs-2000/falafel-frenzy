extends Control

# Using get_node_or_null prevents a crash if this script runs in a scene without this label
@onready var total_coins_label = get_node_or_null("TotalCoinsLabel")

func _ready():
	# Update our home screen display to show how much cash they have!
	if total_coins_label:
		total_coins_label.text = "Coins: " + str(Global.total_coins)

func _on_start_button_pressed():
	print("🚀 BUTTON CLICKS ARE WORKING!")
	Global.reset_game()
	get_tree().change_scene_to_file("res://scenes/MainGame.tscn")

func _on_shop_button_pressed():
	get_tree().change_scene_to_file("res://scenes/Shop.tscn")

func _on_rules_button_pressed():
	get_tree().change_scene_to_file("res://scenes/HowToPlay.tscn")
