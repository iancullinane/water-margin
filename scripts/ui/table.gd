extends Control

var table_result = []


func _ready():
	GameData.data_updated.connect(_on_data_updated)	
	table_result = GameData.select_players()
	refresh_table_view()
	
func _on_data_updated() -> void:
	print("Data updated, refresh view")
	table_result = GameData.select_players()
	refresh_table_view()

func refresh_table_view() -> void:
	var table_container = $Panel/MarginContainer/ScrollContainer/VBoxContainer
	var children = table_container.get_children()
	for i in range(1, children.size()):  # Start from index 1 to skip the first child
		children[i].queue_free()
		
	for player in table_result:
		var row = HBoxContainer.new()  # Create a row
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # Make it stretch
		
		var name_label = Label.new()
		name_label.text = player["name"]
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # Stretch evenly
		
		var score_label = Label.new()
		score_label.text = str(player["stat"])
		score_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # Stretch evenly
		
		row.add_child(name_label)
		row.add_child(score_label)
		
		table_container.add_child(row)  
