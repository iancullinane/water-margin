# TODO: This can probably be broken out nicer
extends VBoxContainer

var self_opened = true

@onready var button1 = $Color1
@onready var button2 = $Color2
@onready var button3 = $Color3

@onready var MainPanel = get_parent()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		toggle_menu()
		
func toggle_menu():
	self_opened = !self_opened
	if self_opened:
		MainPanel.visible = false
	else:
		MainPanel.visible = true
