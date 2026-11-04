extends Control

func _on_retry_button_pressed():
	Global.reset_game()
	get_tree().change_scene_to_file("res://scenes/MainGame.tscn")

func _on_quit_button_pressed():
	get_tree().change_scene_to_file("res://scenes/StartMenu.tscn")
