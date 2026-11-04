extends Control

func _on_back_button_pressed():
	# This sends the player straight back to your main menu scene!
	get_tree().change_scene_to_file("res://scenes/StartMenu.tscn")
