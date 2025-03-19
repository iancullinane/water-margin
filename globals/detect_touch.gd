## DetectTouch is a global singleton listening for player touch

extends Node2D

signal moved
var swipe_start = null
var minimum_drag = 100

func _unhandled_input(event):
	if event.is_action_pressed("click"):
		swipe_start = get_viewport().get_mouse_position()

	if event.is_action_released("click"):
		_calculate_swipe(get_viewport().get_mouse_position())
		
## Calculates the distance from where a player touched to where they released touch
func _calculate_swipe(swipe_end):
	if swipe_start == null: 
		return

	var swipe = swipe_end - swipe_start

	# Determine if the swipe is more horizontal or vertical
	if abs(swipe.x) > abs(swipe.y):  # Horizontal swipe
		if abs(swipe.x) > minimum_drag:
			if swipe.x > 0:
				emit_signal("moved", "right")
			else:
				emit_signal("moved", "left")
	else:  # Vertical swipe
		if abs(swipe.y) > minimum_drag:
			if swipe.y > 0:
				emit_signal("moved", "down")
			else:
				emit_signal("moved", "up")
