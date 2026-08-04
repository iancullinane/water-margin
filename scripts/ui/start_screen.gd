@tool
extends Control

const SAVE_DIR := "user://savegames/"

@onready var saved_games_container = %SavedGameContainer
@onready var saved_games_list: VBoxContainer = %SavedGameContainer/SavedGames


func _ready():
	print(OS.get_data_dir())

	var button = $CenterContainer/StartMenu/VBoxContainer/Button
	button.pressed.connect(_on_start_button_pressed)

	if not Engine.is_editor_hint():
		_populate_saved_games()


func _populate_saved_games() -> void:
	# Clear placeholder labels from the scene
	for child in saved_games_list.get_children():
		child.queue_free()

	var dir := DirAccess.open(SAVE_DIR)
	if dir == null:
		return

	for file_name in dir.get_files():
		if not file_name.ends_with(".tres"):
			continue
		var label := Label.new()
		label.text = file_name.get_basename()
		saved_games_list.add_child(label)

func _on_start_button_pressed():
	logging.log("start button pressed")
	get_tree().change_scene_to_file("res://scenes/game.tscn")
