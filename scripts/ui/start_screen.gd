extends Control

func _ready():
	var button = $CenterContainer/StartMenu/VBoxContainer/Button
	button.pressed.connect(_on_start_button_pressed)

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://main_scene.tscn")
