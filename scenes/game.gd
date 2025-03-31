extends Node2D

func get_map():
	return $Map

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
#	# This label was removed but this is a historcial example covering using the static data json object
	#$Label.text = StaticData.item_data["apple"]["Item"]
