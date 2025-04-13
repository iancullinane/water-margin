## DetectKeyboard is a holder to send events from the keyboard

extends Node2D

signal moved
signal zoomed

func _input(event):
	if event.is_pressed() and not event.is_echo():
		if event.is_action("world_up"):
			emit_signal("moved", "up")
		
		if event.is_action("world_down"):
			emit_signal("moved", "down")
	
		if event.is_action("world_left"):
			emit_signal("moved", "left")

		if event.is_action("world_right"):
			emit_signal("moved", "right")

		if event.is_action("zoom_in"):
			emit_signal("zoomed", "in")

		if event.is_action("zoom_out"):
			emit_signal("zoomed", "out")
