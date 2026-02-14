# This shouldn't be a node, it should be an Object or RefCounted
# as the additionaly load of the Node type os not needed
extends Control

@onready var NameField = $VBoxContainer/NameEntry/TextEdit
@onready var StatField = $VBoxContainer/StatEntry/TextEdit

func _on_insert_button_down() -> void:
	var data = {
		"name": NameField.text,
		"stat": int(StatField.text)
	}
	var success = GameData.add_row("players", data)
	if success:
		print("Inserted {name}: {stat}".format(data))
	else:
		print(Errors.DATA_INSERT_FAILED)

func _on_select_button_down() -> void:
	var selection = GameData.db.select_rows("players", "stat >= 0", ["*"])
	if selection.size() == 0:
		print(Errors.DATA_SELECT_FAILED)
	else:
		print(selection)
		
func _on_update_button_down() -> void:
	var success = GameData.update_rows("players", "name = '" + NameField.text + "'", {"stat": int(StatField.text)})
	if success:
		print("updated")
	else:
		print(Errors.DATA_UPDATE_FAILED)

func _on_delete_button_down() -> void:
	GameData.delete_rows("players", "name = '" + NameField.text + "'")


func _on_custom_button_down() -> void:
	pass # Replace with function body.


func _on_create_table_button_down() -> void:
	var table = {
		"id": {"data_type": "int", "primary_key": true, "auto_increment": true},
		"name": {"data_type": "text"},
		"stat": {"data_type": "float"}
	}
	GameData.db.create_table("players", table)
