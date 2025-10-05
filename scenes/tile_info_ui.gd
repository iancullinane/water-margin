extends CanvasLayer
class_name TileInfoUi


@onready var xy_panel: Label= $Panel/PanelContainer/XYLabel


func _ready()-> void:
	SignalBus.connect("hovered", processUI) 

func processUI(event_data: UiEventData):
	if event_data:
		print(event_data.tile_data)
		xy_panel.text = "X: %s, Y: %s" % [event_data.coordinates.x, event_data.coordinates.y]
		if event_data.tile_data:
			xy_panel.text += "\nTile Data: %s" % [event_data.tile_data.description]
