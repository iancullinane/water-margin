extends CanvasLayer


func get_ground_display()-> Label:
	return $NinePatchRect2/VBoxContainer/GoundDataDisplay
	
func get_terrain_display()-> Label:
	return $NinePatchRect2/VBoxContainer/TerrainDataDisplay
