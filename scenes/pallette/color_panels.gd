# @tool
# extends GridContainer

# @export var start_color: Color = Color.RED
# @export var end_color: Color = Color.BLUE
# @export var grid_size: int = 9  # 3x3 Grid
# #@export var columns: int = 3  # Must match the GridContainer columns

# func _ready():
# 	if Engine.is_editor_hint():
# 		generate_grid()
# 	generate_grid()


# func generate_grid():
# 	# Ensure the GridContainer has the correct column count
# 	columns = max(1, columns)  # Prevent division by zero

# 	# Remove old children
# 	for child in get_children():
# 		remove_child(child)
# 		child.queue_free()

# 	# Create new grid elements
# 	for i in range(grid_size):
# 		var panel = Panel.new()
		
# 		# Make the panel auto-size in the available space
# 		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
# 		panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
		
# 		add_child(panel)

# 		var color_rect = ColorRect.new()
# 		color_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
# 		color_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL

# 		# Interpolate colors
# 		var t = float(i) / float(grid_size - 1)  # Normalize between 0 and 1
# 		color_rect.color = start_color.lerp(end_color, t)

# 		panel.add_child(color_rect)

# 	# Force re-sorting to ensure sizes are adjusted
# 	queue_sort()
