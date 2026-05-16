extends Node2D

## Thin wrapper to act as the mount point of a map

class_name MapCtl

func is_map_ctl():
	return true

func get_current_map() -> Node:
	if get_child_count() > 0:
		return get_child(0)
	return null
