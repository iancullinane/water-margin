extends Node2D

#var main_game := get_parent()
#@onready var map = $Map

func get_map() -> GameMap:
	return $Map
