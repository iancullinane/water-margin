extends CanvasLayer

@onready var ground_display: Label = $NinePatchRect2/VBoxContainer/GoundDataDisplay
@onready var terrain_display: Label = $NinePatchRect2/VBoxContainer/TerrainDataDisplay

func _ready()-> void:
	SignalBus.connect("hovered", processUI) 

func processUI(val: UiEventData):
	update_ground_data_display(val.ground_layer_data)
	update_terrain_data_display(val.terrain_layer_data)


func update_ground_data_display(new_label_text: String):
	ground_display.text = new_label_text

func update_terrain_data_display(new_label_text: String):
	terrain_display.text = new_label_text

func get_ground_display()-> Label:
	return ground_display
	
func get_terrain_display()-> Label:
	return terrain_display
