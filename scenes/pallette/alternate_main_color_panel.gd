@tool
extends GridContainer

@onready var MainPanel: NinePatchRect = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	for panel in get_children():
		if panel is Panel:
			panel.mouse_filter = Control.MOUSE_FILTER_STOP  # Ensures the panel captures clicks
	if Engine.is_editor_hint():
		color_panels()
	color_panels()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var clicked_panel = get_panel_under_mouse()
		if clicked_panel:
			var color_rect = find_color_rect(clicked_panel)
			if color_rect:
				MainPanel.self_modulate = get_random_color()

func get_panel_under_mouse() -> Panel:
	var viewport = get_viewport()
	var mouse_pos = viewport.get_mouse_position()
	for panel in get_children():
		if panel is Panel and panel.get_global_rect().has_point(mouse_pos):
			return panel
	return null

func color_panels() -> void:
	for panel in get_children():
		var color_to_change: ColorRect = find_color_rect(panel)
		color_to_change.color = get_random_color()


func get_random_color() -> Color:
	return Color(randf(), randf(), randf(), 1.0)


# Recursively search a node for the Node we want
func find_color_rect(node: Node) -> ColorRect:
	if node is ColorRect:
		return node
	for child in node.get_children():
		var found_rect = find_color_rect(child)
		if found_rect:
			return found_rect
	return null
