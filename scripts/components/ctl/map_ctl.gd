extends Node2D

## Thin wrapper to act as the mount point of a map

class_name MapCtl

func is_map_ctl():
	return true

## The mount point owns the live map, so this is the single source of truth
## for "the current map". LevelLoader loads into here and delegates queries
## back to this method.
func get_current_map() -> GameMap:
	if get_child_count() > 0:
		return get_child(0) as GameMap
	return null
