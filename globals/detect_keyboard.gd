## DetectKeyboard is a holder to send events from the keyboard

extends Node2D

signal moved
signal zoomed

var last_move_time = 0
var move_buffer = 0.2  # Minimum seconds between moves 

func _input(event):
	var current_time = Time.get_ticks_msec() / 1000.0
	
	if current_time - last_move_time < move_buffer:
		return
		
	if event.is_action("world_up"):
		emit_signal("moved", "up")
		last_move_time = current_time
	
	if event.is_action("world_down"):
		emit_signal("moved", "down")
		last_move_time = current_time

	if event.is_action("world_left"):
		emit_signal("moved", "left")
		last_move_time = current_time

	if event.is_action("world_right"):
		emit_signal("moved", "right")
		last_move_time = current_time

	if event.is_action("zoom_in"):
		emit_signal("zoomed", "in")

	if event.is_action("zoom_out"):
		emit_signal("zoomed", "out")
