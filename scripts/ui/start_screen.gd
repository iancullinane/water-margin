@tool
extends Control

func _ready():
	print(OS.get_data_dir())
	var button = $CenterContainer/StartMenu/VBoxContainer/Button
	button.pressed.connect(_on_start_button_pressed)

func _on_start_button_pressed():
	logging.log("start button pressed")
	get_tree().change_scene_to_file("res://scenes/game.tscn")
