extends Node2D
class_name MapCtl

func is_map_ctl():
	return true

func get_current_map() -> Node:
	if get_child_count() > 0:
		return get_child(0)
	return null
